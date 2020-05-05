#! /opt/local/bin/ruby
# coding: utf-8

require 'timers'

module Tlarb
	class Stream
		DEFAULT_INTERVAL = 5#unit:second

		DEFAULT_OFFSET   = TwicasStream::Comment::GetComments::DEFAULT_OFFSET
		DEFAULT_LIMIT    = 20#TwicasStream::Comment::GetComments::DEFAULT_LIMIT
		DEFAULT_SLICE_ID = TwicasStream::Comment::GetComments::DEFAULT_SLICE_ID

		INDENT = "\s" * 49

		def initialize
			require File.expand_path(File.dirname(__FILE__) + '/model')

			logdev = ROOT_PATH + '/log'

			FileUtils.mkdir_p(logdev)

			logdev += '/log_file_' + Time.current.strftime('%Y%m%d_%H%M%S') + '.log'

			@logger = Logger.new(
				logdev,
				level = Logger::Severity::DEBUG,
				datetime_format = nil
				# => '%Y-%m-%dT%H:%M:%S.%06d '
			)

			@logger.datetime_format = '%Y-%m-%d %H:%M:%S %z '

			@logger.debug { "logger library version = #{Logger::VERSION}" }

			Tlarb.configure do |config|
				@logger.debug {
					"configure" + "\n" +
					INDENT + "environment = #{config.environment}" + "\n" +
					INDENT + "access_token = #{config.access_token}" + "\n" +
					INDENT + "time_zone = #{config.time_zone}" + "\n" +
					INDENT + "year = #{config.year}" + "\n" +
					INDENT + "month = #{config.month}" + "\n" +
					INDENT + "day = #{config.day}" + "\n" +
					INDENT + "movie_id = #{config.movie_id}" + "\n" +
					INDENT + "adapter = #{Model::CONN[:adapter]}" + "\n" +
					INDENT + "database = #{Model::CONN[:database]}"
				}
			end
		end

		def run movie_id, offset = DEFAULT_OFFSET, limit = DEFAULT_LIMIT, slice_id = DEFAULT_SLICE_ID
			timers = Timers::Group.new

			@logger.debug { "interval time = #{DEFAULT_INTERVAL} (s)" }

			@logger.info { "movie id = #{movie_id}" }

			paused_timer = timers.every(DEFAULT_INTERVAL) { STDOUT.print '.' }

			loop_num = 0
			loop do
				loop_num += 1

				@logger.info { "#{loop_num}" }

				# 1. check live status
				status = is_live?(movie_id)
				break if status.nil?

				unless status
					@logger.info { "Live is offline" }
					break
				end

				# 2. get comment
				get_comment(movie_id = movie_id, offset = offset, limit = limit, slice_id = slice_id)

				# 3. wait interval time
				timers.wait

				# 4. repeat 1 ~ 3 until end of live
			end

			paused_timer.cancel

			@logger.close

			STDOUT.puts
		end

		private
		def is_live? movie_id
			# 1. get movie info
			api = TwicasStream::Movie::GetMovieInfo.new(movie_id)

			# 2. response is error, then break
			if api.response.is_error?
				if api.response[:error][:details].nil?
					@logger.error { "#{api.response[:error][:message]} (code: #{api.response[:error][:code]})" }
					STDERR.puts "#{__FILE__}:#{__LINE__}:Error: #{api.response[:error][:message]} (code: #{api.response[:error][:code]})"
				else
					@logger.error { "#{api.response[:error][:message]} (code: #{api.response[:error][:code]}) - #{api.response[:error][:details]}" }
					STDERR.puts "#{__FILE__}:#{__LINE__}:Error: #{api.response[:error][:message]} (code: #{api.response[:error][:code]}) - #{api.response[:error][:details]}"
				end
				return nil
			end

			movie_info = api.response

			if movie_info[:movie].rename_key(old: :id, new: :movie_id).nil?
				@logger.fatal { "#{File.basename(__FILE__)}:#{__LINE__}" }
				STDERR.puts "#{__FILE__}:#{__LINE__}:Fatal Error: "
				return nil
			end

			if movie_info[:broadcaster].rename_key(old: :id, new: :user_id).nil?
				@logger.fatal { "#{File.basename(__FILE__)}:#{__LINE__}" }
				STDERR.puts "#{__FILE__}:#{__LINE__}:Fatal Error: "
				return nil
			end

			# 3. update db
			movie = Model::Movie.create(movie_info[:movie])
			broadcaster = Model::User.create(movie_info[:broadcaster])
			Model::MovieInfo.create(:movies_db_id => movie.id, :broadcasters_db_id => broadcaster.id, :tags => movie_info[:tags])

			return movie_info[:movie][:is_live]
		end

		private
		def get_comment movie_id, offset, limit, slice_id
			# 1. get comments
			api = TwicasStream::Comment::GetComments.new(movie_id = movie_id, offset = offset, limit = limit, slice_id = slice_id)

			# 2. response is error, then break
			if api.response.is_error?
				if api.response[:error][:details].nil?
					@logger.error { "#{api.response[:error][:message]} (code: #{api.response[:error][:code]})" }
					STDERR.puts "#{__FILE__}:#{__LINE__}:Error: #{api.response[:error][:message]} (code: #{api.response[:error][:code]})"
				else
					@logger.error { "#{api.response[:error][:message]} (code: #{api.response[:error][:code]}) - #{api.response[:error][:details]}" }
					STDERR.puts "#{__FILE__}:#{__LINE__}:Error: #{api.response[:error][:message]} (code: #{api.response[:error][:code]}) - #{api.response[:error][:details]}"
				end
				return nil
			end

			comments = api.response

			comments[:comments].reverse.each{ |e|
				if e.rename_key(old: :id, new: :comment_id).nil?
					@logger.fatal { "#{File.basename(__FILE__)}:#{__LINE__}" }
					STDERR.puts "#{__FILE__}:#{__LINE__}:Fatal Error"
					break
				end

				if e[:from_user].rename_key(old: :id, new: :user_id).nil?
					@logger.fatal { "#{File.basename(__FILE__)}:#{__LINE__}" }
					STDERR.puts "#{__FILE__}:#{__LINE__}:Fatal Error"
					break
				end

				# 4.3. update db
				if Model::Comment.find_by(:comment_id => e[:comment_id]).nil?
					from_user = Model::User.create(e[:from_user])
					comment = Model::Comment.create(
														:comment_id => e[:comment_id], 
														:message => e[:message], 
														:from_user_db_id => from_user.id, 
														:created => e[:created]
													)
					Model::CommentList.create(
												:movie_id => comments[:movie_id], 
												:all_count => comments[:all_count], 
												:comments_db_id => comment.id
											)
				end
			}
		end
	end
end

class Hash
	def rename_key(old:, new:)
		return unless has_key?(old)
		return if has_key?(new)
		self[new] = self.delete(old)
		self
	end

	def is_error?
		self.keys.include?(:error)
	end
end

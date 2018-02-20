#! /opt/local/bin/ruby
# coding: utf-8

module Tlarb
	class Analytics
		def initialize
			require File.expand_path(File.dirname(__FILE__) + '/model')
		end
	end

	class ActiveCommentCount < Analytics
		def execute interval = Tlarb::Stream::DEFAULT_INTERVAL
			list = Array.new

			comments = Model::Comment.select(:id, :created).all.order(:id).map{ |e| e.attributes.symbolize_keys }

			current_unix_timestamp = Model::Movie.first.created

			loop do
				active_comment = Hash.new

				active_comment[:created] = current_unix_timestamp

				active_comment[:range] = {
					:begin => active_comment[:created],
					:end => current_unix_timestamp + interval - 1
				}

				active_comment[:comments] = comments.map{ |comment| comment if comment[:created] <= active_comment[:range][:end] }.compact
				active_comment[:current_comment_count] = active_comment[:comments].size

				list.push active_comment

				# remove
				active_comment[:current_comment_count].times{ |i| comments.delete_at(0) }

				current_unix_timestamp = active_comment[:range][:end] + 1

				# break condition
				break if comments.empty?
			end

			list
			# => [
			   # 	{
			   # 		:created => 1518875134, 
			   # 		:range => {:begin => 1518875134, :end => 1518875138}, 
			   # 		:comments => [
			   # 			{:id => 417, :created => 1518875136}, 
			   # 			...
			   # 		], 
			   # 		:current_comment_count => 2
			   # 	},
			   # 	...
			   # ]
		end
	end

	class ActiveUserCount < Analytics
		def execute
			movies = Model::Movie.select(:id, :duration, :current_view_count).all

			movies.order(:id).map{ |e| e.attributes.symbolize_keys }
		end
	end

	class TotalCommentCount < Analytics
		def execute
			movies = Model::Movie.select(:id, :duration, :comment_count).all

			movies.order(:id).map{ |e| e.attributes.symbolize_keys }
		end
	end

	class MaxViewerCount < Analytics
		def execute
			movies = Model::Movie.select(:id, :duration, :max_view_count).all

			movies.order(:id).map{ |e| e.attributes.symbolize_keys }
		end
	end

	class TotalViewerCount < Analytics
		def execute
			movies = Model::Movie.select(:id, :duration, :total_view_count).all

			movies.order(:id).map{ |e| e.attributes.symbolize_keys }
		end
	end

	class UserCommentRank < Analytics
		def execute
			users = Model::User.group(:user_id).all.order(:id).select(:id, :user_id, :screen_id, :name, :image)

			user_with_total_comment_count = users.count(:user_id).to_a.map{ |e| {:user_id => e[0], :total_comment_count => e[1]} }

			users.map.with_index{ |user, idx|
				hash = user.attributes.symbolize_keys

				if user.user_id == user_with_total_comment_count[idx][:user_id]
					hash.store(:total_comment_count, user_with_total_comment_count[idx][:total_comment_count])
				else
					STDERR.puts "#{__FILE__}:#{__LINE__}:Fatal Error: user_id mismatch - #{user.user_id}, #{user_with_total_comment_count[idx][:user_id]}"

					hash.store(:total_comment_count, 0)
				end
				hash
			}
		end
	end
end

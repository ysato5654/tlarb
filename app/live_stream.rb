#! /opt/local/bin/ruby
# coding: utf-8

require 'optparse'

require File.expand_path(File.dirname(__FILE__) + '/../lib/tlarb')

class LiveStream
	attr_reader :environment,
				:user_id,
				:movie_id

	DEFAULT_ENVIRONMENT = 'production'

	def initialize
		opt = OptionParser.new

		params = Hash.new

		opt.on('-e [VAL]', '--environment [VAL]', 'environment (default: production)') { |v| params[:environment] = v }
		opt.on('-u [VAL]', '--user_id [VAL]', 'user id') { |v| params[:user_id] = v }
		opt.on('-m [VAL]', '--movie_id [VAL]', 'movie id') { |v| params[:movie_id] = v }

		opt.parse(ARGV)

		@environment = params.key?(:environment) ? params[:environment] : DEFAULT_ENVIRONMENT
		@user_id = params.key?(:user_id) ? params[:user_id] : ''
		@movie_id = params.key?(:movie_id) ? params[:movie_id] : ''

		@environment = '' unless Tlarb::ENVIRONMENT.include?(@environment)

		if !@user_id.empty? and !@movie_id.empty?
			@user_id = ''
			@movie_id = ''
		end
	end

	def get_movie_id_by_user_id user_id
		movie_id = ''

		# initialize because of setting access token
		Tlarb.initialize('', '')

		api = TwicasStream::User::GetUserInfo.new(user_id)

		unless api.response[:error].nil?
			STDERR.puts "#{__FILE__}:#{__LINE__}:Error: #{api.response[:error][:code]} - #{api.response[:error][:message]}"

			Tlarb.reset
			TwicasStream.reset
		else
			movie_id = api.response[:user][:last_movie_id]
		end

		movie_id
	end

	def run
	end
end

if $0 == __FILE__
	live = LiveStream.new

	env = live.environment

	if env.empty?
		STDERR.puts "#{__FILE__}:#{__LINE__}:Error: option error. usage is 'ruby #{File.basename(__FILE__)} --help'"
		exit(0)
	end

	movie_id = ''

	if !live.user_id.empty?
		movie_id = live.get_movie_id_by_user_id(live.user_id)

		exit(0) if movie_id.empty?

	elsif !live.movie_id.empty?
		movie_id = live.movie_id

	else
		STDERR.puts "#{__FILE__}:#{__LINE__}:Error: option error. usage is 'ruby #{File.basename(__FILE__)} --help'"
		exit(0)
	end

	# initialize
	Tlarb.initialize(env, movie_id)

	STDOUT.puts
	STDOUT.puts "movie id: #{movie_id}"
	STDOUT.puts

	# create data base
	stream = Tlarb::Stream.new
	# start live stream
	stream.run(movie_id)

	STDOUT.puts "Finish"
	STDOUT.puts

end

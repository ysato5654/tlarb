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
end

if $0 == __FILE__
	live_stream = LiveStream.new

	env = live_stream.environment

	if env.empty?
		STDERR.puts "#{__FILE__}:#{__LINE__}:Error: option error. usage is 'ruby #{File.basename(__FILE__)} --help'"
		exit(0)
	end

	if !live_stream.user_id.empty?
		id = {:user_id => live_stream.user_id}
	elsif !live_stream.movie_id.empty?
		id = {:movie_id => live_stream.movie_id}
	else
		STDERR.puts "#{__FILE__}:#{__LINE__}:Error: option error. usage is 'ruby #{File.basename(__FILE__)} --help'"
		exit(0)
	end

	# initialize
	unless Tlarb.initialize(env, id)
		exit(0)
	end

	movie_id = ''
	Tlarb.configure do |config|
		movie_id = config.movie_id
	end

	STDOUT.puts
	STDOUT.puts "user id : #{id[:user_id]}"
	STDOUT.puts "movie id: #{movie_id}"
	STDOUT.puts

	# create data base
	stream = Tlarb::Stream.new
	# start live stream
	stream.run(movie_id)

	STDOUT.puts "Finish"
	STDOUT.puts

end

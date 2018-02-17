#! /opt/local/bin/ruby
# coding: utf-8

if $0 == __FILE__
	require File.expand_path(File.dirname(__FILE__) + '/../lib/tlarb')

	env = 'development'
	#env = 'production'

	#id = {:movie_id => '189037369'}
	id = {:user_id => '124memetan'}

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

	# start live stream
	stream = Tlarb::Stream.new
	stream.run(movie_id)

	STDOUT.puts "Finish"
	STDOUT.puts

end

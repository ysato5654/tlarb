#! /opt/local/bin/ruby
# coding: utf-8

require 'active_record'
require 'twicas_stream'
require 'yaml'
require 'fileutils'

require File.expand_path(File.dirname(__FILE__) + '/tlarb/configure')
require File.expand_path(File.dirname(__FILE__) + '/tlarb/version')

module Tlarb
	extend Configure

	ROOT_PATH = File.expand_path(File.dirname(__FILE__) + '/..')

	ENVIRONMENT = ['development', 'production']

	class << self
		def initialize env, id
			Tlarb.reset
			TwicasStream.reset

			unless ENVIRONMENT.include?(env)
				STDERR.puts "#{__FILE__}:#{__LINE__}:Error: out of limitation. support environment is '#{ENVIRONMENT.join("' or '")}'."

				return false
			end

			Tlarb.configure do |config|
				config.environment = env
				config.access_token = ROOT_PATH + '/config/access_token.txt'
				config.time_zone = 'Tokyo'

				ActiveRecord::Base
				time = Time.current

				config.year = time.year
				config.month = time.month
				config.day = time.day

				TwicasStream.configure do |request_header|
					request_header.access_token = File.read(config.access_token)
				end
			end

			case id.keys
			when [:user_id]
				api = TwicasStream::User::GetUserInfo.new(id[:user_id])

				unless api.response[:error].nil?
					Tlarb.reset
					TwicasStream.reset

					STDERR.puts "#{__FILE__}:#{__LINE__}:Error: #{api.response[:error][:code]} - #{api.response[:error][:message]}"

					return false
				end

				movie_id = api.response[:user][:last_movie_id]

			when [:movie_id]
				movie_id = id[:movie_id]

			else
				Tlarb.reset
				TwicasStream.reset

				STDERR.puts "#{__FILE__}:#{__LINE__}:Error: argument is not 'user_id' or 'movie_id'."

				return false
			end

			Tlarb.configure do |config|
				config.movie_id = movie_id
			end

			require File.expand_path(File.dirname(__FILE__) + '/tlarb/live')
		end
	end
end

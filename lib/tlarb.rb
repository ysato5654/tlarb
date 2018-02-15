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

	class << self
		def initialize arg
			Tlarb.reset
			Tlarb.configure do |config|
				config.access_token = ROOT_PATH + '/config/access_token.txt'
				config.time_zone = 'Tokyo'

				ActiveRecord::Base
				time = Time.current

				config.year = time.year
				config.month = time.month
				config.day = time.day

				TwicasStream.reset
				TwicasStream.configure do |request_header|
					request_header.access_token = File.read(config.access_token)
				end
			end

			if arg.keys == [:user_id]
				user_id = arg[:user_id]
				api = TwicasStream::User::GetUserInfo.new(user_id)

				movie_id = api.response[:user][:last_movie_id]

			elsif arg.keys == [:movie_id]
				movie_id = arg[:movie_id]

			else
				return false
			end

			Tlarb.configure do |config|
				config.movie_id = movie_id
			end

			require File.expand_path(File.dirname(__FILE__) + '/tlarb/live')
		end
	end
end

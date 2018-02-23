#! /opt/local/bin/ruby
# coding: utf-8

require 'active_record'
require 'twicas_stream'
require 'yaml'
require 'fileutils'
require 'logger'

require File.expand_path(File.dirname(__FILE__) + '/tlarb/configure')
require File.expand_path(File.dirname(__FILE__) + '/tlarb/analytics')
require File.expand_path(File.dirname(__FILE__) + '/tlarb/stream')
require File.expand_path(File.dirname(__FILE__) + '/tlarb/view')
require File.expand_path(File.dirname(__FILE__) + '/tlarb/version')

module Tlarb
	extend Configure

	ROOT_PATH = File.expand_path(File.dirname(__FILE__) + '/..')

	ENVIRONMENT = ['development', 'production']

	class << self
		def initialize env, movie_id
			Tlarb.reset
			TwicasStream.reset

			Tlarb.configure do |config|
				config.environment = env
				config.access_token = ROOT_PATH + '/config/access_token.txt'
				config.time_zone = 'Tokyo'

				ActiveRecord::Base
				time = Time.current

				config.year = time.year
				config.month = time.month
				config.day = time.day

				config.movie_id = movie_id

				TwicasStream.configure do |request_header|
					request_header.access_token = File.read(config.access_token)
				end
			end
		end
	end
end

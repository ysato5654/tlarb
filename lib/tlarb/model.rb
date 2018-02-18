#! /opt/local/bin/ruby
# coding: utf-8

module Tlarb
	module Model
		yaml = YAML.load_file(ROOT_PATH + '/config/database.yml')

		environment = ''
		Tlarb.configure do |config|
			environment = config.environment
		end

		database = yaml[environment]['database']

		Tlarb.configure do |config|
			database.gsub!(/year/, config.year.to_s)
			database.gsub!(/month/, config.month.to_s.rjust(2, '0'))
			database.gsub!(/day/, config.day.to_s.rjust(2, '0'))
			database.gsub!(/movie_id/, config.movie_id)
		end

		FileUtils.mkdir_p(ROOT_PATH + '/' + File.dirname(database))

		CONN = {
			adapter: yaml[environment]['adapter'], 
			database: ROOT_PATH + '/' + database
		}

		require File.expand_path(File.dirname(__FILE__) + '/models/movie_info')
		require File.expand_path(File.dirname(__FILE__) + '/models/comment_list')
		require File.expand_path(File.dirname(__FILE__) + '/models/user')
		require File.expand_path(File.dirname(__FILE__) + '/models/movie')
		require File.expand_path(File.dirname(__FILE__) + '/models/comment')
	end
end

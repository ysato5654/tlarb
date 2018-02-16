#! /opt/local/bin/ruby
# coding: utf-8

module Tlarb
	class Live

		INDENT = "\s" + 49

		def initialize
			require File.expand_path(File.dirname(__FILE__) + '/model')

			#logdev = STDOUT
			logdev = ROOT_PATH + '/log/log_file_' + Time.current.strftime('%Y%m%d_%H%M%S') + '.log'

			FileUtils.mkdir_p(File.dirname(logdev)) if logdev.is_a?(String)

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
	end
end

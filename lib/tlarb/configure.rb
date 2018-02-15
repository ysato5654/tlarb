#! /opt/local/bin/ruby
# coding: utf-8

module Tlarb
	module Configure
		CONFIG = [
			:access_token, 
			:time_zone, 
			:year, 
			:month, 
			:day, 
			:movie_id
		].freeze

		attr_accessor(*CONFIG)

		def self.extended(base)
			base.reset
		end

		def configure
			yield self
		end

		def reset
			self.time_zone = 'Tokyo'
			self.year      = ''
			self.month     = ''
			self.day       = ''
			self.movie_id  = ''
			self
		end
	end
end

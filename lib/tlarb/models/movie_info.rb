#! /opt/local/bin/ruby
# coding: utf-8

module Tlarb
	module Model
		class MovieInfo < ActiveRecord::Base
			establish_connection(CONN)

			self.table_name = 'movie_info'

			connection.create_table(:movie_info, force: true) do |t|
				t.integer :movies_db_id, :null => false
				t.integer :broadcasters_db_id, :null => false
				t.string  :tags, :null => false

				t.timestamps
			end
		end
	end
end

#! /opt/local/bin/ruby
# coding: utf-8

module Tlarb
	module Model
		class MovieInfo < ActiveRecord::Base
			yaml = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/../../../config/database.yml'))

			conn = {
						adapter: yaml['development']['adapter'], 
						database: File.expand_path(File.dirname(__FILE__) + '/../../../' + yaml['development']['database'])
					}

			establish_connection(conn)

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

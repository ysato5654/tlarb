#! /opt/local/bin/ruby
# coding: utf-8

module Tlarb
	module Model
		class User < ActiveRecord::Base
			yaml = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/../../../config/database.yml'))

			conn = {
						adapter: yaml['development']['adapter'], 
						database: File.expand_path(File.dirname(__FILE__) + '/../../../' + yaml['development']['database'])
					}

			establish_connection(conn)

			connection.create_table(:users, force: true) do |t|
				t.string  :user_id, :null => false
				t.string  :screen_id, :null => false
				t.string  :name, :null => false
				t.string  :image, :null => false
				t.string  :profile, :null => false
				t.integer :level, :null => false
				t.string  :last_movie_id
				t.boolean :is_live, :null => false
				t.integer :supporter_count, :null => false
				t.integer :supporting_count, :null => false
				t.integer :created, :null => false

				t.timestamps
			end
		end
	end
end

#! /opt/local/bin/ruby
# coding: utf-8

module Tlarb
	module Model
		class Comment < ActiveRecord::Base
			yaml = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/../../../config/database.yml'))

			conn = {
						adapter: yaml['development']['adapter'], 
						database: File.expand_path(File.dirname(__FILE__) + '/../../../' + yaml['development']['database'])
					}

			establish_connection(conn)

			connection.create_table(:comments, force: true) do |t|
				t.string  :comment_id, :null => false
				t.string  :message, :null => false
				t.integer :from_user_db_id, :null => false
				t.integer :created, :null => false

				t.timestamps
			end
		end
	end
end

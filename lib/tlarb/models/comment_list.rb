#! /opt/local/bin/ruby
# coding: utf-8

module Tlarb
	module Model
		class CommentList < ActiveRecord::Base
			yaml = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/../../../config/database.yml'))

			conn = {
						adapter: yaml['development']['adapter'], 
						database: File.expand_path(File.dirname(__FILE__) + '/../../../' + yaml['development']['database'])
					}

			establish_connection(conn)

			connection.create_table(:comment_lists, force: true) do |t|
				t.string  :movie_id, :null => false
				t.integer :all_count, :null => false
				t.integer :comments_db_id, :null => false

				t.timestamps
			end
		end
	end
end

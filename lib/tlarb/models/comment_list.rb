#! /opt/local/bin/ruby
# coding: utf-8

module Tlarb
	module Model
		class CommentList < ActiveRecord::Base
			establish_connection(CONN)

			connection.create_table(:comment_lists, force: true) do |t|
				t.string  :movie_id, :null => false
				t.integer :all_count, :null => false
				t.integer :comments_db_id, :null => false

				t.timestamps
			end
		end
	end
end

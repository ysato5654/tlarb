#! /opt/local/bin/ruby
# coding: utf-8

module Tlarb
	module Model
		class Comment < ActiveRecord::Base
			establish_connection(CONN)

			unless connection.table_exists?('comments')
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
end

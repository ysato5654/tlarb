#! /opt/local/bin/ruby
# coding: utf-8

module Tlarb
	module Model
		class Movie < ActiveRecord::Base
			establish_connection(CONN)

			unless connection.table_exists?('movies')
				connection.create_table(:movies, force: true) do |t|
					t.string  :movie_id, :null => false
					t.string  :user_id, :null => false
					t.string  :title, :null => false
					t.string  :subtitle
					t.string  :last_owner_comment
					t.string  :category
					t.string  :link, :null => false
					t.boolean :is_live, :null => false
					t.boolean :is_recorded, :null => false
					t.integer :comment_count, :null => false
					t.string  :large_thumbnail, :null => false
					t.string  :small_thumbnail, :null => false
					t.string  :country, :null => false
					t.integer :duration, :null => false
					t.integer :created, :null => false
					t.boolean :is_collabo, :null => false
					t.boolean :is_protected, :null => false
					t.integer :max_view_count, :null => false
					t.integer :current_view_count, :null => false
					t.integer :total_view_count, :null => false
					t.string  :hls_url

					t.timestamps
				end
			end
		end
	end
end

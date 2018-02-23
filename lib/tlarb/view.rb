#! /opt/local/bin/ruby
# coding: utf-8

module Tlarb
	class View
	end

	class Gnuplot < View
		DEFAULT_TITLE = ''

		STRFTIME_FORMAT = '%Y-%m-%d_%H:%M:%S'

		def initialize main_title = DEFAULT_TITLE, x_title = DEFAULT_TITLE, y_title = DEFAULT_TITLE, legend = DEFAULT_TITLE
			@title = {
				:main => main_title,
				:x => x_title,
				:y => y_title,
				:legend => legend,
			}
		end

		def test
			IO.popen('gnuplot -persist', 'w') do |io|
				#io.print "set terminal x11\n"
				# for Japanese
				io.print "set terminal aqua font 'ヒラギノ丸ゴ ProN W4, 16'\n"

				io.print "test\n"
			end
		end

		def execute x, y
			path = ROOT_PATH + '/tmp'

			FileUtils.mkdir_p(path)

			movie_id = ''
			Tlarb.configure do |config|
				movie_id = config.movie_id
			end

			path += '/' + movie_id + '.dat'

			File.open(path, 'w+') do |file|
				x.zip(y).each do |x, y|
					if x.is_a?(Time)
						file.print x.strftime(STRFTIME_FORMAT)
					else
						file.print x
					end
					file.print "\t"
					file.print y
					file.puts
				end
			end

			IO.popen('gnuplot -persist', 'w') do |io|
				#io.print "set terminal x11\n"
				# for Japanese
				io.print "set terminal aqua font 'ヒラギノ丸ゴ ProN W4, 16'\n"

				io.print "set key left\n"
				io.print "set grid\n"

				# title
				io.print "set title '#{@title[:main]}'\n"

				# setting axes
				# x
				io.print "set xtics\n"
				if x.first.is_a?(Time)
					io.print "set xdata time\n"

					# input
					io.print "set timefmt '#{STRFTIME_FORMAT}'\n"
					# output
					io.print "set format x '%H:%M'\n"

					#io.print "set xtics rotate by -90\n"
					io.print "set xrange ['#{x.first.strftime(STRFTIME_FORMAT)}':'#{x.last.strftime(STRFTIME_FORMAT)}']\n"
				end

				# y
				io.print "set ytics\n"
				io.print "set yrange [0:*]\n"
				# title
				io.print "set xlabel '#{@title[:x]}'\n"
				io.print "set ylabel '#{@title[:y]}'\n"

				io.print "plot '#{path}' "
				io.print "using 1:2 with lp lt 3 lw 1 pt 10 ps 1 "
				# blue
				io.print "linecolor rgbcolor '#0000FF' "
				# salmon
				#io.print "linecolor rgbcolor '#FA8072' "
				# turquoise
				#io.print "linecolor rgbcolor '#40E0D0' "
				io.print "title '#{@title[:legend]}'"
				io.print "\n"
			end
		end
	end
end

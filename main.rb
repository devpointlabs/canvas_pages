require_relative './pages'
require_relative './course_files'
require_relative './make'

course = ARGV[0] || raise('Missing course id:  ruby main.rb 7')
Pages.new(course)
CourseFiles.new(course)
Make.new(course)


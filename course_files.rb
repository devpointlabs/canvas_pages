require_relative './canvas'
require 'pry'
require 'fileutils'
require 'open-uri'

class CourseFiles < Canvas
  def initialize(course)
    super(course)
    puts 'Downlading images'
    make_request('files')
    build_data
  end

  def build_data
    FileUtils.mkdir_p(@course.to_s) unless Dir.exists?(@course.to_s)
    FileUtils.mkdir_p("#{@course.to_s}/files") unless Dir.exists?("#{@course.to_s}/files")
    @data.each do |obj|
      ext = obj['display_name'].split(".").last
      next if ext == 'mp4'
      File.open(File.join(Dir.pwd, "/#{@course}/files", "#{obj['id']}.#{ext}"), "w+") do |f|
        f << open(obj['url'], {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
      end
    end
  end
end


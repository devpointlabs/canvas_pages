require_relative './canvas'
require 'fileutils'

class Pages < Canvas
  attr_reader :ids, :content
  def initialize(course)
    super(course)
    @content = []
    clean
    make_request('pages')
    build_data
    write_files
  end

  def clean
    puts "Cleaning directory #{@course}/"
    `rm -rf #{@course}`
  end

  def build_data
    puts "Downloading pages from Canvas"
    ids = @data.map { |d| d['url'] }
    ids.each do  |id|
      data = make_single_request("pages/#{URI.encode(id)}")
      @content << data
    end
  end

  def write_files
    dir = "#{@course}"
    FileUtils.mkdir_p(dir) unless Dir.exists?(dir)
    total = 0
    @content.each_with_index do |c, i|
      begin
        title = c['url']
        puts "#{i}: #{title}"
        File.open(File.join(Dir.pwd, "/#{dir}", "#{title}.html"), "w+") do |f|
          f << c['body']
        end
        total += 1
      rescue Exception => e
        puts "ERROR: #{e}"
      end
    end
    
    puts "#{total} files written to #{dir}/"
  end
end


require 'pry'
require 'httparty'
require 'fileutils'
require 'dotenv'
Dotenv.load

BASE_URL = 'https://canvas.devpointlabs.com/api/v1'
TOKEN = ENV['TOKEN']
COURSE = ENV['COURSE']

`rm -rf ${COURSE}`

auth = {"Authorization" => "Bearer #{TOKEN}"}
HTTParty::Basement.default_options.update(verify: false)
url = "#{BASE_URL}/courses/#{COURSE}/pages?per_page=100"

data = HTTParty.get(url, headers: auth )
page = 1
link = data.headers['link'].split("<https://canvas.devpointlabs.com").last
md = link.match(/page=\d+/)
pages = md[0].match(/\d+/)[0].match(/\d+/)[0].to_i
ids = data.map { |d| d['html_url'].split("#{COURSE}/pages/").last }
while page <= pages + 1
  page = page + 1
  url = "#{BASE_URL}/courses/#{COURSE}/pages?per_page=100&page=#{page}"
  data = HTTParty.get(url, headers: auth )
  ids = ids + data.map { |d| d['html_url'].split("#{COURSE}/pages/").last }
end

content = []

ids.each do |id|
  url = "#{BASE_URL}/courses/#{COURSE}/pages/#{id}"
  data = HTTParty.get(url, headers: auth )
  content << data
end

FileUtils.mkdir_p(COURSE.to_s) unless Dir.exists?(COURSE.to_s)

total = 0
content.each_with_index do |c, i|
  begin
    title = c['html_url'].split("#{COURSE}/pages/").last
    puts "#{i}: #{title}"
    File.open(File.join(Dir.pwd, "/#{COURSE}", "#{title}.html"), "w+") do |f|
      f << c['body']
    end
    total += 1
  rescue Exception => e
    puts "ERROR: #{e}"
  end
end

puts "#{total} files written to #{COURSE}/"

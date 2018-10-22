require 'pry'
require 'httparty'
require 'fileutils'
require 'dotenv'
require 'open-uri'
Dotenv.load
BASE_URL = 'https://canvas.devpointlabs.com/api/v1'
TOKEN = ENV['TOKEN']
COURSE = ENV['COURSE']

auth = {"Authorization" => "Bearer #{TOKEN}"}
HTTParty::Basement.default_options.update(verify: false)
url = "#{BASE_URL}/courses/#{COURSE}/files?per_page=100"
data = HTTParty.get(url, headers: auth )
FileUtils.mkdir_p(COURSE.to_s) unless Dir.exists?(COURSE.to_s)
FileUtils.mkdir_p("#{COURSE.to_s}/files") unless Dir.exists?("#{COURSE.to_s}/files")
content = data
page = 1
link = data.headers['link'].split("<https://canvas.devpointlabs.com").last
md = link.match(/page=\d+/)
pages = md[0].match(/\d+/)[0].match(/\d+/)[0].to_i
while page <= pages + 1
  page = page + 1
  url = "#{BASE_URL}/courses/#{COURSE}/files?per_page=100&page=#{page}"
  data = HTTParty.get(url, headers: auth )
  content = content + data
end

content.each do |obj|
  ext = obj['display_name'].split(".").last
  next if ext == 'mp4'
  File.open(File.join(Dir.pwd, "/#{COURSE}/files", "#{obj['id']}.#{ext}"), "w+") do |f|
    f << open(obj['url'], {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
  end
end

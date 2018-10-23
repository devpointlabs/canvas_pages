require 'httparty'
require 'dotenv'
require 'pry'
Dotenv.load

BASE_URL = 'https://canvas.devpointlabs.com/api/v1'

class Canvas
  attr_reader :base_url, :token, :course, :data
  
  def initialize(course)
    @course = course
    @base_url = BASE_URL
    @token = ENV['TOKEN']
    @auth = {"Authorization" => "Bearer #{@token}"}
    @page = 1
    @pages = 1
    @data = []
  end

  def pages(headers)
    link = headers['link'].split("<https://canvas.devpointlabs.com").last
    md = link.match(/page=\d+/)
    @pages = md[0].match(/\d+/)[0].match(/\d+/)[0].to_i
  end

  def make_request(url)
    while @page <= @pages
      HTTParty::Basement.default_options.update(verify: false)
      data = HTTParty.get(
        "#{@base_url}/courses/#{@course}/#{url}?per_page=50&page=#{@page}", 
        headers: @auth 
      )
      pages(data.headers) if @page == 1
      @data = @data + data
      @page += 1
    end
  end

end


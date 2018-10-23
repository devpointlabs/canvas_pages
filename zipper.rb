require 'fileutils'
require 'date'
require 'pry'

class Zipper
  def initialize
    @dirs = Dir.glob('*').grep(/\d+$/)
    start
  end

  def start
    date = DateTime.now.to_s
    FileUtils.mkdir_p('zips') unless Dir.exists?('zips')
    @dirs.each do |dir|
      `zip -r zips/#{dir}-#{date}.zip #{dir}`
    end
  end
end

Zipper.new

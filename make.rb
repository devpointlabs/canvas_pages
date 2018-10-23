require 'fileutils'
require 'dotenv'
require 'pry'
Dotenv.load

COURSE = ENV['COURSE']

raise 'Course content does not exist' unless Dir.exists? COURSE.to_s

@files = Dir.glob("#{COURSE.to_s}/*.html").map { |f| f.split("#{COURSE.to_s}/").last }

`cp styles.css #{COURSE}/styles-#{COURSE}.css`
`cp main.js #{COURSE}/main-#{COURSE}.js`

def links 
  link_content = ""
  @files.each do |file|
    link_content += <<-LINK
      <li class="nav-link">
        <a target="_blank" href="./#{file}">
         #{file.gsub('.html', '')}
        </a>
      </li>
    LINK
  end
  link_content
end

HEAD  = <<-HEADER
  <head> 
    <link rel="stylesheet" href="./styles-#{COURSE}.css" />
    <link href="https://fonts.googleapis.com/css?family=Roboto" rel="stylesheet">
  </head>
HEADER

NAV = <<-NAV
  <button id="toggle_nav">Toggle Nav</button>
  <nav>
    <ul id="nav" class="nav">
      #{links}
    </ul>
  </nav>
NAV

CONTENT = <<-HTML
  <html>
    #{HEAD}
    <body>
      #{NAV}
    </body>
  </html>
HTML

File.open("#{COURSE}/index-#{COURSE}.html", "w") do |file|
  file << CONTENT
end

@files.each do |file|
  original_file = "#{COURSE}/#{file}"
  new_file = original_file + '.new'
  File.open(new_file, 'w') do |fo|
    fo.puts HEAD
    fo.puts NAV
    File.foreach(original_file) do |li|
      #TODO replace images with image found in files/
      fo.puts li
    end
    fo.puts "<script src='./main-#{COURSE}.js'></script>"
  end

  File.rename(new_file, original_file)
end


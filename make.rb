require_relative './canvas'
require 'fileutils'
require 'pry'

class Make < Canvas
  def initialize(course)
    super(course)
    @files = Dir.glob("#{@course.to_s}/*.html").map { |f| f.split("#{@course.to_s}/").last }
    cp_files
    write_index
    fix_files
  end

  def cp_files
    puts 'Copying css & js files'
    `cp styles.css #{@course}/styles-#{@course}.css`
    `cp main.js #{@course}/main-#{@course}.js`
  end

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

  def head 
    <<-HEADER
      <head> 
        <link rel="stylesheet" href="./styles-#{@course}.css" />
        <link href="https://fonts.googleapis.com/css?family=Roboto" rel="stylesheet">
      </head>
    HEADER
  end
  
  def nav(main = false)
    <<-NAV
      #{ main ? '' : '<button id="toggle_nav">Toggle Nav</button>' }
      <nav>
        <ul id="nav" class="nav">
          #{links}
        </ul>
      </nav>
    NAV
  end

  def content(main = false)
    <<-HTML
      <html>
        #{head}
        <body>
          #{nav(main)}
        </body>
      </html>
    HTML
  end

  def write_index
    File.open("#{@course}/index-#{@course}.html", "w") do |file|
      file << content(true)
    end
  end

  def fix_files
    puts 'Fixing image urls'
    @files.each do |file|
      original_file = "#{@course}/#{file}"
      new_file = original_file + '.new'
      File.open(new_file, 'w') do |fo|
        fo.puts head
        fo.puts nav
        File.foreach(original_file) do |li|
          files = `ls #{@course}/files/`.split("\n")
          if li.match(/\<img/)
            li.scan(/files\/\d+/).each do |m|
              id = m.split('files/')[1]
              filename = files.select { |f| f.match(id) }[0]
              li.gsub!("https://canvas.devpointlabs.com/courses/#{@course}/files/#{id}/preview", "./files/#{filename}")
            end
          end
          fo.puts li
        end
        fo.puts "<script src='./main-#{@course}.js'></script>"
      end
    
      File.rename(new_file, original_file)
    end
  end
end

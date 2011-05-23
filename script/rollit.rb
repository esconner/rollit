#!/usr/bin/env ruby

SCRIPT_DIR = File.dirname(__FILE__)

require 'fileutils'
require 'haml'
require "#{SCRIPT_DIR}/TextMarkup.rb"

include TextMarkup


CONTENT_DIR = "#{SCRIPT_DIR}/../content"
OUTPUT_DIR = "#{SCRIPT_DIR}/../output"


# engine = Haml::Engine.new("%p Haml code!")
# engine.render #=> "<p>Haml code!</p>\n"

def convert_filename_to_html(filename)
  filename.sub(/\.rdoc/i, '.html').sub(/\.(md|mkdn?|mdown|markdown)/i, '.html').sub(/\.textile/i, '.html')  
end

def process_file(input_file_path)
  input_file_name = File.basename input_file_path
  output_file_name = convert_filename_to_html(input_file_name)
  output_file_raw_path = OUTPUT_DIR + input_file_path[(CONTENT_DIR.size)...-(input_file_name.size)]
  output_file_path =  output_file_raw_path + output_file_name
  FileUtils.mkpath(output_file_raw_path)
  
  in_contents = ""
  File.open(input_file_path, "rb") do |f|
    in_contents = f.read
  end
  
  out_contents = render(input_file_name, in_contents)
  
  p output_file_path
  # file = File.open(output_file_path, "w")
  # file.write(out_contents)
  # file.close
  
  File.open(output_file_path, "w") do |f|
    f.write(out_contents)
  end
  
end

def process_dir(dir)
  dir.entries.each do |entry|
    filepath = "#{dir.path}/#{entry}"
    process_file(filepath) if File.file?(filepath) && !entry.start_with?('.')
    process_dir(Dir.new(filepath)) if File.directory?(filepath) && entry != '.' && entry != '..'
  end  
end

FileUtils.remove_dir(OUTPUT_DIR, true)
content_dir = Dir.new CONTENT_DIR
process_dir(content_dir)






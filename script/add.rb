#!/usr/bin/env ruby

require 'fileutils'

SCRIPT_DIR = File.dirname(__FILE__)

CONTENT_DIR = "#{SCRIPT_DIR}/../content"
SECTIONS_DIR = "#{CONTENT_DIR}/sections"

TEMPLATE_DIR = "#{SCRIPT_DIR}/../templates"

SECTION_TEMPLATE_DIR = "#{TEMPLATE_DIR}/section"

def print_usage_and_exit
  STDERR.puts("Usage:\n\tadd section section_name [[as] section_id]\n\tadd unit unit_name [[as] unit_id] [[to] section_id]")
  exit -1
end

def check_for_duplicate_in_hash(hash, entity_id, entity_name, entity_type)
  if hash.has_key? entity_id
    STDERR.puts("Duplicate #{entity_type} key (#{entity_id}) found in #{entity_type} #{hash[entity_id]} and #{entity_type} #{entity_name}.\nPlease clean manually.")
    exit -1
  end
end

def check_for_duplicate_create_in_hash(hash, entity_id, entity_name, entity_type)
  if hash.has_key? entity_id
    STDERR.puts("A #{entity_type} key (#{entity_id}) already exists in #{entity_type} #{hash[entity_id]}. Can't add #{entity_type} #{entity_name}.")
    exit -1
  end
end
  
def delete_named_id(name, array)
  index = array.index(name)
  return nil if index.nil?
  index += 1
  result = (index < array.count ? array[index] : nil)
  array.delete_at(index - 1)
  array.delete_at(index - 1)
  result
end

def entities_in_dir(dir, entity_type)
  entities_hash = {}
  dir.entries.each do |entry|
    entity_id, entity_name = entry.split('_', 2)
    next unless entity_id && entity_name
    check_for_duplicate_in_hash(entities_hash, entity_id, entity_name, entity_type)
    entities_hash[entity_id] = entity_name
  end
  entities_hash
end

def new_entity_name_in(entities)
  return nil if entities.empty?
  last_entity_id = entities.keys.sort[-1] do |x, y|
    
  end
  suffix = ""
  last_entity_id.reverse.each_char do |char|
    break if char.to_i.to_s != char
    suffix << char
  end
  new_suffix = (suffix.reverse.to_i + 1).to_s
  new_entity_id = last_entity_id[0...-suffix.size] + new_suffix
end

def fill_section_with_template(path)
  p path
  FileUtils.cp_r(SECTION_TEMPLATE_DIR, path)
end

def add_section(args)
  print_usage_and_exit if args.size == 0
  
  sections_dir = Dir.new SECTIONS_DIR
  sections = entities_in_dir(sections_dir, 'section')
    
  section_id = delete_named_id('as', args)
  section_name = args.shift
  section_id ||= args.shift
  section_id ||= new_entity_name_in(sections)
  section_id ||= '1'
  
  print_usage_and_exit unless section_id && section_name
  
  check_for_duplicate_create_in_hash(sections, section_id, section_name, 'section')
  new_section_path = "#{SECTIONS_DIR}/#{section_id}_#{section_name}"
  new_section_dir = Dir.mkdir(new_section_path)
  fill_section_with_template(new_section_path)
end

def add_unit(args)
  print_usage_and_exit if args.size == 0
  
  section_id = delete_named_id('to', args)
  unit_id = delete_named_id('as', args)
  unit_name = args.shift
  section_id ||= args.shift
  unit_id ||= args.shift
  
  p "#{section_id} - #{unit_id} - #{unit_name}"
  
  # sections_dir = Dir.new SECTIONS_DIR
  # sections = entities_in_dir(sections_dir, 'section')
  #   
  # section_id = delete_named_id('as', args)
  # section_name = args.shift
  # section_id ||= args.shift
  # section_id ||= new_entity_name_in(sections)
  # 
  # print_usage_and_exit unless section_id && section_name
  # 
  # check_for_duplicate_create_in_hash(sections, section_id, section_name, 'section')
  # new_section_path = "#{SECTIONS_DIR}/#{section_id}_#{section_name}"
  # new_section_dir = Dir.mkdir(new_section_path)
  # fill_section_with_template(new_section_path)
end

print_usage_and_exit if ARGV.size == 0

thing_to_add = ARGV.shift
case thing_to_add
when 'section'
  add_section ARGV
when 'unit'
  add_unit ARGV
else
  STDERR.puts "Don't know how to add #{thing_to_add}."
  print_usage_and_exit
end

# pretend = false
# if ARGV[0] == '-p'
#   pretend = true
#   ARGV.shift
# end
# 
# l = Dir.new('.').reject { |fn| /^\./ =~ fn }.sort { |a, b| a.split(' ')[0].to_i <=> b.split(' ')[0].to_i }
# ids = ARGV
# 
# unless ids.size == l.size * 2
#   STDERR.puts("Number of files (#{l.size}) does not match number of given values (#{ids.size}).")
#   exit -2
# end
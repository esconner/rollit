#!/usr/bin/env ruby

require 'fileutils'

SCRIPT_DIR = File.dirname(__FILE__)

CONTENT_DIR = "#{SCRIPT_DIR}/../content"
SECTIONS_DIR = "#{CONTENT_DIR}/sections"

TEMPLATE_DIR = "#{SCRIPT_DIR}/../templates"

SECTION_TEMPLATE_DIR = "#{TEMPLATE_DIR}/section/."
UNIT_TEMPLATE_DIR = "#{TEMPLATE_DIR}/unit/."

def print_usage_and_exit
  STDERR.puts("Usage:\n\tadd section section_name [[as] section_id]\n\tadd unit unit_name [[as] unit_id] [[to] section_id]\nNote that all ids must be numeric.")
  exit -1
end
  
def validate_id(entity_id_string)
  return nil unless entity_id_string
  unless entity_id_string.to_i.to_s == entity_id_string
    STDERR.puts("Invalid id: #{entity_id_string}") 
    exit -1
  end
  entity_id_string.to_i
end

def validate_id_name_hash(hash, entity_id, entity_name, entity_type)
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
    entity_id = entity_id.to_i
    next unless entity_id && entity_name
    validate_id_name_hash(entities_hash, entity_id, entity_name, entity_type)
    entities_hash[entity_id] = entity_name
  end
  entities_hash
end

def new_entity_id_in(entities)
  return 1 if entities.empty?
  last_entity_id = entities.keys.sort[-1]
  last_entity_id + 1
end

def fill_section_with_template(path)
  FileUtils.cp_r(SECTION_TEMPLATE_DIR, path)
end

def fill_unit_with_template(path)
  FileUtils.cp_r(UNIT_TEMPLATE_DIR, path)
end

def section_entities
  sections_dir = Dir.new SECTIONS_DIR
  entities_in_dir(sections_dir, 'section')  
end

def last_section
  section_entities.keys.sort[-1]
end

def section_exists?(section_id)
  section_entities.keys.include? section_id
end


def unit_entities_in_section(section_id)
  sections = section_entities
  section_name = sections[section_id]
  units_dir = Dir.new("#{SECTIONS_DIR}/#{section_id}_#{section_name}/units")
  entities_in_dir(units_dir, 'unit')
end

def add_section(args)
  print_usage_and_exit if args.size == 0
  
  sections = section_entities
  section_id = validate_id(delete_named_id('as', args))
  section_name = args.shift
  section_id ||= validate_id(args.shift)
  section_id ||= new_entity_id_in(sections)
  
  p "#{section_id} - #{section_name}"
  
  print_usage_and_exit unless section_id && section_name
  
  check_for_duplicate_create_in_hash(sections, section_id, section_name, 'section')
  new_section_path = "#{SECTIONS_DIR}/#{section_id}_#{section_name}"
  new_section_dir = Dir.mkdir(new_section_path)
  fill_section_with_template(new_section_path)
end

def add_unit(args)
  print_usage_and_exit if args.size == 0
  
  section_id = validate_id(delete_named_id('to', args))
  unit_id = validate_id(delete_named_id('as', args))
  unit_name = args.shift
  section_id ||= validate_id(args.shift)
  unit_id ||= validate_id(args.shift)
  section_id ||= last_section
  

  print_usage_and_exit unless section_id
  unless section_exists?(section_id)
    STDERR.puts("Section #{section_id} does not exist. Please create before adding units.")
    exit -1
  end
  units = unit_entities_in_section(section_id)
  unit_id ||= new_entity_id_in(units)
  
  print_usage_and_exit unless unit_id && unit_name  
  
  p "#{section_id} - #{unit_id} - #{unit_name}"
  
  check_for_duplicate_create_in_hash(units, unit_id, unit_name, 'unit')
  new_unit_path = "#{SECTIONS_DIR}/#{section_id}_#{section_entities[section_id]}/units/#{unit_id}_#{unit_name}"
  p new_unit_path
  new_unit_dir = Dir.mkdir(new_unit_path)
  fill_unit_with_template(new_unit_path)
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

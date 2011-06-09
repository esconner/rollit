SCRIPT_DIR = File.dirname(__FILE__)

CONTENT_DIR = "#{SCRIPT_DIR}/../content"
SECTIONS_DIR = "#{CONTENT_DIR}/sections"
OUTPUT_DIR = "#{SCRIPT_DIR}/../output"
IMAGE_OUTPUT_DIR = "#{OUTPUT_DIR}/_/images"
THUMBNAIL_IMAGE_OUTPUT_DIR = "#{OUTPUT_DIR}/_/images/thumbnails"
VIDEO_OUTPUT_DIR = "#{OUTPUT_DIR}/_/video"

TEMPLATE_DIR = "#{SCRIPT_DIR}/../templates"

SECTION_TEMPLATE_DIR = "#{TEMPLATE_DIR}/section/."
UNIT_TEMPLATE_DIR = "#{TEMPLATE_DIR}/unit/."

STATIC_OUTPUT_TEMPLATE_DIR = "#{TEMPLATE_DIR}/output/static/."
DYNAMIC_OUTPUT_TEMPLATE_DIR = "#{TEMPLATE_DIR}/output/dynamic/."

def validate_id_name_hash(hash, entity_id, entity_name, entity_type)
  if hash.has_key? entity_id
    STDERR.puts("Duplicate #{entity_type} key (#{entity_id}) found in #{entity_type} #{hash[entity_id]} and #{entity_type} #{entity_name}.\nPlease clean manually.")
    exit -1
  end
end

def entities_in_dir(dir, entity_type)
  entities_hash = {}
  dir.entries.each do |entry|
    next if entry[0] == '.'
    entity_id, entity_name = entry.split('_', 2)
    entity_id = entity_id.to_i
    next unless entity_id && entity_name
    validate_id_name_hash(entities_hash, entity_id, entity_name, entity_type)
    entities_hash[entity_id] = entity_name
  end
  entities_hash
end

def section_entities
  sections_dir = Dir.new SECTIONS_DIR
  entities_in_dir(sections_dir, 'section')  
end

def entity(entity_id, entity_name)
  "#{entity_id}_#{entity_name}"
end

def section_path(section_id, section_name = nil)
  section_name = section_entities[section_id] unless section_name
  "#{SECTIONS_DIR}/#{entity(section_id, section_name)}"  
end

def unit_entities_in_section(section_id)  
  units_dir = Dir.new("#{section_path(section_id)}/units")
  entities_in_dir(units_dir, 'unit')
end

def unit_path(section_id, unit_id, unit_name = nil)
  unit_name = unit_entities_in_section(section_id)[unit_id] unless unit_name
  "#{section_path(section_id)}/units/#{entity(unit_id, unit_name)}"
end

def summary_images_in_unit(section_id, unit_id)
  images_dir = Dir.new("#{unit_path(section_id, unit_id)}/summary_images")
  images_dir.entries.find_all { |entry| entry[0] != '.' }
end

def output_summary_images_in_unit(section_id, unit_id)
  images_dir = Dir.new(IMAGE_OUTPUT_DIR)
  prefix = "#{section_id}_#{unit_id}_"
  images_dir.entries.find_all { |entry| entry =~ Regexp.new("^#{prefix}") }
end

def video_in_unit(section_id, unit_id)
  video_dir = Dir.new("#{unit_path(section_id, unit_id)}/video")
  video_dir.entries.find_all { |entry| entry[0] != '.' }
end

def output_video_base_name_in_unit(section_id, unit_id)
  video_dir = Dir.new(VIDEO_OUTPUT_DIR + "/#{section_id}_#{unit_id}/")
  base_name = video_dir.entries.find { |entry| entry =~ Regexp.new("mov$") }
  base_name ? base_name[0...-4] : nil
end
    



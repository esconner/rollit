SCRIPT_DIR = File.dirname(__FILE__)

CONTENT_DIR = "#{SCRIPT_DIR}/../content"
SECTIONS_DIR = "#{CONTENT_DIR}/sections"
OUTPUT_DIR = "#{SCRIPT_DIR}/../output"

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

# Copyright 2011 ZTT, FH Worms. All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, are
# permitted provided that the following conditions are met:
# 
#    1. Redistributions of source code must retain the above copyright notice, this list of
#       conditions and the following disclaimer.
# 
#    2. Redistributions in binary form must reproduce the above copyright notice, this list
#       of conditions and the following disclaimer in the documentation and/or other materials
#       provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY ZTT, FH WORMS ``AS IS'' AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ZTT, FH WORMS OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# The views and conclusions contained in the software and documentation are those of the
# authors and should not be interpreted as representing official policies, either expressed
# or implied, of ZTT, FH Worms.

SCRIPT_DIR = File.dirname(__FILE__)

CONTENT_DIR = "#{SCRIPT_DIR}/../content"
SECTIONS_DIR = "#{CONTENT_DIR}/sections"
OUTPUT_DIR = "#{SCRIPT_DIR}/../output"
IMAGE_OUTPUT_DIR = "#{OUTPUT_DIR}/_/images"
THUMBNAIL_IMAGE_OUTPUT_DIR = "#{OUTPUT_DIR}/_/images/thumbnails"
VIDEO_OUTPUT_DIR = "#{OUTPUT_DIR}/_/video"
DOWNLOADS_OUTPUT_DIR = "#{OUTPUT_DIR}/_/downloads" # added to store downloads in _/downloads/#_#/FILENAME

TEMPLATE_DIR = "#{SCRIPT_DIR}/../templates"

SECTION_TEMPLATE_DIR = "#{TEMPLATE_DIR}/content/section/."
UNIT_TEMPLATE_DIR = "#{TEMPLATE_DIR}/content/unit/."

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

# added to iterate over those files
def downloads_in_unit(section_id, unit_id)
  downloads_dir = Dir.new("#{unit_path(section_id, unit_id)}/downloads")
  # downloads_in_unit should contain all but the hidden files
  downloads_dir.entries.find_all { |entry| entry[0] != '.' }
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
    



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

require 'action_controller'
require 'RedCloth'
require 'rdiscount'

require File.dirname(__FILE__) + '/rollit_common'

# Check out Crafting Rails Applications by Jose Valim (Pragmatic Programmers)
ActionView::Template.register_template_handler :md, lambda { |template| "RDiscount.new(#{template.source.inspect}).to_html" }
ActionView::Template.register_template_handler :txtl, lambda { |template| "RedCloth.new(#{template.source.inspect}, [:hard_breaks]).to_html" }

class RollitTemplateController < AbstractController::Base
  include AbstractController::Rendering
  include AbstractController::Layouts
  include AbstractController::Helpers
  include AbstractController::AssetPaths

  self.view_paths = [DYNAMIC_OUTPUT_TEMPLATE_DIR, SECTIONS_DIR]
  
  helper_method :render_navigation
  helper_method :render_sections
  helper_method :render_units
  helper_method :render_summary_images
  helper_method :render_notes_for_unit
  helper_method :render_exercises_for_unit
  
  def render_navigation
    navigation_elements = []
    section_entities.each do |section_id, section_name|
      unit_nav_elements = []
      unit_entities_in_section(section_id).each do |unit_id, unit_name|
        unit_nav_elements << [unit_id, unit_name]
      end
      navigation_elements << [section_id, section_name, unit_nav_elements]      
    end
    self.render template: 'navigation', locals: {nav_elements: navigation_elements}
  end
  
  def render_sections
    sections = ActionView::OutputBuffer.new
    section_entities.each do |key, value|
      sections << (self.render template: 'section', locals: {section_id: key, section_name: value})
    end
    sections
  end
  
  def render_units(section_id)
    units = ActionView::OutputBuffer.new
    unit_entities_in_section(section_id).each do |unit_id, unit_name|
      video_base = output_video_base_name_in_unit(section_id, unit_id)
      units << (self.render template: 'unit', locals: {section_id: section_id, unit_id: unit_id, unit_name: unit_name, video_base: video_base})
    end
    units
  end
  
  def render_summary_images(section_id, unit_id)
    images = ActionView::OutputBuffer.new
    output_summary_images_in_unit(section_id, unit_id).each do |image_name|
      images << (self.render template: 'image', locals: {image_name: image_name})
    end
    images     
  end
  
  def content_template_path(section_id, unit_id)
    section_name = section_entities[section_id]
    section = entity(section_id, section_name)
    unit_name = unit_entities_in_section(section_id)[unit_id]
    unit = entity(unit_id, unit_name)
    "#{section}/units/#{unit}"
  end
  
  def render_notes_for_unit(section_id, unit_id)
    ActionView::OutputBuffer.new(self.render template: "#{content_template_path(section_id, unit_id)}/notes")    
  end
  
  def render_exercises_for_unit(section_id, unit_id)
    ActionView::OutputBuffer.new(self.render template: "#{content_template_path(section_id, unit_id)}/exercises")
  end

  
end
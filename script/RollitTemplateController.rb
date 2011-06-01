require 'action_controller'
require 'RedCloth'
require 'rdiscount'

require File.dirname(__FILE__) + '/rollit_common'

ActionView::Template.register_template_handler :md, lambda { |template| "RDiscount.new(#{template.source.inspect}).to_html" }
ActionView::Template.register_template_handler :txtl, lambda { |template| "RedCloth.new(#{template.source.inspect}, [:hard_breaks]).to_html" }

class RollitTemplateController < AbstractController::Base
  include AbstractController::Rendering
  include AbstractController::Layouts
  include AbstractController::Helpers
  include AbstractController::AssetPaths

  self.view_paths = DYNAMIC_OUTPUT_TEMPLATE_DIR
  
  helper_method :render_sections
  
  def render_sections
    sections = ActionView::OutputBuffer.new
    section_entities.each do |key, value|
      sections << (self.render template: 'section', locals: {section_number: key, section_name: value})
    end
    sections
  end
  
end
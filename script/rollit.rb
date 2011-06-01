#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/rollit_common'
require 'fileutils'
require "#{SCRIPT_DIR}/RollitTemplateController"


def add_static_templates_to_output_dir
  FileUtils.cp_r(STATIC_OUTPUT_TEMPLATE_DIR, OUTPUT_DIR)
end


FileUtils.remove_dir(OUTPUT_DIR, true)
add_static_templates_to_output_dir
rtc = RollitTemplateController.new
File.open("#{OUTPUT_DIR}/index.html", "w") do |f|
  f.write(rtc.render template: 'index')
end





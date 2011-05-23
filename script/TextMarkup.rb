require 'RedCloth'
require 'rdiscount'
require 'rdoc/markup/to_html'  # ruby1.9.2 specific 

module TextMarkup
  extend self
  
  # Auto-detect format from filename and render content
  def render(filename, content)
    name = File.basename(filename.to_s.strip)
    raise ArgumentError, 'Filename required!' if name.empty?
    format = detect_format(name)
    format == :text ? content : self.send(format, content)
  end
  
  # Render content for Markdown
  def markdown(content)
    Markdown.new(content).to_html
  end
  
  # Render content for RDoc
  def rdoc(content)
    RDoc::Markup::ToHtml.new.convert(content)
  end
  
  # Render content for Textile
  def textile(content)
    RedCloth.new(content).to_html
  end
  
  protected
  
  # Detect markup format from filename
  def detect_format(filename)
    case(filename)
      when /\.rdoc/i
        :rdoc
      when /\.(md|mkdn?|mdown|markdown)/i
        :markdown
      when /\.textile/i
        :textile
      else
        :text
    end
  end
end
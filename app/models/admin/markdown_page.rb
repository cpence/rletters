# -*- encoding : utf-8 -*-
class MarkdownPage < ActiveRecord::Base
  attr_accessible :name, :content
  
  def friendly_name
    I18n.t("markdown_pages.#{name}")
  end
  
  # Render the Markdown page for a particular name.  This will do nothing if
  # an invalid name is passed.
  def self.render(name)
    page = MarkdownPage.find_by_name(name) rescue nil
    return unless page
    
    Kramdown::Document.new(ERB.new(page.content).result(binding)).to_html.html_safe
  end
end

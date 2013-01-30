# -*- encoding : utf-8 -*-

ActiveAdmin.register MarkdownPage do
  actions :index, :update, :edit, :show 
  menu :parent => "Settings"
  filter :name
  
  sidebar :markdown, :only => :edit do
    str = <<-EOT
      Custom pages may be formatted using the Markdown syntax.  Visit the
      #{link_to 'Kramdown syntax guide', 'http://kramdown.rubyforge.org/syntax.html'}
      for information on the permitted syntax.
    EOT
    para str.html_safe
  end
  
  index do
    column :friendly_name
    default_actions
  end
  
  show :title => :friendly_name do |page|
    attributes_table do
      row :id
      row :friendly_name
      row :preview do
        # Pass the document through erb, then through Kramdown
        Kramdown::Document.new(ERB.new(page.content).result(binding)).to_html.html_safe
      end
      row :content do
        simple_format CGI::escapeHTML(page.content)
      end
    end
    active_admin_comments
  end
  
  form do |f|
    f.inputs "Page: #{markdown_page.friendly_name}" do
      f.input :content, :input_html => { :rows => 30 }
    end
    f.buttons
  end
end

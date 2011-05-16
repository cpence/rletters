# coding: UTF-8

module ApplicationHelper
  
  # Thanks to Peter Gumeson's HTML5 Boilerplate gem for this
  def add_class(name, attrs)
    classes = attrs[:class] || ''
    classes.strip!
    classes = ' ' + classes if !classes.blank?
    classes = name + classes
    attrs.merge(:class => classes)
  end

  def ie_html(attrs={}, &block)
    attrs.symbolize_keys!
    haml_concat("<!--[if lt IE 7]> #{ tag(:html, add_class('ie6', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if IEMobile 7]>    #{ tag(:html, add_class('iem7', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if IE 7]>    #{ tag(:html, add_class('ie7', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if IE 8]>    #{ tag(:html, add_class('ie8', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if (gte IE 9)|!(IE)]><!-->".html_safe)
    haml_tag :html, attrs do
      haml_concat("<!--<![endif]-->".html_safe)
      block.call
    end
  end
  
  def title(page_title)
    content_for(:title) { page_title }
  end
  
  def locale_name(locale)
    if locale.index('-').nil?
      str = I18n.t :"languages.#{locale}"
    else
      str = I18n.t :"languages.#{locale}", :default => [:"languages.#{locale.split('-')[0]}", "Unknown Language"]
    end
    str += " (#{locale})"
  end
  
  def help_button(id)
    link_to 'Help', help_path(:id => id), :class => 'helpbutton', 'data-rel' => 'dialog', 'data-role' => 'button', 'data-inline' => 'true', 'data-icon' => 'info', 'data-iconpos' => 'notext'
  end
end

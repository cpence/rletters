# -*- encoding : utf-8 -*-

def in_modal_dialog(link_or_name, &block)
  link = nil

  if link_or_name.is_a? String
    link = find_link(link_or_name, match: :first)
  else
    link = link_or_name
  end

  href = link[:href]
  back_url = current_url

  visit href

  yield

  visit back_url
end

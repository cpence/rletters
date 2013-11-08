# -*- encoding : utf-8 -*-

# Foundation's modal dialogs don't actually work on Poltergeist for some
# reason, so hack the support here.
def in_modal_dialog(button_name, &block)
  back_url = current_url

  link = find_link(button_name)
  visit link[:href]

  yield

  visit back_url
end

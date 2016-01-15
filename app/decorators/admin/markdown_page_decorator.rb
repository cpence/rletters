
module Admin
  # Decorate MarkdownPage objects
  class MarkdownPageDecorator < ApplicationRecordDecorator
    decorates Admin::MarkdownPage
    delegate_all
  end
end

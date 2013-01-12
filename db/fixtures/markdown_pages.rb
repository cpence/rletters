# -*- encoding : utf-8 -*-

Dir.glob(Rails.root.join('db', 'fixtures', 'markdown', '*.md')) do |md|
  MarkdownPage.seed_once(:name) do |p|
    p.name = File.basename(md, '.md')
    p.content = IO.read(md)
  end
end

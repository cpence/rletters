# -*- encoding : utf-8 -*-

# If we have no administration users at all, then create the default one
unless AdminUser.exists?
  AdminUser.create!(email: 'admin@example.com',
                    password: 'password',
                    password_confirmation: 'password')
  puts 'Seeded administrative user:admin@example.com'
  puts "   -> CHANGE THIS USER'S PASSWORD IMMEDIATELY"
end

# CSL styles
Dir.glob(Rails.root.join('db', 'seeds', 'csl', '*.csl')) do |csl|
  name = ''

  File.open(csl) do |f|
    doc = Nokogiri::XML::Document.parse(f)
    name_elt = doc.at_xpath('xmlns:style/xmlns:info/xmlns:title')
    name = name_elt.content if name_elt
  end

  unless name == ''
    csl_string = IO.read(csl)
    CslStyle.where(name: name).first_or_create(style: csl_string)
    puts "Seeded csl_style:#{name}"
  end
end

# Markdown pages
Dir.glob(Rails.root.join('db', 'seeds', 'markdown', '*.md')) do |md|
  name = File.basename(md, '.md')
  MarkdownPage.where(name: name).first_or_create(content: IO.read(md))
  puts "Seeded markdown_page:#{name}"
end

# Uploaded assets
Dir.glob(Rails.root.join('db', 'seeds', 'images', '*')) do |img|
  extension = File.extname(img)
  name = File.basename(img, extension)
  UploadedAsset.where(name: name).first_or_create(file: File.new(img))
  puts "Seeded asset:#{name}"
end


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
    Users::CslStyle.where(name: name).first_or_create!(style: csl_string)
    puts "Seeded csl_style:#{name}"
  end
end

# Markdown pages
Dir.glob(Rails.root.join('db', 'seeds', 'markdown', '*.md')) do |md|
  name = File.basename(md, '.md')
  Admin::MarkdownPage.where(name: name).first_or_create!(content: IO.read(md))
  puts "Seeded markdown_page:#{name}"
end

# Uploaded assets
Dir.glob(Rails.root.join('db', 'seeds', 'images', '*')) do |img|
  extension = File.extname(img)
  name = File.basename(img, extension)
  Admin::UploadedAsset.where(name: name).first_or_create! do |asset|
    f = File.new(img)
    asset.file = f
    f.close
  end

  puts "Seeded asset:#{name}"
end

# Stop lists
Dir.glob(Rails.root.join('db', 'seeds', 'stoplists', '*.txt')) do |txt|
  language = File.basename(txt, '.txt')
  Documents::StopList.where(language: language).first_or_create!(list: IO.read(txt))
  puts "Seeded stop_list:#{language}"
end

# Warn the user about the administrator password
puts "----------"
puts "Make sure to edit the .env file and change your administrator password!"

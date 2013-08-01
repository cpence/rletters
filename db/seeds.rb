# -*- encoding : utf-8 -*-

# If we have no administration users at all, then create the default one
unless AdminUser.exists?
  AdminUser.create!(email: 'admin@example.com',
                    password: 'password',
                    password_confirmation: 'password')
end

# CSL styles
Dir.glob(Rails.root.join('db', 'seeds', 'csl', '*.csl')) do |csl|
  name = ''

  File.open(csl) do |f|
    doc = REXML::Document.new(f)
    elt = doc.elements.each('style/info/title') do |elt|
      name = elt.get_text.value
      break
    end
  end

  unless name == ''
    csl_string = IO.read(csl)
    CslStyle.where(name: name).first_or_create(style: csl_string)
  end
end

# Markdown pages
Dir.glob(Rails.root.join('db', 'seeds', 'markdown', '*.md')) do |md|
  name = File.basename(md, '.md')  
  MarkdownPage.where(name: name).first_or_create(content: IO.read(md))
end

# Uploaded assets
Dir.glob(Rails.root.join('db', 'seeds', 'images', '*')) do |img|
  extension = File.extname(img)
  name = File.basename(img, extension)
  UploadedAsset.where(name: name).first_or_create(file: File.new(img))
end

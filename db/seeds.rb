# frozen_string_literal: true

# Snippets
Dir.glob(Rails.root.join('db', 'seeds', 'snippets', '*')) do |dir|
  lang = File.basename(dir)

  Dir.glob(Rails.root.join('db', 'seeds', 'snippets', lang, '*.md')) do |md|
    name = File.basename(md, '.md')
    Admin::Snippet.where(name: name, language: lang).first_or_create!(content: IO.read(md))
    puts "Seeded snippet:#{name} [#{lang}]"
  end
end

# Assets
Dir.glob(Rails.root.join('db', 'seeds', 'assets', '*')) do |img|
  extension = File.extname(img)
  name = File.basename(img, extension)
  Admin::Asset.where(name: name).first_or_create! do |asset|
    f = File.new(img)

    blob = ActiveStorage::Blob.create_after_upload!(
      io: f,
      filename: File.basename(img),
      content_type: Mime::Type.lookup_by_extension(extension[1..-1])
    )

    asset.file.attach(blob)
    asset.save

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

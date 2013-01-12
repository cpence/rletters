# -*- encoding : utf-8 -*-

Dir.glob(Rails.root.join('db', 'fixtures', 'images', '*')) do |img|
  UploadedAsset.seed_once(:name) do |a|
    extension = File.extname(img)
    a.name = File.basename(img, extension)
    a.file = File.new(img)
  end
end

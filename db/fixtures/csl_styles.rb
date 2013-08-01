# -*- encoding : utf-8 -*-

Dir.glob(Rails.root.join('db', 'fixtures', 'csl', '*.csl')) do |csl|
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

    CslStyle.seed(:name) do |s|
      s.name = name
      s.style = csl_string
    end
  end
end

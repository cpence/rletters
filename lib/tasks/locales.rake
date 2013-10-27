# -*- encoding : utf-8 -*-
# Rename languages that are different in the CLDR

namespace :locales do
  desc 'Rename problematic CLDR languages'
  task :rename do
    LOCALES_TO_FIX = {
      'fil:' => 'tl:',
      'zh-Hans:' => 'zh-CN:',
      'zh-Hant:' => 'zh-TW:',
      'zh-Hant-HK:' => 'zh-HK:'
    }

    Dir[Rails.root.join('vendor', 'locales', 'cldr', '**', '*.{rb,yml}').to_s].each do |file|
      text = IO.read(file)
      LOCALES_TO_FIX.each { |from, to| text.gsub!(from, to) }
      File.open(file, 'w') { |f| f.write(text) }
    end
  end

  desc 'Fix up CLDR languages (requires hash_syntax, Perl)'
  task :fixup do
    Dir[Rails.root.join('vendor', 'locales', 'cldr', '**', '*.rb').to_s].each do |file|
      `hash_syntax --to-19 #{file}`
    end

    Dir[Rails.root.join('vendor', 'locales', 'cldr', '**', '*.{rb,yml}').to_s].each do |file|
      `perl -i -pe 's/[\t ]+$//g' #{file}`
    end
  end
end

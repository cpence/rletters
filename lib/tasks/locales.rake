# Rename languages that are different in the CLDR or Transifex
require 'fileutils'

namespace :locales do
  desc 'Pull translations from Transifex'
  task :pull do
    `tx pull -a --minimum-perc=1`

    # All of the Transifex language codes use underscores (en_GB) instead of
    # dashes, as Rails does (en-GB).  Rename, and fix with sed.
    Dir[Rails.root.join('config', 'locales', '*_*.yml')].each do |file|
      dash_filename = File.basename(file).tr('_', '-')
      dest = File.join(File.dirname(file), dash_filename)
      FileUtils.mv(file, dest)

      underscore_base = File.basename(file, '.yml')
      dash_base = underscore_base.tr('_', '-')
      `sed -i'' -e 's/#{underscore_base}:/#{dash_base}:/g' #{dest}`
    end
  end

  desc 'Send source file to Transifex'
  task :push do
    `tx push -s`
  end

  desc 'Clean up problematic CLDR languages'
  task :fixup do
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

    Dir[Rails.root.join('vendor', 'locales', 'cldr', '**', '*.rb').to_s].each do |file|
      Bundler.with_clean_env { `hash_syntax --to-19 #{file}` }
    end

    Dir[Rails.root.join('vendor', 'locales', 'cldr', '**', '*.{rb,yml}').to_s].each do |file|
      `perl -i -pe 's/[\t ]+$//g' #{file}`
    end
  end
end

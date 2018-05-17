# frozen_string_literal: true

require 'fileutils'

namespace :rletters do
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
  end
end

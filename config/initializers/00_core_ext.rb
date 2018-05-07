# frozen_string_literal: true

core_ext_files = Rails.root.join('lib', 'core_ext', '**', '*.rb')
Dir[core_ext_files].each { |l| require l }

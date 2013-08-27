# -*- encoding : utf-8 -*-
require 'spec_helper'

if defined?(Encoding) && Encoding.default_external != 'UTF-8'
  Encoding.default_external = 'UTF-8'
end

describe 'The library itself' do
  def check_for_spec_defs_with_double_quotes(filename)
    failing_lines = []

    File.readlines(filename).each_with_index do |line, number|
      failing_lines << number + 1 if line =~ /^ *(describe|it|context) {1}"{1}/
    end

    unless failing_lines.empty?
      "#{filename} uses inconsistent double quotes on lines #{failing_lines.join(', ')}"
    end
  end

  def check_for_tab_characters(filename)
    failing_lines = []
    File.readlines(filename).each_with_index do |line, number|
      failing_lines << number + 1 if line =~ /\t/
    end

    unless failing_lines.empty?
      "#{filename} has tab characters on lines #{failing_lines.join(', ')}"
    end
  end

  def check_for_extra_spaces(filename)
    failing_lines = []
    File.readlines(filename).each_with_index do |line, number|
      next if line =~ /^\s+#.*\s+\n$/
      failing_lines << number + 1 if line =~ /\s+\n$/
    end

    unless failing_lines.empty?
      "#{filename} has spaces on the EOL on lines #{failing_lines.join(', ')}"
    end
  end

  RSpec::Matchers.define :be_well_formed do
    failure_message_for_should do |actual|
      actual.join("\n")
    end

    match do |actual|
      actual.empty?
    end
  end

  it 'has no malformed whitespace' do
    exempt = %r{vendor|LICENSE|\.png|\.svg|\.ico|\.md|db/seeds/|\.xsd|\.xml|\.yml}
    error_messages = []
    Dir.chdir(File.expand_path('../..', __FILE__)) do
      `git ls-files`.split("\n").each do |filename|
        next if filename =~ exempt
        next unless File.file? filename
        error_messages << check_for_tab_characters(filename)
        error_messages << check_for_extra_spaces(filename)
      end
    end
    expect(error_messages.compact).to be_well_formed
  end

  it 'uses single-quotes consistently in specs' do
    included = /spec/
    error_messages = []
    Dir.chdir(File.expand_path('../', __FILE__)) do
      `git ls-files`.split("\n").each do |filename|
        next unless filename =~ included
        next unless File.file? filename
        error_messages << check_for_spec_defs_with_double_quotes(filename)
      end
    end
    expect(error_messages.compact).to be_well_formed
  end

  it 'has all of its view specs' do
    included = %r{app/views/.*\.html\.(haml|erb)}
    error_messages = []
    Dir.chdir(File.expand_path('../..', __FILE__)) do
      `git ls-files`.split("\n").each do |filename|
        next unless filename =~ included
        next if filename.include? 'mailer/'
        next if filename.start_with? 'app/views/layouts/'
        next if File.basename(filename).start_with? '_'
        spec_filename = filename.sub('app/', 'spec/').sub(/\.html.*/, '_spec.rb')
        next if File.exist? spec_filename
        error_messages << "#{filename} has no view spec (checked for #{spec_filename})"
      end
      expect(error_messages.compact).to be_well_formed
    end
  end
end

require 'spec_helper'

if defined?(Encoding) && Encoding.default_external != 'UTF-8'
  Encoding.default_external = 'UTF-8'
end

RSpec.describe 'The library itself' do
  def check_for_spec_defs_with_double_quotes(filename)
    failing_lines = []

    File.readlines(filename).each_with_index do |line, number|
      if line =~ /^ *(describe|it|context) "/
        failing_lines << number + 1 if line !~ /".*#\{.*"/
      end
    end

    return if failing_lines.empty?
    "#{filename} uses inconsistent double quotes on lines #{failing_lines.join(', ')}"
  end

  def check_for_tab_characters(filename)
    failing_lines = []
    File.readlines(filename).each_with_index do |line, number|
      failing_lines << number + 1 if line =~ /\t/
    end

    return if failing_lines.empty?
    "#{filename} has tab characters on lines #{failing_lines.join(', ')}"
  end

  def check_for_extra_spaces(filename)
    failing_lines = []
    File.readlines(filename).each_with_index do |line, number|
      next if line =~ /^\s+#.*\s+\n$/
      failing_lines << number + 1 if line =~ /\s+\n$/
    end

    return if failing_lines.empty?
    "#{filename} has spaces on the EOL on lines #{failing_lines.join(', ')}"
  end

  RSpec::Matchers.define :be_well_formed do
    failure_message do |actual|
      actual.join("\n")
    end

    match(&:empty?)
  end

  it 'has no malformed whitespace' do
    exempt = %r{vendor|LICENSE|\.png|\.svg|\.ico|\.ttf|\.woff|\.svg|\.eot|\.md|db/seeds/|\.xsd|\.xml|\.yml|test/support/requests/|spec/support/requests/|\.sql}
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
end

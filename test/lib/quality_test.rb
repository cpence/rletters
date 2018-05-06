# frozen_string_literal: true
require 'test_helper'

if defined?(Encoding) && Encoding.default_external != 'UTF-8'
  Encoding.default_external = 'UTF-8'
end

class QualityTest < ActiveSupport::TestCase
  setup do
    @files = []

    exempt = %r{vendor|LICENSE|\.sql|\.png|\.svg|\.ico|\.ttf|\.woff|\.svg|\.eot|\.md|db/seeds/|\.xsd|\.xml|\.yml|test/support/requests/}
    Dir.chdir(Rails.root) do
      `git ls-files`.split("\n").each do |filename|
        next if filename =~ exempt
        next unless File.file?(filename)

        @files << filename
      end
    end
  end

  test 'code should not have any tab characters' do
    @files.each do |filename|
      File.readlines(filename).each_with_index do |line, number|
        refute_match /\t/, line, "#{filename} has a tab character on line #{number}"
      end
    end
  end

  test 'code should not have extra spaces' do
    @files.each do |filename|
      File.readlines(filename).each_with_index do |line, number|
        next if line =~ /^\s+#.*\s+\n$/
        refute_match /\s+\n$/, line, "#{filename} has spaces on EOL on line #{number}"
      end
    end
  end
end

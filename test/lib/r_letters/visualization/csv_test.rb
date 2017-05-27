require 'test_helper'
require 'csv'
require 'r_letters/visualization/csv'

class CSVTest < ActiveSupport::TestCase
  class TestClass
    include RLetters::Visualization::CSV
  end

  test 'csv_with_header yields a CSV object' do
    TestClass.new.csv_with_header(header: 'asdf') do |csv|
      assert_kind_of ::CSV, csv
    end
  end

  test 'csv_with_header adds the header' do
    csv_string = TestClass.new.csv_with_header(header: 'asdf') { |_| }
    assert csv_string.start_with?("asdf\n")
  end

  test 'csv_with_header adds subheader if requested' do
    csv_string = TestClass.new.csv_with_header(header: 'asdf',
                                               subheader: 'ghjk') { |_| }
    assert_includes csv_string, "\nghjk\n\"\"\n"
  end

  test 'csv_with_header does not add subheader if not requested' do
    csv_string = TestClass.new.csv_with_header(header: 'asdf') { |_| }
    assert_equal 3, csv_string.count("\n")
  end

  test 'csv_with_header ends CSVs with a blank row' do
    csv_string = TestClass.new.csv_with_header(header: 'asdf') { |_| }
    assert csv_string.end_with?("\n\"\"\n")
  end

  test 'write_csv_data fails with non-enumerable data' do
    ::CSV.generate do |csv|
      assert_raises(ArgumentError) do
        TestClass.new.write_csv_data(csv: csv, data: 42, data_spec: {})
      end
    end
  end

  test 'write_csv_data prints a header row' do
    csv_string = ::CSV.generate do |csv|
      TestClass.new.write_csv_data(csv: csv, data: [[1, 2]],
                                   data_spec: { 'first' => :first,
                                                'second' => :last })
    end

    assert_includes csv_string, "first,second\n"
  end

  test 'write_csv_data prints the data' do
    csv_string = ::CSV.generate do |csv|
      TestClass.new.write_csv_data(csv: csv, data: [[1, 2]],
                                   data_spec: { 'first' => :first,
                                                'second' => :last })
    end

    assert_includes csv_string, "1,2\n"
  end
end

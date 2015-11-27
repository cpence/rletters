require 'spec_helper'
require 'csv'
require 'active_support/concern'
require 'r_letters/visualization/csv'

RSpec.describe RLetters::Visualization::CSV do
  let(:test_class) { Class.new { include RLetters::Visualization::CSV } }

  describe '#csv_with_header' do
    it 'yields a CSV object' do
      test_class.new.csv_with_header('asdf') do |csv|
        expect(csv).to be_a(::CSV)
      end
    end

    it 'adds the header' do
      csv_string = test_class.new.csv_with_header('asdf') { |csv| }
      expect(csv_string).to start_with("asdf\n")
    end

    it 'adds the subheader if requested' do
      csv_string = test_class.new.csv_with_header('asdf', 'ghjk') { |csv| }
      expect(csv_string).to include("\nghjk\n\"\"\n")
    end

    it 'does not add a subheader if not requested' do
      csv_string = test_class.new.csv_with_header('asdf') { |csv| }
      expect(csv_string.count("\n")).to eq(3)
    end

    it 'ends CSVs with a blank row' do
      csv_string = test_class.new.csv_with_header('asdf') { |csv| }
      expect(csv_string).to end_with("\n\"\"\n")
    end
  end

  describe '#write_csv_data' do
    it 'fails with non-enumerable data' do
      ::CSV.generate do |csv|
        expect {
          test_class.new.write_csv_data(csv, 42, {})
        }.to raise_error(ArgumentError)
      end
    end

    it 'prints a header row' do
      csv_string = CSV.generate do |csv|
        test_class.new.write_csv_data(csv, [[1, 2]],
                                      'first' => :first,
                                      'second' => :last)
      end

      expect(csv_string).to include("first,second\n")
    end

    it 'prints the data' do
      csv_string = CSV.generate do |csv|
        test_class.new.write_csv_data(csv, [[1, 2]],
                                      'first' => :first,
                                      'second' => :last)
      end

      expect(csv_string).to include("1,2\n")
    end
  end
end

# -*- encoding : utf-8 -*-
RSpec::Matchers.define :be_lucene_query do |expected|
  match do |actual|
    expect(query_to_array(actual)).to match_array(expected)
  end

  def query_to_array(str)
    return [str[1..-2]] unless str[0] == '('
    str[1..-2].split(' OR ').map { |n| n[1..-2] }
  end

  failure_message_for_should do |actual|
    "expected that #{actual} (or #{query_to_array(actual).inspect}) would be the Lucene query for #{expected.inspect}"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual} (or #{query_to_array(actual).inspect}) would not be the Lucene query for #{expected.inspect}"
  end

  description do
    "be a Lucene query for the list #{expected.inspect}"
  end
end

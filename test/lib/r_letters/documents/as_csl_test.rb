require 'test_helper'

class AsCSLTest < ActiveSupport::TestCase
  test 'creates good citeproc items' do
    doc = build(:full_document)
    as_csl = RLetters::Documents::AsCSL.new(doc)
    csl = as_csl.citeproc_item

    assert_equal 'article-journal', csl.type
    assert_equal 'Dickens', csl.author[0].family
    assert_equal 'C.', csl.author[0].given
    assert_equal 'A Tale of Two Cities', csl.title
    assert_equal 'Actually a Novel', csl.container_title
    assert_equal Date.new(1859), csl.issued.to_date
    assert_equal '1', csl.volume
    assert_equal '1', csl.issue
    assert_equal '1', csl.page
  end

  test 'formats citations correctly' do
    style = flexmock(style: <<eos)
<style xmlns="http://purl.org/net/xbiblio/csl"  class="in-text" version="1.0">
  <info>
    <id />
    <title />
    <updated>2009-08-10T04:49:00+09:00</updated>
  </info>
  <citation>
    <layout>
      <names variable="author">
        <name />
      </names>
    </layout>
  </citation>
  <bibliography>
    <layout>
      <names variable="author">
        <name />
      </names>
    </layout>
  </bibliography>
</style>
eos

    doc = build(:full_document)
    as_csl = RLetters::Documents::AsCSL.new(doc)

    assert_equal 'C. Dickens', as_csl.entry(style)
  end

  test 'raises if you try to format with a weird style' do
    doc = build(:full_document)
    as_csl = RLetters::Documents::AsCSL.new(doc)

    assert_raises(NameError) do
      as_csl.entry(37)
    end
  end
end

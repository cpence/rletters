# frozen_string_literal: true

require 'test_helper'

module Users
  class LibraryTest < ActiveSupport::TestCase
    test 'should not be valid with no name' do
      library = build_stubbed(:library, name: nil)

      refute library.valid?
    end

    test 'should not be valid with no user' do
      library = build_stubbed(:library, user: nil)

      refute library.valid?
    end

    test 'should not be valid with no URL' do
      library = build_stubbed(:library, url: nil)

      refute library.valid?
    end

    test 'should be valid with a complete URL' do
      library = create(:library, url: 'http://google.com/wut?')

      assert library.valid?
    end

    test 'to_s should work' do
      library = create(:library)

      assert_includes library.to_s, library.name
    end

    test 'should parse a protocol-free URL' do
      library = create(:library, url: 'google.com/wut?')

      assert library.valid?
      assert_equal 'http://google.com/wut?', library.url
    end

    test 'should add question mark to URL' do
      library = create(:library, url: 'http://google.com')

      assert library.valid?
      assert_equal 'http://google.com?', library.url
    end

    test 'should not be valid with bad protocol' do
      library = build_stubbed(:library, url: 'file:///usr/share/pwned')

      refute library.valid?
    end
  end
end

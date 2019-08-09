# frozen_string_literal: true

require 'test_helper'

module RLetters
  module Documents
    class AsOpenUrlTest < ActiveSupport::TestCase
      test 'creates good OpenURL params' do
        doc = build(:full_document, authors: 'C. Dickens, M. Twain')
        params = RLetters::Documents::AsOpenUrl.new(doc).params

        assert_equal(
          'ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3A' \
          'mtx%3Ajournal&rft.genre=article&' \
          'rft_id=info:doi%2F10.5678%2Fdickens&' \
          'rft.atitle=A+Tale+of+Two+Cities&rft.title=Actually+a+Novel&' \
          'rft.date=1859&rft.volume=1&rft.issue=1&rft.spage=1&rft.aufirst=C.&' \
          'rft.aulast=Dickens&rft.au=M.+Twain', params
        )
      end
    end
  end
end

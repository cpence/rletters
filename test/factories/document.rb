# frozen_string_literal: true

# rubocop:disable BlockLength

FactoryBot.define do
  factory :document, class: Document do
    transient do
      uid { 'doi:10.1234/this.is.a.doi' }
      doi { nil }
      license { nil }
      license_url { nil }
      authors { nil }
      title { nil }
      journal { nil }
      year { nil }
      volume { nil }
      number { nil }
      pages { nil }
      term_vectors { nil }
    end

    factory :full_document do
      uid { 'doi:10.5678/dickens' }
      doi { '10.5678/dickens' }
      license { 'Public domain' }
      data_source { 'Project Gutenberg' }
      license_url { 'http://www.gutenberg.org/license' }
      authors { 'C. Dickens' }
      title { 'A Tale of Two Cities' }
      journal { 'Actually a Novel' }
      year { '1859' }
      volume { '1' }
      number { '1' }
      pages { '1' }

      term_vectors do
        { 'age' => { tf: 2, positions: [15, 21], df: 735.0 },
          'all' => { tf: 2, positions: [72, 79], df: 1464.0 },
          'authorities' => { tf: 1, positions: [101], df: 156.0 },
          'before' => { tf: 2, positions: [63, 68], df: 982.0 },
          'being' => { tf: 1, positions: [105], df: 1016.0 },
          'belief' => { tf: 1, positions: [29], df: 29.0 },
          'best' => { tf: 1, positions: [3], df: 509.0 },
          'comparison' => { tf: 1, positions: [117], df: 852.0 },
          'darkness' => { tf: 1, positions: [47], df: 5.0 },
          'degree' => { tf: 1, positions: [115], df: 427.0 },
          'despair' => { tf: 1, positions: [59], df: 5.0 },
          'direct' => { tf: 2, positions: [74, 81], df: 659.0 },
          'epoch' => { tf: 2, positions: [27, 33], df: 3.0 },
          'everything' => { tf: 1, positions: [62], df: 4.0 },
          'evil' => { tf: 1, positions: [111], df: 5.0 },
          'far' => { tf: 1, positions: [91], df: 473.0 },
          'foolishness' => { tf: 1, positions: [23], df: 1.0 },
          'for' => { tf: 2, positions: [107, 110], df: 1500.0 },
          'going' => { tf: 2, positions: [73, 80], df: 78.0 },
          'good' => { tf: 1, positions: [108], df: 480.0 },
          'had' => { tf: 2, positions: [61, 66], df: 1435.0 },
          'heaven' => { tf: 1, positions: [76], df: 1.0 },
          'hope' => { tf: 1, positions: [53], df: 89.0 },
          'in' => { tf: 2, positions: [85, 112], df: 1501.0 },
          'incredulity' => { tf: 1, positions: [35], df: 1.0 },
          'insisted' => { tf: 1, positions: [102], df: 3.0 },
          'it' =>
           { tf: 10,
             positions: [0, 6, 12, 18, 24, 30, 36, 42, 48, 54],
             df: 1486.0 },
          'its' => { tf: 2, positions: [99, 104], df: 1220.0 },
          'light' => { tf: 1, positions: [41], df: 551.0 },
          'like' => { tf: 1, positions: [92], df: 837.0 },
          'noisiest' => { tf: 1, positions: [100], df: 1.0 },
          'nothing' => { tf: 1, positions: [67], df: 38.0 },
          'of' =>
           { tf: 12,
             positions: [4, 10, 16, 22, 28, 34, 40, 46, 52, 58, 98, 116],
             df: 1501.0 },
          'on' => { tf: 1, positions: [103], df: 1496.0 },
          'only' => { tf: 1, positions: [118], df: 1422.0 },
          'or' => { tf: 1, positions: [109], df: 1497.0 },
          'other' => { tf: 1, positions: [83], df: 1479.0 },
          'period' => { tf: 2, positions: [88, 95], df: 835.0 },
          'present' => { tf: 1, positions: [94], df: 1233.0 },
          'received' => { tf: 1, positions: [106], df: 673.0 },
          'season' => { tf: 2, positions: [39, 45], df: 185.0 },
          'short' => { tf: 1, positions: [86], df: 500.0 },
          'so' => { tf: 1, positions: [90], df: 848.0 },
          'some' => { tf: 1, positions: [97], df: 1314.0 },
          'spring' => { tf: 1, positions: [51], df: 52.0 },
          'superlative' => { tf: 1, positions: [114], df: 1.0 },
          'that' => { tf: 1, positions: [96], df: 1500.0 },
          'the' =>
           { tf: 14,
             positions: [2, 8, 14, 20, 26, 32, 38, 44, 50, 56, 82, 87,
                         93, 113],
             df: 1500.0 },
          'times' => { tf: 2, positions: [5, 11], df: 816.0 },
          'to' => { tf: 1, positions: [75], df: 1500.0 },
          'us' => { tf: 2, positions: [64, 69], df: 716.0 },
          'was' =>
           { tf: 11,
             positions: [1, 7, 13, 19, 25, 31, 37, 43, 49, 55, 89],
             df: 1483.0 },
          'way' => { tf: 1, positions: [84], df: 533.0 },
          'we' => { tf: 4, positions: [60, 65, 70, 77], df: 1447.0 },
          'were' => { tf: 2, positions: [71, 78], df: 1463.0 },
          'winter' => { tf: 1, positions: [57], df: 40.0 },
          'wisdom' => { tf: 1, positions: [17], df: 5.0 },
          'worst' => { tf: 1, positions: [9], df: 60.0 } }
      end
    end

    initialize_with do
      doc = Document.new(uid: uid, doi: doi, license: license,
                         license_url: license_url, authors: authors,
                         title: title, journal: journal, year: year,
                         volume: volume, number: number, pages: pages)
      doc.term_vectors = term_vectors&.with_indifferent_access
      doc
    end
  end
end

# rubocop:enable BlockLength

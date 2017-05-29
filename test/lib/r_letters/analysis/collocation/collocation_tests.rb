
module CollocationTests
  def run_no_focal_word_test(klass, scoring)
    called_sub_100 = false
    called_100 = false

    result = klass.call(
      scoring: scoring,
      dataset: create(:full_dataset),
      num_pairs: 10,
      progress: lambda do |p|
        if p < 100
          called_sub_100 = true
        else
          called_100 = true
        end
      end)

    assert_kind_of RLetters::Analysis::Collocation::Result, result
    assert_equal scoring, result.scoring
    assert_equal 10, result.collocations.size

    result.collocations.each do |g|
      assert_kind_of Numeric, g[1]
      assert g[1] > 0 if g[1].is_a?(Integer)
      assert g[1].finite? if g[1].is_a?(Float)
    end

    assert called_sub_100
    assert called_100
  end

  def run_focal_word_test(klass, scoring)
    result = klass.call(
      scoring: scoring,
      dataset: create(:full_dataset),
      num_pairs: 10,
      focal_word: 'present')

    assert_kind_of RLetters::Analysis::Collocation::Result, result
    assert_equal scoring, result.scoring

    assert result.collocations.size >= 1

    result.collocations.each do |g|
      assert_includes g[0].split, 'present'
    end

    result.collocations.each do |g|
      assert_kind_of Numeric, g[1]
      assert g[1] > 0 if g[1].is_a?(Integer)
      assert g[1].finite? if g[1].is_a?(Float)
    end
  end

  def run_uppercase_focal_word_test(klass, scoring)
    result = klass.call(
      scoring: scoring,
      dataset: create(:full_dataset),
      num_pairs: 10,
      focal_word: 'PRESENT')

    assert_includes result.collocations[0][0].split, 'present'
  end

  module ClassMethods
    def run_common_tests(klass, scoring_methods)
      scoring_methods.each do |scoring|
        define_method "test_without_focal_word,_scoring_#{scoring}" do
          run_no_focal_word_test(klass, scoring)
        end

        define_method "test_with_focal_word,_scoring_#{scoring}" do
          run_focal_word_test(klass, scoring)
        end

        define_method "test_uppercase_focal_word,_scoring_#{scoring}" do
          run_uppercase_focal_word_test(klass, scoring)
        end
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end

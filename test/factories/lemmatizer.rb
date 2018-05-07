# frozen_string_literal: true

FactoryBot.define do
  factory :lemmatizer, class: OpenStruct do
    skip_create

    words do
      ['it', 'be', 'the', 'best', 'of', 'time', ',', 'it', 'be', 'the',
       'worst', 'of', 'time', ',', 'it', 'be', 'the', 'age', 'of', 'wisdom',
       ',', 'it', 'be', 'the', 'age', 'of', 'foolishness', ',', 'it', 'be',
       'the', 'epoch', 'of', 'belief', ',', 'it', 'be', 'the', 'epoch', 'of',
       'incredulity', ',', 'it', 'be', 'the', 'season', 'of', 'light', ',',
       'it', 'be', 'the', 'season', 'of', 'darkness', ',', 'it', 'be', 'the',
       'spring', 'of', 'hope', ',', 'it', 'be', 'the', 'winter', 'of',
       'despair', ',', 'we', 'have', 'everything', 'before', 'we', ',', 'we',
       'have', 'nothing', 'before', 'we', ',', 'we', 'be', 'all', 'go',
       'direct', 'to', 'Heaven', ',', 'we', 'be', 'all', 'go', 'direct',
       'the', 'other', 'way', '--', 'in', 'short', ',', 'the', 'period', 'be',
       'so', 'far', 'like', 'the', 'present', 'period', ',', 'that', 'some',
       'of', 'its', 'noisiest', 'authority', 'insist', 'on', 'its', 'be',
       'receive', ',', 'for', 'good', 'or', 'for', 'evil', ',', 'in', 'the',
       'superlative', 'degree', 'of', 'comparison', 'only', '.']
    end
  end
end

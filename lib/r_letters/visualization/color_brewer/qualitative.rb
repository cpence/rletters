# frozen_string_literal: true

module RLetters
  module Visualization
    module ColorBrewer
      # The qualitative color schemes
      #
      # From the ColorBrewer page:
      #
      # Qualitative schemes do not imply magnitude differences between legend
      # classes, and hues are used to create the primary visual differences
      # between classes. Qualitative schemes are best suited to representing
      # nominal or categorical data.
      #
      # Most of the qualitative schemes rely on differences in hue with only
      # subtle lightness differences between colors. You may pick a subset of
      # colors from a legend with more classes if you are not pleased with the
      # subsets. For example, you could pick four colors from a seven-color
      # legend. Two exceptions to the use of consistent lightness:
      #
      # Paired Scheme: This scheme presents a series of lightness pairs for
      # each hue (e.g. light green and dark green). Use this when you have
      # categories that should be visually related, though they are not
      # explicitly ordered. For example, 'forest' and 'woodland' would be
      # suitably represented with dark and light green.
      #
      # Accent Scheme: Use to accent small areas or important classes with
      # colors that are more saturated/darker/lighter than others in the
      # scheme - found at the bottom of the 'Accents' legends. Beware of
      # emphasizing unimportant classes when you use qualitative schemes.
      QUALITATIVE_COLOR_SCHEMES = {
        3 => {
          'Accent' => ['#7fc97f', '#beaed4', '#fdc086'],
          'Dark2' => ['#1b9e77', '#d95f02', '#7570b3'],
          'Paired' => ['#a6cee3', '#1f78b4', '#b2df8a'],
          'Pastel1' => ['#fbb4ae', '#b3cde3', '#ccebc5'],
          'Pastel2' => ['#b3e2cd', '#fdcdac', '#cbd5e8'],
          'Set1' => ['#e41a1c', '#377eb8', '#4daf4a'],
          'Set2' => ['#66c2a5', '#fc8d62', '#8da0cb'],
          'Set3' => ['#8dd3c7', '#ffffb3', '#bebada']
        },
        4 => {
          'Accent' => ['#7fc97f', '#beaed4', '#fdc086', '#ffff99'],
          'Dark2' => ['#1b9e77', '#d95f02', '#7570b3', '#e7298a'],
          'Paired' => ['#a6cee3', '#1f78b4', '#b2df8a', '#33a02c'],
          'Pastel1' => ['#fbb4ae', '#b3cde3', '#ccebc5', '#decbe4'],
          'Pastel2' => ['#b3e2cd', '#fdcdac', '#cbd5e8', '#f4cae4'],
          'Set1' => ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3'],
          'Set2' => ['#66c2a5', '#fc8d62', '#8da0cb', '#e78ac3'],
          'Set3' => ['#8dd3c7', '#ffffb3', '#bebada', '#fb8072']
        },
        5 => {
          'Accent' => ['#7fc97f', '#beaed4', '#fdc086', '#ffff99', '#386cb0'],
          'Dark2' => ['#1b9e77', '#d95f02', '#7570b3', '#e7298a', '#66a61e'],
          'Paired' => ['#a6cee3', '#1f78b4', '#b2df8a', '#33a02c', '#fb9a99'],
          'Pastel1' => ['#fbb4ae', '#b3cde3', '#ccebc5', '#decbe4', '#fed9a6'],
          'Pastel2' => ['#b3e2cd', '#fdcdac', '#cbd5e8', '#f4cae4', '#e6f5c9'],
          'Set1' => ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00'],
          'Set2' => ['#66c2a5', '#fc8d62', '#8da0cb', '#e78ac3', '#a6d854'],
          'Set3' => ['#8dd3c7', '#ffffb3', '#bebada', '#fb8072', '#80b1d3']
        },
        6 => {
          'Accent' => ['#7fc97f', '#beaed4', '#fdc086', '#ffff99', '#386cb0',
                       '#f0027f'],
          'Dark2' => ['#1b9e77', '#d95f02', '#7570b3', '#e7298a', '#66a61e',
                      '#e6ab02'],
          'Paired' => ['#a6cee3', '#1f78b4', '#b2df8a', '#33a02c', '#fb9a99',
                       '#e31a1c'],
          'Pastel1' => ['#fbb4ae', '#b3cde3', '#ccebc5', '#decbe4', '#fed9a6',
                        '#ffffcc'],
          'Pastel2' => ['#b3e2cd', '#fdcdac', '#cbd5e8', '#f4cae4', '#e6f5c9',
                        '#fff2ae'],
          'Set1' => ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00',
                     '#ffff33'],
          'Set2' => ['#66c2a5', '#fc8d62', '#8da0cb', '#e78ac3', '#a6d854',
                     '#ffd92f'],
          'Set3' => ['#8dd3c7', '#ffffb3', '#bebada', '#fb8072', '#80b1d3',
                     '#fdb462']
        },
        7 => {
          'Accent' => ['#7fc97f', '#beaed4', '#fdc086', '#ffff99', '#386cb0',
                       '#f0027f', '#bf5b17'],
          'Dark2' => ['#1b9e77', '#d95f02', '#7570b3', '#e7298a', '#66a61e',
                      '#e6ab02', '#a6761d'],
          'Paired' => ['#a6cee3', '#1f78b4', '#b2df8a', '#33a02c', '#fb9a99',
                       '#e31a1c', '#fdbf6f'],
          'Pastel1' => ['#fbb4ae', '#b3cde3', '#ccebc5', '#decbe4', '#fed9a6',
                        '#ffffcc', '#e5d8bd'],
          'Pastel2' => ['#b3e2cd', '#fdcdac', '#cbd5e8', '#f4cae4', '#e6f5c9',
                        '#fff2ae', '#f1e2cc'],
          'Set1' => ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00',
                     '#ffff33', '#a65628'],
          'Set2' => ['#66c2a5', '#fc8d62', '#8da0cb', '#e78ac3', '#a6d854',
                     '#ffd92f', '#e5c494'],
          'Set3' => ['#8dd3c7', '#ffffb3', '#bebada', '#fb8072', '#80b1d3',
                     '#fdb462', '#b3de69']
        },
        8 => {
          'Accent' => ['#7fc97f', '#beaed4', '#fdc086', '#ffff99', '#386cb0',
                       '#f0027f', '#bf5b17', '#666666'],
          'Dark2' => ['#1b9e77', '#d95f02', '#7570b3', '#e7298a', '#66a61e',
                      '#e6ab02', '#a6761d', '#666666'],
          'Paired' => ['#a6cee3', '#1f78b4', '#b2df8a', '#33a02c', '#fb9a99',
                       '#e31a1c', '#fdbf6f', '#ff7f00'],
          'Pastel1' => ['#fbb4ae', '#b3cde3', '#ccebc5', '#decbe4', '#fed9a6',
                        '#ffffcc', '#e5d8bd', '#fddaec'],
          'Pastel2' => ['#b3e2cd', '#fdcdac', '#cbd5e8', '#f4cae4', '#e6f5c9',
                        '#fff2ae', '#f1e2cc', '#cccccc'],
          'Set1' => ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00',
                     '#ffff33', '#a65628', '#f781bf'],
          'Set2' => ['#66c2a5', '#fc8d62', '#8da0cb', '#e78ac3', '#a6d854',
                     '#ffd92f', '#e5c494', '#b3b3b3'],
          'Set3' => ['#8dd3c7', '#ffffb3', '#bebada', '#fb8072', '#80b1d3',
                     '#fdb462', '#b3de69', '#fccde5']
        },
        9 => {
          'Paired' => ['#a6cee3', '#1f78b4', '#b2df8a', '#33a02c', '#fb9a99',
                       '#e31a1c', '#fdbf6f', '#ff7f00', '#cab2d6'],
          'Pastel1' => ['#fbb4ae', '#b3cde3', '#ccebc5', '#decbe4', '#fed9a6',
                        '#ffffcc', '#e5d8bd', '#fddaec', '#f2f2f2'],
          'Set1' => ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00',
                     '#ffff33', '#a65628', '#f781bf', '#999999'],
          'Set3' => ['#8dd3c7', '#ffffb3', '#bebada', '#fb8072', '#80b1d3',
                     '#fdb462', '#b3de69', '#fccde5', '#d9d9d9']
        },
        10 => {
          'Paired' => ['#a6cee3', '#1f78b4', '#b2df8a', '#33a02c', '#fb9a99',
                       '#e31a1c', '#fdbf6f', '#ff7f00', '#cab2d6', '#6a3d9a'],
          'Set3' => ['#8dd3c7', '#ffffb3', '#bebada', '#fb8072', '#80b1d3',
                     '#fdb462', '#b3de69', '#fccde5', '#d9d9d9', '#bc80bd']
        },
        11 => {
          'Paired' => ['#a6cee3', '#1f78b4', '#b2df8a', '#33a02c', '#fb9a99',
                       '#e31a1c', '#fdbf6f', '#ff7f00', '#cab2d6', '#6a3d9a',
                       '#ffff99'],
          'Set3' => ['#8dd3c7', '#ffffb3', '#bebada', '#fb8072', '#80b1d3',
                     '#fdb462', '#b3de69', '#fccde5', '#d9d9d9', '#bc80bd',
                     '#ccebc5']
        },
        12 => {
          'Paired' => ['#a6cee3', '#1f78b4', '#b2df8a', '#33a02c', '#fb9a99',
                       '#e31a1c', '#fdbf6f', '#ff7f00', '#cab2d6', '#6a3d9a',
                       '#ffff99', '#b15928'],
          'Set3' => ['#8dd3c7', '#ffffb3', '#bebada', '#fb8072', '#80b1d3',
                     '#fdb462', '#b3de69', '#fccde5', '#d9d9d9', '#bc80bd',
                     '#ccebc5', '#ffed6f']
        }
      }.freeze
    end
  end
end

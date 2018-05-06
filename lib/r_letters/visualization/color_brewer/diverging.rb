# frozen_string_literal: true

module RLetters
  module Visualization
    module ColorBrewer
      # The diverging color schemes
      #
      # From the ColorBrewer page:
      #
      # Diverging schemes put equal emphasis on mid-range critical values and
      # extremes at both ends of the data range. The critical class or break in
      # the middle of the legend is emphasized with light colors and low and
      # high extremes are emphasized with dark colors that have contrasting
      # hues.
      #
      # Diverging schemes are most effective when the class break in the
      # middle of the sequence, or the lightest middle color, is meaningfully
      # related to the mapped data. Use the break or class emphasized by a hue
      # and lightness change to represent a critical value in the data such as
      # the mean, median, or zero. Colors increase in darkness to represent
      # differences in both directions from this meaningful mid-range value
      # in the data.
      DIVERGING_COLOR_SCHEMES = {
        3 => {
          'PurpleOrange' => ['#f1a340', '#f7f7f7', '#998ec3'],
          'BrownBlueGreen' => ['#d8b365', '#f5f5f5', '#5ab4ac'],
          'PurpleGreen' => ['#af8dc3', '#f7f7f7', '#7fbf7b'],
          'PinkYellowGreen' => ['#e9a3c9', '#f7f7f7', '#a1d76a'],
          'RedBlue' => ['#ef8a62', '#f7f7f7', '#67a9cf'],
          'RedGrey' => ['#ef8a62', '#ffffff', '#999999'],
          'RedYellowBlue' => ['#fc8d59', '#ffffbf', '#91bfdb'],
          'Spectral' => ['#fc8d59', '#ffffbf', '#99d594'],
          'RedYellowGreen' => ['#fc8d59', '#ffffbf', '#91cf60']
        },
        4 => {
          'PurpleOrange' => ['#e66101', '#fdb863', '#b2abd2', '#5e3c99'],
          'BrownBlueGreen' => ['#a6611a', '#dfc27d', '#80cdc1', '#018571'],
          'PurpleGreen' => ['#7b3294', '#c2a5cf', '#a6dba0', '#008837'],
          'PinkYellowGreen' => ['#d01c8b', '#f1b6da', '#b8e186', '#4dac26'],
          'RedBlue' => ['#ca0020', '#f4a582', '#92c5de', '#0571b0'],
          'RedGrey' => ['#ca0020', '#f4a582', '#bababa', '#404040'],
          'RedYellowBlue' => ['#d7191c', '#fdae61', '#abd9e9', '#2c7bb6'],
          'Spectral' => ['#d7191c', '#fdae61', '#abdda4', '#2b83ba'],
          'RedYellowGreen' => ['#d7191c', '#fdae61', '#a6d96a', '#1a9641']
        },
        5 => {
          'PurpleOrange' => ['#e66101', '#fdb863', '#f7f7f7', '#b2abd2',
                             '#5e3c99'],
          'BrownBlueGreen' => ['#a6611a', '#dfc27d', '#f5f5f5', '#80cdc1',
                               '#018571'],
          'PurpleGreen' => ['#7b3294', '#c2a5cf', '#f7f7f7', '#a6dba0',
                            '#008837'],
          'PinkYellowGreen' => ['#d01c8b', '#f1b6da', '#f7f7f7', '#b8e186',
                                '#4dac26'],
          'RedBlue' => ['#ca0020', '#f4a582', '#f7f7f7', '#92c5de', '#0571b0'],
          'RedGrey' => ['#ca0020', '#f4a582', '#ffffff', '#bababa', '#404040'],
          'RedYellowBlue' => ['#d7191c', '#fdae61', '#ffffbf', '#abd9e9',
                              '#2c7bb6'],
          'Spectral' => ['#d7191c', '#fdae61', '#ffffbf', '#abdda4',
                         '#2b83ba'],
          'RedYellowGreen' => ['#d7191c', '#fdae61', '#ffffbf', '#a6d96a',
                               '#1a9641']
        },
        6 => {
          'PurpleOrange' => ['#b35806', '#f1a340', '#fee0b6', '#d8daeb',
                             '#998ec3', '#542788'],
          'BrownBlueGreen' => ['#8c510a', '#d8b365', '#f6e8c3', '#c7eae5',
                               '#5ab4ac', '#01665e'],
          'PurpleGreen' => ['#762a83', '#af8dc3', '#e7d4e8', '#d9f0d3',
                            '#7fbf7b', '#1b7837'],
          'PinkYellowGreen' => ['#c51b7d', '#e9a3c9', '#fde0ef', '#e6f5d0',
                                '#a1d76a', '#4d9221'],
          'RedBlue' => ['#b2182b', '#ef8a62', '#fddbc7', '#d1e5f0',
                        '#67a9cf', '#2166ac'],
          'RedGrey' => ['#b2182b', '#ef8a62', '#fddbc7', '#e0e0e0',
                        '#999999', '#4d4d4d'],
          'RedYellowBlue' => ['#d73027', '#fc8d59', '#fee090', '#e0f3f8',
                              '#91bfdb', '#4575b4'],
          'Spectral' => ['#d53e4f', '#fc8d59', '#fee08b', '#e6f598', '#99d594',
                         '#3288bd'],
          'RedYellowGreen' => ['#d73027', '#fc8d59', '#fee08b', '#d9ef8b',
                               '#91cf60', '#1a9850']
        },
        7 => {
          'PurpleOrange' => ['#b35806', '#f1a340', '#fee0b6', '#f7f7f7',
                             '#d8daeb', '#998ec3', '#542788'],
          'BrownBlueGreen' => ['#8c510a', '#d8b365', '#f6e8c3', '#f5f5f5',
                               '#c7eae5', '#5ab4ac', '#01665e'],
          'PurpleGreen' => ['#762a83', '#af8dc3', '#e7d4e8', '#f7f7f7',
                            '#d9f0d3', '#7fbf7b', '#1b7837'],
          'PinkYellowGreen' => ['#c51b7d', '#e9a3c9', '#fde0ef', '#f7f7f7',
                                '#e6f5d0', '#a1d76a', '#4d9221'],
          'RedBlue' => ['#b2182b', '#ef8a62', '#fddbc7', '#f7f7f7', '#d1e5f0',
                        '#67a9cf', '#2166ac'],
          'RedGrey' => ['#b2182b', '#ef8a62', '#fddbc7', '#ffffff', '#e0e0e0',
                        '#999999', '#4d4d4d'],
          'RedYellowBlue' => ['#d73027', '#fc8d59', '#fee090', '#ffffbf',
                              '#e0f3f8', '#91bfdb', '#4575b4'],
          'Spectral' => ['#d53e4f', '#fc8d59', '#fee08b', '#ffffbf', '#e6f598',
                         '#99d594', '#3288bd'],
          'RedYellowGreen' => ['#d73027', '#fc8d59', '#fee08b', '#ffffbf',
                               '#d9ef8b', '#91cf60', '#1a9850']
        },
        8 => {
          'PurpleOrange' => ['#b35806', '#e08214', '#fdb863', '#fee0b6',
                             '#d8daeb', '#b2abd2', '#8073ac', '#542788'],
          'BrownBlueGreen' => ['#8c510a', '#bf812d', '#dfc27d', '#f6e8c3',
                               '#c7eae5', '#80cdc1', '#35978f', '#01665e'],
          'PurpleGreen' => ['#762a83', '#9970ab', '#c2a5cf', '#e7d4e8',
                            '#d9f0d3', '#a6dba0', '#5aae61', '#1b7837'],
          'PinkYellowGreen' => ['#c51b7d', '#de77ae', '#f1b6da', '#fde0ef',
                                '#e6f5d0', '#b8e186', '#7fbc41', '#4d9221'],
          'RedBlue' => ['#b2182b', '#d6604d', '#f4a582', '#fddbc7', '#d1e5f0',
                        '#92c5de', '#4393c3', '#2166ac'],
          'RedGrey' => ['#b2182b', '#d6604d', '#f4a582', '#fddbc7', '#e0e0e0',
                        '#bababa', '#878787', '#4d4d4d'],
          'RedYellowBlue' => ['#d73027', '#f46d43', '#fdae61', '#fee090',
                              '#e0f3f8', '#abd9e9', '#74add1', '#4575b4'],
          'Spectral' => ['#d53e4f', '#f46d43', '#fdae61', '#fee08b', '#e6f598',
                         '#abdda4', '#66c2a5', '#3288bd'],
          'RedYellowGreen' => ['#d73027', '#f46d43', '#fdae61', '#fee08b',
                               '#d9ef8b', '#a6d96a', '#66bd63', '#1a9850']
        },
        9 => {
          'PurpleOrange' => ['#b35806', '#e08214', '#fdb863', '#fee0b6',
                             '#f7f7f7', '#d8daeb', '#b2abd2', '#8073ac',
                             '#542788'],
          'BrownBlueGreen' => ['#8c510a', '#bf812d', '#dfc27d', '#f6e8c3',
                               '#f5f5f5', '#c7eae5', '#80cdc1', '#35978f',
                               '#01665e'],
          'PurpleGreen' => ['#762a83', '#9970ab', '#c2a5cf', '#e7d4e8',
                            '#f7f7f7', '#d9f0d3', '#a6dba0', '#5aae61',
                            '#1b7837'],
          'PinkYellowGreen' => ['#c51b7d', '#de77ae', '#f1b6da', '#fde0ef',
                                '#f7f7f7', '#e6f5d0', '#b8e186', '#7fbc41',
                                '#4d9221'],
          'RedBlue' => ['#b2182b', '#d6604d', '#f4a582', '#fddbc7', '#f7f7f7',
                        '#d1e5f0', '#92c5de', '#4393c3', '#2166ac'],
          'RedGrey' => ['#b2182b', '#d6604d', '#f4a582', '#fddbc7', '#ffffff',
                        '#e0e0e0', '#bababa', '#878787', '#4d4d4d'],
          'RedYellowBlue' => ['#d73027', '#f46d43', '#fdae61', '#fee090',
                              '#ffffbf', '#e0f3f8', '#abd9e9', '#74add1',
                              '#4575b4'],
          'Spectral' => ['#d53e4f', '#f46d43', '#fdae61', '#fee08b', '#ffffbf',
                         '#e6f598', '#abdda4', '#66c2a5', '#3288bd'],
          'RedYellowGreen' => ['#d73027', '#f46d43', '#fdae61', '#fee08b',
                               '#ffffbf', '#d9ef8b', '#a6d96a', '#66bd63',
                               '#1a9850']
        },
        10 => {
          'PurpleOrange' => ['#7f3b08', '#b35806', '#e08214', '#fdb863',
                             '#fee0b6', '#d8daeb', '#b2abd2', '#8073ac',
                             '#542788', '#2d004b'],
          'BrownBlueGreen' => ['#543005', '#8c510a', '#bf812d', '#dfc27d',
                               '#f6e8c3', '#c7eae5', '#80cdc1', '#35978f',
                               '#01665e', '#003c30'],
          'PurpleGreen' => ['#40004b', '#762a83', '#9970ab', '#c2a5cf',
                            '#e7d4e8', '#d9f0d3', '#a6dba0', '#5aae61',
                            '#1b7837', '#00441b'],
          'PinkYellowGreen' => ['#8e0152', '#c51b7d', '#de77ae', '#f1b6da',
                                '#fde0ef', '#e6f5d0', '#b8e186', '#7fbc41',
                                '#4d9221', '#276419'],
          'RedBlue' => ['#67001f', '#b2182b', '#d6604d', '#f4a582', '#fddbc7',
                        '#d1e5f0', '#92c5de', '#4393c3', '#2166ac', '#053061'],
          'RedGrey' => ['#67001f', '#b2182b', '#d6604d', '#f4a582', '#fddbc7',
                        '#e0e0e0', '#bababa', '#878787', '#4d4d4d', '#1a1a1a'],
          'RedYellowBlue' => ['#a50026', '#d73027', '#f46d43', '#fdae61',
                              '#fee090', '#e0f3f8', '#abd9e9', '#74add1',
                              '#4575b4', '#313695'],
          'Spectral' => ['#9e0142', '#d53e4f', '#f46d43', '#fdae61', '#fee08b',
                         '#e6f598', '#abdda4', '#66c2a5', '#3288bd',
                         '#5e4fa2'],
          'RedYellowGreen' => ['#a50026', '#d73027', '#f46d43', '#fdae61',
                               '#fee08b', '#d9ef8b', '#a6d96a', '#66bd63',
                               '#1a9850', '#006837']
        },
        11 => {
          'PurpleOrange' => ['#7f3b08', '#b35806', '#e08214', '#fdb863',
                             '#fee0b6', '#f7f7f7', '#d8daeb', '#b2abd2',
                             '#8073ac', '#542788', '#2d004b'],
          'BrownBlueGreen' => ['#543005', '#8c510a', '#bf812d', '#dfc27d',
                               '#f6e8c3', '#f5f5f5', '#c7eae5', '#80cdc1',
                               '#35978f', '#01665e', '#003c30'],
          'PurpleGreen' => ['#40004b', '#762a83', '#9970ab', '#c2a5cf',
                            '#e7d4e8', '#f7f7f7', '#d9f0d3', '#a6dba0',
                            '#5aae61', '#1b7837', '#00441b'],
          'PinkYellowGreen' => ['#8e0152', '#c51b7d', '#de77ae', '#f1b6da',
                                '#fde0ef', '#f7f7f7', '#e6f5d0', '#b8e186',
                                '#7fbc41', '#4d9221', '#276419'],
          'RedBlue' => ['#67001f', '#b2182b', '#d6604d', '#f4a582', '#fddbc7',
                        '#f7f7f7', '#d1e5f0', '#92c5de', '#4393c3', '#2166ac',
                        '#053061'],
          'RedGrey' => ['#67001f', '#b2182b', '#d6604d', '#f4a582', '#fddbc7',
                        '#ffffff', '#e0e0e0', '#bababa', '#878787', '#4d4d4d',
                        '#1a1a1a'],
          'RedYellowBlue' => ['#a50026', '#d73027', '#f46d43', '#fdae61',
                              '#fee090', '#ffffbf', '#e0f3f8', '#abd9e9',
                              '#74add1', '#4575b4', '#313695'],
          'Spectral' => ['#9e0142', '#d53e4f', '#f46d43', '#fdae61', '#fee08b',
                         '#ffffbf', '#e6f598', '#abdda4', '#66c2a5', '#3288bd',
                         '#5e4fa2'],
          'RedYellowGreen' => ['#a50026', '#d73027', '#f46d43', '#fdae61',
                               '#fee08b', '#ffffbf', '#d9ef8b', '#a6d96a',
                               '#66bd63', '#1a9850', '#006837']
        }
      }.freeze
    end
  end
end

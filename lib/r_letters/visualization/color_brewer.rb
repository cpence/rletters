
module RLetters
  module Visualization
    # Color ramps from the ColorBrewer color palettes
    #
    # These are drawn from ColorBrewer, www.ColorBrewer.org, by Cynthia A.
    # Brewer, Geography, Pennsylvania State University.
    #
    # Copyright (c) 2002 Cynthia Brewer, Mark Harrower, and The Pennsylvania
    # State University.
    #
    # Licensed under the Apache License, Version 2.0 (the "License"); you may
    # not use this file except in compliance with the License. You may obtain
    # a copy of the License at
    #
    # http://www.apache.org/licenses/LICENSE-2.0
    #
    # Unless required by applicable law or agreed to in writing, software
    # distributed under the License is distributed on an "AS IS" BASIS,
    # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    # See the License for the specific language governing permissions and
    # limitations under the License.
    #
    # In particular, these were adapted from Mike Bostock's bl.ocks.org code
    # listing: http://bl.ocks.org/mbostock/5577023
    module ColorBrewer
      # The sequential color schemes
      #
      # From the ColorBrewer page:
      #
      # Sequential schemes are suited to ordered data that progress from low to
      # high. Lightness steps dominate the look of these schemes, with light
      # colors for low data values to dark colors for high data values.
      SEQUENTIAL_COLOR_SCHEMES = {
        3 => {
          'YellowGreen' => ['#f7fcb9', '#addd8e', '#31a354'],
          'YellowGreenBlue' => ['#edf8b1', '#7fcdbb', '#2c7fb8'],
          'GreenBlue' => ['#e0f3db', '#a8ddb5', '#43a2ca'],
          'BlueGreen' => ['#e5f5f9', '#99d8c9', '#2ca25f'],
          'PurpleBlueGreen' => ['#ece2f0', '#a6bddb', '#1c9099'],
          'PurpleBlue' => ['#ece7f2', '#a6bddb', '#2b8cbe'],
          'BluePurple' => ['#e0ecf4', '#9ebcda', '#8856a7'],
          'RedPurple' => ['#fde0dd', '#fa9fb5', '#c51b8a'],
          'PurpleRed' => ['#e7e1ef', '#c994c7', '#dd1c77'],
          'OrangeRed' => ['#fee8c8', '#fdbb84', '#e34a33'],
          'YellowOrangeRed' => ['#ffeda0', '#feb24c', '#f03b20'],
          'YellowOrangeBrown' => ['#fff7bc', '#fec44f', '#d95f0e'],
          'Purples' => ['#efedf5', '#bcbddc', '#756bb1'],
          'Blues' => ['#deebf7', '#9ecae1', '#3182bd'],
          'Greens' => ['#e5f5e0', '#a1d99b', '#31a354'],
          'Oranges' => ['#fee6ce', '#fdae6b', '#e6550d'],
          'Reds' => ['#fee0d2', '#fc9272', '#de2d26'],
          'Greys' => ['#f0f0f0', '#bdbdbd', '#636363']
        },
        4 => {
          'YellowGreen' => ['#ffffcc', '#c2e699', '#78c679', '#238443'],
          'YellowGreenBlue' => ['#ffffcc', '#a1dab4', '#41b6c4', '#225ea8'],
          'GreenBlue' => ['#f0f9e8', '#bae4bc', '#7bccc4', '#2b8cbe'],
          'BlueGreen' => ['#edf8fb', '#b2e2e2', '#66c2a4', '#238b45'],
          'PurpleBlueGreen' => ['#f6eff7', '#bdc9e1', '#67a9cf', '#02818a'],
          'PurpleBlue' => ['#f1eef6', '#bdc9e1', '#74a9cf', '#0570b0'],
          'BluePurple' => ['#edf8fb', '#b3cde3', '#8c96c6', '#88419d'],
          'RedPurple' => ['#feebe2', '#fbb4b9', '#f768a1', '#ae017e'],
          'PurpleRed' => ['#f1eef6', '#d7b5d8', '#df65b0', '#ce1256'],
          'OrangeRed' => ['#fef0d9', '#fdcc8a', '#fc8d59', '#d7301f'],
          'YellowOrangeRed' => ['#ffffb2', '#fecc5c', '#fd8d3c', '#e31a1c'],
          'YellowOrangeBrown' => ['#ffffd4', '#fed98e', '#fe9929', '#cc4c02'],
          'Purples' => ['#f2f0f7', '#cbc9e2', '#9e9ac8', '#6a51a3'],
          'Blues' => ['#eff3ff', '#bdd7e7', '#6baed6', '#2171b5'],
          'Greens' => ['#edf8e9', '#bae4b3', '#74c476', '#238b45'],
          'Oranges' => ['#feedde', '#fdbe85', '#fd8d3c', '#d94701'],
          'Reds' => ['#fee5d9', '#fcae91', '#fb6a4a', '#cb181d'],
          'Greys' => ['#f7f7f7', '#cccccc', '#969696', '#525252']
        },
        5 => {
          'YellowGreen' => ['#ffffcc', '#c2e699', '#78c679', '#31a354',
                            '#006837'],
          'YellowGreenBlue' => ['#ffffcc', '#a1dab4', '#41b6c4', '#2c7fb8',
                                '#253494'],
          'GreenBlue' => ['#f0f9e8', '#bae4bc', '#7bccc4', '#43a2ca',
                          '#0868ac'],
          'BlueGreen' => ['#edf8fb', '#b2e2e2', '#66c2a4', '#2ca25f',
                          '#006d2c'],
          'PurpleBlueGreen' => ['#f6eff7', '#bdc9e1', '#67a9cf', '#1c9099',
                                '#016c59'],
          'PurpleBlue' => ['#f1eef6', '#bdc9e1', '#74a9cf', '#2b8cbe',
                           '#045a8d'],
          'BluePurple' => ['#edf8fb', '#b3cde3', '#8c96c6', '#8856a7',
                           '#810f7c'],
          'RedPurple' => ['#feebe2', '#fbb4b9', '#f768a1', '#c51b8a',
                          '#7a0177'],
          'PurpleRed' => ['#f1eef6', '#d7b5d8', '#df65b0', '#dd1c77',
                          '#980043'],
          'OrangeRed' => ['#fef0d9', '#fdcc8a', '#fc8d59', '#e34a33',
                          '#b30000'],
          'YellowOrangeRed' => ['#ffffb2', '#fecc5c', '#fd8d3c', '#f03b20',
                                '#bd0026'],
          'YellowOrangeBrown' => ['#ffffd4', '#fed98e', '#fe9929', '#d95f0e',
                                  '#993404'],
          'Purples' => ['#f2f0f7', '#cbc9e2', '#9e9ac8', '#756bb1', '#54278f'],
          'Blues' => ['#eff3ff', '#bdd7e7', '#6baed6', '#3182bd', '#08519c'],
          'Greens' => ['#edf8e9', '#bae4b3', '#74c476', '#31a354', '#006d2c'],
          'Oranges' => ['#feedde', '#fdbe85', '#fd8d3c', '#e6550d', '#a63603'],
          'Reds' => ['#fee5d9', '#fcae91', '#fb6a4a', '#de2d26', '#a50f15'],
          'Greys' => ['#f7f7f7', '#cccccc', '#969696', '#636363', '#252525']
        },
        6 => {
          'YellowGreen' => ['#ffffcc', '#d9f0a3', '#addd8e', '#78c679',
                            '#31a354', '#006837'],
          'YellowGreenBlue' => ['#ffffcc', '#c7e9b4', '#7fcdbb', '#41b6c4',
                                '#2c7fb8', '#253494'],
          'GreenBlue' => ['#f0f9e8', '#ccebc5', '#a8ddb5', '#7bccc4',
                          '#43a2ca', '#0868ac'],
          'BlueGreen' => ['#edf8fb', '#ccece6', '#99d8c9', '#66c2a4',
                          '#2ca25f', '#006d2c'],
          'PurpleBlueGreen' => ['#f6eff7', '#d0d1e6', '#a6bddb', '#67a9cf',
                                '#1c9099', '#016c59'],
          'PurpleBlue' => ['#f1eef6', '#d0d1e6', '#a6bddb', '#74a9cf',
                           '#2b8cbe', '#045a8d'],
          'BluePurple' => ['#edf8fb', '#bfd3e6', '#9ebcda', '#8c96c6',
                           '#8856a7', '#810f7c'],
          'RedPurple' => ['#feebe2', '#fcc5c0', '#fa9fb5', '#f768a1',
                          '#c51b8a', '#7a0177'],
          'PurpleRed' => ['#f1eef6', '#d4b9da', '#c994c7', '#df65b0',
                          '#dd1c77', '#980043'],
          'OrangeRed' => ['#fef0d9', '#fdd49e', '#fdbb84', '#fc8d59',
                          '#e34a33', '#b30000'],
          'YellowOrangeRed' => ['#ffffb2', '#fed976', '#feb24c', '#fd8d3c',
                                '#f03b20', '#bd0026'],
          'YellowOrangeBrown' => ['#ffffd4', '#fee391', '#fec44f', '#fe9929',
                                  '#d95f0e', '#993404'],
          'Purples' => ['#f2f0f7', '#dadaeb', '#bcbddc', '#9e9ac8', '#756bb1',
                        '#54278f'],
          'Blues' => ['#eff3ff', '#c6dbef', '#9ecae1', '#6baed6', '#3182bd',
                      '#08519c'],
          'Greens' => ['#edf8e9', '#c7e9c0', '#a1d99b', '#74c476', '#31a354',
                       '#006d2c'],
          'Oranges' => ['#feedde', '#fdd0a2', '#fdae6b', '#fd8d3c', '#e6550d',
                        '#a63603'],
          'Reds' => ['#fee5d9', '#fcbba1', '#fc9272', '#fb6a4a', '#de2d26',
                     '#a50f15'],
          'Greys' => ['#f7f7f7', '#d9d9d9', '#bdbdbd', '#969696', '#636363',
                      '#252525']
        },
        7 => {
          'YellowGreen' => ['#ffffcc', '#d9f0a3', '#addd8e', '#78c679',
                            '#41ab5d', '#238443', '#005a32'],
          'YellowGreenBlue' => ['#ffffcc', '#c7e9b4', '#7fcdbb', '#41b6c4',
                                '#1d91c0', '#225ea8', '#0c2c84'],
          'GreenBlue' => ['#f0f9e8', '#ccebc5', '#a8ddb5', '#7bccc4',
                          '#4eb3d3', '#2b8cbe', '#08589e'],
          'BlueGreen' => ['#edf8fb', '#ccece6', '#99d8c9', '#66c2a4',
                          '#41ae76', '#238b45', '#005824'],
          'PurpleBlueGreen' => ['#f6eff7', '#d0d1e6', '#a6bddb', '#67a9cf',
                                '#3690c0', '#02818a', '#016450'],
          'PurpleBlue' => ['#f1eef6', '#d0d1e6', '#a6bddb', '#74a9cf',
                           '#3690c0', '#0570b0', '#034e7b'],
          'BluePurple' => ['#edf8fb', '#bfd3e6', '#9ebcda', '#8c96c6',
                           '#8c6bb1', '#88419d', '#6e016b'],
          'RedPurple' => ['#feebe2', '#fcc5c0', '#fa9fb5', '#f768a1',
                          '#dd3497', '#ae017e', '#7a0177'],
          'PurpleRed' => ['#f1eef6', '#d4b9da', '#c994c7', '#df65b0',
                          '#e7298a', '#ce1256', '#91003f'],
          'OrangeRed' => ['#fef0d9', '#fdd49e', '#fdbb84', '#fc8d59',
                          '#ef6548', '#d7301f', '#990000'],
          'YellowOrangeRed' => ['#ffffb2', '#fed976', '#feb24c', '#fd8d3c',
                                '#fc4e2a', '#e31a1c', '#b10026'],
          'YellowOrangeBrown' => ['#ffffd4', '#fee391', '#fec44f', '#fe9929',
                                  '#ec7014', '#cc4c02', '#8c2d04'],
          'Purples' => ['#f2f0f7', '#dadaeb', '#bcbddc', '#9e9ac8', '#807dba',
                        '#6a51a3', '#4a1486'],
          'Blues' => ['#eff3ff', '#c6dbef', '#9ecae1', '#6baed6', '#4292c6',
                      '#2171b5', '#084594'],
          'Greens' => ['#edf8e9', '#c7e9c0', '#a1d99b', '#74c476', '#41ab5d',
                       '#238b45', '#005a32'],
          'Oranges' => ['#feedde', '#fdd0a2', '#fdae6b', '#fd8d3c', '#f16913',
                        '#d94801', '#8c2d04'],
          'Reds' => ['#fee5d9', '#fcbba1', '#fc9272', '#fb6a4a', '#ef3b2c',
                     '#cb181d', '#99000d'],
          'Greys' => ['#f7f7f7', '#d9d9d9', '#bdbdbd', '#969696', '#737373',
                      '#525252', '#252525']
        },
        8 => {
          'YellowGreen' => ['#ffffe5', '#f7fcb9', '#d9f0a3', '#addd8e',
                            '#78c679', '#41ab5d', '#238443', '#005a32'],
          'YellowGreenBlue' => ['#ffffd9', '#edf8b1', '#c7e9b4', '#7fcdbb',
                                '#41b6c4', '#1d91c0', '#225ea8', '#0c2c84'],
          'GreenBlue' => ['#f7fcf0', '#e0f3db', '#ccebc5', '#a8ddb5',
                          '#7bccc4', '#4eb3d3', '#2b8cbe', '#08589e'],
          'BlueGreen' => ['#f7fcfd', '#e5f5f9', '#ccece6', '#99d8c9',
                          '#66c2a4', '#41ae76', '#238b45', '#005824'],
          'PurpleBlueGreen' => ['#fff7fb', '#ece2f0', '#d0d1e6', '#a6bddb',
                                '#67a9cf', '#3690c0', '#02818a', '#016450'],
          'PurpleBlue' => ['#fff7fb', '#ece7f2', '#d0d1e6', '#a6bddb',
                           '#74a9cf', '#3690c0', '#0570b0', '#034e7b'],
          'BluePurple' => ['#f7fcfd', '#e0ecf4', '#bfd3e6', '#9ebcda',
                           '#8c96c6', '#8c6bb1', '#88419d', '#6e016b'],
          'RedPurple' => ['#fff7f3', '#fde0dd', '#fcc5c0', '#fa9fb5',
                          '#f768a1', '#dd3497', '#ae017e', '#7a0177'],
          'PurpleRed' => ['#f7f4f9', '#e7e1ef', '#d4b9da', '#c994c7',
                          '#df65b0', '#e7298a', '#ce1256', '#91003f'],
          'OrangeRed' => ['#fff7ec', '#fee8c8', '#fdd49e', '#fdbb84',
                          '#fc8d59', '#ef6548', '#d7301f', '#990000'],
          'YellowOrangeRed' => ['#ffffcc', '#ffeda0', '#fed976', '#feb24c',
                                '#fd8d3c', '#fc4e2a', '#e31a1c', '#b10026'],
          'YellowOrangeBrown' => ['#ffffe5', '#fff7bc', '#fee391', '#fec44f',
                                  '#fe9929', '#ec7014', '#cc4c02', '#8c2d04'],
          'Purples' => ['#fcfbfd', '#efedf5', '#dadaeb', '#bcbddc', '#9e9ac8',
                        '#807dba', '#6a51a3', '#4a1486'],
          'Blues' => ['#f7fbff', '#deebf7', '#c6dbef', '#9ecae1', '#6baed6',
                      '#4292c6', '#2171b5', '#084594'],
          'Greens' => ['#f7fcf5', '#e5f5e0', '#c7e9c0', '#a1d99b', '#74c476',
                       '#41ab5d', '#238b45', '#005a32'],
          'Oranges' => ['#fff5eb', '#fee6ce', '#fdd0a2', '#fdae6b', '#fd8d3c',
                        '#f16913', '#d94801', '#8c2d04'],
          'Reds' => ['#fff5f0', '#fee0d2', '#fcbba1', '#fc9272', '#fb6a4a',
                     '#ef3b2c', '#cb181d', '#99000d'],
          'Greys' => ['#ffffff', '#f0f0f0', '#d9d9d9', '#bdbdbd', '#969696',
                      '#737373', '#525252', '#252525']
        },
        9 => {
          'YellowGreen' => ['#ffffe5', '#f7fcb9', '#d9f0a3', '#addd8e',
                            '#78c679', '#41ab5d', '#238443', '#006837',
                            '#004529'],
          'YellowGreenBlue' => ['#ffffd9', '#edf8b1', '#c7e9b4', '#7fcdbb',
                                '#41b6c4', '#1d91c0', '#225ea8', '#253494',
                                '#081d58'],
          'GreenBlue' => ['#f7fcf0', '#e0f3db', '#ccebc5', '#a8ddb5',
                          '#7bccc4', '#4eb3d3', '#2b8cbe', '#0868ac',
                          '#084081'],
          'BlueGreen' => ['#f7fcfd', '#e5f5f9', '#ccece6', '#99d8c9',
                          '#66c2a4', '#41ae76', '#238b45', '#006d2c',
                          '#00441b'],
          'PurpleBlueGreen' => ['#fff7fb', '#ece2f0', '#d0d1e6', '#a6bddb',
                                '#67a9cf', '#3690c0', '#02818a', '#016c59',
                                '#014636'],
          'PurpleBlue' => ['#fff7fb', '#ece7f2', '#d0d1e6', '#a6bddb',
                           '#74a9cf', '#3690c0', '#0570b0', '#045a8d',
                           '#023858'],
          'BluePurple' => ['#f7fcfd', '#e0ecf4', '#bfd3e6', '#9ebcda',
                           '#8c96c6', '#8c6bb1', '#88419d', '#810f7c',
                           '#4d004b'],
          'RedPurple' => ['#fff7f3', '#fde0dd', '#fcc5c0', '#fa9fb5',
                          '#f768a1', '#dd3497', '#ae017e', '#7a0177',
                          '#49006a'],
          'PurpleRed' => ['#f7f4f9', '#e7e1ef', '#d4b9da', '#c994c7',
                          '#df65b0', '#e7298a', '#ce1256', '#980043',
                          '#67001f'],
          'OrangeRed' => ['#fff7ec', '#fee8c8', '#fdd49e', '#fdbb84',
                          '#fc8d59', '#ef6548', '#d7301f', '#b30000',
                          '#7f0000'],
          'YellowOrangeRed' => ['#ffffcc', '#ffeda0', '#fed976', '#feb24c',
                                '#fd8d3c', '#fc4e2a', '#e31a1c', '#bd0026',
                                '#800026'],
          'YellowOrangeBrown' => ['#ffffe5', '#fff7bc', '#fee391', '#fec44f',
                                  '#fe9929', '#ec7014', '#cc4c02', '#993404',
                                  '#662506'],
          'Purples' => ['#fcfbfd', '#efedf5', '#dadaeb', '#bcbddc', '#9e9ac8',
                        '#807dba', '#6a51a3', '#54278f', '#3f007d'],
          'Blues' => ['#f7fbff', '#deebf7', '#c6dbef', '#9ecae1', '#6baed6',
                      '#4292c6', '#2171b5', '#08519c', '#08306b'],
          'Greens' => ['#f7fcf5', '#e5f5e0', '#c7e9c0', '#a1d99b', '#74c476',
                       '#41ab5d', '#238b45', '#006d2c', '#00441b'],
          'Oranges' => ['#fff5eb', '#fee6ce', '#fdd0a2', '#fdae6b', '#fd8d3c',
                        '#f16913', '#d94801', '#a63603', '#7f2704'],
          'Reds' => ['#fff5f0', '#fee0d2', '#fcbba1', '#fc9272', '#fb6a4a',
                     '#ef3b2c', '#cb181d', '#a50f15', '#67000d'],
          'Greys' => ['#ffffff', '#f0f0f0', '#d9d9d9', '#bdbdbd', '#969696',
                      '#737373', '#525252', '#252525', '#000000']
        }
      }

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
      }

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
      }
    end
  end
end

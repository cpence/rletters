'use strict';

// Build the global variables we need to get bootstrap going
window.jQuery = require('jquery');
window.Tether = require('tether');
require('bootstrap-loader');

// Require all of our jQuery plugins, which should just work given our
// use of ProvidePlugin
require('jquery-ujs');
require('jscroll');
require('nestable-fork');
import 'nestable-fork/src/jquery.nestable.css';
require('typeahead.js');
require('d3');

// Require all of our own code
require('../util');
require('../jobs');
require('../datasets');
require('../search');
require('../users');
require('../workflow');

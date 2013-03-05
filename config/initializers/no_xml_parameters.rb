# -*- encoding : utf-8 -*-

# Make extra certain that CVE-2013-0156 is fixed.
ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::XML)

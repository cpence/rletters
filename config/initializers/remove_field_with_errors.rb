# -*- encoding : utf-8 -*-
# The "field_with_errors" <div> tag messes up jQuery Mobile, remove it
ActionView::Base.field_error_proc = proc { |input, _| input }

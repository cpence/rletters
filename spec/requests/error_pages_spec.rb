# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Error pages" do

  it "renders the 404 template" do
    get_via_redirect "/asdf/notapage"

    response.code.to_i.should eq(404)
    response.should have_rendered('404')
  end

  it "renders the 500 template" do
    stub_request(:any, /127\.0\.0\.1/).to_timeout
    get_via_redirect "/search/"

    response.code.to_i.should eq(500)
    response.should have_rendered('500')
  end

end

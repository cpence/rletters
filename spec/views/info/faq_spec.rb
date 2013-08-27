# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'info/faq' do
  before(:each) do
    render
  end

  it 'does not include nested ul tags' do
    expect(rendered).to_not have_tag('ul > ul')
  end

  it 'has some faq questions' do
    expect(rendered).to have_tag('ul > li')
  end
end

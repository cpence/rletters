# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'export_citations/params' do

  before(:each) do
    register_job_view_path

    @dataset = FactoryGirl.create(:dataset)
  end

  it 'has links to all the document formats' do
    render

    Document.serializers.each do |k, v|
      link = url_for(controller: 'datasets',
                     action: 'task_start',
                     class: 'ExportCitations',
                     job_params: { format: k },
                     id: @dataset.to_param)

      expect(rendered).to have_tag("a[href='#{link}']")
    end
  end

end

# -*- encoding : utf-8 -*-
require 'spec_helper'

describe DatasetsHelper do

  describe '#render_job_partial' do
    it 'succeeds for a partial that is present' do
      expect(helper).to receive(:render).with(file: Rails.root.join('lib', 'jobs', 'analysis', 'views', 'plot_dates', '_start.html.haml').to_s)
      helper.render_job_partial(Jobs::Analysis::PlotDates, 'start')
    end

    it 'renders something reasonable for missing partials' do
      output = helper.render_job_partial(Jobs::Analysis::PlotDates, 'notapartial')
      expect(output).to start_with('<p>')
    end
  end

end

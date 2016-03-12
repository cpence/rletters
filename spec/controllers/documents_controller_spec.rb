require 'rails_helper'

RSpec.describe DocumentsController, type: :controller do
  describe '#export' do
    context 'when displaying as HTML' do
      it 'will not load' do
        get :export, params: { uid: generate(:working_uid) }
        expect(controller.response.response_code).to eq(406)
      end
    end

    context 'when exporting in other formats' do
      RLetters::Documents::Serializers::Base.available.each do |k|
        it "exports in #{k} format" do
          get :export, params: { uid: generate(:working_uid), format: k.to_s }
          expect(response).to be_valid_download(Mime::Type.lookup_by_extension(k).to_s)
        end
      end

      it 'fails to export an invalid format' do
        get :export, params: { uid: generate(:working_uid), format: 'csv' }
        expect(controller.response.response_code).to eq(406)
      end
    end
  end

  describe '#citeulike' do
    context 'when request succeeds' do
      it 'redirects to citeulike' do
        stub_connection(/www\.citeulike\.org/, 'citeulike')
        get :citeulike, params: { uid: 'doi:10.1371/journal.pntd.0000534' }
        expect(response).to redirect_to('http://www.citeulike.org/article/10443922')
      end
    end

    context 'when no documents are found' do
      it 'raises an exception' do
        stub_connection(/www\.citeulike\.org/, 'citeulike_failure')
        expect {
          get :citeulike, params: { uid: 'doi:10.1371/journal.pntd.0000534' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when request times out' do
      it 'raises an exception' do
        stub_request(:any, %r{www\.citeulike\.org/json/.*}).to_timeout

        expect {
          get :citeulike, params: { uid: 'doi:10.1371/journal.pntd.0000534' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end

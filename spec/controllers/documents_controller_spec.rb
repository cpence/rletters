# -*- encoding : utf-8 -*-
require 'spec_helper'

describe DocumentsController do
  describe '#export' do
    context 'when displaying as HTML' do
      it 'will not load' do
        get :export, uid: generate(:working_uid)
        expect(controller.response.response_code).to eq(406)
      end
    end

    context 'when exporting in other formats' do
      RLetters::Documents::Serializers::MIME_TYPES.each do |k|
        it "exports in #{k.to_s} format" do
          get :export, uid: generate(:working_uid), format: k.to_s
          expect(response).to be_valid_download(Mime::Type.lookup_by_extension(k).to_s)
        end
      end

      it 'fails to export an invalid format' do
        get :export, uid: generate(:working_uid), format: 'csv'
        expect(controller.response.response_code).to eq(406)
      end
    end
  end

  describe '#mendeley' do
    context 'when request succeeds' do
      before(:all) do
        Admin::Setting.mendeley_key = '5ba3606d28aa1be94e9c58502b90a49c04dc17289'
      end

      after(:all) do
        Admin::Setting.mendeley_key = ''
      end

      it 'redirects to Mendeley' do
        stub_connection(/api.mendeley.com/, 'mendeley')
        get :mendeley, uid: 'doi:10.1111/j.1439-0310.2008.01576.x'
        expect(response).to redirect_to('http://www.mendeley.com/catalog/choose-good-scientific-problem-1/')
      end
    end

    context 'when request times out' do
      before(:all) do
        Admin::Setting.mendeley_key = '5ba3606d28aa1be94e9c58502b90a49c04dc17289'
      end

      after(:all) do
        Admin::Setting.mendeley_key = ''
      end

      before(:each) do
        stub_request(:any, /api\.mendeley\.com\/.*/).to_timeout
      end

      it 'raises an exception' do
        expect {
          get :mendeley, uid: 'doi:10.1111/j.1439-0310.2008.01576.x'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#citeulike' do
    context 'when request succeeds' do
      it 'redirects to citeulike' do
        stub_connection(/www.citeulike.org/, 'citeulike')
        get :citeulike, uid: 'doi:10.1111/j.1439-0310.2008.01576.x'
        expect(response).to redirect_to('http://www.citeulike.org/article/3509563')
      end
    end

    context 'when request times out' do
      before(:each) do
        stub_request(:any, %r{www\.citeulike\.org/json/.*}).to_timeout
      end

      it 'raises an exception' do
        expect {
          get :citeulike, uid: 'doi:10.1111/j.1439-0310.2008.01576.x'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end

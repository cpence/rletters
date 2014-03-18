# -*- encoding : utf-8 -*-
require 'spec_helper'

describe SearchHelper do

  # This is a spec for /lib/core_ext/markdown_handler, but we need access to
  # helper.render, so we have to do this in a helper spec.
  context 'with a Markdown template including ERB' do
    before(:each) do
      @path = Rails.root.join('app', 'views', 'search', 'test_spec.md')
      $spec_markdown_global = 'things'
      File.open(@path, 'w') do |file|
        file.puts('# Testing <%= $spec_markdown_global %> #')
      end
    end

    after(:each) do
      File.delete(@path)
    end

    it 'renders the Markdown as expected' do
      html = helper.render file: @path

      expect(html).to be
      expect(html).to have_selector('h1', text: 'Testing things')
    end
  end

  describe '#document_bibliography_entry' do
    context 'when no user is logged in' do
      before(:each) do
        @doc = Document.find(FactoryGirl.generate(:working_uid))

        allow(helper).to receive(:current_user).and_return(nil)
        allow(helper).to receive(:user_signed_in?).and_return(false)
      end

      it 'renders the default template' do
        expect(helper).to receive(:render).with(partial: 'document',
                                                locals: { document: @doc })
        helper.document_bibliography_entry(@doc)
      end
    end

    context 'when the user has no CSL style set' do
      before(:each) do
        @doc = Document.find(FactoryGirl.generate(:working_uid))

        @user = FactoryGirl.create(:user)
        allow(helper).to receive(:current_user).and_return(@user)
        allow(helper).to receive(:user_signed_in?).and_return(true)
      end

      it 'renders the default template' do
        expect(helper).to receive(:render).with(partial: 'document',
                                                locals: { document: @doc })
        helper.document_bibliography_entry(@doc)
      end
    end

    context 'when the user has a CSL style set, for a normal document' do
      before(:each) do
        @doc = Document.find(FactoryGirl.generate(:working_uid))

        @csl_style = Users::CslStyle.find_by!(name: 'American Psychological Association 6th Edition')
        @user = FactoryGirl.create(:user, csl_style_id: @csl_style.id)
        allow(helper).to receive(:current_user).and_return(@user)
        allow(helper).to receive(:user_signed_in?).and_return(true)
      end

      it 'renders a CSL style' do
        expect_any_instance_of(RLetters::Documents::AsCSL).to receive(:entry).with(@csl_style).and_return('')
        helper.document_bibliography_entry(@doc)
      end
    end

    context 'when the user has a CSL style set, for a remote document' do
      before(:each) do
        @doc = Document.find('gutenberg:3172')

        @csl_style = Users::CslStyle.find_by!(name: 'American Psychological Association 6th Edition')
        @user = FactoryGirl.create(:user, csl_style_id: @csl_style.id)
        allow(helper).to receive(:current_user).and_return(@user)
        allow(helper).to receive(:user_signed_in?).and_return(true)
      end

      it 'renders a cloud icon' do
        expect_any_instance_of(RLetters::Documents::AsCSL).to receive(:entry).with(@csl_style).and_return('')
        html = helper.document_bibliography_entry(@doc)

        expect(html).to have_selector('span.fi-upload-cloud')
      end
    end
  end

end

# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe DocumentDecorator, type: :decorator do
  include Capybara::RSpecMatchers

  describe '#citation' do
    context 'when no user is logged in' do
      before(:example) do
        @doc = described_class.decorate(Document.find(generate(:working_uid)))

        allow(Draper::ViewContext.current).to receive(:current_user).and_return(nil)
        allow(Draper::ViewContext.current).to receive(:user_signed_in?).and_return(false)
      end

      it 'renders the default template' do
        expect(Draper::ViewContext.current).to receive(:render).with(
          partial: 'document',
          locals: { document: @doc })
        @doc.citation
      end
    end

    context 'when the user has no CSL style set' do
      before(:example) do
        @doc = described_class.decorate(Document.find(generate(:working_uid)))

        @user = create(:user)
        allow(Draper::ViewContext.current).to receive(:current_user).and_return(@user)
        allow(Draper::ViewContext.current).to receive(:user_signed_in?).and_return(true)
      end

      it 'renders the default template' do
        expect(Draper::ViewContext.current).to receive(:render).with(
          partial: 'document',
          locals: { document: @doc })
        @doc.citation
      end
    end

    context 'when the user has a CSL style set, for a normal document' do
      before(:example) do
        @doc = described_class.decorate(Document.find(generate(:working_uid)))

        @csl_style = Users::CslStyle.find_by!(name: 'American Psychological Association 6th Edition')
        @user = create(:user, csl_style_id: @csl_style.id)
        allow(Draper::ViewContext.current).to receive(:current_user).and_return(@user)
        allow(Draper::ViewContext.current).to receive(:user_signed_in?).and_return(true)
      end

      it 'renders a CSL style' do
        expect_any_instance_of(RLetters::Documents::AsCSL).to receive(:entry).with(@csl_style).and_return('')
        @doc.citation
      end
    end

    context 'when the user has a CSL style set, for a remote document' do
      before(:example) do
        @doc = described_class.decorate(Document.find('gutenberg:3172'))

        @csl_style = Users::CslStyle.find_by!(name: 'American Psychological Association 6th Edition')
        @user = create(:user, csl_style_id: @csl_style.id)
        allow(Draper::ViewContext.current).to receive(:current_user).and_return(@user)
        allow(Draper::ViewContext.current).to receive(:user_signed_in?).and_return(true)
      end

      it 'renders a cloud icon' do
        expect_any_instance_of(RLetters::Documents::AsCSL).to receive(:entry).with(@csl_style).and_return('')
        html = @doc.citation

        expect(html).to have_selector('span.fi-upload-cloud')
      end
    end
  end
end

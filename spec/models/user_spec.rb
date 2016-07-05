require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#valid' do
    context 'when no name is specified' do
      before(:example) do
        @user = build_stubbed(:user, name: nil)
      end

      it 'is not valid' do
        expect(@user).not_to be_valid
      end
    end

    context 'when no email is specified' do
      before(:example) do
        @user = build_stubbed(:user, email: nil)
      end

      it 'is not valid' do
        expect(@user).not_to be_valid
      end
    end

    context 'when a duplicate email is specified' do
      before(:example) do
        @dupe = create(:user)
        @user = build(:user, email: @dupe.email)
      end

      it 'is not valid' do
        expect(@user).not_to be_valid
      end
    end

    context 'when a bad email is specified' do
      before(:example) do
        @user = build(:user, email: 'asdf-not-an-email.com')
      end

      it 'is not valid' do
        expect(@user).not_to be_valid
      end
    end

    context 'when language is invalid' do
      before(:example) do
        @user = build_stubbed(:user, language: 'notalocaleCODE123')
      end

      it 'is not valid' do
        expect(@user).not_to be_valid
      end
    end

    context 'when all attributes are set correctly' do
      before(:example) do
        @user = create(:user)
      end

      it 'is valid' do
        expect(@user).to be_valid
      end
    end
  end

  describe '#workflow_dataset' do
    it 'raises for too-high values' do
      @user = create(:user, workflow_datasets: [])

      expect {
        @user.workflow_dataset(0)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raises for invalid values' do
      @user = create(:user, workflow_datasets: [999999])

      expect {
        @user.workflow_dataset(0)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'works for valid values' do
      @user = create(:user)
      @dataset = create(:dataset, user: @user)
      @user.workflow_datasets = [@dataset.to_param]
      @user.save

      expect(@user.workflow_dataset(0)).to eq(@dataset)
    end
  end

  describe '#csl_style' do
    it 'is nil if no csl_style_id is set' do
      @user = create(:user)
      expect(@user.csl_style).to be_nil
    end

    it 'is nil if an invalid csl_style_id is set' do
      @user = create(:user, csl_style_id: '999999')
      expect(@user.csl_style).to be_nil
    end

    it 'works for valid values' do
      @csl_style = create(:csl_style)
      @user = create(:user, csl_style_id: @csl_style.to_param)
      expect(@user.csl_style).to eq(@csl_style)
    end
  end
end

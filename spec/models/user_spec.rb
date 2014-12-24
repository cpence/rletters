require 'spec_helper'

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
        @user = build_stubbed(:user, email: @dupe.email)
      end

      it 'is not valid' do
        expect(@user).not_to be_valid
      end
    end

    context 'when a bad email is specified' do
      before(:example) do
        @user = build_stubbed(:user, email: 'asdf-not-an-email.com')
      end

      it 'is not valid' do
        expect(@user).not_to be_valid
      end
    end

    context 'when a non-numeric per_page is specified' do
      before(:example) do
        @user = build_stubbed(:user, per_page: 'asdfasdf')
      end

      it 'is not valid' do
        expect(@user).not_to be_valid
      end
    end

    context 'when a non-integer per_page is specified' do
      before(:example) do
        @user = build_stubbed(:user, per_page: 3.14159)
      end

      it 'is not valid' do
        expect(@user).not_to be_valid
      end
    end

    context 'when a negative per_page is specified' do
      before(:example) do
        @user = build_stubbed(:user, per_page: -20)
      end

      it 'is not valid' do
        expect(@user).not_to be_valid
      end
    end

    context 'when per_page is zero' do
      before(:example) do
        @user = build_stubbed(:user, per_page: 0)
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
end

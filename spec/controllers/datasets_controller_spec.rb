require 'spec_helper'

RSpec.describe DatasetsController, type: :controller do
  before(:example) do
    @user = create(:user)
    sign_in @user

    @dataset = create(:full_dataset, user: @user, working: true)
  end

  describe '#index' do
    context 'standard GET request' do
      context 'when not logged in' do
        before(:example) do
          sign_out :user
        end

        it 'redirects to the login page' do
          get :index
          expect(response).to redirect_to(root_path)
        end
      end

      context 'when logged in' do
        it 'loads successfully' do
          get :index
          expect(response).to be_success
        end
      end
    end

    context 'XHR GET request' do
      it 'loads successfully' do
        xhr :get, :index
        expect(response).to be_success
      end

      it 'assigns the list of datsets' do
        xhr :get, :index
        expect(assigns(:datasets)).to eq([@dataset])
      end

      it 'ignores disabled datasets' do
        create(:dataset, user: @user, name: 'Disabled', disabled: true)
        xhr :get, :index
        expect(assigns(:datasets)).to eq([@dataset])
      end
    end
  end

  describe '#new' do
    it 'loads successfully' do
      get :new
      expect(response).to be_success
    end

    it 'assigns dataset' do
      get :new
      expect(assigns(:dataset)).to be_new_record
    end
  end

  describe '#create' do
    context 'with no workflow active' do
      before(:context) do
        Resque.inline = false
      end

      after(:context) do
        Resque.inline = true
      end

      before(:example) do
        post :create, dataset: { name: 'Disabled Dataset' },
                      q: '*:*', fq: nil, def_type: 'lucene'
        @user.datasets.reload
      end

      after(:example) do
        Resque.remove_queue(:ui)
      end

      it 'creates a delayed job' do
        expect(Resque.size(:ui)).to eq(1)
      end

      it 'creates a skeleton dataset' do
        expect(@user.datasets.size).to eq(2)
      end

      it 'makes that dataset inactive' do
        expect(@user.datasets.active.size).to eq(1)

        expect(@user.datasets.inactive.size).to eq(1)
        expect(@user.datasets.inactive[0].name).to eq('Disabled Dataset')
      end

      it 'redirects to index when done' do
        expect(response).to redirect_to(datasets_path)
      end
    end

    context 'with an active workflow' do
      it 'redirects to the workflow activation when workflow is active' do
        @user.workflow_active = true
        @user.workflow_class = 'ArticleDates'
        @user.save

        post :create, dataset: { name: 'Disabled Dataset' },
                      q: '*:*', fq: nil, def_type: 'lucene'
        @user.datasets.reload

        expect(response).to redirect_to(workflow_activate_path('ArticleDates'))
        expect(flash[:success]).to be
      end
    end
  end

  describe '#show' do
    context 'without clear_failed' do
      it 'loads successfully' do
        get :show, id: @dataset.to_param
        expect(response).to be_success
      end

      it 'assigns dataset' do
        get :show, id: @dataset.to_param
        expect(assigns(:dataset)).to eq(@dataset)
      end
    end

    context 'with a disabled dataset' do
      before(:example) do
        @disabled = create(:dataset, user: @user, name: 'Disabled',
                                     disabled: true)
      end

      it 'raises an exception' do
        expect {
          get :show, id: @disabled.to_param
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with clear_failed' do
      before(:example) do
        create(:task, dataset: @dataset, failed: true)
        get :show, id: @dataset.to_param, clear_failed: true
      end

      it 'loads successfully' do
        expect(response).to be_success
      end

      it 'deletes the failed task' do
        expect(@dataset.tasks.failed).to be_empty
      end

      it 'sets the flash' do
        expect(flash[:notice]).not_to be_nil
      end
    end
  end

  describe '#destroy' do
    before(:context) do
      Resque.inline = false
    end

    after(:context) do
      Resque.inline = true
    end

    before(:example) do
      delete :destroy, id: @dataset.to_param
    end

    after(:example) do
      Resque.remove_queue(:ui)
    end

    it 'creates a delayed job' do
      expect(Resque.size(:ui)).to eq(1)
    end

    it 'redirects to the index when done' do
      expect(response).to redirect_to(datasets_path)
    end

    it 'disables the dataset' do
      @user.datasets.reload
      @dataset.reload

      expect(@user.datasets.active).to be_empty
      expect(@user.datasets.inactive.size).to eq(1)
      expect(@dataset.disabled).to be true
    end
  end

  describe '#update' do
    context 'when an invalid document is passed' do
      it 'raises an exception' do
        expect {
          patch :update, id: @dataset.to_param, uid: 'fail'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with a disabled dataset' do
      before(:example) do
        @disabled = create(:dataset, user: @user, name: 'Disabled',
                                     disabled: true)
      end

      it 'raises an exception' do
        expect {
          patch :update, id: @disabled.to_param, uid: generate(:working_uid)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when all parameters are valid' do
      it 'adds to the dataset' do
        expect {
          patch :update, id: @dataset.to_param, uid: generate(:working_uid)
        }.to change { @dataset.entries.count }.by(1)
      end

      it 'redirects to the dataset page' do
        patch :update, id: @dataset.to_param, uid: generate(:working_uid)
        expect(response).to redirect_to(dataset_path(@dataset))
      end
    end

    context 'with a remote document' do
      it 'sets the fetch flag' do
        expect(@dataset.fetch).to be false

        patch :update, id: @dataset.to_param, uid: 'gutenberg:3172'
        @dataset.reload

        expect(@dataset.fetch).to be true
      end
    end
  end
end

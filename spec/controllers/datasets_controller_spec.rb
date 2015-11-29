require 'rails_helper'

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
      it 'creates the dataset' do
        post :create, dataset: { name: 'New Dataset' },
                      q: '*:*', fq: nil, def_type: 'lucene'
        @user.datasets.reload

        expect(@user.datasets.size).to eq(2)

        d = @user.datasets.order(:created_at).last
        expect(d.name).to eq('New Dataset')
        expect(d.queries.size).to eq(1)
        expect(d.queries[0].q).to eq('*:*')
        expect(d.queries[0].def_type).to eq('lucene')
      end

      it 'redirects to index when done' do
        post :create, dataset: { name: 'New Dataset' },
                      q: '*:*', fq: nil, def_type: 'lucene'

        expect(response).to redirect_to(datasets_path)
      end
    end

    context 'with an active workflow' do
      before(:example) do
        @user.workflow_active = true
        @user.workflow_class = 'ArticleDates'
        @user.save!

        post :create, dataset: { name: 'New Dataset' },
                      q: '*:*', fq: nil, def_type: 'lucene'
        @user.reload.datasets.reload
      end

      after(:example) do
        @user.workflow_active = false
        @user.workflow_class = nil
        @user.workflow_datasets.clear
        @user.save!

        @user.reload
      end

      it 'links it and redirects to the workflow activation when workflow is active' do
        expect(response).to redirect_to(workflow_activate_path('ArticleDates'))
        expect(flash[:success]).to be
      end

      it 'links the dataset' do
        expect(@user.workflow_datasets.count).to eq(1)
        expect(@user.workflow_datasets[0]).to eq(@user.datasets.order(:created_at).last.to_param)
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
    it 'destroys the dataset' do
      delete :destroy, id: @dataset.to_param

      @user.datasets.reload
      expect(@user.datasets).to be_empty
    end

    it 'redirects to the index when done' do
      delete :destroy, id: @dataset.to_param
      expect(response).to redirect_to(datasets_path)
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

    context 'when all parameters are valid' do
      it 'adds to the dataset' do
        expect {
          patch :update, id: @dataset.to_param, uid: generate(:working_uid)
        }.to change { @dataset.reload.document_count }.by(1)
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

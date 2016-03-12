require 'rails_helper'

RSpec.describe AdminController, type: :controller do
  context 'when logged in' do
    before(:example) do
      @admin = create(:administrator)
      sign_in @admin
    end

    describe '#index' do
      it 'loads successfully' do
        get :index
        expect(response).to be_success
      end
    end

    describe '#collection_index' do
      context 'with a normal model' do
        before(:each) do
          @users = [create(:user), create(:user)]
          get :collection_index, params: { model: 'user' }
        end

        it 'loads successfully' do
          expect(response).to be_success
        end

        it 'assigns the model' do
          expect(assigns(:model)).to eq(User)
        end

        it 'assigns the collection' do
          expect(assigns(:collection)).to match_array(@users)
        end
      end

      context 'with a tree model' do
        before(:each) do
          @root_cat = create(:category)
          @child_cat = create(:category, parent_id: @root_cat.id)
          get :collection_index, params: { model: 'documents/category' }
        end

        it 'loads successfully' do
          expect(response).to be_success
        end

        it 'assigns the model' do
          expect(assigns(:model)).to eq(Documents::Category)
        end

        it 'assigns the roots as the collection' do
          expect(assigns(:collection)).to eq([@root_cat])
        end
      end
    end

    describe '#collection_edit' do
      context 'bulk delete' do
        before(:each) do
          @users = [create(:user), create(:user), create(:user)]
        end

        it 'works correctly' do
          id_0 = @users[0].id
          id_1 = @users[1].id
          id_2 = @users[2].id

          patch :collection_edit, params: { model: 'user',
                                            bulk_action: 'delete',
                                            ids: [id_0, id_2].to_json }
          expect(User.exists?(id_0)).to be false
          expect(User.exists?(id_1)).to be true
          expect(User.exists?(id_2)).to be false
        end
      end

      context 'tree edit' do
        before(:each) do
          @root_cat = create(:category)
          @child_cat = create(:category, parent_id: @root_cat.id)
        end

        it 'works correctly' do
          tree = [{'id' => @child_cat.to_param,
                   'children' => [{'id' => @root_cat.to_param}]}]

          patch :collection_edit, params: { model: 'documents/category',
                                            bulk_action: 'tree',
                                            tree: tree.to_json }

          @root_cat.reload
          @child_cat.reload

          expect(Documents::Category.roots.size).to eq(1)
          expect(Documents::Category.roots[0].id).to eq(@child_cat.id)
          expect(@child_cat.children.size).to eq(1)
          expect(@child_cat.children[0].id).to eq(@root_cat.id)
        end
      end

      context 'bad edit command' do
        it 'fails' do
          patch :collection_edit, params: { model: 'user', bulk_action: 'what' }
          expect(response.code.to_i).to eq(422)
        end
      end
    end

    describe '#item_index' do
      before(:each) do
        @user = create(:user)
        get :item_index, params: { model: 'user', id: @user.to_param }
      end

      it 'loads successfully' do
        expect(@response).to be_success
      end

      it 'assigns the model' do
        expect(assigns(:model)).to eq(User)
      end
    end

    describe '#item_new' do
      before(:each) do
        get :item_new, params: { model: 'user' }
      end

      it 'loads successfully' do
        expect(@response).to be_success
      end

      it 'assigns the model' do
        expect(assigns(:model)).to eq(User)
      end
    end

    describe '#item_create' do
      it 'works correctly' do
        attributes = attributes_for(:user)
        post :item_create, params: { model: 'user', item: attributes }

        expect(User.find_by(name: attributes[:name])).not_to be_nil
      end
    end

    describe '#item_delete' do
      it 'works correctly' do
        user = create(:user)

        expect {
          delete :item_delete, params: { model: 'user', id: user.to_param }
        }.to change { User.count }.by(-1)
      end
    end

    describe '#item_edit' do
      before(:each) do
        @user = create(:user)
        get :item_edit, params: { model: 'user', id: @user.to_param }
      end

      it 'loads successfully' do
        expect(@response).to be_success
      end

      it 'assigns the model' do
        expect(assigns(:model)).to eq(User)
      end
    end

    describe '#item_update' do
      it 'works correctly' do
        user = create(:user)
        patch :item_update, params: { model: 'user', id: user.to_param,
                                      item: { email: 'wat@wat.com' } }

        expect(user.reload.email).to eq('wat@wat.com')
      end
    end
  end

  # Que jobs are very odd models; double-check that everything actually
  # works
  context 'with Admin::QueJob' do
    before(:example) do
      @admin = create(:administrator)
      sign_in @admin
    end

    describe '#item_delete' do
      it 'works' do
        mock_que_job

        expect {
          delete :item_delete, params: { model: 'admin/que_job',
                                         id: Admin::QueJob.first.to_param }
        }.to change { Admin::QueJob.count }.by(-1)
      end
    end

    context 'bulk delete' do
      it 'works' do
        mock_que_job(1)
        mock_que_job(2)
        mock_que_job(3)

        patch :collection_edit, params: { model: 'admin/que_job',
                                          bulk_action: 'delete',
                                          ids: [1, 3].to_json }
        expect(Admin::QueJob.where(job_id: 1).count).to eq(0)
        expect(Admin::QueJob.where(job_id: 2).count).to eq(1)
        expect(Admin::QueJob.where(job_id: 3).count).to eq(0)
      end
    end
  end

  context 'when not logged in' do
    describe '#index' do
      it 'redirects to admin sign-in' do
        get :index
        expect(response).to redirect_to(new_administrator_session_path)
      end
    end

    describe '#collection_index' do
      it 'redirects to admin sign-in' do
        get :collection_index, params: { model: 'user' }
        expect(response).to redirect_to(new_administrator_session_path)
      end
    end

    describe '#collection_edit' do
      it 'redirects to admin sign-in' do
        user = create(:user)

        patch :collection_edit, params: { model: 'user',
                                          batch_action: 'delete',
                                          ids: "[#{user.to_param}]" }
        expect(response).to redirect_to(new_administrator_session_path)
      end

      it 'does not editing' do
        user = create(:user)

        expect {
          patch :collection_edit, params: { model: 'user',
                                            batch_action: 'delete',
                                            ids: "[#{user.to_param}]" }
        }.not_to change { User.count }
      end
    end

    describe '#item_index' do
      it 'redirects to admin sign-in' do
        user = create(:user)

        get :item_index, params: { model: 'user', id: user.to_param }
        expect(response).to redirect_to(new_administrator_session_path)
      end
    end

    describe '#item_new' do
      it 'redirects to admin sign-in' do
        get :item_new, params: { model: 'user' }
        expect(response).to redirect_to(new_administrator_session_path)
      end
    end

    describe '#item_create' do
      it 'redirects to admin sign-in' do
        post :item_create, params: { model: 'user',
                                     item: attributes_for(:user) }
        expect(response).to redirect_to(new_administrator_session_path)
      end

      it 'does no creating' do
        expect {
          post :item_create, params: { model: 'user',
                                       item: attributes_for(:user) }
        }.not_to change { User.count }
      end
    end

    describe '#item_delete' do
      it 'redirects to admin sign-in' do
        user = create(:user)

        delete :item_delete, params: { model: 'user', id: user.to_param }
        expect(response).to redirect_to(new_administrator_session_path)
      end

      it 'does no deleting' do
        user = create(:user)

        expect {
          delete :item_delete, params: { model: 'user', id: user.to_param }
        }.not_to change { User.count }
      end
    end

    describe '#item_edit' do
      it 'redirects to admin sign-in' do
        user = create(:user)

        get :item_edit, params: { model: 'user', id: user.to_param,
                                  user: { email: 'wat@wat.com' } }
        expect(response).to redirect_to(new_administrator_session_path)
      end
    end

    describe '#item_update' do
      it 'redirects to admin sign-in' do
        user = create(:user)

        patch :item_update, params: { model: 'user', id: user.to_param,
                                      user: { email: 'wat@wat.com' } }
        expect(response).to redirect_to(new_administrator_session_path)
      end

      it 'does no updating' do
        user = create(:user)

        expect {
          patch :item_update, params: { model: 'user', id: user.to_param,
                                        user: { email: 'wat@wat.com' } }
        }.not_to change { user.email }
      end
    end
  end
end

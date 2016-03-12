require 'rails_helper'

RSpec.describe ListsController, type: :controller do
  # We're not testing the views separately here, since what matters is how
  # the externally facing API works.
  render_views

  describe '#authors' do
    it 'loads successfully' do
      expect { get :authors }.not_to raise_error
    end

    it 'creates good JSON' do
      get :authors
      array = JSON.load(response.body)
      expect(array).to be_an(Array)

      array.each do |a|
        expect(a).to be_a(Hash)
        expect(a.keys).to eq(['val'])
      end

      expect(array).to satisfy { |a|
        a.find { |h| h['val'] == 'Peter J. Hotez' }
      }
    end

    it 'works with filter queries' do
      get :authors, params: { q: 'boel' }
      array = JSON.load(response.body)
      expect(array).to be_an(Array)

      expect(array).to satisfy { |a|
        a.find { |h| h['val'] == 'Marleen Boelaert' }
      }
      expect(array).not_to satisfy { |a|
        a.find { |h| h['val'] == 'Peter J. Hotez' }
      }
    end
  end

  describe '#journals' do
    it 'loads successfully' do
      expect { get :journals }.not_to raise_error
    end

    it 'creates good JSON' do
      get :journals
      array = JSON.load(response.body)
      expect(array).to be_an(Array)

      array.each do |a|
        expect(a).to be_a(Hash)
        expect(a.keys).to eq(['val'])
      end

      expect(array).to satisfy { |a|
        a.find { |h| h['val'] == 'PLoS Neglected Tropical Diseases' }
      }
    end

    it 'works with filter queries' do
      get :journals, params: { q: 'act' }
      array = JSON.load(response.body)
      expect(array).to be_an(Array)

      expect(array).to satisfy { |a|
        a.find { |h| h['val'] == 'Actually a Novel' }
      }
      expect(array).not_to satisfy { |a|
        a.find { |h| h['val'] == 'PLoS Neglected Tropical Diseases' }
      }
    end
  end
end

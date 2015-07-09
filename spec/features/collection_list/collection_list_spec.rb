# MMT-113

# In the future we need to add tests for 0 collections, 1 collection and multiple pages of collections.
# When we have more realistic data we also need to add tests for various counts of granules, and the proper formatting of those counts.

require 'rails_helper'

describe 'Collections List Display' do

  context 'when on home page and not logged in' do
    before :each do
      visit "/"
    end

    context 'when user clicks on provider name' do
      before :each do
        click_on 'Provider 1'
      end

      it 'shows the collection page and collection list' do
        expect(page).to have_content('Provider 1')
        expect(page).to have_content('[Provider description goes here]')
        expect(page).to have_css('table#collections')
        expect(page.find('table#collections')).to have_content('ACRIM III Level 2 Daily Mean Data V001')
        expect(page.find('table#collections')).to have_content('0')
      end
    end
  end

end

require 'rails_helper'

describe 'Bulk Updating Instruments' do
  before :all do
    _ingest_response, @find_and_remove_concept_response = publish_collection_draft
    _ingest_response, @find_and_update_concept_response = publish_collection_draft
  end

  before do
    login

    visit new_bulk_updates_search_path
  end

  context 'when previewing a Find & Remove bulk update', js: true do
    let(:bulk_update_name) { 'Bulk Update Instruments Test Find & Remove 001' }

    before do
      # Search collections
      select 'Entry Title', from: 'Search Field'
      find(:css, "input[id$='query_text']").set(@find_and_remove_concept_response.body['EntryTitle'])
      click_button 'Submit'

      # select search result
      check 'checkall'
      click_on 'Next'

      # Bulk Update form
      fill_in 'bulk_update_name', with: bulk_update_name
      select 'Instruments', from: 'Field to Update'
      select 'Find & Remove', from: 'Update Type'
      fill_in 'Short Name', with: 'LVIS'
      click_on 'Preview'
    end

    it 'displays the preview information' do
      expect(page).to have_content('Preview of New MMT_2 Bulk Update')

      expect(page).to have_content("Name #{bulk_update_name}")
      expect(page).to have_content('Field to Update Instruments')
      expect(page).to have_content('Update Type Find And Remove')
      within '.find-values-preview' do
        expect(page).to have_content('Short Name: LVIS')
      end

      within '.bulk-update-preview-table' do
        expect(page).to have_content(@find_and_remove_concept_response.body['EntryTitle'])
        expect(page).to have_content(@find_and_remove_concept_response.body['ShortName'])
      end
    end

    context 'when submitting the bulk update' do
      before do
        click_on 'Submit'

        # need to wait until the task status is 'COMPLETE'
        task_id = page.current_path.split('/').last
        wait_for_complete_bulk_update(task_id: task_id)

        # Reload the page, because CMR
        page.evaluate_script('window.location.reload()')
      end

      it 'displays the bulk update status page' do
        expect(page).to have_css('h2', text: bulk_update_name)

        within '.eui-info-box' do
          expect(page).to have_content('Status Complete')
          expect(page).to have_content('Field to Update Instruments')
          expect(page).to have_content('Update Type Find And Remove')
        end

        within '.find-values-preview' do
          expect(page).to have_content('Find Values to Remove')
          expect(page).to have_content('Short Name: LVIS')
        end
      end

      context 'when viewing the collection' do
        before do
          within '#bulk-update-status-table' do
            click_on @find_and_remove_concept_response.body['EntryTitle']
          end
        end

        it 'does not display the removed platform' do
          within '.platform-cards' do
            expect(page).to have_no_content('LVIS')

            expect(page).to have_content('ADS')
            expect(page).to have_content('ATM')
            expect(page).to have_content('SMAP L-BAND RADIOMETER')
          end
        end
      end
    end
  end

  context 'when previewing a Find & Update bulk update', js: true do
    let(:bulk_update_name) { 'Bulk Update Instruments Test Find & Update 002' }

    before do
      # Search collections
      select 'Entry Title', from: 'Search Field'
      find(:css, "input[id$='query_text']").set(@find_and_update_concept_response.body['EntryTitle'])
      click_button 'Submit'

      # select search result
      check 'checkall'
      click_on 'Next'

      # Bulk Update form
      fill_in 'bulk_update_name', with: bulk_update_name
      select 'Instruments', from: 'Field to Update'
      select 'Find & Update', from: 'Update Type'
      fill_in 'Short Name', with: 'ADS'
      # Select new Short Name from Select2
      find('.select2-container .select2-selection').click
      # I would prefer to choose 'ACOUSTIC SOUNDERS', but KMS does not provide a
      # Long Name for that value, and Bulk Update fails (until CMR-4552 is addressed).
      # So we need to choose a value that was already added
      find(:xpath, '//body').find('.select2-dropdown li.select2-results__option', text: 'ATM').click

      click_on 'Preview'
    end

    it 'displays the preview information' do
      expect(page).to have_content('Preview of New MMT_2 Bulk Update')

      expect(page).to have_content("Name #{bulk_update_name}")
      expect(page).to have_content('Field to Update Instruments')
      expect(page).to have_content('Update Type Find And Update')

      # Find Values to Update
      within '.find-values-preview' do
        expect(page).to have_content('Short Name: ADS')
      end

      # New Values
      within '.new-values-preview' do
        expect(page).to have_content('Short Name: ATM')
        expect(page).to have_content('Long Name: Airborne Topographic Mapper')
      end

      within '.bulk-update-preview-table' do
        expect(page).to have_content(@find_and_update_concept_response.body['EntryTitle'])
        expect(page).to have_content(@find_and_update_concept_response.body['ShortName'])
      end
    end

    context 'when submitting the bulk update' do
      before do
        click_on 'Submit'

        # need to wait until the task status is 'COMPLETE'
        task_id = page.current_path.split('/').last
        wait_for_complete_bulk_update(task_id: task_id)

        # Reload the page, because CMR
        page.evaluate_script('window.location.reload()')
      end

      it 'displays the bulk update status page' do
        expect(page).to have_css('h2', text: bulk_update_name)

        within '.eui-info-box' do
          expect(page).to have_content('Status Complete')
          expect(page).to have_content('Field to Update Instruments')
          expect(page).to have_content('Update Type Find And Update')
        end

        within '.find-values-preview' do
          expect(page).to have_content('Find Values to Update')
          expect(page).to have_content('Short Name: ADS')
        end

        within '.new-values-preview' do
          expect(page).to have_content('New Value')
          expect(page).to have_content('Short Name: ATM')
          expect(page).to have_content('Long Name: Airborne Topographic Mapper')
        end
      end

      context 'when viewing the collection' do
        before do
          within '#bulk-update-status-table' do
            click_on @find_and_update_concept_response.body['EntryTitle']
          end
        end

        it 'does not display the removed platform' do
          within '.platform-cards' do
            expect(page).to have_no_content('ADS')

            expect(page).to have_content('LVIS')
            expect(page).to have_content('SMAP L-BAND RADIOMETER')
            # We updated to a value that was already used, so want to make sure
            # it is now there twice.
            expect(page).to have_content('ATM', count: 2)
          end
        end
      end
    end
  end
end

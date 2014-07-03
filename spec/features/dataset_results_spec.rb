require "spec_helper"

describe "Dataset results", reset: false do
  before :all do
    load_page :search
    # scrolling in these specs doesn't work unless the window is resized
    page.driver.resize_window(1000, 1000)
  end

  after :each do
    click_on 'Clear Filters'
    wait_for_xhr
  end

  it "displays the first 20 datasets when first visiting the page" do
    expect(page).to have_css('#dataset-results-list .panel-list-item', count: 20)
  end

  it "loads more results when the user scrolls to the bottom of the current list" do
    expect(page).to have_css('#dataset-results-list .panel-list-item', count: 20)
    page.execute_script "$('#dataset-results .master-overlay-content')[0].scrollTop = 10000"
    wait_for_xhr

    # Featured datasets throws this off.  Normally it would be 40 (double the currently
    # loaded datasets.  Because of featured datasets, there are 22 currently loaded
    # datasets, so it requests the next 22, making for 44 total.  Since 2 are in the
    # featured list, that means there are 42 in the non-featured list.
    expect(page).to have_css('#dataset-results-list .panel-list-item', count: 42)

    # Reset
    load_page :search
  end

  it "does not load additional results after all results have been loaded" do
    fill_in "keywords", with: "AST"
    wait_for_xhr
    page.execute_script "$('#dataset-results .master-overlay-content')[0].scrollTop = 10000"
    wait_for_xhr
    expect(page).to have_css('#dataset-results-list .panel-list-item', count: 35)
    expect(page).to have_no_content('Loading datasets...')
    page.execute_script "$('#dataset-results .master-overlay-content')[0].scrollTop = 0"
  end

  it "displays thumbnails for datasets which have stored thumbnail URLs" do
    fill_in "keywords", with: 'C186815383-GSFCS4PA'
    wait_for_xhr
    expect(page).to have_css("img.panel-list-thumbnail")
    expect(page).to have_no_text("No image available")
  end

  it "displays a placeholder for datasets which have no thumbnail URLs" do
    fill_in "keywords", with: 'C179003030-ORNL_DAAC'
    wait_for_xhr
    expect(page).to have_no_css("img.panel-list-thumbnail")
    expect(page).to have_text("No image available")
  end

  # EDSC-145: As a user, I want to see how long my dataset searches take, so that
  #           I may understand the performance of the system
  it "shows how much time the dataset search took" do
    search_time_element = find('#dataset-results .panel-list-meta')
    expect(search_time_element.text).to match(/Search Time: \d+\.\d+s/)
  end

  context 'when clicking the "View dataset" button' do
    before(:all) do
      first_dataset_result.click_link "View dataset"
    end

    it 'highlights the "View dataset" button' do
      expect(page).to have_css('#dataset-results a[title="Hide dataset"].button-active', count: 1)
    end

    context 'and clicking back' do
      before(:all) { first_dataset_result.click_link "Hide dataset" }

      it "un-highlights the selected dataset" do
        expect(page).to have_no_css('#dataset-results a[title="Hide dataset"].button-active')
      end
    end
  end
end

require 'spec_helper'
# require 'rake'

describe "Item Locations should show correct library hours", :js => true do

  # I'm not sure... do I ever have to re-run the Rake tasks as part of the rspec?
  # before :all do
  #   Location.clear_and_load_fixtures!
  #   Rake.application.rake_require "tasks/solr_ingest"
  #   Rake.application.rake_require "tasks/sync_hours"
  #   Rake::Task.define_task(:environment)
  #   Rake.application.invoke_task "hours:sync"
  #   Location.clear_and_load_fixtures!
  # end

  it "for Avery Drawings & Archives" do
    # puts catalog_path('8277276')
    visit catalog_path('8277276')
    # page.save_and_open_page # debug
    page.should have_text('Avery Drawings & Archives')
    click_link('Avery Drawings & Archives - By appt. (Non-Circulating)')
    # page.save_and_open_page # debug
    page.should have_text('Avery Drawings & Archives')
    page.should have_link("Full Hours Info", :href=>"http://www.columbia.edu/cu/lweb/services/hours/index.html?library=avery-drawings-archives")
  end

  it "for Avery Classics" do
    visit catalog_path('565036')
    page.should have_text('Avery Classics')
    click_link('Avery Classics')
    page.should have_text('Avery Classics')
    page.should have_link("Floorplans", :href=>"http://library.columbia.edu/locations/avery/floorplans.html")    
    page.should have_link("Full Hours Info", :href=>"http://www.columbia.edu/cu/lweb/services/hours/index.html?library=avery-classics")
  end


  it "for Oral History Research Office" do
    visit catalog_path('4075929')
    page.should have_text('Oral History, 801 Butler')
    click_link('Oral History, 801 Butler')
    page.should have_text('Oral History')
    # page.save_and_open_page # debug
    page.should have_link("Home Page", :href=>"http://library.columbia.edu/locations/ccoh.html")
    page.should have_link("Full Hours Info", :href=>"http://www.columbia.edu/cu/lweb/services/hours/index.html?library=ccoh")
  end

end


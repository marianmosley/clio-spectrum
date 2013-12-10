require 'spec_helper'

describe "The home page" do
  it "should display search fields for archives, catalog, new arrivals, journals" do
    visit root_path
    page.should have_css(".search_box.catalog option")
    page.should have_css(".search_box.new_arrivals option")
    page.should have_css(".search_box.academic_commons option")
    page.should have_css(".search_box.journals option")
  end
end

require 'spec_helper'


describe 'Testing' do


  it "q of 'Buddhism' should get 8,500-10,500 results" do
    resp = solr_resp_doc_ids_only({'q'=>'Buddhism'})
    resp.should have_at_least(8500).documents
    resp.should have_at_most(10500).documents
  end



end
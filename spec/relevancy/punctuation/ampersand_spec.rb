require 'spec_helper'

describe "ampersands in queries" do

  shared_examples_for "ampersand ignored" do | q_with_amp, exp_ids, first_x |
    let(:q_no_amp) { q_with_amp.to_s.sub(' & ', ' ') }
    let(:resp) { solr_resp_ids_from_query(q_with_amp.to_s) }
    let(:presp) { solr_resp_ids_from_query("\"#{q_with_amp}\"") }
    let(:tresp) { solr_resp_doc_ids_only(title_search_args(q_with_amp)) }
    let(:ptresp) { solr_resp_doc_ids_only(title_search_args("\"#{q_with_amp}\"")) }
    it "should have great results for query" do
      resp.should include(exp_ids).in_first(first_x).documents
      presp.should include(exp_ids).in_first(first_x).documents
      tresp.should include(exp_ids).in_first(first_x).documents
      ptresp.should include(exp_ids).in_first(first_x).documents
    end
    it "should ignore ampersand in everything searches" do
      resp.should have_the_same_number_of_documents_as(solr_resp_ids_from_query(q_no_amp))
    end
    it "should ignore ampersand in everything phrase searches" do
      presp.should have_the_same_number_of_documents_as(solr_resp_ids_from_query("\"#{q_no_amp}\""))
    end
    it "should ignore ampersand in title searches" do
      tresp.should have_the_same_number_of_documents_as(solr_resp_doc_ids_only(title_search_args(q_no_amp)))
    end
    it "should ignore ampersand in title phrase searches" do
      ptresp.should have_the_same_number_of_documents_as(solr_resp_doc_ids_only(title_search_args("\"#{q_no_amp}\"")))
    end
  end

  context "2 term query 'Bandits & Bureaucrats'", :jira => 'VUF-831' do
    it_behaves_like "ampersand ignored", "Bandits & Bureaucrats", "1520976", 1
  end

  context "2 term query 'time & money'" do
    it_behaves_like "ampersand ignored", "time & money", "1677948", 2
  end

  context "3 term query 'of time & place' (former stopword 'of')" do
    it_behaves_like "ampersand ignored", "of time & place", "890516", 1
    it_behaves_like "ampersand ignored", "of time & place", ["890516", "5965634"], 6
  end 
  
  context "3 term query 'ESRI data & maps'", :jira=>'SW-85' do
    it_behaves_like "ampersand ignored", "ESRI data & maps", ["4997454", "4371369", "5563388", "6137735", "4998150", "3328665"], 15
  end

  context "3 term query 'Crystal growth & design'", :jira=>'VUF-1057' do
    it_behaves_like "ampersand ignored", "Crystal growth & design", "2832602", 1
  end

  context "3 term query 'Fish & Shellfish Immunology'", :jira=>'VUF-1100' do
    it_behaves_like "ampersand ignored", "Fish & Shellfish Immunology", "3325997", 3
  end 
  
  context "3 term query 'Environmental Science & Technology'", :jira=>'VUF-1150' do
    it_behaves_like "ampersand ignored", "Environmental Science & Technology", "400913", 1
  end

  context "4 term query title search 'horn violin & piano'" do
    it_behaves_like "ampersand ignored", "horn violin & piano", ["1380582", "1760603"], 4
  end 

  context "4 term query 'crosby stills nash & young'" do
    it_behaves_like "ampersand ignored", "crosby stills nash & young", "8303979", 3
  end

  context "4 term query 'steam boat & canal routes'" do
    it_behaves_like "ampersand ignored", "steam boat & canal routes", "6413229", 1
  end 
  
  context "5 term query 'horns, violins, viola, cello & organ'" do
    it_behaves_like "ampersand ignored", "horns, violins, viola, cello & organ", "1954454", 1
  end 
  
  context "5 term query 'the truth about cats & dogs' (former stopword 'the')" do
    it_behaves_like "ampersand ignored", "the truth about cats & dogs", "1254850", 1
  end
  
  context "5 term query 'anatomy of the dog & cat' (former stopwords 'of', 'the')" do
    it_behaves_like "ampersand ignored", "anatomy of the dog & cat", "3324413", 1
  end 

  context "6 term query 'horns, violins, viola, cello & organ continuo'" do
    it_behaves_like "ampersand ignored", "horns, violins, viola, cello & organ continuo", "6438612", 1
  end

  context "6 term query 'Dr. Seuss & Mr. Geisel : a biography' (former stopword 'a')" do
    it_behaves_like "ampersand ignored", "Dr. Seuss & Mr. Geisel : a biography", "2997769", 1
  end 

  context "6 term query 'Zen & the Art of Motorcycle Maintenance' (former stopwords 'of', 'the')" do
    it_behaves_like "ampersand ignored", "Zen & the Art of Motorcycle Maintenance", ["718905", "160242"], 5
  end 

  context "7 term query 'Practical legal problems in music & recording industry' (former stopword 'in')" do
    it_behaves_like "ampersand ignored", "Practical legal problems in music & recording industry", "2101314", 1
  end

  context "multiple ampersands: 'Bob & Carol & Ted & Alice'" do
    it_behaves_like "ampersand ignored", "Bob & Carol & Ted & Alice", "6937449", 1
  end

end
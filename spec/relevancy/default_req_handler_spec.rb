require 'spec_helper'

describe "Default Request Handler" do
  
  it "q of 'Buddhism' should get 8,500-10,500 results", :jira => 'VUF-160' do
    resp = solr_resp_ids_from_query 'Buddhism'
    resp.should have_at_least(15000).documents
    resp.should have_at_most(20000).documents
  end
  
  it "q of 'String quartets Parts' and variants should be plausible", :jira => 'VUF-390' do
    resp = solr_resp_ids_from_query 'String quartets Parts'
    resp.should have_at_least(600).documents
    resp.should have_the_same_number_of_results_as(solr_resp_ids_from_query('(String quartets Parts)'))
    resp.should have_more_results_than(solr_resp_ids_from_query('"String quartets Parts"'))
  end
  
  it "q of 'french beans food scares' should get specific match and non-match" do
    resp = solr_resp_ids_from_query 'french beans food scares'
    resp.should include("4919441")
    resp.should include("5562843")
    resp.should include("5355592")
  end
  
  it "matches in title should sort first - waffle" do
    resp = solr_resp_ids_from_query 'waffle'
    resp.should include("3100237").as_first_result
    resp.should include("1985702").before("3023395")
    resp.should include("1985702").before("4499268")
  end
  
  it "matches in title should sort first - memoirs of a physician" do
    resp = solr_resp_ids_titles_from_query 'memoirs of a physician'
    resp.should include("title_display" => /memoirs of a physician/i).in_each_of_first(2).documents
  end

  it "like titles should appear together in result" do
    resp = solr_resp_ids_from_query 'wanderlust'
    resp.should include(['2352854', '9148277', '8873733', '2995657', '8329024']).in_first(10)
  end

  it "single result expected: 'jill kerr conway' " do
    resp = solr_resp_ids_from_query 'jill kerr conway'
    resp.should have_at_most(0).results
    # resp.should include("4735430").as_first_result
    resp2 = solr_resp_doc_ids_only({'q'=>'jill k. conway'})
    resp.should have_fewer_results_than(resp2)
  end
  
  it "single character as term: 'jill k conway' " do
    resp = solr_resp_ids_from_query 'jill k. conway'
    resp.should include("3125003")
    resp.should have_the_same_number_of_results_as(solr_resp_ids_from_query('jill k conway'))
    resp.should have_the_same_number_of_results_as(solr_resp_ids_from_query('k conway jill'))
  end
  
  it "history of the jews by paul johnson" do
    resp = solr_resp_ids_from_query 'history of the jews by paul johnson'
    resp.should include(["3377816", "566421", "4460418"]).in_first(5).results
  end

  it "'call of the wild'" do
    resp = solr_resp_ids_titles({'q'=>'call of the wild', 'rows'=>'30'})
    resp.should include('title_display' => /call of the wild/i).in_each_of_first(15).documents
    # below have it in 245a
    resp.should include(['1701281', '418858', '7156431', '2540319', '4679802',
                        '4814618', '1524114', '2650763', '43004', '4228824']).in_first(30).documents
  end

  it "searches should not be case sensitive" do
    resp = solr_resp_ids_from_query 'harry potter'
    resp.should have_the_same_number_of_results_as(solr_resp_ids_from_query('Harry Potter'))
    resp.should have_the_same_number_of_results_as(solr_resp_ids_from_query('Harry potter'))
    resp.should have_the_same_number_of_results_as(solr_resp_ids_from_query('harry Potter'))
    resp.should have_the_same_number_of_results_as(solr_resp_ids_from_query('hArRy pOTTEr'))
  end

  context "world atlas of coral reefs" do
    it "World atlas of coral reefs" do
      resp = solr_resp_ids_from_query 'World atlas of coral reefs'
      resp.should include('3125436').as_first
      resp.should include('3271118')
    end    
  end
  
  # marquis - I can't find an example of this at Columbia.
  # 
  # it "exact match in 245a should be first results: 'search'", :jira => ['VUF-212', 'SW-64'] do
  #   #  There are two records:  4216963, 4216961  that have the word "search" in the 245, 
  #   # and also have the word "search" in the 880 vernacular 245 field. 
  #   # Because the term appears twice:  in the 245a and the corresponding 880a, 
  #   #   these records have been appearing first.
  #   resp = solr_resp_ids_from_query 'search'
  #   match_245a = ['8833422', '394764', '6785774', '2641095', '3335969', '9666416', '457493', '7547799', '1656104', '9218024']
  #   resp.should include(match_245a).before("4216963") # has 880 245a with search
  #   resp.should include(match_245a).before("4216961") # has 880 245a with search
  # end

  it "Lectures on the Calculus of Variations and Optimal Control Theory" do
    resp = solr_resp_ids_titles_from_query 'Lectures on the Calculus of Variations and Optimal Control Theory'
    resp.should include('1545997').as_first
    resp.should_not include("title_display" => /Shape optimization and optimal design/i).in_each_of_first(10)
    resp.should have_at_most(50).results
  end

  it "death and taxes" do
    resp = solr_resp_ids_titles_from_query 'death and taxes'
    resp.should include('title_display' => /^death and taxes$/i).in_each_of_first(5)
  end
  
  it "way we never were" do
    resp = solr_resp_ids_titles_from_query 'way we never were'
    resp.should include('title_display' => /way we never were/i).as_first
  end
  
  it "united states code" do
    resp = solr_resp_ids_titles_from_query 'united states code'
    resp.should include("title_display" => /^united states code$/i).in_each_of_first(4)
    resp.should include(['8526798', '8526808', '4348634', '8526779', '8526781']).in_first(10)
  end
  
  it "zeitschrift" do
    resp = solr_resp_ids_titles_from_query 'Zeitschrift'
    resp.should include(['9436404', '9094058', '9509166']).in_first(10) # has 245a of Zeitschrift
    resp.should include('title_display' => /^zeitschrift$/i).in_each_of_first(15)
    resp.should have_at_least(7000).results
  end
  
  context "first chalk talk, July 21, 2011" do
    # really from https://consul.stanford.edu/display/NGDE/SearchWorks+201+Backnoise+chatter
    it "vitamin A" do
      # 64
      resp = solr_resp_ids_titles_from_query 'Vitamin A'
      resp.should have_at_least(600).results
      resp.should include('title_display' => /^vitamin a\.?$/i).in_each_of_first(2)
      resp.should include('title_display' => /vitamin a/i).in_each_of_first(20)
    end
    it "humanities 21st century america english" do
      # 70
      resp = solr_resp_ids_from_query('humanities 21st century america english')
      resp.should have_at_most(2).results
    end
  end
  
  it "happiness, a history" do
    resp = solr_resp_ids_from_query 'happiness a history'
    resp.should include(['6816289', '5511057']).in_first(3)
  end
  
  it "should allow barcode searches", :jira => 'SW-682' do
    resp = solr_resp_ids_from_query '36105041286266'
    resp.should include('2029735').as_first
    resp.should have_at_most(3).results
  end
  
  it "the atomic" do
    resp = solr_resp_ids_titles_from_query 'the atomic'
    resp.should have_at_least(2500).results
    resp.should include('title_display' => /the atomic/i).in_each_of_first(20).documents
#    resp.should include('title_display' => /^the atomic/i).in_each_of_first(20).documents  # works with Solr 3.6 dismax
  end

  it "atomic bomb" do
    resp = solr_resp_ids_titles_from_query 'atomic bomb'
    resp.should have_at_least(200).results
    resp.should include('title_display' => /atomic bomb/i).in_each_of_first(20).documents
    resp.should include('title_display' => /^atomic bomb$/i).in_each_of_first(1).documents
  end

  it "the atomic bomb" do
    resp = solr_resp_ids_titles_from_query 'the atomic bomb'
    resp.should have_at_least(900).results
    resp.should include('title_display' => /the atomic bomb/i).in_each_of_first(20).documents
    # Columbia has no item titled simply "The Atomic Bomb"
    # resp.should include('title_display' => /^the atomic bomb$/i).in_each_of_first(3).documents
    resp.should include('title_display' => /^the atomic bomb/i).in_each_of_first(10).documents
  end
  
  it "price of sex" do
    resp = solr_resp_ids_from_query 'price of sex'
    resp.should include('9177285').as_first
    resp.should have_at_least(200).results
  end
  
  it "on the road" do
    resp = solr_resp_ids_titles_from_query 'on the road'
    resp.should have_at_least(14500).results
    resp.should include('title_display' => /^on the road\W*$/i).in_each_of_first(15).documents
  end
  
  it "war and peace" do
    resp = solr_resp_ids_titles_from_query 'war and peace'
    resp.should have_at_least(13500).results
    resp.should include('title_display' => /^war and peace$/i).in_each_of_first(20).documents
  end
  
  it "history of cartography" do
    resp = solr_resp_ids_titles_from_query 'history of cartography'
    resp.should have_at_least(850).results
    resp.should include('title_display' => /^history of cartography$/i).in_each_of_first(4).documents
    resp.should include('title_display' => /^(the )?history of cartography$/i).in_each_of_first(5).documents
  end

end
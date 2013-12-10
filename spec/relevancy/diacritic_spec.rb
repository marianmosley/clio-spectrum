# encoding: UTF-8
# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Diacritics" do
    
  it "Acute Accent é", :jira => 'VUF-106' do
    resp = solr_resp_doc_ids_only({'q'=>'étude'})
    resp.should include(["115185", "1052447"])
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'etude'}))
  end
  
  it "Grave à" do
    resp = solr_resp_doc_ids_only({'q'=>'verità'})
    resp.should include(["448749", "421932"])
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'verita'}))
  end
  
  context "Umlaut" do
    it "ä (German)" do
      resp = solr_resp_doc_ids_only({'q'=>'Ränsch-Trill'})
      resp.should include("1352750")
      resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'Ransch-Trill'}))
    end
    it "ü (Turkish)", :xfocus => true do
      resp = solr_response({'q'=>"Türkiye'de üniversite", 'fl'=>'id,title_display', 'facet'=>false, :rows => 1})
      # resp.should have_at_least(8).documents
      # resp.should include("title_display" => /T[üu]rkiye'de [üu]niversite/i).in_each_of_first(2).documents
      resp.should include("title_display" => /\p{Any}niversite ve siyaset/i).in_each_of_first(1).documents
      resp.should include("title_display" => /universite ve siyaset/i).in_each_of_first(1).documents
      resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>"Turkiye'de universite"}))
    end
  end
  
  it "Circumflex ê" do
    resp = solr_resp_doc_ids_only({'q'=>'ancêtres'})
    resp.should include("548657")
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'ancetres'}))
  end
  
  it "Tilde ñ" do
    resp = solr_resp_doc_ids_only({'q'=>'Muñoz'})
    resp.should include(["5451940", "3149663", "5623871"])
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'munoz'}))
  end
  
  it "Cedilla ç" do
    resp = solr_resp_doc_ids_only({'q'=>'exaltação'})
    resp.should have_documents
    resp.should include(["3363604", "1515557"])
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'exaltacao'}))
  end
  
  context "Russian ligature ͡ " do
    it "tysi͡acha" do
      resp = solr_resp_doc_ids_only({'q'=>'tysi͡acha'})
      resp.should have_documents
      resp.should include(["7801896", "2248336"])
      resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'tysiacha'}))
    end
    it "Fevralʹskogo" do
      resp = solr_resp_doc_ids_only({'q'=>'Fevralʹskogo'})
      resp.should have_at_least(5).documents
      resp.should include(["2503153", "2986472"])
      resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'Fevralskogo'}))
      # not designed to work with apostrophe substitution, esp. as apostrophe is Solr operator
#      resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>"Fevral'skogo"}))
    end
  end
  
  it "Soft Znak ś" do
    # cyrillic: Восемьсoт
    resp = solr_resp_doc_ids_only({'q'=>'vosemśot'})
    resp.should have_documents
    resp.should include(["2989530", "2987816"])
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'vosemʹsot'}))
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>"vosemsot"}))
  end
  
  it "Hard Znak ̋" do
    resp = solr_resp_doc_ids_only({'q'=>'Obe̋dinenie'})
    resp.should have_documents
    resp.should include(["6937833", "6269750"])
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'Obʺedinenie'}))
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'Obedinenie'}))
  end
  
  it "Caron ť" do
    resp = solr_resp_doc_ids_only({'q'=>'povesť'})
    resp.should have_documents
    resp.should include(["968216", "2574766"])
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>"povest'"}))
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'povest'}))
  end
  
  it "Caron ǔ (Latvian)" do
    resp = solr_resp_doc_ids_only({'q'=>'Latviesǔ'})
    resp.should have_documents
    resp.should include(["140729", "1170562"])
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>"Latviesu'"}))
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'Latviesu'}))
  end
  
  it "Ogonek ą" do
    resp = solr_resp_doc_ids_only({'q'=>'gąszczu'})
    resp.should have_documents
    resp.should include(["383890"])
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>"gaszczu'"}))
  end
  
  it "Overdot Ż" do
    resp = solr_resp_doc_ids_only({'q'=>'Żydów'})
    resp.should have_documents
    resp.should include(["299610", "8962046"])
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>"zydow'"}))
  end

  context "macron" do
    it "ī (russian)" do
      resp = solr_resp_doc_ids_only({'q'=>'istorīi'})
      resp.should have_documents
      resp.should include(["6033554", "5201390"])
      resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>"istorii'"}))
    end
    it "ō" do
      resp = solr_resp_doc_ids_only({'q'=>'Kuginuki, Tōru'}) 
      resp.should have_documents
      resp.should include(["6489325"])
      resp2 = solr_resp_doc_ids_only({'q'=>'Kuginuki, Toru'})
      resp2.should have_the_same_number_of_results_as(resp)
      resp.should have_documents
      resp.should include(["6489325"])
    end
    it "ū" do
      resp = solr_resp_doc_ids_only({'q'=>'Rekishi yūgaku'})
      resp.should have_documents
      resp.should include(["3799036", "10278914"])
      resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'Rekishi yugaku'}))
    end
    it "ē Greek" do
      resp = solr_resp_doc_ids_only({'q'=>'Tsiknakēs'})
      resp.should include(["9284968", "2255939"])
      resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'Tsiknakes'}))
    end
    it "ō Greek" do
      resp = solr_resp_doc_ids_only({'q'=>'Kōstas'})
      resp.should have_documents
      resp.should include(["2276100", "5045489"])
      resp.should have_at_least(600).documents
      resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'Kostas'}))
    end
  end
  
  it "Kreska Ṡ" do
    resp = solr_resp_doc_ids_only({'q'=>'Ṡpiewy polskie'})
    resp.should include(["10322533", "1665603"])
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'Spiewy polskie'}))
  end
  
  it "d with crossbar lower case" do
    resp = solr_resp_doc_ids_only({'q'=>'Tuđina'})
    resp.should include(["1752198"]).in_first(1).documents
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'Tudina'}))
  end

  context "Polish chars Ż ł ó" do
    it "ł in Białe usta" do
      resp = solr_resp_doc_ids_only({'q'=>'Białe usta'})
      resp.should include("655277").in_first(1).results
      resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'Biale usta'}))
    end
    
    it "Żuławy dziejów " do
      resp = solr_resp_doc_ids_only({'q'=>'Żuławy dziejów'})
      resp.should have_documents
      resp.should include(["580681"])
      resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'Zulawy dziejow'}))
    end
  end
  
  it "Hebrew transliteration Ḥ" do
    resp = solr_resp_doc_ids_only({'q'=>'le-Ḥayim', 'rows'=>'20'})
    resp.should include(["3179609", "1115595"])
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'le-Hayim'}))
  end

  it "Hebrew script vowels (e.g. in  סֶגוֹל)" do
    resp = solr_resp_doc_ids_only({'q'=>'סֶגוֹל'})
    resp.should have_documents
    resp.should include(["6701662", "663318"])
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'סגול'}))
  end
  
  it "Arabic script دَ" do
    resp = solr_resp_doc_ids_only({'q'=>  "دَ" })
    resp.should have_documents
    resp.should have_at_least(1000).documents
    # sent email to John Eilts 2010-08-22  for better test search examples
    # resp.should include("4776517")
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=> "د" }))
  end
  
  it "Arabic script alif with diacritics" do
    resp = solr_resp_doc_ids_only({'q'=> "أ" })
    resp.should have_documents
    resp.should include(["8928917", "6002900"])
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>  "أ" }))
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=> "ـأ" }))
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>  "أ" }))
  end
  # marquis - can't find Columbia example, omit until it's an issue.
  # it "Arabic alif variantإ", :jira => 'SW-719' do
  #   resp = solr_resp_doc_ids_only({'q'=> "إمام السفينة" })
  #   resp.should have_documents
  #   resp.should include(["8928917", "6002900"])
  #   resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>  "امام السفينة" }))
  # end
  
  it "Greek ῆ" do
    resp = solr_resp_doc_ids_only({'q'=>'τῆς'})
    resp.should have_documents
    resp.should include(["9519025", "6095137"])
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'της'}))
  end
  
  context "Turkish ı (undotted i) (Unicode U+0131)" do
    it "Batı" do
      resp = solr_resp_doc_ids_only({'q'=>'Batı'})
      resp.should have_at_least(200).documents
      resp.should have_documents
      resp.should include(["3375329", "3375393"])
      resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'Bati'}))
    end
    it "Vakıflar dergisi" do
      resp = solr_resp_doc_ids_only({'q'=>'Vakıflar dergisi'})
      resp.should have_at_least(2).documents
      resp.should include(["404258", "743519"]).as_first(2).documents
      resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'Vakiflar dergisi'}))
    end
    it "anlayısının" do
      resp = solr_response({'q'=>"anlayısının", 'fl'=>'id,title_display', 'facet'=>false})
      resp.should have_at_least(4).documents
      resp.should include(["2400801", "6617483"])
      resp.should include("title_display" => /anlay[ıi][sş][ıi]n[ıi]n/i).in_each_of_first(2).documents
      resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>"anlayisinin"}))
    end    
  end
  
  it "Turkish ğ" do
    resp = solr_resp_doc_ids_only({'q'=>'Doğu'})
    resp.should have_at_least(500).documents
    resp.should include("5532993").in_first(10).documents # "title_display":"Doğu Batı",
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'Dogu'}))
  end
  
  it "Turkish ş" do
    # resp = solr_response({'q'=>"gelişimi", 'fl'=>'id,title_display', 'rows' => '25', 'facet'=>false})
    resp = solr_resp_ids_titles_from_query 'gelişimi'
    resp.should have_at_least(40).documents
    # target content may be in subtitle_display
    resp.should include("title_display" => /geli[şs]imi/i).in_each_of_first(5).documents
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>"gelisimi"}))
  end
  
  context "Icelandic  ðýþ" do
    it "Đ, ð (d with crossbar)" do
      resp = solr_resp_doc_ids_only({'q'=>'Điðriks'})
      resp.should include(["2357272"])
      resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'Diðriks'}))
      resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'ðiðriks'}))
    end
    it "Þ, þ (thorn)" do
      resp = solr_resp_doc_ids_only({'q'=>'Þiðriks'})
      resp.should have_at_least(20).documents
      resp.should include(["4319047", "657426"])
      resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'þiðriks'}))
    end
    it "Ý, ý " do
      resp = solr_resp_doc_ids_only({'q'=>'lýginnar'})
      resp.should include(["5362447"])
      resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'lyginnar'}))
    end
  end
  
# marquis - Hunh?  Removing.
#   it "@o" do
#     resp = solr_resp_doc_ids_only({'q'=>'@oEtudes @oeconomiques'})
#     resp.should include("386893").as_first
# #    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'Etudes economiques'}))
#   end
    

  it "Ae ligature uppercase Æ" do
    resp = solr_resp_doc_ids_only({'q'=>'Æon'})
    resp.should have_at_least(100).documents
    resp.should include(["6271238"])
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'AEon'}))
  end 

  it "ae ligature lowercase æ" do
    resp = solr_resp_doc_ids_only({'q'=>'Encyclopædia'})
    resp.should have_at_least(2000).documents
    resp.should include(["8288262"])
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'Encyclopaedia'}))
  end

  it "oe ligature lowercase œ" do
    resp = solr_resp_doc_ids_only({'q'=>'Cœur'})
    resp.should have_at_least(2000).documents
    resp.should include(["3996937", "2608667"])
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'Coeur'}))
  end

  it "Vietnamese (Từ điẻ̂n Việt )" do
    resp = solr_resp_doc_ids_only({'q'=>'Từ điẻ̂n Việt'})
    resp.should include(["5447608", "5447578", "3701957", "1899428"])
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'Tu dien viet'}))
    # variant diacritics...
    # resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>'Tụ̆-diĕ̂n Việt'}))
  end 

  it "ʻ (Korean)" do
    resp = solr_resp_doc_ids_only({'q'=>"Yi Tʻae-jun"})
    resp.should have_at_least(50).documents
    resp.should include(["6866385", "3740444"])
    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>"Yi Tae-jun"}))
#    resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>"yi tae-jun"}))
  end

  context "music  ♯ and  ♭" do
    # see also synonyms_spec
    it "♭ vs. b", :jira => ['SW-648'] do
      resp = solr_resp_doc_ids_only({'q'=>"Concertos, horn, orchestra, K. 417, E♭ major"})
      resp.should have_at_least(70).documents
      resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>"Concertos, horn, orchestra, K. 417, Eb major"}))
    end
    it "♯ vs #"do
      resp = solr_resp_doc_ids_only({'q'=>"Symphonies, no. 5, C♯ minor"})
      resp.should have_at_least(45).documents
      resp.should have_the_same_number_of_results_as(solr_resp_doc_ids_only({'q'=>"Symphonies, no. 5, C# minor"}))
    end
  end

end
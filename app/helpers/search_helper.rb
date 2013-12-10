#encoding: UTF-8
module SearchHelper
  def show_all_search_boxes
    (controller.controller_name == 'search' && controller.action_name == 'index') || (params['q'].to_s.empty?  && params['s.q'].to_s.empty? && params['commit'].to_s.empty?)
  end

  def active_search_box
    con = controller.controller_name
    act = controller.action_name

    if con == 'search' && act == 'index'
      "quicksearch"
    elsif act == 'ebooks' || con == 'ebooks'
      'ebooks'
    else
      @active_source
    end
  end


  def search_render_options(search, source)
    opts ={'template' => @search_style}.
        merge(source['render_options'] || {}).
        merge(search['render_options'] || {})
    opts['count'] = search['count'].to_i if search['count']
    opts
  end

  def dropdown_with_select_tag(name, field_options, field_default = nil, *html_args)
    dropdown_options = html_args.extract_options!

    dropdown_default = field_options.invert[field_default] || field_options.keys.first
    select_options = dropdown_options.delete(:select_options) || {}

    result = render(:partial => "/dropdown_select", :locals => { name: name, field_options: field_options, dropdown_options: dropdown_options, field_default: field_default, dropdown_default: dropdown_default, select_options: select_options })
  end

  def display_search_boxes(source)
    render(:partial => "/_search/search_box", :locals => {source: source})
  end


  def display_advanced_search(source)
    options = DATASOURCES_CONFIG['datasources'][source]['search_box'] || {}
    blacklight_config = Spectrum::Engines::Solr.generate_config(source)
    if options['search_type'] == "blacklight" && options['advanced'] == true
      return fix_catalog_links(render('/catalog/advanced_search', :localized_params => params), source)
    end
    if options['search_type'] == "summon" && options['advanced'] == true
      # Rails.logger.debug "display_advanced_search() source=[#{source}]"
      return render '/spectrum/summon/advanced_search', source: source, path: source == "articles" ? articles_index_path : newspapers_index_path
    end
  end

  def display_search_form(source)
    options = DATASOURCES_CONFIG['datasources'][source]['search_box'] || {}

    search_params = determine_search_params
    div_classes = ["search_box", source]
    div_classes << "multi" if show_all_search_boxes
    div_classes << "selected" if active_search_box == source


    result = "".html_safe
    if show_all_search_boxes || active_search_box == source
      has_options = (options['search_type'].in?("blacklight","summon") ? "search_q with_options" : "search_q without_options")

      # BASIC SEARCH INPUT BOX
      summon_query_as_hash = {}
      if @results.kind_of?(Hash) && @results.values.first.instance_of?(Spectrum::Engines::Summon)
        # when summon fails, these may be nil
        if @results.values.first.search && @results.values.first.search.query
          summon_query_as_hash = @results.values.first.search.query.to_hash
        end
      end
      result += text_field_tag(:q,
          search_params[:q] || summon_query_as_hash['s.q'] || '',
          class: has_options, id: "#{source}_q", placeholder: options['placeholder'])

      ### for blacklight (catalog, academic commons)
      if options['search_type'] == "blacklight"
        # insert hidden fields
        result += standard_hidden_keys_for_search
        # insert drop-down
        if options['search_fields'].kind_of?(Hash)
          result += dropdown_with_select_tag(:search_field, options['search_fields'].invert, h(search_params[:search_field]), :title => "Targeted search options", :class=>"search_options")
        end

      ### for summon (articles, newspapers)
      elsif options['search_type'] == "summon"
        # insert hidden fields
        # If we're at the Quicksearch landing page, building search-forms that will be
        # shown to the user via Javascript datasource switching, mark as "new_search"
        if @active_source == 'quicksearch'
          result += hidden_field_tag 'new_search', 'true'
        end
        result += hidden_field_tag 'source', @active_source || 'articles'
        result += hidden_field_tag "form", "basic"

        # Pass through Summon facets, checkboxes, sort, paging, as hidden form variables
        # For any Summon data-source:  Articles or Newspapers
        result += summon_hidden_keys_for_search(summon_query_as_hash.except('s.fq'))

        # insert drop-down
        result += dropdown_with_select_tag(:search_field, options['search_fields'].invert, h(search_params[:search_field]), :title => "Targeted search options", :class=>"search_options")
      end

      # "Search" button
      result += content_tag(:button, '<i class="icon-search icon-white"></i> <span class="visible-desktop">Search</span>'.html_safe, type: "submit", class: "btn basic_search_button btn-primary", name: 'commit', value: 'Search')

      # link to advanced search
      if options['search_type'].in?("summon", "blacklight") && options['advanced']
        result += content_tag(:a, "Advanced Search", :class => "btn btn-link advanced_search_toggle", :href => "#")
      end


      result = content_tag(:div, result, class: 'search_row input-append', escape: false)

      raise "no route in #{source} " unless options['route']

      result = content_tag(:form, result, :'accept-charset' => 'UTF-8', :class=> "form-inline", :action => self.send(options['route']), :method => 'get')

      result = content_tag(:div, result, :class => div_classes.join(" "))

    end

    return result
  end

  # UNUSED ???
  # def display_search_box(source, &block)
  #   div_classes = ["search_box", source]
  #   div_classes << "multi" if show_all_search_boxes
  #   div_classes << "selected" if active_search_box == source
  #
  #   if show_all_search_boxes || active_search_box == source
  #     content_tag(:div, capture(&block), :class => div_classes.join(" "))
  #   else
  #     ""
  #   end
  # end
  #
  # UNUSED ???
  # def previous_page(search)
  #   if search.page <= 1
  #     content_tag('span', "« Previous", :class => "prev prev_page disabled")
  #   else
  #     content_tag('span', content_tag('a', "« Previous", :href => search.previous_page), :class => "prev prev_page")
  #   end
  # end
  #
  # UNUSED ???
  # def next_page(search)
  #   if search.page >= search.page_count
  #     content_tag('span', "Next »", :class => "next next_page disabled")
  #   else
  #     content_tag('span', content_tag('a', "Next »", :href => search.next_page), :class => "next next_page")
  #   end
  # end
  #
  # UNUSED ???
  # def page_links(search)
  #   max_page = [search.page_count, 20].min
  #   results = [1,2] + ((-5..5).collect { |i| search.page + i }) + [max_page - 1, max_page]
  #
  #   results = results.reject { |i| i <= 0 || i > [search.page_count,20].min}.uniq.sort
  #
  #   previous = 1
  #   results.collect do |page|
  #     page_delimited = number_with_delimiter(page)
  #     result = if page == search.page
  #       content_tag('span', page_delimited, :class => 'page current')
  #     elsif page - previous > 1
  #       content_tag('span', "...", :class => 'page gap') +
  #         content_tag('span', content_tag('a', page_delimited, :href => search.set_page(page)), :class => 'page')
  #     else
  #       content_tag('span', content_tag('a', page_delimited, :href => search.set_page(page)), :class => 'page')
  #     end
  #
  #     previous = page
  #     result
  #
  #   end.join("").html_safe
  #
  # end


end

# encoding: utf-8

module DisplayHelper
  def get_column_classes(column)
    # "result_column span#{column['width']}"
    "result_column col-sm-#{column['width']}"
  end

  MIME_MAPPINGS = {
    'application/pdf'      =>   'pdf.png',
    'application/msword'   =>   'doc.png',
    'application/msexcel'  =>   'xls.png',
  }

  def dam_document_icon(document)
    return '' unless document.mime

    if (mime_icon = MIME_MAPPINGS[document.mime])
      return image_tag("format_icons/#{mime_icon}", size: '20x20')
    end

    extension = document.url.sub(/.*\./, '')
    if %w(mp3 mp4 xlsx).include? extension
      return image_tag("format_icons/#{extension}.png", size: '20x20')
    end
  end

  def dam_document_link(document)
    return '' unless document and document.url
    basename = document.url.sub(/.*\//, '')
    return '' unless basename
    link_to "#{basename}", document.url
  end

  def render_first_available_partial(partials, options)
    partials.each do |partial|
      begin
        return render(partial: partial, locals: options)
      rescue ActionView::MissingTemplate
        next
      end
    end

    fail "No partials found from #{partials.inspect}"
  end

  FORMAT_MAPPINGS = {
    'Book' => 'book',
    'Online' => 'link',
    'Computer File' => 'computer-file',
    'Sound Recording' => 'non-musical-recording',
    'Music - Score' => 'musical-score',
    'Music - Recording' => 'musical-recording',
    'Thesis' => 'thesis',
    'Microformat' => 'microform',
    'Journal/Periodical' => 'journal',
    'Conference Proceedings' => 'conference',
    'Video' => 'video',
    'Map/Globe' => 'map-or-globe',
    'Manuscript/Archive' => 'manuscript',
    'Newspaper' => 'newspaper',
    'Database' => 'database',
    'Image' => 'image'
  }

  def formats_with_icons(document)
    document['format'].listify.map do |format|
      if (icon = FORMAT_MAPPINGS[format]) && @add_row_style != :text
        image_tag("icons/#{icon}.png", size: '16x16') + " #{format}"
      else
        format.to_s
      end
    end.join(', ').html_safe
  end

  def render_documents(documents, options)
    current_viewstyle = get_browser_option('viewstyle') ||
                        DATASOURCES_CONFIG['datasources'][@active_source]['default_viewstyle'] ||
                        'list'

    # Assume view-style is the configured default, or "list" if no default configured...
    viewstyle = DATASOURCES_CONFIG['datasources'][@active_source]['default_viewstyle'] ||
                'list'

    # ... but if an alternative view-style option is set,
    # and if this data-source has a configuration which includes that view-style,
    # then use it instead.
    datasource_viewstyles = DATASOURCES_CONFIG['datasources'][@active_source]['viewstyles']
    if (saved_viewstyle_option = get_browser_option('viewstyle')) &&
       (datasource_viewstyles = DATASOURCES_CONFIG['datasources'][@active_source]['viewstyles']) &&
       datasource_viewstyles.key?(saved_viewstyle_option)
      viewstyle = saved_viewstyle_option
    end

    partial = "/_display/#{options[:action]}/#{viewstyle}"
    render partial,  documents: documents.listify
  end

  def render_document_view(document, options = {})
    options.symbolize_keys!
    template = options.delete(:template) || fail('Must specify template')
    formats = determine_formats(document, options.delete(:format))
# raise
    # Render based on @active_source -- unless an alternative is passed in
    options[:source] ||= @active_source

    partial_list = formats.map { |format| "/_formats/#{format}/#{template}" }
    @add_row_style = options[:style]
    view = render_first_available_partial(partial_list, options.merge(document: document))
    @add_row_style = nil

    view
  end

  SOLR_FORMAT_LIST = {
    'Music - Recording' => 'music_recording',
    'Music - Score' => 'music',
    'Journal/Periodical' => 'serial',
    'Manuscript/Archive' => 'manuscript_archive',
    'Newspaper' => 'newspaper',
    'Video' => 'video',
    'Map/Globe' => 'map_globe',
    'Book' => 'book'
  }

  SUMMON_FORMAT_LIST = {
    'Book' => 'ebooks',
    'Journal Article' => 'article'
  }

  FORMAT_RANKINGS = %w(ac database map_globe manuscript_archive video music_recording music newspaper serial book clio ebooks article articles summon lweb)

  def format_online_results(link_hash)
    non_circ_img = image_tag('icons/noncirc.png', class: 'availability')
    link_hash.map do |link|
      non_circ_img +
      link_to(process_online_title(link[:title]).abbreviate(80), link[:url]) +
      content_tag(:span, link[:note], class: 'url_link_note')
    end
  end

  def format_brief_location_results(locations, document)
    locations.map do |location|

      loc_display, hold_id = location.split('|DELIM|')

      image_tag('icons/none.png',
                class: "availability holding_#{hold_id}") +
        process_holdings_location(loc_display) +
        additional_brief_location_note(document, location)
        # Can't do this without more work...
        # Location.get_location_note(loc_display, document)
    end
  end

  # Any additional special notes, possibly multiple, for this document at this location
  def additional_holdings_location_notes(document, location)
    location_notes = []

    # Law records need a link back to their native catalog
    if document && in_pegasus?(document)
      location_notes << content_tag(:span, pegasus_item_link(document, 'Search Results'), class: 'url_link_note')
    end

    # Check for any location notes in app_config - that's used for
    # somewhat dynamic values that we don't want to put in code
    app_config_location_notes = APP_CONFIG['location_notes'] || {}
    app_config_location_notes.keys.each { |location_note_key|
      if location.starts_with? location_note_key
        location_notes << app_config_location_notes[location_note_key].html_safe
      end
    }

    return location_notes
  end

  # Any additional special note, for this document at this location
  def additional_brief_location_note(document, location)
    # Law records need a link back to their native catalog
    if document && in_pegasus?(document)
      return content_tag(:span, pegasus_item_link(document, 'Search Results'), class: 'url_link_note')
    end
  end

  def pegasus_item_link(document, context = @active_source)
    url = 'http://pegasus.law.columbia.edu'
    if document && document.id
      # NEXT-996 - Rename "Pegasus" link
      return link_to 'Check Law catalog for status',
                     "#{url}/record=#{document.id}",
                     :'data-ga-category' => 'Pegasus Link',
                     :'data-ga-action' => context,
                     :'data-ga-label' => document['title_display'] || document.id
    else
      return link_to url, url
    end
  end

  def determine_formats(document, defaults = [])
    formats = defaults.listify
    # AC records, from the AC Solr, don't self-identify.
    formats << 'ac' if @active_source == 'academic_commons'
    # Database items - from the Voyager feed - will identify themselves,
    # via their "source", which we should respect no matter the current
    # GUI-selected datasource
    # formats << "database" if @active_source == "databases"
    case document
    when SolrDocument
      formats << 'clio'
# raise
      document['format'].listify.each do |format|
        formats << SOLR_FORMAT_LIST[format] if SOLR_FORMAT_LIST[format]
      end
      # What's the "home" datasource for this record?
      # Could be multiple (e.g., 'catalog' and 'database')
      document['source_display'].listify.each do |source|
        formats << source if FORMAT_RANKINGS.include? source
      end
    when Summon::Document
      formats << 'summon'
      document.content_types.each do |format|
        formats << SUMMON_FORMAT_LIST[format] if SUMMON_FORMAT_LIST[format]
      end
    end
# raise
    formats.sort { |x, y| FORMAT_RANKINGS.index(x) <=> FORMAT_RANKINGS.index(y) }
  end

  # for segregating search values from display values
  DELIM = '|DELIM|'

  # generate_value_links() is used extensively throughout catalog show
  # helpers, to build CLIO search links out of MARC values, for use on
  # the item-detail pages.
  def generate_value_links(values, category)
    # out - an array of strings to be returned by this function,
    # one per input value.
    out = []

    values.listify.each do |v|

      # Fields intended for for search links will have distinct
      # display/search values delimited within the field.
      display_value, search_value, t880_indicator = v.split(DELIM)

      # If the split didn't find us a search_value, this field was
      # not setup for searching - return the value for display, no link.
      unless search_value
        out << v
        next
      end

      # the display value has already been made html-escaped by MarcHelper.
      # mark it as html-safe to avoid double-encoding
      display_value = display_value.html_safe

      # if we're displaying plain text, do not include links
      if @add_row_style == :text
        out << display_value
        next
      end

      case category

      when :all
        q = '"' + search_value + '"'
        out << link_to(display_value, url_for(controller: 'catalog', action: 'index', q: q, search_field: 'all_fields', commit: 'search'))

      when :author
        # t880_indicator is not nil when data is from an 880 field (vernacular)
        # temp workaround until we can get 880 authors into the author facet
        if t880_indicator
          # q = '"' + search_value + '"'
          # out << link_to(display_value, url_for(:controller => "catalog", :action => "index", :q => q, :search_field => "author", :commit => "search"))
          out << display_value

        else
          # remove punctuation to match entries in author_facet
          # using solrmarc removeTrailingPunc rule
          search_value = remove_punctuation(search_value)

          out << link_to(display_value, url_for(:controller => 'catalog', :action => 'index', 'f[author_facet][]' => search_value))
        end

      # Obsoleted, replaced by generate_value_links_subject(), defined below
      # when :subject
      #   out << link_to(display_value, url_for(:controller => "catalog", :action => "index", :q => search_value, :search_field => "subject", :commit => "search"))

      # when :title
      #   q = '"' + search_value + '"'
      #   out << link_to(display_value, url_for(:controller => "catalog", :action => "index", :q => q, :search_field => "title", :commit => "search"))

      when :series_title
        q = search_value
        out << link_to(display_value, url_for(controller: 'catalog', action: 'index', q: q, search_field: 'series_title', commit: 'search'))

      else
        fail 'invalid category specified for generate_value_links'
      end

    end

    out
  end

  def remove_punctuation(value)
    # matches edit from SolrMARC removeTrailingPunc method: Utils.cleanData
    #
    # Removes trailing characters (space, comma, slash, semicolon, colon) and
    #  trailing period if it is preceded by at least three (two?) letters

    curr = value
    prev = ''

    while curr != prev
      prev = curr
      curr = curr.strip

      curr = curr.gsub(/\s*[,\/;:]$/, '')

      if curr =~ /\.$/
        if curr =~ /[JS]r\.$/
          # don't strip period off Jr. or Sr.
        elsif curr =~ /\w\w\.$/
          curr = curr.chop
        elsif curr =~ /\p{L}\p{L}\.$/
          curr = curr.chop
          # IsCombiningDiacriticalMarks is not supported in Ruby; using weaker formulation
          # elsif curr =~ /\w\p{IsCombiningDiacriticalMarks}?\w\p{IsCombiningDiacriticalMarks}?\.$/
          #  curr = curr.chop
        elsif curr =~ /\w[^a-zA-Z0-9 ]?\w[^a-zA-Z0-9 ]?\.$/
          curr = curr.chop
        elsif curr =~ /\p{Punct}\.$/
          curr = curr.chop
        end
      end

    end

    curr
  end

  def generate_value_links_subject(values)
    # search value the same as the display value
    # but chained to create a series of searches that is increasingly narrower
    # esample: a - b - c
    # link display   search
    #   a             "a"
    #   b             "a b"
    #   c             "a b c"

    values.listify.map do |value|
#    values.listify.select { |x| x.respond_to?(:split)}.collect do |value|

      searches = []
      subheads = value.split(' - ')
      first = subheads.shift
      display = first
      search = first
      title = first

      searches << build_subject_url(display, search, title)

      unless subheads.empty?
        subheads.each do |subhead|
          display = subhead
          search += ' ' + subhead
          title += ' - ' + subhead
          searches << build_subject_url(display, search, title)
        end
      end

      if @add_row_style == :text
        searches.join(' - ')
      else
        searches.join(' > ')
      end

    end
  end

  def build_subject_url(display, search, title)
    display = display.html_safe

    search = CGI.unescapeHTML(search)

    if @add_row_style == :text
      display
    else
      link_to(display, url_for(controller: 'catalog',
                               action: 'index',
                               q: '"' + search + '"',
                               search_field: 'subject',
                               commit: 'search'),
              title: title)
    end
  end

  def add_row(title, value, options = {})
    options.reverse_merge!(@add_row_options) if @add_row_options.kind_of?(Hash)
    options.reverse_merge!(
      display_blank: false,
      join: nil,
      abbreviate: nil,
      html_safe: true,
      expand: false,
      style: @add_row_style || :definition,
      spans: [2, 10],
      label_style: 'field'
    )

    value_txt = convert_values_to_text(value, options)
    spans = options[:spans]

    result = ''
    if options[:display_blank] || !value_txt.empty?
      if options[:style] == :text
        result = (title.to_s + ': ' + value_txt.to_s + "\n").html_safe
      else
        result = content_tag(:div, class: 'row document-row') do
          if options[:style] == :definition
            # add space after row label, to help capybara string matchers
            content_tag(:div, title.to_s.html_safe + ' ', class: "#{options[:label_style]} col-sm-#{spans.first}") +
            content_tag(:div, value_txt, class: "value col-sm-#{spans.last}")
          end
        end
      end

    end

    result
  end

  def convert_values_to_text(value, options = {})
    values = value.listify

    values = values.map { |txt| txt.to_s.abbreviate(options[:abbreviate]) } if options[:abbreviate]

    if options[:html_safe]
      values = values.map(&:html_safe)
    else
      values = values.map { |v| h(v) }.map(&:html_safe)
    end

    # Join multiple data values into a single delimited display string
    values = values.join(options[:join]).listify if options[:join]

    # Don't do our fancy html/JS markup if we're in a text-only context
    if options[:style] == :text
      return values.join("\r\n  ")
    end

    # "Teaser" option - If the text is long enough, wrap the end of it
    # within a span, with a hide/show toggle.
    # based on:  http://stackoverflow.com/questions/14940166
    # based on:  http://jsfiddle.net/VNdmZ/4/
    if options[:teaser]
      values = values.map do |value|
        value.strip!
        teaser_length = options[:teaser].respond_to?(:to_i) ? options[:teaser].to_i : 180
        breaking_space_index = value.index(' ', teaser_length)

        # if we found an appropriate space character at which to break content...
        if breaking_space_index
          before = value[0, breaking_space_index]
          after = value[breaking_space_index + 1 .. -1]
          icon_i = content_tag(:span, nil, class: 'glyphicon glyphicon-resize-full toggle-teaser')
          value = "#{before} #{content_tag(:span, after, class: 'teaser')} #{icon_i}".html_safe
        else
          value
        end
      end
    end

    if values.length > 1
      values = values.map { |v| content_tag(:div, v, class: 'entry') }
    end

    if options[:expand] && values.length > 3
      values = [
        values[0],
        values[1],
        content_tag(:div, link_to("#{values.length - 2} more &#x25BC;".html_safe, '#'), class: 'entry expander'),
        content_tag(:div, values[2..-1].join('').html_safe, class: 'expander_more')
      ]
    end

    value_txt = values.join("\n")

    if options[:expand_to] && !options[:expand_to].strip.empty?
      value_txt += content_tag(:div, link_to(' more &#x25BC;'.html_safe, '#'),
                               class: 'entry expander')
      value_txt += content_tag(:div, options[:expand_to].html_safe,
                               class: 'expander_more')
    end

    value_txt = value_txt.html_safe
    value_txt
  end

  # Exports CUL Catalog SolrDocument as an OpenURL KEV
  # (key-encoded value) query string.
  # For use to create COinS, among other things. COinS are
  # for Zotero, among other things.
  def catalog_to_openurl_ctx_kev(document)
    return '' unless document
    fail 'Document has no format!  ' + document.id unless document[:format]
    format = document[:format].first ||= 'book'

    fields = []
    fields.push('ctx_ver=Z39.88-2004')

    document[ :author_display] && document[ :author_display].each do |author|
      fields.push("rft.au=#{ CGI.escape(author) }")
    end

    document[ :title_display] && Array.wrap(document[ :title_display]).each do |title|
      fields.push("rft.title=#{ CGI.escape(title) }")
    end

    document[ :full_publisher_display] && document[ :full_publisher_display].each do |publisher|
      fields.push("rft.pub=#{ CGI.escape(publisher) }")
    end

    # '_sort' fields are not multi-valued - can't do .each
    document[ :pub_date_sort] && Array.wrap(document[ :pub_date_sort]).each do |pub_date_sort|
      fields.push("rft.date=#{ CGI.escape(pub_date_sort.to_s) }")
    end

    document[ :isbn_display] && document[ :isbn_display].each do |isbn|
      fields.push("rft.isbn=#{ CGI.escape(isbn) }")
    end

    if format =~ /journal/i
      # JOURNAL-SPECIFIC FIELDS
      fields.push('rft_val_fmt=info:ofi/fmt:kev:mtx:journal')
      # title is redundantly given as "atitle" for books
      document[ :title_display] && Array.wrap(document[ :title_display]).each do |title|
        fields.push("rft.atitle=#{ CGI.escape(title) }")
      end
    else
      # BOOK-SPECIFIC FIELDS
      fields.push('rft_val_fmt=info:ofi/fmt:kev:mtx:book')
      # title is redundantly given as "btitle" for books
      document[ :title_display] && Array.wrap(document[ :title_display]).each do |title|
        fields.push("rft.btitle=#{ CGI.escape(title) }")
      end
    end

    fields.push("rft.genre=#{ CGI.escape(format_to_rft_genre(format)) }")

    fields.join('&')
  end

  def format_to_rft_genre(format)
    case format
    when /journal/i
      'article'
    when /book/i
      'book'
    when /proceeding/i
      'proceeding'
    when /conference/i
      'conference'
    when /report/i
      'report'
    else
      # http://ocoins.info/cobgbook.html
      # "general document type to be used when available data elements
      #  do not allow determination of a more specific document type"
      'document'
    end
  end

  # Exports CUL Academic Commons SolrDocument as an OpenURL KEV
  # (key-encoded value) query string.
  # For use to create COinS, among other things. COinS are
  # for Zotero, among other things.
  def ac_to_openurl_ctx_kev(document)
    fields = []

    fields.push('ctx_ver=Z39.88-2004')
    fields.push('rft_val_fmt=info:ofi/fmt:kev:mtx:journal')

    # Many fields used to be arrays on katana, but on macana appear to be strings?
    # Defend ourselves by using Array.wrap() on everything.

    Array.wrap(document[ :id]).each do |id|
      document_url = 'http://academiccommons.columbia.edu/catalog/' + id
      fields.push("rft_id=#{ CGI.escape(document_url) }")
    end

    document[ :author_facet] && Array.wrap(document[ :author_facet]).each do |author|
      fields.push("rft.au=#{ CGI.escape(author) }")
    end

    document[ :title_display] && Array.wrap(document[ :title_display]).each do |title|
      fields.push("rft.atitle=#{ CGI.escape(title) }")
    end

    document[ :publisher] && Array.wrap(document[ :publisher]).each do |publisher|
      fields.push("rft.pub=#{ CGI.escape(publisher) }")
    end

    document[ :pub_date_sort] && Array.wrap(document[ :pub_date_sort]).each do |pub_date_sort|
      fields.push("rft.date=#{ CGI.escape(pub_date_sort) }")
    end

    fields.join('&')
  end

  # Our versions of link_to_previous_document/link_to_next_document,
  # with awareness of the current action (e.g., librarian_view)
  # (AND, I switched from .pagination. to .pagination_compact., to pick
  # up my Glyphicons for XS output display)
  def link_to_previous_document_and_action(previous_document)
    link_opts = session_tracking_params(previous_document, search_session['counter'].to_i - 1).merge(:class => "previous", :rel => 'prev')
    link_to_unless previous_document.nil?, raw(t('views.pagination_compact.previous')), { id: previous_document, action: controller.action_name }, link_opts do
      content_tag :span, raw(t('views.pagination.previous')), class: 'previous'
    end
  end

  def link_to_next_document_and_action(next_document)
    link_opts = session_tracking_params(next_document, search_session['counter'].to_i + 1).merge(:class => "next", :rel => 'next')
    link_to_unless next_document.nil?, raw(t('views.pagination_compact.next')), { id: next_document, action: controller.action_name }, link_opts do
      content_tag :span, raw(t('views.pagination.next')), class: 'next'
    end
  end

  # Core Blacklight, 5.2.0
  # ##
  # # Link to the previous document in the current search context
  # def link_to_previous_document(previous_document)
  #   link_opts = session_tracking_params(previous_document, search_session['counter'].to_i - 1).merge(:class => "previous", :rel => 'prev')
  #   link_to_unless previous_document.nil?, raw(t('views.pagination.previous')), url_for_document(previous_document), link_opts do
  #     content_tag :span, raw(t('views.pagination.previous')), :class => 'previous'
  #   end
  # end
  # 
  # ##
  # # Link to the next document in the current search context
  # def link_to_next_document(next_document)
  #   link_opts = session_tracking_params(next_document, search_session['counter'].to_i + 1).merge(:class => "next", :rel => 'next')
  #   link_to_unless next_document.nil?, raw(t('views.pagination.next')), url_for_document(next_document), link_opts do
  #     content_tag :span, raw(t('views.pagination.next')), :class => 'next'
  #   end
  # end





end

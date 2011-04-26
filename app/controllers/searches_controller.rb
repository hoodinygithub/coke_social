class SearchesController < ApplicationController

  def show
    @query = CGI::unescape(params[:q]) rescue nil
    @search_types ||= [:playlists, :users]
    @sort_types = { :latest => { :playlists => 'updated_at DESC', :users => 'created_at DESC' }, \
                    :alphabetical => 'normalized_name ASC', \
                    :relevance => nil, \
                    :highest_rated => { :playlists => 'rating_cache DESC', :users => nil }, \
                    :top => { :playlists => 'playlist_total_plays DESC', :users => nil }
                  }

    @sort_type = get_sort_by_param(@sort_types.keys, :relevance) #params.fetch(:sort_by, nil).to_sym rescue :relevance
    @active_scope = params[:scope].nil? ? @search_types[0] : params[:scope].to_sym
    @page = params[:page] || 1
    @counts = {}
    @results = {}
    msg = "not_for_msgr"
    if request.xhr?
      if @active_scope == :all
        search_results(msg,@search_types, 4)
        default_active_scope
      else
        search_results(msg,@active_scope.to_a)
      end

      if params.has_key? :result_only
        render :partial => "searches/#{@active_scope.to_s}"
      else
        render :partial => 'searches/list'
      end
    else
      unless @query.nil?
        if @active_scope == :all
          search_results(msg,@search_types)
          default_active_scope
        else
          search_results(msg,@active_scope.to_a)
        end
      else
        @search_types.each do |t|
          @results.store(t, [])
          @counts.store(t, 0)
        end
      end
    end
  end

  def content
    @query = params[:q]
    @search_types ||= [:artists, :songs, :albums]
    @sort_type = :relevance
    @sort_types = { :relevance => nil }

    @active_scope = params[:scope].nil? ? @search_types[0] : params[:scope].to_sym

    @counts = {}
    @results = {}
    msg = "not_for_msgr"
    @active_scope == :all ? search_results(msg,@search_types, 4) : search_results(@active_scope.to_a)

    @local = true if params[:local]
    render :partial => 'searches/content_list'#, :layout => false
  end

  def messenger_searchresults
    @query = CGI::unescape(params[:q]) rescue nil
    @search_types ||= [:playlists, :users]
    @sort_types = { :latest => { :playlists => 'updated_at DESC', :users => 'created_at DESC' }, \
                    :alphabetical => 'normalized_name ASC', \
                    :relevance => nil, \
                    :highest_rated => { :playlists => 'rating_cache DESC', :users => nil }, \
                    :top => { :playlists => 'playlist_total_plays DESC', :users => nil }
                  }

#    @sort_type = get_sort_by_param(@sort_types.keys, :relevance) #params.fetch(:sort_by, nil).to_sym rescue :relevance
    @sort_type =  :relevance
#    @active_scope = params[:scope].blank? ? @search_types[0] : params[:scope].to_sym
    @page = params[:page] || 1
    @counts = {}
    @results = {}
    @title = t('coke_messenger.search.title')
    msg = "msgr"
    if !@query.blank?
        search_results(msg,@search_types)
    else
      @search_types.each do |t|
        @results.store(t, [])
        @counts.store(t, 0)
      end
    end
    render 'coke_messenger/messenger_searchresults', :layout => layout_unless_xhr('messenger')
  end

  def messenger_search_emotion_results
    @query = CGI::unescape(params[:q]) rescue nil
    @search_types ||= [:playlists]
    @sort_types = { :latest => { :playlists => 'updated_at DESC', :users => 'created_at DESC' }, \
                    :alphabetical => 'normalized_name ASC', \
                    :relevance => nil, \
                    :highest_rated => { :playlists => 'rating_cache DESC', :users => nil }, \
                    :top => { :playlists => 'playlist_total_plays DESC', :users => nil }
                  }

    @sort_type =  :relevance
    @page = params[:page] || 1
    @counts = {}
    @results = {}
    @title = t('coke_messenger.default_messenger_title')+CGI::unescape(params[:q])
    msg = "msgr"
    if !@query.blank?
        search_results(msg,@search_types, 5)
    else
      @search_types.each do |t|
        @results.store(t, [])
        @counts.store(t, 0)
      end
    end
    @total_pages = @results[:playlists].total_pages
    if params.has_key? :page
      render :partial => 'coke_messenger/search_emotion_result', :collection => @results[:playlists]
    else
      @results[:playlists] = @results[:playlists].sortable(
            :results,
            [:popularity, :total_plays],
            [:most_recent, :updated_at],
            [:rating, :rating_cache],
            [:alpha, :name]
      )
      render 'coke_messenger/messenger_search_emotion_results', :layout => layout_unless_xhr('messenger')
    end
  end

  private
    def default_active_scope
      @active_scope = @counts.sort{ |a, b| b[1] <=> a[1] }.first[0] unless @search_types.include? @active_scope
    end

    # def default_sort_type
    #   @sort_type = :relevance
    # end

    def sort_users_by_alpha(*args)
      args.first.sort!{ |a, b| a[1].name <=> b[1].name rescue 0 }
    end

    def search_results (msg,types=[], per_page = 12)
      unless msg == "msgr"
        opts = { :page => @page, :per_page => per_page, :star => true, :retry_stale => true }
      else
        opts = { :star => true, :retry_stale => true }
      end  
      @search_types.each do |scope|
        dataset = []
        obj_scope = scope == :stations ? :abstract_stations : scope
        obj = obj_scope.to_s.classify.constantize
        opts.delete(:order)

        if types.include? scope
          #default_sort_type scope == @active_scope
          sort_instruction = nil
          custom_sort = false

          if(@sort_types[@sort_type].is_a? Hash)
            sort_instruction = @sort_types[@sort_type][scope]
            unless sort_instruction.nil?
              custom_sort = true if sort_instruction.is_a?(Symbol)
              opts.merge!(:order => @sort_types[@sort_type][scope]) unless custom_sort
            end
          else
            sort_instruction = @sort_types[@sort_type]
            unless sort_instruction.nil?
              custom_sort = true if sort_instruction.is_a?(Symbol)
              opts.merge!(:order => @sort_types[@sort_type]) unless custom_sort
            end
          end
            dataset = obj.search(@query, opts) if types.include? scope
            send(sort_instruction, dataset) if custom_sort
        end
        @results.store(scope, dataset)
        @counts.store(scope, obj.search_count(@query, opts))
      end
    end
end


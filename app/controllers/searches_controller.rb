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
    if request.xhr?
      if @active_scope == :all
        search_results(@search_types, 4)
        default_active_scope 
      else 
        search_results(@active_scope.to_a)
      end
      
      if params.has_key? :result_only
        render :partial => "searches/#{@active_scope.to_s}"
      else
        render :partial => 'searches/list'
      end      
    else
      unless @query.nil?
        if @active_scope == :all
          search_results(@search_types) 
          default_active_scope
        else
          search_results(@active_scope.to_a)
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

    @active_scope == :all ? search_results(@search_types, 4) : search_results(@active_scope.to_a)
    
    @local = true if params[:local]
    render :partial => 'searches/content_list'#, :layout => false
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
    
    def search_results (types=[], per_page = 12)
      opts = { :page => @page, :per_page => per_page, :star => true, :retry_stale => true }

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


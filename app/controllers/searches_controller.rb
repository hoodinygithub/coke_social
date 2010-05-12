class SearchesController < ApplicationController

  def show
    @query = CGI::unescape(params[:q]) rescue nil
    @search_types ||= [:playlists, :users]    
    @sort_type = params.fetch(:sort_by, nil).to_sym rescue :relevance
    @sort_types = { :latest => { :playlists => 'updated_at DESC', :users => 'created_at DESC' }, \
                    :alphabetical => 'name ASC', \
                    :relevance => nil, \
                    :top => { :playlists => 'playlist_total_plays DESC', :users => nil } }

    @active_scope = params[:scope].nil? ? @search_types[0] : params[:scope].to_sym

    @counts = {}
    @results = {}
    if request.xhr?
      @active_scope == :all ? search_all_types(4) : search_only_active_type(12)
      
      if params.has_key? :result_only
        render :partial => "searches/#{@active_scope.to_s}"
      else
        render :partial => 'searches/list'
      end      
    else
      unless @query.nil?
        @active_scope == :all ? search_all_types : search_only_active_type
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

    @active_scope == :all ? search_all_types(4) : search_only_active_type(12)
    
    @local = true if params[:local]
    render :partial => 'searches/content_list'#, :layout => false
  end

  private  
    def default_active_scope
      @active_scope = @counts.sort{ |a, b| b[1] <=> a[1] }.first[0] unless @search_types.include? @active_scope
    end
    def default_sort_type
      @sort_type = :relevance
    end
    
    def search_only_active_type (per_page = 12)
      opts = { :page => params[:page], :per_page => per_page }

      @search_types.each do |scope|
        obj_scope = scope == :stations ? :abstract_stations : scope
        obj = obj_scope.to_s.classify.constantize
        active = scope == @active_scope

        opts.delete(:order)
        if(@sort_types[@sort_type].is_a? Hash)
          unless @sort_types[@sort_type][scope].nil?
            opts.merge!(:order => @sort_types[@sort_type][scope])
          else
            default_sort_type if active
          end
        else
          unless @sort_types[@sort_type].nil?
            opts.merge!(:order => @sort_types[@sort_type]) 
          else
            default_sort_type if active
          end
        end

        @results.store(scope, (active) ? obj.search(@query, opts) : [])
        @counts.store(scope, obj.search_count("#{@query}*"))
      end
    end
  
    def search_all_types (per_page = 12)
      opts = { :page => params[:page], :per_page => per_page }
      opts.merge!(:order => @sort_types[@sort_type]) unless @sort_types[@sort_type].nil?

      @search_types.each do |scope|
        obj_scope = scope == :stations ? :abstract_stations : scope
        obj = obj_scope.to_s.classify.constantize

        @results.store(scope, obj.search(@query, opts))
        @counts.store(scope, obj.search_count("#{@query}*"))
      end
      default_active_scope
    end
end


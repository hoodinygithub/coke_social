class FollowersController < ApplicationController
  include ApplicationHelper

  current_tab :community
  current_filter :followers

  def index
    @dashboard_menu = :followers
    sort_types  = { :latest => 'followings.approved_at DESC', :alphabetical => 'followings.follower_name'  }
    @sort_type = get_sort_by_param(sort_types.keys, :latest) #params.fetch(:sort_by, nil).to_sym rescue :latest

    begin
        if profile_artist?
          @pending    = profile_artist.follow_requests
          @collection = profile_artist.followers.paginate :page => params[:page], :per_page => 15, :order => sort_types[@sort_type]
        else
          @pending    = profile_user.follow_requests
          @collection = profile_user.followers.paginate :page => params[:page], :per_page => 15, :order => sort_types[@sort_type]
        end
        if request.xhr?
          render :partial => 'followings/ajax_list'
        end
    rescue NoMethodError
      redirect_to new_session_path
    end
  end
end


class BadgesController < ApplicationController
  def index
    @sort_type = params.fetch(:sort_by, nil).to_sym rescue :latest

    begin
        sort_types = { :latest => 'created_at DESC', :alphabetical => 'name'  }
        @badge_awards = profile_user.badge_awards.paginate :page => params[:page], :per_page => 10, :order => sort_types[@sort_type]
    rescue NoMethodError
      redirect_to new_session_path
    end
  end

  def show
    @badge_award = profile_user.badge_awards.find(params[:id])
    @friends_with_badge = profile_user.followees.with_badge(@badge_award)
    @others_with_badge = @badge_award.badge.winners.other_than_user_and_followees(profile_user)
  end
end

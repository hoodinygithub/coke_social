class ReviewsController < ApplicationController

  skip_before_filter :sanitize_params

  before_filter :load_sort_data, :load_records, :only => [:list, :index, :items]

  def index
    @dashboard_menu = :reviews
    if on_dashboard?
      params[:controller] = 'my'
      params[:action]     = 'reviews'
    end
    @collection = @records.paginate :page => @page, :per_page => 6

    if request.xhr?
      render :partial => 'ajax_list'
    end
  end

  def list
    @collection = @records.paginate :page => @page, :per_page => 5
    render 'playlist_reviews_list', :layout => false
  end

  def items
    @collection = @records.paginate :page => @page, :per_page => 5
    render :partial => 'playlist_review_item', :collection => @collection
  end

  def destroy
    @review = Comment.find(params[:id])
    if @review.user == current_user or @review.commentable.owner == current_user
      @review.destroy
      render :json => { :success => true, :id => params[:id], :count => records_count }
    else
      render :json => { :success => false }
    end
  end

  def edit
    @review = Comment.find(params[:id])
    @full_partial = params[:full] ? true : false
  end

  def update
    review = Comment.find(params[:id])
    review.comment = params[:comment]
    review.rating  = params[:rating]
    partial = params[:full] ? 'item' : 'playlist_review_item'
    if review.save
      review.commentable.update_attribute('rating_cache', review.commentable.rating)
      render :json => { :success => true,
                        :id      => review.id,
                        :html    => render_to_string( :partial => partial, :collection => [review] )
                      }
    else
      render :json => { :success => false, :errors => review.errors.to_json }
    end
  end

  def create
    @playlist = Playlist.find(params[:playlist_id])
    review  = Comment.new(:comment => params[:comment],
                          :rating  => params[:rating],
                          :user_id => current_user.id )
    if review.valid?
      has_commented = @playlist.comments.find_by_user_id(current_user.id) if @playlist
      if has_commented
        @review_params = params
        render :json => { :success => false, :redirect_to => "reviews/#{has_commented.id}/duplicate_warning" }
      else
        @playlist.rate_with(review)
        render :json => { :success => true,
                          :html => render_to_string( :partial => 'playlist_review_item', :collection => [review] )
                        }
      end
    else
      render :json => { :success => false, :errors => review.errors.to_json }
    end
  end

  def duplicate_warning
    @review = Comment.find(params[:id])
  end

  def confirm_remove
    @review = Comment.find(params[:id])
  end

  def records_count
    @review.commentable.comments.size
  end

  def show
    @review = Comment.find(params[:id])
  end

protected

  def load_sort_data
    sort_types = { :latest => 'comments.updated_at DESC', :highest_rated => 'comments.rating DESC' }
    sort_by    = params.fetch(:sort_by, nil).to_sym rescue :latest
    @sort_data = sort_types[sort_by]
    @page      = params[:page].blank? ? 1 : params[:page]
    @sort_type = params.fetch(:sort_by, nil).to_sym rescue :latest
  end

  def load_records
    conditions = {}
    conditions.merge!({ :commentable_type => 'Playlist', :commentable_id => params[:playlist_id] }) if params[:playlist_id]
    conditions.merge!({ :user_id => profile_account.id }) if profile_account and !request.xhr?
    @playlist  = Playlist.find(params[:playlist_id]) if params[:playlist_id]
    @records   = Comment.all(:conditions => conditions, :order => @sort_data )
  end

end

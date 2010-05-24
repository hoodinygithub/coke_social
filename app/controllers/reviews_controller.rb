class ReviewsController < ApplicationController

  skip_before_filter :sanitize_params

  before_filter :load_sort_data, :load_records, :only => [:list, :index, :items]

  def index
    @collection = @records.paginate :page => @page, :per_page => 10
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
    render :edit, :layout => false
  end

  def update
    review = Comment.find(params[:id])
    review.comment = params[:comment]
    review.rating  = params[:rating]
    if review.save
      render :json => { :success => true,
                        :id      => review.id,
                        :html    => render_to_string( :partial => 'playlist_review_item', :collection => [review] )
                      }
    else
      render :json => { :success => false, :errors => review.errors.to_json }
    end
  end

  def create
    @playlist     = Playlist.find(params[:playlist_id])
    review  = Comment.new(:comment => params[:comment],
                          :rating  => params[:rating],
                          :user_id => current_user.id )
    if review.valid?
      has_commented = @playlist.comments.find_by_user_id(current_user.id) if @playlist
      if has_commented
        @review_params = params
        render :json => { :success => false, :redirect_to => "reviews/#{has_commented.id}/duplicate_warning" }
      else
        @playlist.comments << review
        @playlist.save!
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

protected

  def load_sort_data
    sort_types = { :latest => 'comments.created_at DESC', :highest_rated => 'comments.rating DESC' }
    sort_by    = params.fetch(:sort_by, nil).to_sym rescue :latest
    @sort_data = sort_types[sort_by]
    @page      = params[:page].blank? ? 1 : params[:page]
  end

  def load_records
    conditions = { :commentable_type => 'Playlist', :commentable_id => params[:playlist_id] } if params[:playlist_id]
    @playlist  = Playlist.find(params[:playlist_id]) if params[:playlist_id]
    @records   = Comment.all(:conditions => conditions, :order => @sort_data )
  end

end

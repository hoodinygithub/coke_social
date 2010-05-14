class ReviewsController < ApplicationController
  def index
    @sort_type = params.fetch(:sort_by, nil).to_sym rescue :latest
    @section = "reviews_page"
    @collection = []
  end

end

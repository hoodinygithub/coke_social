class SubscriptionsController < ApplicationController

  def index
    @collection = []
    @sort_type = params.fetch(:sort_by, nil).to_sym rescue :latest
  end

end

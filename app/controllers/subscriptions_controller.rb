class SubscriptionsController < ApplicationController

  def index
    @collection = []
    sort_types = { :latest => nil }
    @sort_type = get_sort_by_param(sort_types.keys, :latest) #params.fetch(:sort_by, nil).to_sym rescue :latest
  end

end

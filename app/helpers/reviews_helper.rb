module ReviewsHelper
  
  def reviews_actions_for(review, review_size=90)
    read_more = "<a href=\"#\" onclick=\"Base.reviews.show(#{review.id}); return false;\">
                   #{t('actions.read_more')}
                 </a>" if review.comment.size > review_size

    edit = "<a href=\"#\" onclick=\"Base.reviews.edit(#{review.id}, true); return false;\">
              #{t('actions.edit')}
            </a>" if review.user == current_user

    actions = [read_more, edit].compact.join('|')
  end

end

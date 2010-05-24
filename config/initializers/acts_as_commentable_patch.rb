Comment.class_eval do

  extend ActionView::Helpers::SanitizeHelper::ClassMethods
  include ActionView::Helpers::SanitizeHelper

  validates_presence_of :comment
  validates_presence_of :rating

  validate :sanitize_comment

protected

  def sanitize_comment
    errors.add(:comment, I18n.t('share.errors.message.invalid_chars')) unless sanitize(comment) == comment
  end
end

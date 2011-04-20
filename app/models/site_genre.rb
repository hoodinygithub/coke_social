class SiteGenre < ActiveRecord::Base
  belongs_to :site
  belongs_to :genre
end

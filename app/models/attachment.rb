class Attachment < ApplicationRecord
  belongs_to :asset, polymorphic: true
  validates :kind, :file_url, presence: true    
end

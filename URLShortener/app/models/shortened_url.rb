
class ShortenedUrl < ApplicationRecord
    validates :long_url, :short_url, :user_id, presence: true
    validates :short_url, uniqueness: true

    belongs_to :submitter,
      primary_key: :id,
      foreign_key: :user_id,
      class_name: :User

    

    def self.random_code
      code = SecureRandom.urlsafe_base64(4)
      while ShortenedUrl.exists?(short_url: code)
        code = SecureRandom.urlsafe_base64(4)
      end
      code
    end

    def self.from_long_url(user, long_url)
      code = self.random_code
      self.create!(long_url: long_url, short_url: code, user_id: user.id)
    end

end

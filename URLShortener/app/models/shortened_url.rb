
class ShortenedUrl < ApplicationRecord
    validates :long_url, :short_url, :user_id, presence: true
    validates :short_url, uniqueness: true

    belongs_to :submitter,
      primary_key: :id,
      foreign_key: :user_id,
      class_name: :User

    has_many :visits,
      primary_key: :id,
      foreign_key: :shortened_url_id,
      class_name: :Visit

    has_many :visitors,
      through: :visits,
      source: :user

    has_many :unique_visitors,
      # Proc.new { distinct }  IS THE SAME AS:
      -> { distinct },
      through: :visits,
      source: :user

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

    def num_clicks
      self.visits.count
    end

    def num_unique_clicks
       self.visitors.select(:user_id).distinct.count
    end

    # select a period of time that we define is recent
    # give the number of clicks within that time period
    def num_recent_uniques
      recent_clicks = self.visits.where("created_at: > ?", 10.minutes.ago)
      recent_clicks.select(:user_id).distinct.count
    end


end

# digg = ShortenedUrl.find(3)
# digg.num_recent_uniqs

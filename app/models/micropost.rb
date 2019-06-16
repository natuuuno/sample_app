class Micropost < ApplicationRecord
  belongs_to :user # userと関連づける
  default_scope -> { order(created_at: :desc) } #default_scopeメソッドでdbからデータを取得した時の順序の指定ができる
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true # user_idが必ず存在
  validates :content, presence: true, length: { maximum: 140 } # 投稿が必ず140字以内
  validate  :picture_size

  private

    # アップロードされた画像のサイズをバリデーションする
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
end

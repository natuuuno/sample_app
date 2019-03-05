class User < ApplicationRecord
  attr_accessor :remember_token #remember_token属性を作成
  before_save { email.downcase! }
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }

  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
               BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # def self.digest(string) #ここでのselfはUserモデルではなくUserクラスを指す
  #   cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
  #              BCrypt::Engine.cost
  #   BCrypt::Password.create(string, cost: cost)
  # end

  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # def self.new_token
  #   SecureRandom.urlsafe_base64
  # end

  # class << self
  #   # 渡された文字列のハッシュ値を返す
  #   def digest(string)
  #     cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
  #                BCrypt::Engine.cost
  #     BCrypt::Password.create(string, cost: cost)
  #   end
  #
  #   #ランダムなトークンを返す
  #   def new_token
  #     SecureRandom.urlsafe_base64
  #   end
  # end

  # 永続セッションのためにユーザーをDBに記憶させる
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡されたtokenがdigestと一致したらtrueを返す
  def authenticated?(remember_token)
    return false if remember_digest.nil? #記憶ダイジェストがnilのときにfalseを返す
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # userのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end
end

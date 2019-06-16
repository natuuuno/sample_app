class User < ApplicationRecord
  has_many :microposts, dependent: :destroy # micropostと関連づけ,userが削除された際micropostも削除される
  attr_accessor :remember_token, :activation_token, :reset_token #remember_token,activation_token,reset_token属性を作成
  before_save :downcase_email
  before_create :create_activation_digest
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
               BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためにユーザーをDBに記憶させる
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡されたtokenがdigestと一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest") #sendメソッドを使ってremember_digestのremember部分を変数として扱う
    return false if digest.nil? #記憶ダイジェストがnilのときにfalseを返す
    BCrypt::Password.new(digest).is_password?(token)
  end

  # userのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest:  User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago  # メールを送信した時間が現在時刻の２時間前よりはやい
  end

  # 試作feedの定義
  def feed
    Micropost.where("user_id = ?", id)
  end

private

  #メールアドレスを小文字にする
  def downcase_email
    self.email.downcase!
  end

  #有効化トークンとダイジェストを作成・代入する
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
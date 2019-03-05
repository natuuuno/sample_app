require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

  def setup
    @user = users(:michael) #fixturesで定義されたテストユーザー
    remember(@user) #rememberメソッドでテストユーザーを記憶
  end

  test "current_user returns right user when session is nil" do
    assert_equal @user, current_user #同じユーザーであることを確認
    assert is_logged_in?
  end

  test "current_user returns nil when remember digest is wrong" do
    # ユーザーの記憶ダイジェストが記憶トークンと対応していない場合current_userがnilになるのを確認
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
end

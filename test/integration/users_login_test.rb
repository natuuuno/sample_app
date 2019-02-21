require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael) #fixture/users.ymlのテスト用ユーザーを参照
  end

  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: "", password: "" } }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "login with valid information followed by logout" do
    get login_path
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }
    assert is_logged_in?
    assert_redirected_to @user #リダイレクト先が正しいかどうか
    follow_redirect! #そのページに実際に移動
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0 #ログインパスのリンクがページにないことを確認
    assert_select "a[href=?]", logout_path #ログアウト用のリンクがあることを確認
    assert_select "a[href=?]", user_path(@user) #プロフィール用リンクがあることを確認
    delete logout_path #ログアウトパスにdeleteメソッドでアクセス
    assert_not is_logged_in? #ログイン状態ではないことを確認
    assert_redirected_to root_url
    follow_redirect! #そのページに実際に移動
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end
end

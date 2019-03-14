require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin) #管理者でログイン
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name #管理者は名前が表示
      unless user == @admin #管理者じゃないユーザー
        assert_select 'a[href=?]', user_path(user), text: 'delete' #deleteが表示
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin) #非管理者をdeleteをしたら総数-1
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin) #非管理者でログイン
    get users_path
    assert_select 'a', text: 'delete', count: 0 #deleteは表示されない
  end
end

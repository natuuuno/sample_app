require 'test_helper'

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)
    # has_many,belong_toの関連づけを行うと、user.microposts.createみたいな書き方で、userを通してmicropostを作成できる
    # buildはnewと同様オブジェクトを返すが、bdに反映しない
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  #micropostが有効か
  test "should be valid" do 
    assert @micropost.valid?
  end

  #user_idが存在してるか
  test "user id should be present" do 
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  #contentが存在してるか
  test "content should be present" do 
    @micropost.content = "   "
    assert_not @micropost.valid?
  end

  #contentの長さが140字以内か
  test "content should be at most 140 characters" do 
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

  #db上の最初のmicropostがfixture内のmicropost(most_recent)と同じか
  test "order should be most recent first" do 
    assert_equal microposts(:most_recent), Micropost.first
  end
end

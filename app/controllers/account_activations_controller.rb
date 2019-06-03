class AccountActivationsController < ApplicationController
    #アカウントを有効化するeditアクション
    def edit
        user = User.find_by(email: params[:email])
        if user && !user.activated? && user.authenticated?(:activation, params[:id]) 
            user.activate #ユーザーをアクティブに
            log_in user #ログイン
            flash[:success] = "Account activated!"
            redirect_to user #ユーザーページにリダイレクト
        else
            flash[:danger] = "Invalid activation link"
            redirect_to root_url #トップにリダイレクト
        end
      end
end

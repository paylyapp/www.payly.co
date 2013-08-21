class UserController < ApplicationController
  layout "user"
  before_filter :authenticate_user!

  def root
    @pre_title = "Pages Dashboard"
    @user = current_user
    if @user.stacks.where(:archived => false).empty?
      @stack = Stack.new
      @stack.seller_name = @user.full_name
      @stack.seller_email = @user.email
      @stack.page_token = loop do
        random_token = SecureRandom.urlsafe_base64
        break random_token unless Stack.where(:page_token => random_token).exists?
      end
    else
      @stacks = @user.stacks
      @transactions = []
      @stacks.each do |stack|
        if stack.archived == false
          stack.transactions.each do |transaction|
            @transactions << transaction
          end
        end
      end
      @transactions = @transactions.sort {|x,y| y["created_at"] <=> x["created_at"] }
      @transactions = @transactions.take(10)
    end
  end

  def settings
    @user = User.find(current_user)
  end
end

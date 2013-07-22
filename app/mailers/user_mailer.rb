class UserMailer < ActionMailer::Base
  default :from => "Tim from Payly <welcome@payly.co>"

  def welcome_email(user)
    @user = user
    @url  = "http://payly.co/login"
    mail(:to => user.email, :subject => "Welcome to Payly")
  end
end

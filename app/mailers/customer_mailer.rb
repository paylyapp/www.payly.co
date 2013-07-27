class CustomerMailer < ActionMailer::Base
  default :from => "Tim from Payly <receipt@payly.co>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.customer.confirmation.subject
  #
  def confirmation(customer)
    @customer = customer
    @url = pocket_path(:token => @customer.user_token)
    mail(:to => @customer.email, :subject => "Pocket - Confirmation your identity")
  end
end

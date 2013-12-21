class CustomerMailer < ActionMailer::Base
  layout "email"

  default :from => "Tim from Payly <info@payly.co>"

  def confirmation(customer)
    @customer = customer
    mail(:to => @customer.email, :subject => "Pocket - Confirmation your identity")
  end
end

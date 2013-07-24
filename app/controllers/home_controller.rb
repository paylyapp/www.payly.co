class HomeController < ApplicationController
  def index

  end

  def faqs
    @title = "FAQs"
  end

  def terms
    @title = "Terms of Service"
  end

  def privacy
    @title = "Privacy Policy"
  end

  def thank_you
    @title = "Thanks for signing up"
  end
end

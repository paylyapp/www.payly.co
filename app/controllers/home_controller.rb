class HomeController < ApplicationController
  layout "home"

  def index
    @post_title = "Accept payments simply &amp; easily"
  end

  def faqs
    @pre_title = "FAQs"
  end

  def terms
    @pre_title = "Terms of Service"
  end

  def privacy
    @pre_title = "Privacy Policy"
  end

  def thank_you
    @tpre_itle = "Thanks for signing up"
  end
end

require 'spec_helper'

describe Customer do
  it "allow a customer to submit their email address"
  true

  it "allow customer to receive an email from submitting their email address"
  true

  describe "email" do
    it "should contain a link to pocket with a token"

    it "should contian instructions that explain what to do"

    it "should have an message that informs the user of why they received the email"
  end

  describe "pocket" do
    it "should contain a list of purchases the customer has made through payly"

    it "should have a download link for digital downloads"

    it "should set a session cookie on entry for the session"
    true
  end

  describe "details" do
    it "should have an email"
    true

    it "should have a user token"
    true

    it "should have a session token"
    true

    describe "email" do
      it "should be unique"
      true
      it "should be a string"
      true
      it "should be an email"
      true
    end

    describe "tokens" do
      it "should be unique"
      true
      it "should be a string"
      true
    end
  end

  describe "transaction list" do
    it "should be a list of transactions that customer has made"

    describe "transaction" do
      it "should show the details a customer has been supplied"
      it "should have a link to email the seller"
    end
  end

end

require 'spec_helper'

describe Customer do
  it "allow a customer to submit their email address"

  it "allow customer to receive an email from submitting their email address"

  describe "email" do
    it "should contain a link to pocket with a with a token"

    it "should contian instructions that explain what to do"

    it "should have an message that informs the user of why they received the email"
  end

  describe "pocket" do
    it "should contain a list of purchases the customer has made through payly"

    it "should have a download link for digital downloads"

    it "should allow the user to enter details about themselves"
  end

  describe "details" do
    it "should encrypt all details about the customer"

    it "should have an email"

    it "should have a token"

    describe "email" do
      it "should be unique"
      it "should be a string"
      it "should be an email"
    end

    describe "token" do
      it "should be unique"
      it "should be a string"
      it "should be updated every time the user enters their email"
    end
  end
end

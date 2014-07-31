require 'spec_helper'

describe Cielo::Connection do
  before do
    FakeWeb.allow_net_connect = true

    @connection = Cielo::Connection.new
    @connection2 = Cielo::Connection.new "1001734898", "e84827130b9837473681c2787007da5914d6359947015a5cdb2b8843db0fa832"
  end

  after do
    FakeWeb.allow_net_connect = false
  end

  it "should estabilish connection when was created" do
    @connection.environment.should_not be_nil
    @connection2.environment.should_not be_nil
  end

  describe "making a request" do
    it "should make a request" do
      response = @connection.request! :data => "Anything"

      response.body.should_not be_nil
      response.should be_kind_of Net::HTTPSuccess
    end
  end

  describe "passing an access key and a client number" do
    it "should make a request whithout any problem" do
      response = @connection2.request! :data => "Anything"

      response.body.should_not be_nil
      response.should be_kind_of Net::HTTPSuccess
    end
  end

end

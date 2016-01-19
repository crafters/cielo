require 'spec_helper'

describe Cielo::Connection do
  before do
    WebMock.allow_net_connect!

    @connection = Cielo::Connection.new
    @connection2 = Cielo::Connection.new '1001734898', 'e84827130b9837473681c2787007da5914d6359947015a5cdb2b8843db0fa832'
  end

  after do
    WebMock.disable_net_connect!
  end

  it 'should estabilish connection when was created' do
    expect(@connection.environment).to_not be_nil
    expect(@connection2.environment).to_not be_nil
  end

  describe 'making a request' do
    it 'should make a request' do
      response = @connection.request! data: 'Anything'

      expect(response.body).to_not be_nil
      expect(response).to be_kind_of(Net::HTTPSuccess)
    end
  end

  describe 'passing an access key and a client number' do
    it 'should make a request whithout any problem' do
      response = @connection2.request! data: 'Anything'

      expect(response.body).to_not be_nil
      expect(response).to be_kind_of(Net::HTTPSuccess)
    end
  end
end

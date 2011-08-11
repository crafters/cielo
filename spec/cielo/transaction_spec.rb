#encoding: utf-8
require 'spec_helper'

describe Cielo::Transaction do
  before do
    @transaction = Cielo::Transaction.new
  end
  
  describe "create a transaction" do
    before do
      @params = {:numero => "1", :valor => "100", :bandeira => "visa", :"url-retorno" => "http://some.thing.com"}
    end
    [:numero, :valor, :bandeira, :"url-retorno"].each do |parameter|
      it "raises an error when #{parameter} isn't informed" do
        lambda { @transaction.create! @params.except!(parameter) }.should raise_error(Cielo::MissingArgumentError)
      end
    end
    it "delivers an successful message" do
      response = @transaction.create! @params
      
      response[:transacao][:tid].should_not be_nil
      response[:transacao][:"url-autenticacao"].should_not be_nil
      
      response = @transaction.catch!("1001734898056B3C1001")
      
    end
    
    it "delivers a response with error message when status isn't 200" do
      FakeWeb.register_uri(:any, "https://qasecommerce.cielo.com.br/servicos/ecommwsec.do",
        :body => "Nothing to be found 'round here",
        :status => ["404", "Not Found"])
      response = @transaction.create! @params
      
      response[:erro].should_not be_nil
      response[:erro][:codigo].should be_eql("000")
    end
    
    it "delivers a response with error message when the server send" do
      FakeWeb.register_uri(:any, "https://qasecommerce.cielo.com.br/servicos/ecommwsec.do",
        :body => "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?> <erro xmlns=\"http://ecommerce.cbmp.com.br\"> <codigo>001</codigo> <mensagem>Requisição inválida</mensagem> </erro>", :content_type => "application/xml")
      response = @transaction.create! @params

      response[:erro].should_not be_nil
      response[:erro][:codigo].should be_eql("001")
    end
    
  end
  
  describe "Verify a transaction status" do
    it "returns null when no tid is informed" do
      @transaction.verify!(nil).should be_nil
    end
    it "returns a successfull message" do
      FakeWeb.register_uri(:any, "https://qasecommerce.cielo.com.br/servicos/ecommwsec.do",
        :body => "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n<transacao id=\"1308170973\" versao=\"1.1.0\" xmlns=\"http://ecommerce.cbmp.com.br\">\n  <tid>1001734898056B3C1001</tid>\n  <dados-pedido>\n    <numero>1</numero>\n    <valor>100</valor>\n    <moeda>986</moeda>\n    <data-hora>2011-06-15T18:45:16.705-02:00</data-hora>\n    <idioma>PT</idioma>\n  </dados-pedido>\n  <forma-pagamento>\n    <bandeira>visa</bandeira>\n    <produto>1</produto>\n    <parcelas>1</parcelas>\n  </forma-pagamento>\n  <status>0</status>\n</transacao>\n\n", :content_type => "application/xml")
      
      response = @transaction.verify!("1001734898056B3C1001")

      response[:transacao][:tid].should_not be_nil
      response[:transacao][:status].should_not be_nil
    end
  end
  
  describe "Catch a transaction" do
    it "returns null when no tid is informed" do
      @transaction.catch!(nil).should be_nil
    end
    it "returns a successfull message" do
      FakeWeb.register_uri(:any, "https://qasecommerce.cielo.com.br/servicos/ecommwsec.do",
        :body => "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n<transacao id=\"1308170973\" versao=\"1.1.0\" xmlns=\"http://ecommerce.cbmp.com.br\">\n  <tid>1001734898056B3C1001</tid>\n  <dados-pedido>\n    <numero>1</numero>\n    <valor>100</valor>\n    <moeda>986</moeda>\n    <data-hora>2011-06-15T18:45:16.705-02:00</data-hora>\n    <idioma>PT</idioma>\n  </dados-pedido>\n  <forma-pagamento>\n    <bandeira>visa</bandeira>\n    <produto>1</produto>\n    <parcelas>1</parcelas>\n  </forma-pagamento>\n  <status>0</status>\n</transacao>\n\n", :content_type => "application/xml")
      
      response = @transaction.catch!("1001734898056B3C1001")

      response[:transacao][:tid].should_not be_nil
      response[:transacao][:status].should_not be_nil
    end
  end
  
  describe "Using a production environment" do
    before do
      Cielo.setup do |config|
        config.environment = :production
        config.numero_afiliacao = "1001734891"
        config.chave_acesso="e84827130b9837473681c2787007da5914d6359947015a5cdb2b8843db0fa832"
      end
    end
    
    it "must use the production environment" do
      Cielo.numero_afiliacao.should be_eql "1001734891"
    end
    
  end
  
end
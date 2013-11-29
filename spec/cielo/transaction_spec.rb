#encoding: utf-8
require 'spec_helper'

describe Cielo::Transaction do
  let(:default_params) { {:numero => "1", :valor => "100", :bandeira => "visa", :"url-retorno" => "http://some.thing.com"} }
  let(:card_params) { { :cartao_numero => '4012888888881881',  :cartao_validade => '201508', :cartao_indicador => '1', :cartao_seguranca => '973', :cartao_portador => 'Nome portador' } }
  let(:card_token_params) { { :cartao_numero => '4012888888881881',  :cartao_validade => '201508', :cartao_portador => 'Nome portador' } }

  before do
    @transaction = Cielo::Transaction.new
    @token = Cielo::Token.new
  end

  describe "create a buy page store transaction with token" do 
    before do 
      Cielo.stub(:numero_afiliacao).and_return('1006993069')
      Cielo.stub(:chave_acesso).and_return('25fbb99741c739dd84d7b06ec78c9bac718838630f30b112d033ce2e621b34f3')
      response = @token.create! card_token_params, :store
      token = response[:"retorno-token"][:token][:"dados-token"][:"codigo-token"]

      @params = default_params.merge(:token => token, :autorizar => 3)
    end

    it 'delivers an successful message' do
      response = @transaction.create! @params, :store

      # 7 is when transactions was not autenticated
      response[:transacao][:autenticacao][:eci].should eq("7")
    end
  end


  describe "create a buy page store recurrent transaction with token" do 
    before do 
      Cielo.stub(:numero_afiliacao).and_return('1006993069')
      Cielo.stub(:chave_acesso).and_return('25fbb99741c739dd84d7b06ec78c9bac718838630f30b112d033ce2e621b34f3')
      response = @token.create! card_token_params, :store
      token = response[:"retorno-token"][:token][:"dados-token"][:"codigo-token"]

      # #autorizar => 4 indicates recurring transaction
      @params = default_params.merge(:token => token, :autorizar => 4)
    end

    it 'delivers an successful message' do
      response = @transaction.create! @params, :store

      # 7 is when transactions was not autenticated
      response[:transacao][:autenticacao][:eci].should eq("7")
    end
  end

  # Error on system whe uses gerar-token => true (Verify with Cielo)
  # describe "create a buy page store transaction with token generation" do 
  #   before do
  #     Cielo.stub(:numero_afiliacao).and_return('1006993069')
  #     Cielo.stub(:chave_acesso).and_return('25fbb99741c739dd84d7b06ec78c9bac718838630f30b112d033ce2e621b34f3')

  #     default_params.merge!(:"gerar-token" => false)

  #     @params = default_params.merge(card_params)
  #   end

  #   it 'delivers an successful message and have a card token' do
  #     response = @transaction.create! @params, :store

  #     response[:transacao][:tid].should_not be_nil
  #     response[:transacao][:"url-autenticacao"].should_not be_nil
  #     # Verifies if token is not nil, it can be used for future transactions
  #     response[:transacao][:"codigo-token"].should_not be_nil
  #   end
  # end

  describe "create a buy page store transaction" do
    before do
      Cielo.stub(:numero_afiliacao).and_return('1006993069')
      Cielo.stub(:chave_acesso).and_return('25fbb99741c739dd84d7b06ec78c9bac718838630f30b112d033ce2e621b34f3')

      @params = default_params.merge(card_params)
    end

    [:cartao_portador, :cartao_numero, :cartao_validade, :cartao_seguranca, :numero, :valor, :bandeira, :"url-retorno"].each do |parameter|
      it "raises an error when #{parameter} isn't informed" do
        lambda { @transaction.create!(@params.except!(parameter), :store) }.should raise_error(Cielo::MissingArgumentError)
      end
    end

    it 'delivers an successful message' do
      response = @transaction.create! @params, :store

      response[:transacao][:tid].should_not be_nil
      response[:transacao][:"url-autenticacao"].should_not be_nil

      response = @transaction.catch!("1001734898056B3C1001")
    end
  end

  describe "create a buy page cielo transaction" do
    before do
      @params = default_params
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

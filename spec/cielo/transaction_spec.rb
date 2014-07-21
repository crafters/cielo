#encoding: utf-8
require 'spec_helper'

describe Cielo::Transaction do
  let(:default_params) { {:numero => "1", :valor => "100", :bandeira => "visa", :"url-retorno" => "http://some.thing.com"} }
  let(:card_params) { { :cartao_numero => '4012888888881881',  :cartao_validade => '201508', :cartao_indicador => '1', :cartao_seguranca => '973', :cartao_portador => 'Nome portador' } }
  let(:card_token_params) { { :cartao_numero => '4012888888881881',  :cartao_validade => '201508', :cartao_portador => 'Nome portador' } }
  let(:authentication_card_params){ { :cartao_numero => '5453010000066167', :cartao_validade => '201805', :cartao_seguranca => "123", :cartao_portador => "Nome portador" }}

  before do
    @transaction = Cielo::Transaction.new
    @token = Cielo::Token.new
  end

  describe "create a buy page store transaction with token" do
    before do
      Cielo.stub(:numero_afiliacao).and_return('1006993069')
      Cielo.stub(:chave_acesso).and_return('25fbb99741c739dd84d7b06ec78c9bac718838630f30b112d033ce2e621b34f3')

      FakeWeb.register_uri(:any, "https://qasecommerce.cielo.com.br/servicos/ecommwsec.do",
        :body => "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?><retorno-token versao=\"1.2.1\" id=\"57239017\" xmlns=\"http://ecommerce.cbmp.com.br\"><token><dados-token><codigo-token>TuS6LeBHWjqFFtE7S3zR052Jl/KUlD+tYJFpAdlA87E=</codigo-token><status>1</status><numero-cartao-truncado>455187******0183</numero-cartao-truncado></dados-token></token></retorno-token>", :content_type => "application/xml")

      response = @token.create! card_token_params, :store
      token = response[:"retorno-token"][:token][:"dados-token"][:"codigo-token"]

      @params = default_params.merge(:token => token, :autorizar => 3)
    end

    it 'delivers an successful message' do
      FakeWeb.register_uri(:any, "https://qasecommerce.cielo.com.br/servicos/ecommwsec.do",
        :body => "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?><transacao versao=\"1.2.1\" id=\"1385758302\" xmlns=\"http://ecommerce.cbmp.com.br\"><tid>10069930690BB0381001</tid><pan>52WC7RsmcNuEUSjrYWAEhCOjoLMnMCm4KMTQBqN7PdM=</pan><dados-pedido><numero>1</numero><valor>100</valor><moeda>986</moeda><data-hora>2013-11-29T18:51:43.854-02:00</data-hora><idioma>PT</idioma><taxa-embarque>0</taxa-embarque></dados-pedido><forma-pagamento><bandeira>visa</bandeira><produto>1</produto><parcelas>1</parcelas></forma-pagamento><status>6</status><autenticacao><codigo>6</codigo><mensagem>Transacao sem autenticacao</mensagem><data-hora>2013-11-29T18:51:43.865-02:00</data-hora><valor>100</valor><eci>7</eci></autenticacao><autorizacao><codigo>6</codigo><mensagem>Transa??o autorizada</mensagem><data-hora>2013-11-29T18:51:43.869-02:00</data-hora><valor>100</valor><lr>00</lr><arp>123456</arp><nsu>766008</nsu></autorizacao><captura><codigo>6</codigo><mensagem>Transacao capturada com sucesso</mensagem><data-hora>2013-11-29T18:51:44.006-02:00</data-hora><valor>100</valor></captura></transacao>", :content_type => "application/xml")

      response = @transaction.create! @params, :store

      # 7 is when transactions was not autenticated
      response[:transacao][:autenticacao][:eci].should eq("7")
    end
  end

  describe "create a recurring transaction with token" do
    before do
      Cielo.stub(:numero_afiliacao).and_return('1006993069')
      Cielo.stub(:chave_acesso).and_return('25fbb99741c739dd84d7b06ec78c9bac718838630f30b112d033ce2e621b34f3')

      FakeWeb.register_uri(:any, "https://qasecommerce.cielo.com.br/servicos/ecommwsec.do",
        :body => "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?><retorno-token versao=\"1.2.1\" id=\"57239017\" xmlns=\"http://ecommerce.cbmp.com.br\"><token><dados-token><codigo-token>TuS6LeBHWjqFFtE7S3zR052Jl/KUlD+tYJFpAdlA87E=</codigo-token><status>1</status><numero-cartao-truncado>455187******0183</numero-cartao-truncado></dados-token></token></retorno-token>", :content_type => "application/xml")

      response = @token.create! card_token_params, :store
      token = response[:"retorno-token"][:token][:"dados-token"][:"codigo-token"]

      # #autorizar => 4 indicates recurring transaction
      @params = default_params.merge(:token => token, :autorizar => 4)
    end

    it 'delivers an successful message' do
      FakeWeb.register_uri(:any, "https://qasecommerce.cielo.com.br/servicos/ecommwsec.do",
        :body => "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?><transacao versao=\"1.2.1\" id=\"1385758302\" xmlns=\"http://ecommerce.cbmp.com.br\"><tid>10069930690BB0381001</tid><pan>52WC7RsmcNuEUSjrYWAEhCOjoLMnMCm4KMTQBqN7PdM=</pan><dados-pedido><numero>1</numero><valor>100</valor><moeda>986</moeda><data-hora>2013-11-29T18:51:43.854-02:00</data-hora><idioma>PT</idioma><taxa-embarque>0</taxa-embarque></dados-pedido><forma-pagamento><bandeira>visa</bandeira><produto>1</produto><parcelas>1</parcelas></forma-pagamento><status>6</status><autenticacao><codigo>6</codigo><mensagem>Transacao sem autenticacao</mensagem><data-hora>2013-11-29T18:51:43.865-02:00</data-hora><valor>100</valor><eci>7</eci></autenticacao><autorizacao><codigo>6</codigo><mensagem>Transa??o autorizada</mensagem><data-hora>2013-11-29T18:51:43.869-02:00</data-hora><valor>100</valor><lr>00</lr><arp>123456</arp><nsu>766008</nsu></autorizacao><captura><codigo>6</codigo><mensagem>Transacao capturada com sucesso</mensagem><data-hora>2013-11-29T18:51:44.006-02:00</data-hora><valor>100</valor></captura></transacao>", :content_type => "application/xml")

      response = @transaction.create! @params, :store

      # 7 is when transactions was not autenticated
      response[:transacao][:autenticacao][:eci].should eq("7")
    end
  end

  # Error on system when uses gerar-token => true (Verify with Cielo)
  describe "create a buy page store transaction with token generation" do
    before do
      FakeWeb.register_uri(:any, "https://qasecommerce.cielo.com.br/servicos/ecommwsec.do",
        :body => "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?><transacao versao=\"1.2.1\" id=\"1390315327\" xmlns=\"http://ecommerce.cbmp.com.br\"><tid>10069930690DCC341001</tid><pan>52WC7RsmcNuEUSjrYWAEhCOjoLMnMCm4KMTQBqN7PdM=</pan><dados-pedido><numero>1</numero><valor>100</valor><moeda>986</moeda><data-hora>2014-01-21T12:42:08.865-02:00</data-hora><idioma>PT</idioma><taxa-embarque>0</taxa-embarque></dados-pedido><forma-pagamento><bandeira>visa</bandeira><produto>1</produto><parcelas>1</parcelas></forma-pagamento><status>6</status><autenticacao><codigo>6</codigo><mensagem>Transacao sem autenticacao</mensagem><data-hora>2014-01-21T12:42:08.872-02:00</data-hora><valor>100</valor><eci>7</eci></autenticacao><autorizacao><codigo>6</codigo><mensagem>Transa??o autorizada</mensagem><data-hora>2014-01-21T12:42:08.885-02:00</data-hora><valor>100</valor><lr>00</lr><arp>123456</arp><nsu>904244</nsu></autorizacao><captura><codigo>6</codigo><mensagem>Transacao capturada com sucesso</mensagem><data-hora>2014-01-21T12:42:08.912-02:00</data-hora><valor>100</valor></captura><token><dados-token><codigo-token>2ta/YqYaeyolf2NHkBWO8grPqZE44j3PvRAQxVQQGgE=</codigo-token><status>1</status><numero-cartao-truncado>401288******1881</numero-cartao-truncado></dados-token></token></transacao>", :content_type => "application/xml")

      Cielo.stub(:numero_afiliacao).and_return('1006993069')
      Cielo.stub(:chave_acesso).and_return('25fbb99741c739dd84d7b06ec78c9bac718838630f30b112d033ce2e621b34f3')

      default_params.merge!(:"gerar-token" => true, :autorizar => 3)

      @params = default_params.merge(card_params)
    end

    it 'delivers an successful message and have a card token' do
      response = @transaction.create! @params, :store

      response[:transacao][:tid].should_not be_nil
      response[:transacao][:token][:"dados-token"][:"codigo-token"].should_not be_nil
    end
  end

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
      FakeWeb.register_uri(:any, "https://qasecommerce.cielo.com.br/servicos/ecommwsec.do",
        :body => "<?xml version='1.0' encoding='ISO-8859-1'?><transacao versao='1.2.1' id='1385759313' xmlns='http://ecommerce.cbmp.com.br'><tid>10069930690BB0441001</tid><pan>52WC7RsmcNuEUSjrYWAEhCOjoLMnMCm4KMTQBqN7PdM=</pan><dados-pedido><numero>1</numero><valor>100</valor><moeda>986</moeda><data-hora>2013-11-29T19:08:34.048-02:00</data-hora><idioma>PT</idioma><taxa-embarque>0</taxa-embarque></dados-pedido><forma-pagamento><bandeira>visa</bandeira><produto>1</produto><parcelas>1</parcelas></forma-pagamento><status>0</status><url-autenticacao>https://qasecommerce.cielo.com.br/web/index.cbmp?id=55152147c2c9e44c340cb4e50d171e37</url-autenticacao></transacao>", :content_type => "application/xml")

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

  describe "Cancel a transaction" do
    it "returns null when no tid is informed" do
      @transaction.cancel!(nil).should be_nil
    end
    it "returns a successfull message" do
      FakeWeb.register_uri(:any, "https://qasecommerce.cielo.com.br/servicos/ecommwsec.do",
        :body => "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n<transacao id=\"1308170973\" versao=\"1.1.0\" xmlns=\"http://ecommerce.cbmp.com.br\">\n  <tid>1001734898056B3C1001</tid>\n  <dados-pedido>\n    <numero>1</numero>\n    <valor>100</valor>\n    <moeda>986</moeda>\n    <data-hora>2011-06-15T18:45:16.705-02:00</data-hora>\n    <idioma>PT</idioma>\n  </dados-pedido>\n  <forma-pagamento>\n    <bandeira>visa</bandeira>\n    <produto>1</produto>\n    <parcelas>1</parcelas>\n  </forma-pagamento>\n  <status>0</status>\n</transacao>\n\n", :content_type => "application/xml")

      response = @transaction.cancel!("1001734898056B3C1001")

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

    it "must use the production client number" do
      @connection = Cielo::Connection.new
      @connection.numero_afiliacao.should be_eql "1001734891"
    end

    it "must use the configuration informed" do
      @connection2 = Cielo::Connection.new "0100100100", "e84827130b9837473681c2787007da5914d6359947015a5cdb2b8843db0fa800"
      @connection2.numero_afiliacao.should be_eql "0100100100"
      @connection2.chave_acesso.should be_eql "e84827130b9837473681c2787007da5914d6359947015a5cdb2b8843db0fa800"
    end

  end

end

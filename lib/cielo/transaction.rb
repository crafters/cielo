#encoding: utf-8
require 'bigdecimal'
module Cielo
  class Transaction

    attr_reader :numero_afiliacao
    attr_reader :chave_acesso
    attr_reader :versao

    def initialize numero_afiliacao = Cielo.numero_afiliacao, chave_acesso = Cielo.chave_acesso, versao = '1.2.1'
      @numero_afiliacao = numero_afiliacao
      @chave_acesso = chave_acesso
      @versao = versao
      @connection = Cielo::Connection.new @numero_afiliacao, @chave_acesso, @versao
    end

    def create!(parameters = {}, buy_page = :cielo)
      if buy_page == :store
        store_page_create!(parameters)
      else
        cielo_page_create!(parameters)
      end
    end

    def store_page_create!(parameters={})
      analysis_parameters(parameters, :buy_page_store)
      message = @connection.xml_builder('requisicao-transacao') do |xml, target|
        if target == :after
          xml.tag!("dados-portador") do
            if parameters[:token].present?
              xml.tag!('token', parameters[:token])
            else
              xml.tag!('numero', parameters[:cartao_numero])
              xml.tag!('validade', parameters[:cartao_validade])
              xml.tag!('indicador', parameters[:cartao_indicador])
              xml.tag!('codigo-seguranca', parameters[:cartao_seguranca])
              xml.tag!('nome-portador', parameters[:cartao_portador])
              xml.tag!('token', '')
            end
          end
          default_transaction_xml(xml, parameters)
        end
      end

      @connection.make_request! message
    end

    def cielo_page_create!(parameters={})
      analysis_parameters(parameters, :buy_page_cielo)
      message = @connection.xml_builder("requisicao-transacao") do |xml, target|
        if target == :after
          default_transaction_xml(xml, parameters)
        end
      end
      @connection.make_request! message
    end

    def verify!(cielo_tid)
      return nil unless cielo_tid
      message = @connection.xml_builder("requisicao-consulta") do |xml, target|
        if target == :before
          xml.tid "#{cielo_tid}"
        end
      end

      @connection.make_request! message
    end

    def catch!(cielo_tid)
      return nil unless cielo_tid
      message = @connection.xml_builder("requisicao-captura") do |xml, target|
        if target == :before
          xml.tid "#{cielo_tid}"
        end
      end
      @connection.make_request! message
    end

    def authorize!(cielo_tid)
      return nil unless cielo_tid
      message = @connection.xml_builder("requisicao-autorizacao-tid") do |xml, target|
        if target == :before
          xml.tid "#{cielo_tid}"
        end
      end
      @connection.make_request! message
    end

    def cancel!(cielo_tid, valor=0)
      return nil unless cielo_tid
      message = @connection.xml_builder("requisicao-cancelamento") do |xml, target|
        if target == :before
          xml.tid "#{cielo_tid}"
        end
        if target == :after
          xml.valor "#{valor}" if BigDecimal.new(valor) > 0
        end
      end
      @connection.make_request! message
    end

    private
    def default_transaction_xml(xml, parameters)
      xml.tag!("dados-pedido") do
        [:numero, :valor, :moeda, :"data-hora", :idioma, :"soft-descriptor"].each do |key|
          xml.tag!(key.to_s, parameters[key].to_s)
        end
      end
      xml.tag!("forma-pagamento") do
        [:bandeira, :produto, :parcelas].each do |key|
          xml.tag!(key.to_s, parameters[key].to_s)
        end
      end
      xml.tag!("url-retorno", parameters[:"url-retorno"])
      xml.autorizar parameters[:autorizar].to_s
      xml.capturar parameters[:capturar].to_s
      xml.tag!("gerar-token", parameters[:"gerar-token"])
    end

    def analysis_parameters(parameters={}, buy_page = :buy_page_cielo)
      to_analyze = [:numero, :valor, :bandeira, :"url-retorno"]

      if buy_page == :buy_page_store
        if parameters[:token].present?
          to_analyze.concat([:token])
        else
          to_analyze.concat([:cartao_numero, :cartao_validade, :cartao_portador])
          to_analyze.concat([:cartao_seguranca]) unless ['1.0.0', '1.1.0', '1.1.1'].include?(@versao)
        end
      end

      to_analyze.each do |parameter|
        raise Cielo::MissingArgumentError, "Required parameter #{parameter} not found" unless parameters[parameter]
      end

      parameters.merge!(:moeda => "986") unless parameters[:moeda]
      parameters.merge!(:"data-hora" => Time.now.strftime("%Y-%m-%dT%H:%M:%S")) unless parameters[:"data-hora"]
      parameters.merge!(:idioma => "PT") unless parameters[:idioma]
      parameters.merge!(:produto => "1") unless parameters[:produto]
      parameters.merge!(:parcelas => "1") unless parameters[:parcelas]
      parameters.merge!(:autorizar => "2") unless parameters[:autorizar]
      parameters.merge!(:capturar => "true") unless parameters[:capturar]
      parameters.merge!(:"url-retorno" => Cielo.return_path) unless parameters[:"url-retorno"]
      parameters.merge!(:cartao_indicador => '1') unless parameters[:cartao_indicador] && buy_page == :buy_page_store
      parameters.merge!(:"gerar-token" => false) unless parameters[:"gerar-token"]

      parameters
    end


  end
end

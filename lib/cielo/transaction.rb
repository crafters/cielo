#encoding: utf-8
module Cielo
  class Transaction
    def initialize
      @connection = Cielo::Connection.new
    end
    def create!(parameters={})
      analysis_parameters(parameters)
      message = xml_builder("requisicao-transacao") do |xml|
        xml.send("dados-pedido") do
          [:numero, :valor, :moeda, :"data-hora", :idioma].each do |key|
            xml.send(key.to_s, parameters[key].to_s)
          end
        end
        xml.send("forma-pagamento") do
          [:bandeira, :produto, :parcelas].each do |key|
            xml.send(key.to_s, parameters[key].to_s)
          end
        end
        xml.send("url-retorno", parameters[:"url-retorno"])
        xml.autorizar parameters[:autorizar].to_s
        xml.capturar parameters[:capturar].to_s
      end
      make_request! message
    end
    
    def verify!(cielo_tid)
      return nil unless cielo_tid
      message = xml_builder("requisicao-consulta", :before) do |xml|
        xml.tid "#{cielo_tid}"
      end
      
      make_request! message
    end
    
    def catch!(cielo_tid)
      return nil unless cielo_tid
      message = xml_builder("requisicao-captura", :before) do |xml|
        xml.tid "#{cielo_tid}"
      end
      make_request! message
    end
    
    private
    def analysis_parameters(parameters={})
      [:numero, :valor, :bandeira, :"url-retorno"].each do |parameter|
        raise Cielo::MissingArgumentError, "Required parameter #{parameter} not found" unless parameters[parameter]
      end
      parameters.merge!(moeda: "986") unless parameters[:moeda]
      parameters.merge!(:"data-hora" => Time.now.strftime("%Y-%m-%dT%H:%M:%S")) unless parameters[:"data-hora"]
      parameters.merge!(idioma: "PT") unless parameters[:idioma]
      parameters.merge!(produto: "1") unless parameters[:produto]
      parameters.merge!(parcelas: "1") unless parameters[:parcelas]
      parameters.merge!(autorizar: "2") unless parameters[:autorizar]
      parameters.merge!(capturar: "true") unless parameters[:capturar]
      parameters.merge!(:"url-retorno" => Cielo.return_path) unless parameters[:"url-retorno"]
      parameters
    end
    
    def xml_builder(group_name, target=:after, &block)
      xml = Builder::XmlMarkup.new
      xml.instruct! :xml, :version=>"1.0", :encoding=>"ISO-8859-1"
      xml.send(group_name, id: "#{Time.now.to_i}", versao: "1.1.0") do
        block.call(xml) if target == :before
        xml.send("dados-ec") do
          xml.numero Cielo.numero_afiliacao
          xml.chave Cielo.chave_acesso
        end
        block.call(xml) if target == :after
      end
      xml
    end
    
    def make_request!(message)
      params = { mensagem: message.target! }
      
      result = @connection.request! params
      parse_response(result)
    end
    
    def parse_response(response)
      case response
      when Net::HTTPSuccess
        document = REXML::Document.new(response.body)
        parse_elements(document.elements)
      else
        {:erro => { :codigo => "000", :mensagem => "Impossível contactar o servidor"}}
      end
    end
    def parse_elements(elements)
      map={}
      elements.each do |element|
        element_map = {}
        element_map = element.text if element.elements.empty? && element.attributes.empty?
        element_map.merge!("value" => element.text) if element.elements.empty? && !element.attributes.empty?
        element_map.merge!(parse_elements(element.elements)) unless element.elements.empty?
        map.merge!(element.name => element_map)
      end
      map.symbolize_keys
    end
  end
end
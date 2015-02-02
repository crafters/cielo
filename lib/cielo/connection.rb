#encoding: utf-8

module Cielo
  class Connection
    attr_reader :environment
    attr_reader :numero_afiliacao
    attr_reader :chave_acesso

    def initialize numero_afiliacao = Cielo.numero_afiliacao, chave_acesso = Cielo.chave_acesso
      @environment = eval(Cielo.environment.to_s.capitalize)
      @numero_afiliacao = numero_afiliacao
      @chave_acesso = chave_acesso
      port = 443
      @http = Net::HTTP.new(@environment::BASE_URL,port)
      @http.ssl_version = :TLSv1 if @http.respond_to? :ssl_version
      @http.use_ssl = true
      @http.open_timeout = 10*1000
      @http.read_timeout = 40*1000
    end

    def request!(params={})
      str_params = ""
      params.each do |key, value|
        str_params+="&" unless str_params.empty?
        str_params+="#{key}=#{value}"
      end
      @http.request_post(self.environment::WS_PATH, str_params)
    end

    def xml_builder(group_name, target=:after, &block)
      xml = Builder::XmlMarkup.new
      xml.instruct! :xml, :version=>"1.0", :encoding=>"ISO-8859-1"
      xml.tag!(group_name, :id => "#{Time.now.to_i}", :versao => "1.2.1") do
        block.call(xml) if target == :before
        xml.tag!("dados-ec") do
          xml.numero @numero_afiliacao #Cielo.numero_afiliacao
          xml.chave @chave_acesso #Cielo.chave_acesso
        end
        block.call(xml) if target == :after
      end
      xml
    end

    def make_request!(message)
      params = { :mensagem => message.target! }
      result = self.request! params
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

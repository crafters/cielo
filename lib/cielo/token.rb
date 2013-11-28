#encoding: utf-8
module Cielo
  class Token
    def initialize
      @connection = Cielo::Connection.new
    end

    def create!(parameters = {}, buy_page = :cielo)
      message = xml_builder('requisicao-token') do |xml|
        xml.tag!("dados-portador") do
          xml.tag!('numero', parameters[:cartao_numero])
          xml.tag!('validade', parameters[:cartao_validade])
          xml.tag!('nome-portador', parameters[:cartao_portador])
        end
      end

      @connection.make_request! message
    end

    private
    def xml_builder(group_name, target=:after, &block)
      xml = Builder::XmlMarkup.new
      xml.instruct! :xml, :version=>"1.0", :encoding=>"ISO-8859-1"
      xml.tag!(group_name, :id => "#{Time.now.to_i}", :versao => "1.2.1") do
        block.call(xml) if target == :before
        xml.tag!("dados-ec") do
          xml.numero Cielo.numero_afiliacao
          xml.chave Cielo.chave_acesso
        end
        block.call(xml) if target == :after
      end
      xml
    end
  end
end

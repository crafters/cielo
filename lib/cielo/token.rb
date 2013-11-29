#encoding: utf-8
module Cielo
  class Token
    def initialize
      @connection = Cielo::Connection.new
    end

    def create!(parameters = {}, buy_page = :cielo)
      message = @connection.xml_builder('requisicao-token') do |xml|
        xml.tag!("dados-portador") do
          xml.tag!('numero', parameters[:cartao_numero])
          xml.tag!('validade', parameters[:cartao_validade])
          xml.tag!('nome-portador', parameters[:cartao_portador])
        end
      end

      @connection.make_request! message
    end
  end
end

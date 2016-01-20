module Cielo
  class Token
    attr_accessor :response

    def initialize(connection = Cielo::Connection.new)
      @connection = connection
    end

    def create!(parameters = {}, _buy_page = :cielo)
      message = @connection.xml_builder('requisicao-token') do |xml, target|
        if target == :after
          xml.tag!('dados-portador') do
            xml.tag!('numero', parameters[:cartao_numero])
            xml.tag!('validade', parameters[:cartao_validade])
            xml.tag!('nome-portador', parameters[:cartao_portador])
          end
        end
      end

      self.response = @connection.make_request!(message)
    end
  end
end

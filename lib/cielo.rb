#encoding: utf-8
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/hash'
require "net/http"
require "rexml/document"
require "builder"
[:connection, :transaction].each { |lib| require "cielo/#{lib}" }

module Cielo

  # Write your own production class
  #class Production
  #  @@numero_afiliacao = "suporteweb@cielo.com.br"
  #  @@chave_acesso="suporteweb@cielo.com.br"
  #  cattr_reader :numero_afiliacao, :chave_acesso
  #  BASE_URL = "ecommerce.cbmp.com.br"
  #  WS_PATH = "/servicos/ecommwsec.do"
  #  DOMAIN_URL = "Your Web Site here"
  #end

  class Test
    @@numero_afiliacao = "1001734898"
    @@chave_acesso="e84827130b9837473681c2787007da5914d6359947015a5cdb2b8843db0fa832"
    cattr_reader :numero_afiliacao, :chave_acesso
    BASE_URL = "qasecommerce.cielo.com.br"
    WS_PATH = "/servicos/ecommwsec.do"
    DOMAIN_URL = "http://localhost:3000"
  end
  
  @@environment = :test
  mattr_accessor :environment

  def self.setup
    yield self
  end
  class MissingArgumentError < StandardError; end
end
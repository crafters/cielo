module Cielo
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)
      
      desc "Cria o initializer da cielo na app rails"
      
      def copy_initializer
        template "cielo.rb", "config/initializers/cielo.rb"
      end
      
    end
  end
end
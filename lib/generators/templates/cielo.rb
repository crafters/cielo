# encoding: utf-8
# Use esse arquivo para configurar a integração com a cielo.
Cielo.setup do |config|
  # Altere para production ao final dos seus testes
  # config.environment = :test
  
  # Número de afiliação fornecido pela cielo.
  # O numero padrão é o número usado para testes.
  # config.numero_afiliacao = "1001734898"
  
  # Chave de acesso para autenticação.
  # O número padrão é o número usado para os testes.
  # config.chave_acesso = "e84827130b9837473681c2787007da5914d6359947015a5cdb2b8843db0fa832"
  
  # Após o processamento pela cielo, o usuário será redirecionado para uma página.
  # que é configurada abaixo, nessa action você pode consultar o status do TID
  # para poder mostrar na tela.
  # config.return_path = "http://localhost:3000"
end
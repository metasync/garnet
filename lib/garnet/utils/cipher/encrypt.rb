# frozen_string_literal: true

module Garnet
  module Utils
    class Cipher
      def public_key
        OpenSSL::PKey::RSA.new(File.binread(public_key_file))
      end

      def private_key
        OpenSSL::PKey::RSA.new File.binread(private_key_file)
      end

      def encrypt(string)
        Base64.strict_encode64(public_key.public_encrypt(string))
      end

      def decrypt(encrypted_string)
        private_key.private_decrypt(Base64.strict_decode64(encrypted_string))
      end

      def encrypt_env_var(env_var)
        encrypt(ENV.fetch(env_var, nil))
      end

      def decrypt_env_var(env_var)
        decrypt(ENV.fetch(env_var, nil))
      end
    end
  end
end

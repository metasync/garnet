# frozen_string_literal: true

require_relative '../utils/cipher'

namespace :cipher do
  desc 'Generate cipher keys'
  task :generate_keys do
    Garnet::Utils::Cipher.new.generate_keys
  end

  desc 'Encrypt a string'
  task :encrypt, [:string] do |_, args|
    string = args.string
    if string.nil?
      require 'io/console'
      puts 'Enter text to encrypt'
      string = $stdin.noecho(&:gets).chomp
    end
    puts Garnet::Utils::Cipher.new.encrypt(string)
  end

  desc 'Encrypt an environment variable'
  task :encrypt_env_var, [:env_var] do |_, args|
    puts Garnet::Utils::Cipher.new.encrypt_env_var(args.env_var)
  end

  desc 'Decrypt an environment variable'
  task :decrypt_env_var, [:env_var] do |_, args|
    puts Garnet::Utils::Cipher.new.decrypt_env_var(args.env_var)
  end
end

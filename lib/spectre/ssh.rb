require 'net/ssh'
require 'logger'
require 'spectre'
require 'net/ssh/proxy/http'

module Spectre
  module SSH
    @@cfg = {}

    class SSHError < Exception
    end

    class SSHConnection < Spectre::DslClass
      def initialize host, username, opts, logger
        opts[:non_interactive] = true

        @__logger = logger
        @__host = host
        @__username = username
        @__opts = opts
        @__session = nil
        @__exit_code = nil
        @__output = ''
      end

      def username user
        @__username = user
      end

      def password pass
        @__opts[:password] = pass
        @__opts[:auth_methods].push 'password' unless @__opts[:auth_methods].include? 'password'
      end

      def private_key file_path
        @__opts[:keys] = [file_path]
        @__opts[:auth_methods].push 'publickey' unless @__opts[:auth_methods].include? 'publickey'
      end

      def passphrase phrase
        @__opts[:passphrase] = phrase
      end

      def file_exists path
        exec "ls #{path}"
        exit_code == 0
      end

      def owner_of path
        exec "stat -c %U #{path}"
        output.chomp
      end

      def connect!
        return unless @__session == nil or @__session.closed?

        begin
          @__session = Net::SSH.start(@__host, @__username, @__opts)
        rescue SocketError
          raise SSHError.new("Unable to connect to #{@__host} with user #{@__username}")
        rescue Net::SSH::AuthenticationFailed
          raise SSHError.new("Authentication failed for #{@__username}@#{@__host}. Please check password, SSH keys and passphrases.")
        end
      end

      def close
        return unless @__session and not @__session.closed?

        @__session.close
      end

      def can_connect?
        @__output = nil

        begin
          connect!
          @__session.open_channel.close
          @__output = "successfully connected to #{@__host} with user #{@__username}"
          @__exit_code = 0
          return true
        rescue Exception => e
          @__logger.error e.message
          @__output = "unable to connect to #{@__host} with user #{@__username}"
          @__exit_code = 1
        end

        return false
      end

      def exec command
        connect!

        log_str = "#{@__session.options[:user]}@#{@__session.host} -p #{@__session.options[:port]} #{command}"

        @channel = @__session.open_channel do |channel|
          channel.exec(command) do |_ch, success|
            abort "could not execute #{command} on #{@__session.host}" unless success

            @__output = ''

            channel.on_data do |_, data|
              @__output += data
            end

            channel.on_extended_data do |_, _type, data|
              @__output += data
            end

            channel.on_request('exit-status') do |_, data|
              @__exit_code = data.read_long
            end

            # channel.on_request('exit-signal') do |ch, data|
            #   exit_code = data.read_long
            # end
          end
        end

        @channel.wait
        @__session.loop

        log_str += "\n" + @__output
        @__logger.info log_str
      end

      def output
        @__output
      end

      def exit_code
        @__exit_code
      end
    end


    class << self
      def ssh name, options = {}, &block
        cfg = @@cfg[name] || {}

        host = cfg['host'] || name
        username = options[:username] || cfg['username']
        password = options[:password] || cfg['password']

        opts = {}
        opts[:password] = password
        opts[:port] = options[:port] || cfg['port'] || 22

        ssh_key = options[:key] || cfg['key']
        opts[:keys] = [ssh_key] unless ssh_key.nil?
        opts[:passphrase] = options[:passphrase] || cfg['passphrase']

        opts[:auth_methods] = []
        opts[:auth_methods].push 'publickey' unless opts[:keys].nil? or opts[:keys].empty?
        opts[:auth_methods].push 'password' unless opts[:password].nil?

        proxy_host = options[:proxy_host] || cfg['proxy_host']
        proxy_port = options[:proxy_port] || cfg['proxy_port']
        opts[:proxy] = Net::SSH::Proxy::HTTP.new(proxy_host, proxy_port) unless proxy_host.nil?

        ssh_con = SSHConnection.new(host, username, opts, @@logger)

        begin
          ssh_con.instance_eval &block
        ensure
          ssh_con.close
        end
      end
    end

    Spectre.register do |config|
      @@logger = Spectre::Logging::ModuleLogger.new(config, 'spectre/ssh')

      if config.key? 'ssh'
        config['ssh'].each do |name, cfg|
          @@cfg[name] = cfg
        end
      end
    end

    Spectre.delegate :ssh, to: self
  end
end

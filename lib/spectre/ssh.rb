require 'net/ssh'
require 'net/ssh/proxy/http'
require 'logger'

module Spectre
  module SSH
    @@cfg = {}

    class SSHError < Exception
    end

    class SSHConnection
      attr_reader :exit_code, :output

      def initialize host, username, opts, logger
        opts[:non_interactive] = true

        @logger = logger
        @host = host
        @username = username
        @opts = opts
        @session = nil
        @exit_code = nil
        @output = ''
      end

      def username user
        @username = user
      end

      def password pass
        @opts[:password] = pass
        @opts[:auth_methods].push('password') unless @opts[:auth_methods].include? 'password'
      end

      def private_key file_path
        @opts[:keys] = [file_path]
        @opts[:auth_methods].push('publickey') unless @opts[:auth_methods].include? 'publickey'
      end

      def passphrase phrase
        @opts[:passphrase] = phrase
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
        return unless @session == nil or @session.closed?

        begin
          @session = Net::SSH.start(@host, @username, @opts)
        rescue SocketError
          raise SSHError.new("Unable to connect to #{@host} with user #{@username}")
        rescue Net::SSH::AuthenticationFailed
          raise SSHError.new("Authentication failed for #{@username}@#{@host}. Please check password, SSH keys and passphrases.")
        end
      end

      def close
        return unless @session and not @session.closed?

        @session.close
      end

      def can_connect?
        @output = nil

        begin
          connect!
          @session.open_channel.close
          @output = "successfully connected to #{@host} with user #{@username}"
          @exit_code = 0
          return true
        rescue Exception => e
          @logger.error e.message
          @output = "unable to connect to #{@host} with user #{@username}"
          @exit_code = 1
        end

        return false
      end

      def exec command
        connect!

        log_str = "ssh #{@username}@#{@session.host} -p #{@session.options[:port]} #{command}"

        @session.open_channel do |channel|
          channel.exec(command) do |_ch, success|
            abort "could not execute #{command} on #{@session.host}" unless success

            @output = ''

            channel.on_data do |_ch, data|
              @output += data
            end

            channel.on_extended_data do |_ch, _type, data|
              @output += data
            end

            channel.on_request('exit-status') do |_ch, data|
              @exit_code = data.read_long
            end

            channel.on_request('exit-signal') do |_ch, data|
              @exit_code = data.read_long
            end
          end
        end.wait

        @session.loop

        log_str += "\n" + @output
        @logger.info(log_str)
      end
    end

    class << self
      @@config = defined?(Spectre::CONFIG) ? Spectre::CONFIG['ssh'] : {}
      @@logger = defined?(Spectre.logger) ? Spectre.logger : Logger.new(STDOUT)

      def ssh name, options = {}, &block
        cfg = @@config[name] || {}

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
        opts[:auth_methods].push('publickey') unless opts[:keys].nil? or opts[:keys].empty?
        opts[:auth_methods].push('password') unless opts[:password].nil?

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
  end
end

describe 'spectre/ssh' do
  it 'can connect with password', tags: [:ssh, :password, :deps] do
    ssh 'localhost', port: 2222, username: 'developer', password: 'dev' do
      info 'trying to connect'

      expect 'to be able to connect via SSH' do
        can_connect?.should_be true
      end
    end
  end

  it 'can not connect with SSH', tags: [:ssh, :fail, :deps] do
    ssh 'localhost', port: 2222, username: 'developer', password: 'someworongpassword' do
      info 'trying to connect'

      expect 'to be able to connect via SSH' do
        can_connect?.should_be false
      end
    end
  end

  it 'can execute commands on server', tags: [:ssh, :deps] do
    ssh 'localhost', port: 2222, username: 'developer', password: 'dev' do
      log 'try to list files from user root'

      expect 'a logs directory in root directory' do
        exec 'ls'
        fail_with "no 'logs' directory" unless output.lines.include? "logs\n"
      end
    end
  end

  it 'can connect with ssh key', tags: [:ssh, :key, :deps] do
    ssh 'localhost', port: 2222, username: 'developer', key: resources['sample_key'], passphrase: 'test' do
      log 'try to list files from user root'

      expect 'a logs directory in root directory' do
        exec 'ls'
        fail_with "no 'logs' directory" unless output.lines.include? "logs\n"
      end
    end
  end

  it 'does not authenticate without passphrase', tags: [:ssh, :key, :deps] do
    observe do
      ssh 'localhost', port: 2222, username: 'developer', key: resources['sample_key'] do
        log 'try to list files from user root'

        exec 'ls'
        fail_with "no 'logs' directory" unless output.lines.include? "logs\n"
      end
    end

    expect 'the connection to fail' do
      success?.should_be false
    end
  end
end

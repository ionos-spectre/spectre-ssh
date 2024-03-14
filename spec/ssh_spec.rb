module Spectre
  CONFIG = {
    'ssh' => {
      'example' => {
        'host' => 'some-data.host',
        'username' => 'dummy',
        'password' => '<some-secret-password>',
      },
    },
  }
end

require_relative '../lib/spectre/ssh'

RSpec.describe 'SSH' do
  it 'does a ssh connection' do
    opts = [
      'some-data.host',
      'dummy',
      {
        auth_methods: ['password'],
        non_interactive: true,
        passphrase: nil,
        password: Spectre::CONFIG['ssh']['example']['password'],
        port: 22
      }
    ]

    net_ssh = double(Net::SSH)

    ssh_channel = double(Net::SSH::Connection::Channel)
    allow(ssh_channel).to receive(:wait)
    expect(ssh_channel).to receive(:exec).with('ls')

    ssh_session = double(Net::SSH::Connection::Session)
    allow(ssh_session).to receive(:open_channel).and_return(ssh_channel).and_yield(ssh_channel)
    allow(ssh_session).to receive(:closed?).and_return(false)
    allow(ssh_session).to receive(:close)
    allow(ssh_session).to receive(:loop)
    allow(ssh_session).to receive(:options).and_return(opts[2])
    allow(ssh_session).to receive(:host).and_return(opts[0])
    
    allow(Net::SSH).to receive(:start).with(*opts).and_return(ssh_session)


    Spectre::SSH.ssh 'some-data.host' do
      username 'dummy'
      password '<some-secret-password>'
      exec 'ls'
    end

    expect(ssh_channel).to receive(:exec).with('ls')
    
    Spectre::SSH.ssh 'example' do
      exec 'ls'
    end
  end
end

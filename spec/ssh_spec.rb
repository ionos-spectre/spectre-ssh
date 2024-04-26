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
        port: 22,
      }
    ]

    double(Net::SSH)

    ssh_channel = double(Net::SSH::Connection::Channel)
    allow(ssh_channel).to receive(:wait)
    allow(ssh_channel).to receive(:on_data)
      .and_yield(ssh_channel, 'some data')

    allow(ssh_channel).to receive(:on_extended_data)
    # .and_yield(ssh_channel, nil, 'some data')

    allow(ssh_channel).to receive(:on_request)
      .with('exit-status')
    # .and_yield(ssh_channel, 'some data')

    allow(ssh_channel).to receive(:on_request)
      .with('exit-signal')
    # .and_yield(ssh_channel, 'some data')

    ssh_session = double(Net::SSH::Connection::Session)
    allow(ssh_session).to receive(:open_channel)
      .and_return(ssh_channel)
      .and_yield(ssh_channel)

    allow(ssh_session).to receive(:closed?).and_return(false)
    allow(ssh_session).to receive(:close)
    allow(ssh_session).to receive(:loop)
    allow(ssh_session).to receive(:options).and_return(opts[2])
    allow(ssh_session).to receive(:host).and_return(opts[0])

    allow(Net::SSH).to receive(:start)
      .with(*opts)
      .and_return(ssh_session)

    expect(ssh_channel).to receive(:exec).with('ls').and_yield(ssh_channel, true)
    expect(ssh_channel).to receive(:exec).with('ls dummy.txt')
    expect(ssh_channel).to receive(:exec).with('stat -c %U dummy.txt')

    test_output = nil

    Spectre::SSH.ssh 'some-data.host' do
      username 'dummy'
      password '<some-secret-password>'
      exec 'ls'

      file_exists 'dummy.txt'
      owner_of 'dummy.txt'

      test_output = output
    end

    expect(ssh_channel).to receive(:exec).with('ls')
    expect(test_output).to eq('some data')

    Spectre::SSH.ssh 'example' do
      exec 'ls'
    end
  end
end

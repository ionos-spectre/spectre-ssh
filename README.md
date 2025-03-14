# Spectre SSH

[![Build](https://github.com/ionos-spectre/spectre-ssh/actions/workflows/build.yml/badge.svg)](https://github.com/ionos-spectre/spectre-ssh/actions/workflows/build.yml)
[![Gem Version](https://badge.fury.io/rb/spectre-ssh.svg)](https://badge.fury.io/rb/spectre-ssh)

This is a [spectre](https://github.com/ionos-spectre/spectre-core) module which provides SSH access functionality to the spectre framework.

## Install

```bash
$ sudo gem install spectre-ssh
```

## Configure

Add the module to your `spectre.yml`

```yml
include:
 - spectre/ssh
```

Configure some predefined SSH connection options in your environment file

```yml
ssh:
  some_ssh_conn:
    host: some.server.com
    username: dummy
    password: '*****'
    key: path/to/.ssh/id_rsa
    passphrase: '*****'
    proxy_host: some_proxy_host
    proxy_port: 1234
```

## Usage

With the SSH helper you can define SSH connection parameters in the environment file and use the `ssh` function in your specs.

Within the `ssh` block there are the following functions available

| Method         | Parameters  | Description                                            |
| -------        | ----------  | -----------                                            |
| `file_exists`  | `file_path` | Checks if a file exists and returns a boolean value    |
| `owner_of`     | `file_path` | Returns the owner of a given file                      |
| `can_connect?` | _none_      | Returns `true` if a connection could be established    |
| `exec`         | `command`   | Executes a command via SSH                             |
| `output`       | _none_      | The output of the SSH command, which was last executed |


```ruby
ssh 'some_ssh_conn' do # use connection name from config
  file_exists('../path/to/some/existing_file.txt').should_be true
  owner_of('/bin').should_be 'root'
  exec 'ls -al'
end
```

```ruby
ssh 'some_server.com', username: 'dummy', password: '*****', proxy_host: 'some_proxy_host', proxy_port: 1234  do 
  file_exists('../path/to/some/existing_file.txt').should_be true
  owner_of('/bin').should_be 'root'
  exec 'ls -al'
end
```

You can also use the `ssh` function without configuring any connection in your environment file, by providing parameters to the function.
This is helpful, when generating the connection parameters during the *spec* run.

```ruby
ssh 'some.server.com', username: 'dummy', password: '*****'  do
  file_exists('../path/to/some/existing_file.txt').should_be true
  owner_of('/bin').should_be 'root'
end
```

```ruby
ssh 'some.server.com', username: 'dummy', key: 'path/to/.ssh/id_rsa', passphrase: '*****'  do
  file_exists('../path/to/some/existing_file.txt').should_be true
  owner_of('/bin').should_be 'root'
end
```

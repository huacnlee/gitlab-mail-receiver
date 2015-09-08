# GitLab Mail Receiver

[![Gem Version](https://badge.fury.io/rb/gitlab-mail-receiver.svg)](http://badge.fury.io/rb/gitlab-mail-receiver) [![CI Status](https://travis-ci.org/huacnlee/gitlab-mail-receiver.svg)](https://travis-ci.org/huacnlee/gitlab-mail-receiver)

The way of allow your GitLab support Email receive and parse the email content, and find Issue/MergeRequest to create reply.

[中文介绍](https://ruby-china.org/topics/27143)

## Features

- Receive Email reply to check Issue/MergeRequest and create comment.
- Very easy to configure on GitLab project.
- Cleanup the mail content.

The WorkFlow:

```
                 /-->  [ Notify ] ----------------> [Mail Server] <---> [Mail Client]
  { GitLab } ---/                                         ^
       ^                                                  |
       |-------< [ gitlab-mail-receiver ] <---- check --> |
```

## Requirements

- GitLab 7.13 (I just tested on this version.)
- An Email can receive mail via POP3/IMAP.


## Configuration

Add this gem in GitLab project Gemfile:

```rb
gem 'gitlab-mail-receiver'
```

Create initialize file in GitLab `config/initializes/gitlab-mail-receiver.rb`:

```rb
require 'gitlab-mail-receiver'

Notify.send(:prepend, MailReceiver::ReplyTo)

MailReceiver.configure do
  self.sender = 'xxx@your-mail-host.com'
  self.poll_interval = 5
  self.imap = {
    server: 'imap.your-mail-host.com',
    port: 993,
    ssl: true,
    username: 'xxx@your-mail-host.com',
    password: 'your-password'
  }
end
```

## Run commands

```
$ cd gitlab
$ bundle exec gitlab-mail-receiver -h
Commands:
  gitlab-mail-receiver help [COMMAND]  # Describe available commands or one specific command
  gitlab-mail-receiver restart         # Restart Daemon
  gitlab-mail-receiver start           # Start Daemon
  gitlab-mail-receiver stop            # Stop Daemon
  gitlab-mail-receiver version         # Show version

Options:
  [--root=ROOT]
                 # Default: ./
$ bundle exec gitlab-mail-receiver start
Started gitlab-mail-receiver on pid: 59386
I, [2015-09-01T13:36:50.813124 #59387]  INFO -- : Celluloid 0.17.1.2 is running in BACKPORTED mode. [ http://git.io/vJf3J ]
...
```

## Run in production

```
$ cd gitlab
$ RAILS_ENV=production bundle exec gitlab-mail-receiver start -d
pid_file: ./tmp/pids/gitlab-mail-receiver.pid
log_file: ./log/gitlab-mail-receiver.log
Started gitlab-mail-receiver on pid: 58861
```

> NOTE: The daemon log will write to `$rails_root/log/gitlab-mail-receiver.log`

Stop daemon

```bash
$ bundle exec gitlab-mail-receiver stop
Stoping gitlab-mail-receiver... [OK]
```


### Daemon Signals

gitlab-mail-receiver has support the [Unix process signal](https://en.wikipedia.org/wiki/Unix_signal) to manage the daemon.

You can use the `kill` command to send the signal to the master process.

- USR2 - Hot reload processes.
- QUIT - Stop processes.

```
$ ps aux | grep gitlab-mail-receiver
git      15488  0.2  0.2 612612 242920 pts/3   Sl   14:24   0:16 gitlab-mail-receiver [worker]
git      16320  0.0  0.0 309100 43004 pts/3    Sl   11:54   0:00 gitlab-mail-receiver [master]
$ kill -USR2 15488
```


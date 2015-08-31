# GitLab Mail Receiver

This gem can allow your GitLab to receive emails to create Issue comments like GitHub.

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
- A Email can receive mail via POP3/IMAP.


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
    server: 'imap.your-mail-host.com'
    port: 993
    ssl: true
    username: 'xxx@your-mail-host.com'
    password: 'your-password'
  }
end
```

## Run

```
$ cd gitlab
$ bundle exec gitlab-mail-receiver
```

> NOTE: The daemon log will write to `$rails_root/log/gitlab-mail-receiver.log`

## Run in production

```
$ cd gitlab
$ RAILS_ENV=production nohup bundle exec gitlab-mail-receiver &
```

# GitLab Mail Receiver

This gem can allow your GitLab to receive emails to create Issue comments like GitHub.


## Requirements

- GitLab 7.13 (I just tested on this version.)
- A Email can receive mail via IMAP.


## Configuration

Add this gem in GitLab project Gemfile:

```rb
gem 'gitlab-mail-receiver'
```

Add config in GitLab config/initializes/gitlab-mail-receiver.rb

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
$ gitlab-mail-receiver
```

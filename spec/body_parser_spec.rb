require 'spec_helper'

describe 'BodyParser' do
  class Content < OpenStruct
    include MailReceiver::BodyParser
  end

  let(:mail) do
    super_body = body
    Mail::Message.new do
      from 'foo@bar.com'
      body super_body
      subject 'RE: foo 123'
    end
  end
  let(:content) { Content.new(mail: mail) }

  describe '.extract' do
    subject { content.extract }

    context 'simple' do
      let(:body) { 'Hello world' }

      it { is_expected.to eq body }
    end

    context 'multlines' do
      let(:body) { "Hello world\n\nThis is last line" }
      it { is_expected.to eq body }
    end

    context 'Has - prefix' do
      let(:body) do
        %(This is the first line.

- The line with - prefix

> 在 2015年9月8日，13:51，xxxx 写道：
>
> "New comment for Issue 1540" GitLab 通知中心，以及 Email 直接回复 Issue 功能 <http://gitlab.com/huacnlee/gitlab-mail-receiver/issues/2#note_123>
> "Author: huacnlee wrote:"
>
> Hello)
      end

      it { is_expected.to eq body }
    end
  end
end

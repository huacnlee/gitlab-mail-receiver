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

      it 'should return utf-8 encoding' do
        expect(subject.encoding.to_s).to eq 'UTF-8'
      end
    end

    context 'multlines' do
      let(:body) { "Hello world\n\nThis is last line" }
      it { is_expected.to eq body }
    end

    context 'Has - prefix & > prefix' do
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

    context 'GBK encoding' do
      let(:body) { 'Hello 邮件'.force_encoding('GBK') }

      it 'should work' do
        expect(subject).to eq 'Hello 邮件'
        expect(subject.encoding.to_s).to eq 'UTF-8'
      end
    end
  end
end

require 'spec_helper'
require 'mail/message'

describe 'Receiver' do
  let(:logger) { Logger.new('/dev/null') }
  let(:to) { MailReceiver.config.sender }
  let(:body) { "hello world" }
  let(:message) {
    that = self
    Mail::Message.new do
      from 'foo@bar.com'
      to that.to
      subject "Test subject"
      body that.body
    end
  }
  let(:receiver) { MailReceiver::Receiver.new(message, logger: logger) }

  context 'Bad to address' do
    it { expect(receiver.logger).to eq(logger) }
    it { expect(receiver.mail).to eq(message) }
    it { expect(receiver.hash_data).to eq({}) }
    it { expect(receiver.project_slug).to eq(nil) }
    it { expect(receiver.project).to eq(nil) }
    it { expect(receiver.issue_id).to eq(nil) }
    it { expect(receiver.target_id).to eq(nil) }
    it { expect(receiver.to).to eq(to) }
    it { expect(receiver.from).to eq('foo@bar.com') }

    it "should .body work" do
      allow(receiver).to receive(:extract) { 'abc' }
      expect(receiver.body).to eq('abc')
    end

    it "should .current_user work" do
      u = { email: 'foo@bar.com' }
      expect(receiver.current_user).to eq(u)
    end
  end

  context 'normal' do
    let(:hash) { { p: 'foo/bar', id: '201', t: 'i', n: '201511' } }
    let(:query) { MailReceiver::Encoder.encode(hash) }
    let(:to) { "reply+#{query}@gitlab.com" }

    it { expect(receiver.prefix).to eq("reply+#{query}") }
    it { expect(receiver.hash_data).to eq(hash) }
    it { expect(receiver.project_slug).to eq(hash[:p]) }
    it { expect(receiver.project).to eq({ slug: hash[:p] }) }
    it { expect(receiver.issue_id).to eq(hash[:id]) }
    it { expect(receiver.target_id).to eq(hash[:n]) }
    it { expect(receiver.merge_request?).to eq(false) }
  end
end

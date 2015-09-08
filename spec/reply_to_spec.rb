require 'spec_helper'

describe 'ReplyTo' do
  class Monkey
    include MailReceiver::ReplyTo

    def initialize(opts)
      @note = opts[:note]
      @project = opts[:project]
    end

    def default_email_reply_to
      'foo@bar.com'
    end
  end

  let(:project) { Project.new(id: 301) }
  let(:note) { Note.new(id: 10) }
  let(:monkey) { Monkey.new(note: note, project: project) }

  describe '.convert_able' do
    context 'Issue' do
      let(:obj) { Issue.new(iid: 2) }

      it 'should work' do
        res = monkey.send(:convert_able, obj)
        expect(res).to eq({ id: 2, n: note.id, t: 'i'})
      end
    end

    context 'MergeRequest' do
      let(:obj) { MergeRequest.new(iid: 3) }

      it 'should work' do
        res = monkey.send(:convert_able, obj)
        expect(res).to eq({ id: 3, n: note.id, t: 'm'})
      end
    end

    context 'Other' do
      let(:obj) { Other.new(iid: 3) }

      it 'should work' do
        res = monkey.send(:convert_able, obj)
        expect(res).to eq nil
      end
    end
  end

  describe '.reply_to_address' do
    context 'Issue' do
      let(:obj) { Issue.new(iid: 2) }

      it 'should work' do
        res = monkey.send(:reply_to_address, obj)
        expect(res).to eq 'reply+id=2&n=10&p=&t=i@gitlab.com'
      end
    end

    context 'MergeRequest' do
      let(:obj) { MergeRequest.new(iid: 4) }

      it 'should work' do
        res = monkey.send(:reply_to_address, obj)
        expect(res).to eq 'reply+id=4&n=10&p=&t=m@gitlab.com'
      end
    end

    context 'Other' do
      let(:obj) { Other.new(iid: 4) }

      it 'should work' do
        res = monkey.send(:reply_to_address, obj)
        expect(res).to eq monkey.default_email_reply_to
      end
    end
  end
end

require 'spec_helper'

describe 'Encoder' do
  let(:t) { '#' }
  let(:raw) { { slug: 'huacnlee/gitlab-mail-receiver', t: t, id: "2091" } }
  let(:query) { 'id=2091&slug=huacnlee%2Fgitlab-mail-receiver&t=%23' }

  describe '#encode' do
    let(:res) { MailReceiver::Encoder.encode(raw) }

    it 'should work' do
      expect(res).to eq(query)
    end

    context 'has bad char' do
      let(:t) { '@+ab' }

      it 'should work' do
        expect(res).not_to include('@')
        expect(res).not_to include('+')
      end
    end
  end

  describe '#decode' do
    it 'should work' do
      expect(MailReceiver::Encoder.decode(query)).to eq(raw)
    end
  end

end

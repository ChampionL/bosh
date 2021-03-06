require 'spec_helper'

describe Bosh::Director::App do
  let(:config) { Bosh::Director::Config.load_file(asset('test-director-config.yml')) }

  describe 'initialize' do
    it 'takes a Config' do
      described_class.new(config)
    end

    it 'establishes the singleton instance' do
      expected_app_instance = described_class.new(config)

      expect(described_class.instance).to be(expected_app_instance)
    end

    it 'configures the legacy Config system' do # This will go away when the legacy Config.configure() goes away
      BD::Config.should_receive(:configure).with(config.hash)

      described_class.new(config)
    end
  end

  describe '#blobstores' do
    it 'provides the blobstores' do
      expect(described_class.new(config).blobstores).to be_a(Bosh::Director::Blobstores)
    end
  end
end
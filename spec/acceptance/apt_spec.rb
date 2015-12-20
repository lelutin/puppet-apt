require 'spec_helper_acceptance'

describe 'apt class' do

  context 'default parameters' do
    it 'should work idempotently with no errors' do
      pp = <<-EOS
        class { 'apt': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe package('apt') do
      it { is_expected.to be_installed }
    end

  end
end

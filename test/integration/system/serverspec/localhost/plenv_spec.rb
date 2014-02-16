require 'spec_helper'

_user = 'root'
_plenv_root = '/usr/local/plenv'
_versions = %w{
  5.16.2
}

# plenv installed
describe command('plenv') do
  let(:path) { ::File.join _plenv_root, 'bin' }
  it { should return_exit_status 0 }
end

# each perl version installed
_versions.each do |version|
  perl_command = File.join(_plenv_root, 'versions', version, 'bin/perl')
  keyword      = version.gsub('-', '')

  describe command(perl_command + ' --version') do
    it { should return_stdout /#{ Regexp.escape keyword }/ }
  end
end

# default version
keyword = 'v5.16.2'

describe command('perl --version') do
  let(:path) { ::File.join _plenv_root, 'shims' }
  it { should return_stdout /#{ Regexp.escape keyword }/ }
end


# installed cpan modules
_versions.each do |version|
  bin_dir = File.join(_plenv_root, 'versions', version, 'bin')

  describe file(::File.join(bin_dir, 'cpanm')) do
    it { should be_file }
    it { should be_executable }
  end

  describe file(::File.join(bin_dir, 'carton')) do
    it { should be_file }
    it { should be_executable }
  end
end

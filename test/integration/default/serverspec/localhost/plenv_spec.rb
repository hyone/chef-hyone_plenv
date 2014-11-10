require 'spec_helper'

_user = 'hoge'
_plenv_root = ::File.join('/home', _user, '.plenv')
_versions = %w{
  5.20.1
}

set :path, "#{::File.join(_plenv_root, 'bin')}:#{::File.join(_plenv_root, 'shims')}:$PATH"

# plenv installed
describe command('plenv') do
  its(:exit_status) { should eq 0 }
end

# each perl version installed
_versions.each do |version|
  perl_command = File.join(_plenv_root, 'versions', version, 'bin/perl')
  keyword      = version.gsub('-', '')

  describe command(perl_command + ' --version') do
    its(:stdout) { should =~ /#{ Regexp.escape keyword }/ }
  end
end

# default version
keyword = _versions[0]

describe command('perl --version') do
  its(:stdout) { should =~ /#{ Regexp.escape keyword }/ }
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

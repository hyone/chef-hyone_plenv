default['hyone_plenv']['repository'] = 'git://github.com/tokuhirom/plenv.git'
default['hyone_plenv']['reference'] = 'master'
default['hyone_plenv']['build_repository'] = 'git://github.com/tokuhirom/Perl-Build.git'
default['hyone_plenv']['build_reference']  = 'master'

default['hyone_plenv']['user']  = nil
default['hyone_plenv']['group'] = nil
default['hyone_plenv']['home']  = nil
default['hyone_plenv']['path']  = nil

default['hyone_plenv']['versions'] = [
  { :version => '5.18.1', :configure_opts => "" }
]
default['hyone_plenv']['global'] = '5.18.1'

default['hyone_plenv']['setup_bash'] = false

::Chef::Recipe.send(:include, HyonePlenv::Helper)

_user       = get_user(node)
_group      = get_user(node)
_home       = get_home(node, _user)
_plenv_root = get_plenv_root(node, _user)


case
when platform?('ubuntu')
  include_recipe 'apt'
end

## user and group
user _user do
  home _home
  supports manage_home: true
  shell '/bin/bash'
  action [:create]
end

group _group do
  members [ _user ]
  action [:create]
end

# Generate locales to avoid warnings like:
# 'bash: warning: setlocale: LC_ALL: cannot change locale (ja_JP.UTF-8)'
case
when platform?('centos')
  execute 'generate locale' do
    command 'localedef -f UTF-8 -i ja_JP /usr/lib/locale/ja_JP.UTF-8'
    action [:run]
  end
when platform?('ubuntu')
  execute 'locale-gen' do
    command 'locale-gen ja_JP.UTF-8'
    action [:run]
  end
end

## fix '/dev/fd/62: No such file or directory' trouble on docker
execute 'fix docker problem' do
  command <<-EOC
    ln -s /proc/self/fd /dev/fd
  EOC
  not_if { ::File.exists? '/dev/fd' }
end

## plenv

include_recipe 'hyone_plenv::default'

# install a sample cpan module
node['hyone_plenv']['versions'].each do |perl|
  hyone_plenv_cpanm 'Carton' do
    user _user
    perl_version perl['version']
    options(:force => true) if perl_version == '5.8.8'
  end
end

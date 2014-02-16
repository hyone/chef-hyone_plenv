::Chef::Recipe.send(:include, HyonePlenv::Helper)

_user       = get_user(node)
_group      = get_user(node)
_home       = get_home(node, _user)
_plenv_root = get_plenv_root(node, _user)

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

execute 'sudo without password' do
  command <<-EOC
    echo "#{_user} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/#{_user}
    chmod 0440 /etc/sudoers.d/#{_user}
  EOC
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

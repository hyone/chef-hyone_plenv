#
# Cookbook Name:: hyone_plenv
# Recipe:: default
#
# Copyright (C) 2013 YOUR_NAME
# 
# All rights reserved - Do Not Redistribute
#

::Chef::Recipe.send(:include, HyonePlenv::Helper)


# prepare for each platform

begin
  include_recipe "#{cookbook_name}::#{node['platform_family']}"
rescue Chef::Exceptions::RecipeNotFound
end

# requirements

include_recipe 'build-essential'
include_recipe 'git'


%w{
  patch
  curl
  tar
  bzip2
}.each do |name|
  package name do
    action [:install]
  end
end


# install plenv

_user       = get_user(node)
_group      = get_group(node, _user)
_home       = get_home(node, _user)
_plenv_root = get_plenv_root(node, _user)


git "plenv" do
  user        _user
  group       _group
  repository  node['hyone_plenv']['repository']
  reference   node['hyone_plenv']['reference']
  destination _plenv_root
  action      :sync
end


directory ::File.join(_plenv_root, 'plugins') do
  owner _user
  group _group
  mode  0755
  action :create
end


git "perl-build" do
  user        _user
  group       _group
  repository  node['hyone_plenv']['build_repository']
  reference   node['hyone_plenv']['build_reference']
  destination ::File.join(_plenv_root, 'plugins/perl-build/')
  action      :sync
end


if node['hyone_plenv']['setup_bash']
  plenv_search_path = ::File.join(_plenv_root, 'bin')
  rc_file = ::File.join(_home, ".bash_profile")

  file rc_file do
    user  _user
    group _group
    action [:create]
  end

  ruby_block 'setup plenv settings for bash' do
    block do
      file = Chef::Util::FileEdit.new(rc_file)
      file.insert_line_if_no_match /^\s*#{ Regexp.escape 'eval "$(plenv init -)"'}\s*$/, <<-EOC.undent
        export PATH="#{plenv_search_path}:$PATH"
        export PLENV_ROOT="#{_plenv_root}"
        eval "$(plenv init -)"
      EOC
      file.write_file
    end
  end
end


# install perl implementations

node['hyone_plenv']['versions'].each do |perl|
  hyone_plenv_install perl['version'] do
    user _user
    plenv_root _plenv_root
    configure_opts perl['configure_opts'] if perl['configure_opts']
  end
end


# set default implementation

default_version = node['hyone_plenv']['default']

hyone_plenv_global default_version do
  user _user
  plenv_root _plenv_root
end

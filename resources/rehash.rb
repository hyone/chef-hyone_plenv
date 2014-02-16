actions [:run]
default_action :run

attribute :name,    :kind_of => String, :name_attribute => true
attribute :version, :kind_of => String

# load common lazy default attributes

::Chef::Resource.send(:include, HyonePlenv::Resource::DefaultAttribute)

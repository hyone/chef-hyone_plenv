actions [:run]
default_action :run

attribute :version, :kind_of => String, :name_attribute => true

# load common lazy default attributes

::Chef::Resource.send(:include, HyonePlenv::Resource::DefaultAttribute)

actions [:run]
default_action :run

attribute :name,        :kind_of => String, :name_attribute => true
attribute :version,     :kind_of => String
attribute :cwd,         :kind_of => String
attribute :environment, :kind_of => Hash,   :default => {}
attribute :command,     :kind_of => String, :required => true


# load common lazy default attributes

::Chef::Resource.send(:include, HyonePlenv::Resource::DefaultAttribute)

def version(arg = nil)
  if @version.nil?
    arg ||= global_perl_version(self)
  end

  set_or_return(:version, arg, :kind_of => String)
end


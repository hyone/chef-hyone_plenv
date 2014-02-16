actions [:install, :upgrade]
default_action :install

attribute :package,        :kind_of => String, :name_attribute => true
# NOTE: :options only support long name options:
#       { :ri => true, :rdoc => false, :bin_dir => "/path/to/hoge" }
#       => --ri --no-rdoc --bin-dir "/path/to_hoge"
attribute :options,        :kind_of => Hash,   :default => {}
attribute :perl_version,   :kind_of => String

attr_accessor :exists

# load common lazy default attributes

::Chef::Resource.send(:include, HyonePlenv::Resource::DefaultAttribute)


def perl_version(arg = nil)
  if @perl_version.nil?
    arg ||= global_perl_version(self)
  end

  set_or_return(:perl_version, arg, :kind_of => String)
end

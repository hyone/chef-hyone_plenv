::Chef::Provider.send(:include, HyonePlenv::Helper)


action :install do
  if current_resource.exists
    Chef::Log.info "#{current_resource.perl_path} already exists - nothing to do."
  else
    converge_by("Install #{new_resource.version} on plenv") do
      plenv_install_perl
    end
  end
end


def whyrun_supported?
  true
end

def load_current_resource
  @current_resource = Chef::Resource::HyonePlenvInstall.new(new_resource.version)
  @current_resource.user(new_resource.user)
  @current_resource.home(new_resource.home)
  @current_resource.plenv_root(new_resource.plenv_root)
  @current_resource.configure_opts(new_resource.configure_opts)

  if ::File.exists? @current_resource.perl_path
    @current_resource.exists = true
  end
end


private

def plenv_install_perl
  _command = "plenv install #{new_resource.version}"
  unless new_resource.configure_opts.nil? or new_resource.configure_opts.empty?
    _command << " #{new_resource.configure_opts}"
  end

  rehash = get_rehash_resource(
    run_context,
    new_resource.user,
    new_resource.home,
    new_resource.plenv_root
  )

  hyone_plenv_exec "install perl implementation #{new_resource.version}" do
    user       new_resource.user
    home       new_resource.home
    plenv_root new_resource.plenv_root
    command    _command
    notifies :run, rehash, :immediately
  end
end


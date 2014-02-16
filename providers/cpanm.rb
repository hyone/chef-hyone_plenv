::Chef::Resource.send(:include, HyonePlenv::Helper)

action :install do
  if current_resource.exists
    Chef::Log.info "#{current_resource.package} on #{current_resource.perl_version} already exists - nothing to do."
  else
    converge_by(
      "install #{new_resource.package} on #{new_resource.perl_version}"
    ) do
      plenv_cpanm_install
    end
  end
end

action :upgrade do
  converge_by("upgrade #{current_resource.package} on #{current_resource.perl_version}") do
    plenv_cpanm_upgrade
  end
end

def whyrun_supported?
  true
end


def load_current_resource
  @current_resource = Chef::Resource::HyonePlenvCpanm.new(new_resource.package)
  @current_resource.user(new_resource.user)
  @current_resource.home(new_resource.home)
  @current_resource.options(new_resource.options)
  @current_resource.plenv_root(new_resource.plenv_root)
  @current_resource.perl_version(new_resource.perl_version)

  command = exec_with_plenv "perldoc -l #{@current_resource.package}",
    @current_resource.plenv_root,
    @current_resource.user,
    @current_resource.home,
    @current_resource.perl_version
 
  if command.status.to_i == 0
    @current_resource.exists = true
  end
end


private

def plenv_cpanm_install
  rehash = get_rehash_resource(
    run_context,
    new_resource.user,
    new_resource.home,
    new_resource.plenv_root,
    new_resource.perl_version
  )

  # install cpanm self
  hyone_plenv_exec "install cpanm on #{new_resource.perl_version}" do
    user       new_resource.user
    version    new_resource.perl_version
    plenv_root new_resource.plenv_root
    command "plenv install-cpanm"
    notifies :run, rehash, :immediately
    not_if { ::File.exists? ::File.join(plenv_root, "versions/#{new_resource.perl_version}/bin/cpanm") }
  end

  options_str = parse_options(new_resource.options)

  hyone_plenv_exec "install #{new_resource.package} on #{new_resource.perl_version}" do
    user       new_resource.user         if new_resource.user
    home       new_resource.home         if new_resource.home
    version    new_resource.perl_version if new_resource.perl_version
    plenv_root new_resource.plenv_root   if new_resource.plenv_root
    command <<-EOC
      plenv exec cpanm #{options_str} #{new_resource.package}
    EOC
    notifies :run, rehash, :immediately
  end
end


def plenv_cpanm_upgrade
  rehash = get_rehash_resource(
    run_context,
    current_resource.user,
    current_resource.home,
    current_resource.plenv_root
  )

  options_str = parse_options(current_resource.options)

  hyone_plenv_exec "exec to upgrade #{current_resource.package} on #{current_resource.perl_version}" do
    user       current_resource.user         if current_resource.user
    home       current_resource.home         if current_resource.home
    version    current_resource.perl_version if current_resource.perl_version
    plenv_root current_resource.plenv_root   if current_resource.plenv_root
    command <<-EOC
      plenv exec cpanm update #{options_str} #{current_resource.package}
    EOC
    notifies :run, rehash, :immediately
  end
end

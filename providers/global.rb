action :run do
  converge_by("plenv global #{new_resource.version}") do
    rehash = get_rehash_resource(
      run_context,
      new_resource.user,
      new_resource.home,
      new_resource.plenv_root
    )

    hyone_plenv_exec "plenv global #{new_resource.version}" do
      user       new_resource.user       if new_resource.user
      home       new_resource.home       if new_resource.home
      plenv_root new_resource.plenv_root if new_resource.plenv_root
      command <<-EOC
        plenv global #{new_resource.version}
      EOC
      notifies :run, rehash, :immediately
    end
  end
end

def whyrun_supported?
  true
end


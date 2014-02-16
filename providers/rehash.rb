action :run do
  converge_by("plenv rehash: #{new_resource.name}") do
    hyone_plenv_exec "plenv rehash: #{new_resource.name}" do
      user       new_resource.user       if new_resource.user
      home       new_resource.home       if new_resource.home
      plenv_root new_resource.plenv_root if new_resource.plenv_root
      version    new_resource.version    if new_resource.version
      command <<-EOC
        plenv rehash
      EOC
    end
  end
end

def whyrun_supported?
  true
end



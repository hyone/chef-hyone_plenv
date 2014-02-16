execute 'apt-get update' do
    user  'root'
    group 'root'
    command <<-EOC
      apt-get update
    EOC
end

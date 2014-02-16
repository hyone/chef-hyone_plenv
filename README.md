# hyone_plenv cookbook

## Requirements

## Usage

```json
{
  "hyone_plenv": {
    "user":  "hoge",
    "group": "hoge",
    "path": "/home/hoge/local/plenv",
    "default":  "5.18.1",
    "versions": [
      {
        "version": "5.18.1"
      },
      {
        "version":        "5.16.2",
        "configure_opts": "-Dusethreads"
      }
    ],
    "setup_bash": true
  },

  "run_list": [
    "recipe[hyone_plenv::default]"
  ]
}
```

## Recipes

### hyone_plenv::default

install plenv and perl implementations

## LWRP

install plenv

```ruby
include_recipe 'hyone_plenv::default'
```

install perl implmentation

```ruby
hyone_plenv_install '5.18.1' do
  user 'root'
  plenv_root '/usr/local/plenv'
  configure_opts '-Dusethreads'
end
```

set global perl version

```ruby
hyone_plenv_global default_version do
  user _user
  plenv_root _plenv_root
end
```

install cpan module

```ruby
hyone_plenv_cpanm 'Carton' do
  user 'vagrant'
  perl_version '5.16.2'
end
```

exec with plenv

```ruby
hyone_plenv_exec 'install application libraries' do
  user 'vagrant'
  cwd  '/app'
  command <<-EOC
    carton install
  EOC
end
```

## Attributes

- `node['hyone_plenv']['user']` - user of plenv installation

- `node['hyone_plenv']['group']` - group of plenv installation

- `node['hyone_plenv']['home']` - home directory of plenv installation

- `node['hyone_plenv']['path']` - path of plenv installation ( if not specifed, use `~/.plenv` )

- `node['hyone_plenv']['versions']` - perl implementations to install
  ```json
  [{ "version": "5.16.2", "configure_opts": "-Dusethreads" }]
  ```

- `node['hyone_plenv']['setup_bash']` - whether or not add plenv settings to `~/.bash_profile`

Either `path` or `home` must be specified.

## Author

Author:: hyone (hyone.development@gmail.com)

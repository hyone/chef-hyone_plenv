module HyonePlenv
  module Helper

    def user_home(user)
      case user
      when 'root' then '/root'
      else File.join('/home', user)
      end
    end

    def get_user(attr)
      attr['hyone_plenv']['user'] ||
        (attr.has_key?('main') && attr['main']['user']) ||
        'root'
    end

    def get_group(attr, user = nil)
      attr['hyone_plenv']['group'] ||
        (attr.has_key?('main') && attr['main']['group']) ||
        user || get_user(attr)
    end

    def get_home(attr, user = nil)
      attr['hyone_plenv']['home'] ||
        (attr.has_key?('main') && attr['main']['home']) ||
        user_home(user || get_user(attr))
    end

    def get_plenv_root(attr, user = nil)
      attr['hyone_plenv']['path'] || ::File.join(get_home(attr, user), '.plenv')
    end

    def get_rehash_resource(run_context, _user, _home = nil, _plenv_root = nil, _version = nil)
      _id = [_user, _home, _plenv_root, _version].join(':')
      rehash = begin
        run_context.resource_collection.find(:hyone_plenv_rehash => _id)
      rescue Chef::Exceptions::ResourceNotFound => e
        hyone_plenv_rehash _id do
          user       _user
          home       _home       if _home
          plenv_root _plenv_root if _plenv_root
          version    _version    if _version
          action :nothing
        end
      end
      rehash
    end

    def exec_with_plenv(command_str, plenv_root, user, home, version = nil)
      # NOTE: 'command.environment['PATH'] = ...' causes error 'bash not found'
      #       so, put 'export PATH=...' inline in command string
      _commandline = <<-EOC 
        export PATH="#{ ::File.join(plenv_root, 'bin') }:$PATH"
        export PLENV_ROOT="#{plenv_root}"
        eval "$(plenv init -)"
        #{ "plenv shell #{version}" if version }
        #{command_str}
      EOC
      command = Mixlib::ShellOut.new(_commandline)
      command.user = user
      command.environment['HOME'] = home
      command.run_command
      return command
    end

    def global_perl_version(resource)
      command = exec_with_plenv "plenv version | cut -d ' ' -f 1",
        resource.plenv_root,
        resource.user,
        resource.home
      command.stdout.chomp
    end

    def parse_options(options)
      options.map {|k, v|
        option = k.to_s.gsub('_', '-')
        case
        when v == true  then "--#{option}"
        when v == false then "--no-#{option}" 
        else "--#{option} #{v}"
        end
      }.join(' ')
    end

  end

  # define attribute's lazy default value

  module Resource
    module DefaultAttribute
      include ::HyonePlenv::Helper

      def user(arg = nil)
        if @user.nil?
          arg ||= get_user(node)
        end
        set_or_return(:user, arg, :kind_of => String)
      end

      def group(arg = nil)
        if @group.nil?
          arg ||= get_group(node, user)
        end
        set_or_return(:group, arg, :kind_of => String)
      end

      def home(arg = nil)
        if @home.nil?
          arg ||= get_home(node, user)
        end
        set_or_return(:home, arg, :kind_of => String)
      end

      def plenv_root(arg = nil)
        if @plenv_root.nil?
          arg ||= get_plenv_root(node, user)
        end
        set_or_return(:plenv_root, arg, :kind_of => String)
      end

    end
  end

end

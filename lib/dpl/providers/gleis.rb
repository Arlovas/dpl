module Dpl
  module Providers
    class Gleis < Provider
      status :dev

      description sq(<<-str)
        tbd
      str

      gem 'thor', require: true
      gem 'gleis', '~> 0.6.0'

      opt '--app APP',       'Gleis application to upload to', default: :repo_name
      opt '--username NAME', 'Gleis username', required: true
      opt '--password PASS', 'Gleis password', required: true, secret: true
      opt '--key_name NAME', 'Name of the SSH deploy key pushed to Gleis', default: 'dpl_deploy_key'
      opt '--verbose'

      needs :ssh_key

      cmds login:      'gleis auth login %{username} %{password} --skip-keygen',
           logout:     'gleis auth logout',
           validate:   'gleis app status -a %{app}',
           add_key:    'gleis auth key add %{file} %{key_name}',
           remove_key: 'gleis auth key remove dpl_%{key_name}',
           git_url:    'gleis app git -a %{app} -q',
           deploy:     'git push %{push_opts} -f %{git_url} HEAD:refs/heads/master'

      errs login:      'Login failed',
           validate:   'Application not found',
           add_key:    'Adding SSH key failed',
           remove_key: 'Removing key failed',
           git_url:    'Failed to retrieve Git URL',
           deploy:     'Deploying application failed'

      attr_reader :git_url

      def login
        shell :login
      end

      def setup
        @git_url = shell :git_url
      end

      def validate
        shell :validate
      end

      def add_key(file)
        shell :add_key, file: file
      end

      def deploy
        shell :deploy
      end

      def remove_key
        shell :remove_key
      end

      private

        def push_opts
          '-v' if verbose?
        end
    end
  end
end

require 'open3'

module Scrutinizer
  module Ocular
    class RepositoryIntrospector
      def initialize(dir)
        @dir = dir
      end

      def get_repository_name()
        stdout, status = Open3.capture2('git remote -v', :chdir => @dir)

        raise 'Repository name could not be determined' unless status.exitstatus == 0

        output = stdout.to_s
        patterns = [
            /^origin\s+(?:git@|(?:git|https?):\/\/)([^:\/]+)(?:\/|:)([^\/]+)\/([^\/\s]+?)(?:\.git)?(?:\s|\n)/,
            /^[^\s]+\s+(?:git@|(?:git|https?):\/\/)([^:\/]+)(?:\/|:)([^\/]+)\/([^\/\s]+?)(?:\.git)?(?:\s|\n)/,
        ]

        patterns.each { |pattern|
          if output =~ pattern
            return get_repository_type($1) + '/' + $2 + '/' + $3
          end
        }

        raise "Could not determine repository. Please set the 'SCRUTINIZER_REPOSITORY' environment variable"
      end

      def get_current_parents
        stdout, status = Open3.capture2('git log --pretty=%P -n1 HEAD', :chdir => @dir)

        raise 'Parents could not be determined' unless status.exitstatus == 0

        output = stdout.to_s.strip
        if output.empty?
          return []
        end

        output.split(' ')
      end

      def get_current_revision
        stdout, status = Open3.capture2('git rev-parse HEAD', :chdir => @dir)

        raise 'Revision could not be determined' unless status.exitstatus == 0

        stdout.to_s.strip
      end

      private
        def get_repository_type(host)
          if host == "github.com"
              return "g"
          elsif host == "bitbucket.org"
              return "b"
          end

          raise "Unknown host " + host
        end
    end
  end
end


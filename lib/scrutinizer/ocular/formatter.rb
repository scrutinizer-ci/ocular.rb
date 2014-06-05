require 'scrutinizer/ocular/api_client'
require 'scrutinizer/ocular/repository_introspector'
require 'scrutinizer/ocular/output'
require 'json'

module Scrutinizer
  module Ocular
    class Serializer
      def serialize(result)
        files = []
        result.files.each do |file|
          files << {
            :name => file.filename,
            :lines => file.coverage
          }
        end

        files.to_json
      end
    end

    class LocalOutputFormatter
      def initialize
        @output_file = ENV['SCRUTINIZER_CC_FILE'] || "./coverage.json"
        @serializer = Serializer.new
      end

      def format(result)
        File.open(@output_file, 'w') do |file|
          file.write(@serializer.serialize(result))
        end
      end
    end

    class UploadingFormatter
      attr_accessor :output

      def initialize
        introspector = RepositoryIntrospector.new(Dir.pwd)

        api_url = ENV['SCRUTINIZER_HOST'] || "https://scrutinizer-ci.com/api"
        access_token = ENV['SCRUTINIZER_ACCESS_TOKEN'] || nil
        @repository = ENV['SCRUTINIZER_REPOSITORY'] || introspector.get_repository_name
        @revision = ENV['SCRUTINIZER_REVISION'] || introspector.get_current_revision

        @api_client = ApiClient.new(
          api_url,
          @repository,
          @revision,
          introspector.get_current_parents,
          access_token
        )

        @serializer = Serializer.new
        @output = StdoutOutput.new
      end

      def format(result)
        begin
          @output.write("Uploading code coverage for '#{@repository}' and revision '#{@revision}'... ")
          @api_client.upload("rb-cc", @serializer.serialize(result))
          @output.write("Done!\n")
        rescue UploadFailed => e
          @output.write("Failed\n")

          if e.response.code.to_i == 401 || e.response.code.to_i == 403
            @output.write("Please make sure to set an access token via the environment variable 'SCRUTINIZER_ACCESS_TOKEN'\n")
            @output.write("You can obtain access tokens with 'READ' permission on https://scrutinizer-ci.com/profile/applications")
          else
            @output.write(e.response.body)
          end
        end
      end
    end
  end
end
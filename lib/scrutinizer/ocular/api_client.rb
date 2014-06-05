require 'uri'
require 'net/https'
require 'json'
require 'base64'

module Scrutinizer
  module Ocular
    class UploadFailed < StandardError
      attr_reader :response

      def initialize(response)
        @response = response
      end
    end

    class ApiClient
      def initialize(api_url, repository_name, revision, parents, access_token)
        @api_url = api_url
        @repository_name = repository_name
        @revision = revision
        @parents = parents
        @access_token = access_token
        @http = create_http_service(@api_url)

        disable_net_blockers!
      end

      def upload(format, data)
        uri = URI.parse(@api_url + '/repositories/' + @repository_name + '/data/code-coverage')

        request = Net::HTTP::Post.new(uri.request_uri)
        request.add_field('Content-Type', 'application/json')
        request.body = {
            :revision => @revision,
            :parents => @parents,
            :coverage => {
                :format => format,
                :data => Base64.encode64(data)
            }
        }.to_json

        response = @http.request(request)

        if response.code.to_i < 200 || response.code.to_i >= 300
          raise UploadFailed.new(response), "Upload failed with status #{response.code}"
        end
      end

      private

        def create_http_service(url)
          uri = URI(url)
          pem_file = File.absolute_path(File.dirname(__FILE__) + '/../../../res/cacert.pem')
          pem = File.read(pem_file)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.cert = OpenSSL::X509::Certificate.new(pem)
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER

          http
        end

        def disable_net_blockers!
          host = URI(@api_url).host

          if defined?(WebMock)
            allow = WebMock::Config.instance.allow || []
            WebMock::Config.instance.allow = [*allow].push host
          end

          if defined?(VCR)
            VCR.send(VCR.version.major < 2 ? :config : :configure) do |c|
              c.ignore_hosts host
            end
          end
        end
    end
  end
end


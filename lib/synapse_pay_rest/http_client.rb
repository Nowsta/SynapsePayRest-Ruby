require 'rest-client'
require 'json'

module SynapsePayRest
  class HTTPClient

    attr_accessor :base_url
    attr_accessor :options
    attr_accessor :headers
    attr_accessor :user_id
    attr_accessor :timeout

    def initialize(options, base_url, user_id: nil)
      @options = options
      user = '|%s' % options['fingerprint']
      if options.has_key?('oauth_key')
        user = '%s|%s' % [options['oauth_key'], options['fingerprint']]
      end
      gateway = '%s|%s' % [options['client_id'], options['client_secret']]
      @headers = {
        :content_type => :json,
        :accept => :json,
        'X-SP-GATEWAY' => gateway,
        'X-SP-USER' => user,
        'X-SP-USER-IP' => options['ip_address']
      }
      @base_url = base_url
      # RestClient.log = 'stdout'
      @user_id = user_id
      @timeout = options['timeout']
    end

    def update_headers(user_id: nil, oauth_key: nil, fingerprint: nil, client_id: nil, client_secret: nil, ip_address: nil)
      if user_id
        @user_id = user_id
      end
      if oauth_key and !fingerprint
        @headers['X-SP-USER'] = '%s|%s' % [oauth_key, @options['fingerprint']]
      elsif oauth_key and fingerprint
        @headers['X-SP-USER'] = '%s|%s' % [oauth_key, fingerprint]
      end

      if client_id and !client_secret
        @headers['X-SP-GATEWAY'] = '%s|%s' % [client_id, @options['client_secret']]
      elsif client_id and client_secret
        @headers['X-SP-GATEWAY'] = '%s|%s' % [client_id, client_secret]
      elsif !client_id and client_secret
        @headers['X-SP-GATEWAY'] = '%s|%s' % [@options['client_id'], client_secret]
      end

      if ip_address
        @headers['X-SP-USER-IP'] = ip_address
      end
    end

    def post(path, payload)
      url = base_url + path
      response = with_error_handling do
        make_request(method: :post, url: url, payload: payload.to_json)
      end
      JSON.parse(response)
    end

    def patch(path, payload)
      url = base_url + path
      response = with_error_handling do
        make_request(method: :patch, url: url, payload: payload.to_json)
      end
      JSON.parse(response)
    end

    def get(path)
      url = base_url + path
      response = with_error_handling { make_request(method: :get, url: url) }
      JSON.parse(response)
    end

    def delete(path)
      url = base_url + path
      response = with_error_handling { make_request(method: :delete, url: url) }
      JSON.parse(response)
    end

    private

    def make_request(options)
      base_options = { headers: @headers }
      base_options[:timeout] = timeout if timeout
      RestClient::Request.execute(base_options.merge(options))
    end

    def with_error_handling
      yield
    rescue RestClient::RequestTimeout => e
      format_error(504, messages[:timeout])
    rescue RestClient::ExceptionWithResponse => e
      code = e.response.code
      well_formed?(code) ? e.response : format_error(code, messages[:error])
    end

    def well_formed?(code)
      [400, 401, 404, 409].include?(code)
    end

    def messages
      map = {
        timeout: "Our payments service was unresponsive.",
        error: "Error occurred with our payments service.",
      }
      map.default = "An unhanded error occurred with our payments service."
      map
    end

    def format_error(code, message)
      {
        "error_code" => code.to_s,
        "error" => { "en" => message },
        "success" => false,
      }.to_json
    end
  end
end

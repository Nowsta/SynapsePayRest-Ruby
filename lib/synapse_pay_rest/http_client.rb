require 'rest-client'

module SynapsePayRest
  class HTTPClient

    attr_accessor :base_url
    attr_accessor :options
    attr_accessor :headers
    attr_accessor :user_id

    def initialize(options, base_url, user_id: nil)
      @options = options
      user = '|%s' %options['fingerprint']
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
      response = with_error_handling { RestClient.post(url, payload.to_json, @headers) }
      JSON.parse(response)
    end

    def patch(path, payload)
      url = base_url + path
      response = with_error_handling { RestClient.patch(url, payload.to_json, @headers) }
      JSON.parse(response)
    end

    def get(path)
      url = base_url + path
      response = with_error_handling { RestClient.get(url, @headers) }
      JSON.parse(response)
    end

    def delete(path)
      url = base_url + path
      response = with_error_handling { RestClient.delete(url, @headers) }
      JSON.parse(response)
    end

    private

    def with_error_handling
      yield
    rescue => e
      # By the way, this is a really bad idea.
      # See: https://www.relishapp.com/womply/ruby-style-guide/docs/exceptions
      # The exceptions should be enumerated. Not all exceptions are going
      # to be parsable by JSON. The only one that should be captured are the
      # are the HTTP Client responses.
      case e.response.code
      when 400
        return e.response
      when 401
        return e.response
      when 409
        return e.response
      when 405
        return handle_method_not_allowed()
      when 500
        return handle_internal_server_error()
      when 502
        return handle_gateway_error()
      when 504
        return handle_timeout_error()
      else
        return handle_unknown_error()
      end
    end

    def handle_internal_server_error()
      return {'success' => false, 'reason' => 'Our payments service is currently down. Please try again in a minute.'}.to_json
    end

    def handle_method_not_allowed()
      return {'success' => false, 'reason' => 'The method is not allowed. Check your id parameters.'}.to_json
    end

    def handle_gateway_error()
      return {'success' => false, 'reason' => 'Our payments service is currently down. Please try again in a minute.'}.to_json
    end

    def handle_timeout_error()
      return {'success' => false, 'reason' => 'A timeout has occurred.'}.to_json
    end

    def handle_unknown_error()
      return {'success' => false, 'reason' => 'An unexpected error has occured. Please try again in a minute.'}.to_json
    end
  end
end

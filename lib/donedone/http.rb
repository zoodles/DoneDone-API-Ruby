require 'net/https'
require 'uri'
require_relative 'multipart'

module DoneDone
  class Http
    attr_reader :domain, :data, :files, :method_url
    attr_reader :_request, :_debug
    private :_request
    private :_debug

    attr_reader :put_class, :get_class, :post_class, :multipart_post_class
    attr_reader :http_class, :ssl_verify_mode, :ssl_version
    def initialize(domain, username, password, options={})
      @domain = domain
      @_username = username
      @_password = password

      @put_class = options[:put_class] || Net::HTTP::Put
      @get_class = options[:get_class] || Net::HTTP::Get
      @post_class = options[:post_class] || Net::HTTP::Post
      @multipart_post_class = options[:multipart_post_class] || Multipart::Post
      @http_class = options[:http_class] || Net::HTTP
      @ssl_verify_mode = options[:ssl_verify_mode] || Constant::SSL_VERIFY_MODE
      @ssl_version = options[:ssl_version] || Constant::SSL_VERSION
    end

    def reset(options = {})
      @data = options[:data]
      @files = options[:files]
      @_request = nil
      @uri = nil
      @base_url = nil
      @host = nil
      @http = nil
      @_debug = options.has_key?(:debug) ? options[:debug] : false
    end

    def host
      unless @host
        @host = Constant.url_for('HOST', domain)
      end
      @host
    end

    def get(method_url, options={})
      @method_url = method_url
      reset(options)
      request(get_class)
    end

    def put(method_url, options={})
      @method_url = method_url
      reset(options)
      request(put_class) do
        append_any_form_data
      end
    end

    def post(method_url, options={})
      @method_url = method_url
      reset(options)
      request(post_class) do
        files ? append_multipart_data : append_any_form_data
      end
    end


    private

    def http
      unless @http
        @http = http_class.new(uri.host, uri.port)
        @http.use_ssl = true
        @http.verify_mode = ssl_verify_mode
        @http.ssl_version = ssl_version
      end
      @http
    end

    def base_url
      unless @base_url
        @base_url = Constant.url_for('BASE_URL', host)
      end
      @base_url
    end

    def uri
      unless @uri
        @uri = URI.parse("#{base_url}#{method_url}")
      end
      @uri
    end

    def request(method_class)
      debug { "#{method_class.name}, #{uri.request_uri.inspect} - host: #{uri.host}, - port: #{uri.port}" }
      @_request = method_class.new(uri.request_uri)

      yield if block_given?

      debug { "uri: #{uri.inspect}, files: #{files.inspect}" }
      _request.basic_auth(@_username, @_password)

      debug { "request: #{_request.to_hash.inspect}" }
      http.request(_request)
    end

    def append_any_form_data #(data=data)
      if data
        debug { "form_data: #{data.inspect}" }
        _request.set_form_data(data)
      end
    end

    def append_multipart_data #(files=files, data=data)
      body, content_type, useragent =
        multipart_post_class.prepare_query( files.merge(data) )

      debug { "params: #{params.inspect}; body: #{body.inspect}, content_type: #{content_type.inspect}, useragent: #{useragent.inspect}" }
      @_request.content_type = content_type
      @_request.content_length = body.size
      @_request["User-Agent"] = useragent

      @_request.body = body
    end

    def debug
      puts(yield) if _debug && block_given?
    end
  end
end

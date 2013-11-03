require 'net/https'
require 'uri'
require_relative 'multipart'

module DoneDone
  class Http
    attr_reader :domain, :data, :files, :method_url
    attr_reader :_request, :_debug
    private :_request
    private :_debug

    def initialize
    end

    def set(domain, username, password, method_url, options = {})
      @domain = domain
      @_username = username
      @_password = password
      @method_url = method_url
      @data = options[:data]
      @files = options[:files]
      @_request = nil
      @_debug = options.has_key?(:debug) ? options[:debug] : false
    end

    def base_url
      unless @base_url
        @base_url = Constant.url_for('BASE_URL', domain) if domain
      end
      @base_url
    end

    def uri
      URI.parse(base_url + method_url)
    end

    def put
      fail "unset" unless uri
      puts "put, #{uri.request_uri.inspect}" if _debug
      @_request = Net::HTTP::Put.new(uri.request_uri)
      puts "form_data, #{data.inspect}" if _debug
      @_request.set_form_data(data) if data
      process
    end

    def get
      fail "unset" unless uri
      puts "get, #{uri.request_uri.inspect}" if _debug
      @_request = Net::HTTP::Get.new(uri.request_uri)
      process
    end

    def post
      fail "unset" unless uri
      puts "post, #{uri.request_uri.inspect}" if _debug
      @_request = Net::HTTP::Post.new(uri.request_uri)

      if files.nil? || files.empty?
        puts "form_data, #{data.inspect}" if _debug
        @_request.set_form_data(data) if data
      else
        params = files.reduce({}){|m,h|m[h.keys.first] = h.values.first; m}
        params.merge!(data)
        body, _header = Multipart::Post.prepare_query(params)
        puts "unused header: #{_header.inspect}"

        puts "params: #{params.inspect}; body: #{body.inspect}"
        @_request.content_type = Multipart::Post::CONTENT_TYPE
        @_request.content_length = body.size
        @_request["User-Agent"] = Multipart::Post::USERAGENT

        @_request.body = body
      end
      process
    end


    private

    def process
      puts "request_method: #{request_method}, uri: #{uri.inspect}, files: #{files.inspect}" if _debug
      puts "http - host: #{uri.host}, - port: #{uri.port}" if _debug
      @_http = Net::HTTP.new(uri.host, uri.port)
      @_http.use_ssl = true
      @_http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @_http.ssl_version = :SSLv3

      @_request.basic_auth(@_username, @_password)

      puts "request: #{_request.to_hash.inspect}" if _debug
      @_http.request(_request)
    end
  end
end

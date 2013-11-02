# Takes a hash of file-key and file-name and returns a string of text
# formatted to be sent as a multipart form post.

require 'mime/types'
require 'cgi'


module DoneDone
  module Multipart
    VERSION = "1.0.0" unless const_defined?(:VERSION)

    # Formats a given hash as a multipart form post
    # If determine if the params are Files or Strings and process
    # appropriately
    class Post
      # We have to pretend like we're a web browser...
      USERAGENT = "Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en-us) AppleWebKit/523.10.6 (KHTML, like Gecko) Version/3.0.4 Safari/523.10.6" unless const_defined?(:USERAGENT)
      BOUNDARY = '--JTMultiPart' + rand(1000000).to_s + 'ZZZZZ' unless const_defined?(:BOUNDARY)
      CONTENT_TYPE = "multipart/form-data; boundary=#{ BOUNDARY }" unless const_defined?(:CONTENT_TYPE)
      HEADER = { "Content-Type" => CONTENT_TYPE, "User-Agent" => USERAGENT } unless const_defined?(:HEADER)

      def self.prepare_query(params)
        fp = []

        params.each do |k, v|
          if File.exists?(v) # must be a file
            path = File.path(v)
            content = File.binread(v)
            fp.push(FileParam.new(k, path, content))
          else # must be a string
            fp.push(StringParam.new(k, v))
          end
        end

        # Assemble the request body using the special multipart format
        query = fp.collect {|p| "--" + BOUNDARY + "\r\n" + p.to_multipart }.join("")  + "--" + BOUNDARY + "--"
        return query, HEADER
      end
    end


    private

    class StringParam
      attr_accessor :k, :v

      def initialize(k, v)
        @k = k
        @v = v
      end

      def to_multipart
        return "Content-Disposition: form-data; name=\"#{CGI::escape(k)}\"\r\n\r\n#{v}\r\n"
      end
    end

    # Formats the contents of a file for inclusion with a multipart
    # form post
    class FileParam
      attr_accessor :k, :filename, :content

      def initialize(k, filename, content)
        @k = k
        @filename = filename
        @content = content
      end

      def to_multipart
        # If we can tell the possible mime-type from the filename, use the
        # first in the list; otherwise, use "application/octet-stream"
        mime_type = MIME::Types.type_for(filename)[0] || MIME::Types["application/octet-stream"][0]
        return "Content-Disposition: form-data; name=\"#{CGI::escape(k)}\"; filename=\"#{ filename }\"\r\n" +
          "Content-Transfer-Encoding: binary\r\n" +
          "Content-Type: #{ mime_type.simplified }\r\n\r\n#{ content }\r\n"
      end
    end
  end
end

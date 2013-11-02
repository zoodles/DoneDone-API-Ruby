require 'net/https'
require "uri"
require "json"
require_relative 'multipart.rb'

#require 'net/http/post/multipart'
#require 'mime/types'
#require 'cgi'

class IssueTracker
  #Provide access to the DoneDone IssueTracker API.
  #See http://www.getdonedone.com/api for complete documentation for the
  #API.

  # Token used to terminate the file in the post body. Make sure it is not
  # present in the file you're uploading.
  #BOUNDARY = "AaB03x"
  #USERAGENT = "Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en-us) AppleWebKit/523.10.6 (KHTML, like Gecko) Version/3.0.4 Safari/523.10.6" unless const_defined?(:USERAGENT)
  #CONTENT_TYPE = "multipart/form-data; boundary=#{ BOUNDARY }" unless const_defined?(:CONTENT_TYPE)
  #HEADER = { "Content-Type" => CONTENT_TYPE, "User-Agent" => USERAGENT } unless const_defined?(:HEADER)


  attr_reader :_debug
  attr_reader :base_url
  attr_reader :response
  private :_debug
  private :base_url

  #_debug - print debug messages
  #domain - company's DoneDone domain
  #username - DoneDone username
  #password - DoneDone password

  def initialize(domain, username, password=nil, debug=false)
    @base_url = "https://#{domain}.mydonedone.com/IssueTracker/API/"
    @response = nil
    @_debug = debug
    @_username = username
    @_password = password #not good to pass this around!
  end

  def result
    response ?  JSON.parse( response.body ) : ""
  end


  # Perform generic API calling
  #This is the base method for all IssueTracker API calls.
  # method_url - IssueTracker method URL
  # data - optional POST form data
  # attachemnts - optional list of file paths
  # update - flag to indicate if this is a PUT operation
  def api(method_url, data=nil, attachments=nil, update=false, post=false)
    @response = nil
    uri = URI.parse(@base_url + method_url)
    files = []
    request_method = nil

    if attachments
      puts "attachments" if _debug
      request_method = :post
      attachments.each_with_index do |attachment, index|
        files.push({"attachment-#{index}" => attachment})
      end
    else
      request_method = :get
    end

    if update
      puts "using put" if _debug
      request_method = :put
    end

    if post
      puts "using post" if _debug
      request_method = :post
    end

    @response = http(request_method, uri, data, files)
    return result
  rescue Exception => e
    warn e.message
    warn e.backtrace.inspect
    return ""
  end

  # Get all Projects with the API enabled
  # load_with_issues - Passing true will deep load all of the projects as
  # well as all of their active issues.
  def projects(load_with_issues=false)
    url = load_with_issues ? 'Projects/true' : 'Projects'
    api url
  end

  # Get priority levels
  def priority_levels
    api 'PriorityLevels'
  end

  # Get all people in a project
  # project_id - project id
  def all_people_in_project project_id
    api "PeopleInProject/#{project_id}"
  end

  # Get all issues in a project
  # project_id - project id
  def all_issues_in_project project_id
    api "IssuesInProject/#{project_id}"
  end

  # Check if an issue exists
  # project_id - project id
  # issue_id - issue id
  def issue_exist?(project_id, issue_id)
    api("DoesIssueExist/#{project_id}/#{issue_id}")
    !result.empty? ? result["IssueExists"] : false
  end

  # Get potential statuses for issue
  # Note: If you are an admin, you'll get both all allowed statuses
  # as well as ALL statuses back from the server
  # project_id - project id
  # issue_id - issue id
  def potential_statuses_for_issue( project_id, issue_id)
    api "PotentialStatusesForIssue/#{project_id}/#{issue_id}"
  end

  # Note: You can use this to check if an issue exists as well,
  # since it will return a 404 if the issue does not exist.
  def issue_details(project_id, issue_id)
    api "Issue/#{project_id}/#{issue_id}"
  end

  # Get a list of people that cane be assigend to an issue
  def people_for_issue_assignment(project_id, issue_id)
    api "PeopleForIssueAssignment/#{project_id}/#{issue_id}"
  end

  #Create Issue
  # project_id - project id
  # title - required title.
  # priority_id - priority levels
  # resolver_id - person assigned to solve this issue
  # tester_id - person assigned to test and verify if a issue is
  # resolved
  # description - optional description of the issue
  # tags - a string of tags delimited by comma
  # watcher_id - a string of people's id delimited by comma
  # attachments - list of file paths
  def create_issue( project_id, title, priority_id, resolver_id, tester_id, description=nil, tags=nil, watcher_id=nil, attachments=nil)
    data = {
      'title' => title,
      'priority_level_id' => priority_id,
      'resolver_id' => resolver_id,
      'tester_id' => tester_id,
    }

    data['description'] = description if description
    data['tags'] = tags if tags
    data['watcher_ids'] = watcher_id if watcher_id

    api( "Issue/#{project_id}", data, attachments, false, true)
    !result.empty? ? result["IssueID"] : nil
  end

  #Create Comment on issue
  #project_id - project id
  #issue_id - issue id
  #comment - comment string
  #people_to_cc_ids - a string of people to be CCed on this comment,
  #delimited by comma
  #attachments - list of absolute file path.
  def create_comment(project_id, order_number, comment, people_to_cc_ids=nil, attachments=nil)
    data = {'comment' => comment}
    data['people_to_cc_ids']= people_to_cc_ids if people_to_cc_ids
    api( "Comment/#{project_id}/#{order_number}", data, attachments, false, true)
    !result.empty? ? result["CommentURL"] : nil
  end

  #Update Issue
  # If you provide any parameters then the value you pass will be
  # used to update the issue. If you wish to keep the value that's
  # already on an issue, then do not provide the parameter in your
  # PUT data. Any value you provide, including tags, will overwrite
  # the existing values on the issue. If you wish to retain the
  # tags for an issue and update it by adding one new tag, then
  # you'll have to provide all of the existing tags as well as the
  # new tag in your tags parameter, for example.

  # project_id - project id
  # order_number - issue id
  # title - required title
  # priority_id - priority levels
  # resolver_id - person assigned to solve this issue
  # tester_id - person assigned to test and verify if a issue is
  # resolved
  # description - optional description of the issue
  # tags - a string of tags delimited by comma
  # state_id - a valid state that this issue can transition to
  # attachments - list of file paths
  def update_issue(project_id, order_number, title=nil, priority_id=nil, resolver_id=nil, tester_id=nil, description=nil, tags=nil, state_id=nil, attachments=nil)
    data = {}
    data['title'] = title if title
    data['priority_level_id'] = priority_id if priority_id
    data['resolver_id'] = resolver_id if resolver_id

    data['tester_id'] = tester_id if tester_id
    data['description'] = description if description
    data['tags'] = tags if tags
    data['state_id'] = state_id if state_id

    api("Issue/#{project_id}/#{order_number}", data, attachments, true)
    !result.empty? ? result["IssueURL"] : nil
  end


  private

  def http(request_method, uri, data, files)
    puts "request_method: #{request_method}, uri: #{uri.inspect}, files: #{files.inspect}" if _debug

    puts "http - host: #{uri.host}, - port: #{uri.port}" if _debug
    @_http = Net::HTTP.new(uri.host, uri.port)
    @_http.use_ssl = true
    @_http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @_http.ssl_version = :SSLv3

    case request_method
    when :post
      puts "post, #{uri.request_uri.inspect}" if _debug
      @_request = Net::HTTP::Post.new(uri.request_uri)

      if files.empty?
        puts "form_data, #{data.inspect}" if _debug
        @_request.set_form_data(data) # this breaks it!
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

    when :put
      puts "put, #{uri.request_uri.inspect}" if _debug
      @_request = Net::HTTP::Put.new(uri.request_uri)
      puts "form_data, #{data.inspect}" if _debug
      @_request.set_form_data(data)

    else # get
      puts "get, #{uri.request_uri.inspect}" if _debug
      @_request = Net::HTTP::Get.new(uri.request_uri)

    end

    @_request.basic_auth(@_username, @_password)


    puts "request: #{@_request.to_hash.inspect}" if _debug

    @_http.request(@_request)
  end

  def mp_form(uri, files)
    #if !files.empty?
    #  post_body = []
    #  # while
    #  if !files.empty?
    #    file_info = files.pop
    #    file_name = file_info.keys.first
    #    file_path = file_info[file_name]
    #
    #          # warn "multi-file uploads not supported; only uploading the first file: #{file_name}!"
    #          
    #          # post_body << file_to_multipart(file_name, file_path, 'image/jpg', File.binread(file_path))
    #          post_body << file_to_multipart(file_name, file_path, 'text/plain', File.read(file_path))
    #
    #        #@_request.body_stream=File.open(file_path)
    #        #@_request.body_stream=File.binread(file_path)
    #
    #        # # @_request["Content-Type"] = "multipart/form-data"
    #        #@_request.add_field('session', BOUNDARY)
    #
    #        #@_request.add_field('Content-Length', File.size(file_path))
    #        @_request["Content-Length"] = File.size(file_path)
    #        end
    #        @_request.body = post_body.collect {|p| '--' + BOUNDARY + "\r\n" + p}.join('') + "--" + BOUNDARY + "--\r\n"
    #        @_request["Content-Type"] = "multipart/form-data, boundary=#{BOUNDARY}"
    #end
  end
end

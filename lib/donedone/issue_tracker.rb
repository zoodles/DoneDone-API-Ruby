require_relative "http"
require_relative "constant"
require "json"

module DoneDone
  class IssueTracker
    HELPER_METHODS = [:response, :result]
    def self.api_methods
      instance_methods(false) - HELPER_METHODS
    end

    #Provide access to the DoneDone IssueTracker API.
    #See http://www.getdonedone.com/api for complete documentation for the
    #API.

    attr_reader :response
    attr_reader :_debug
    private :_debug
    attr_reader :_http_helper
    private :_http_helper

    #_debug - print debug messages
    #domain - company's DoneDone domain
    #username - DoneDone username
    #password - DoneDone password

    def initialize(domain, username, password=nil, options = {})
      @_debug = options.has_key?(:debug) ? options[:debug] : false
      @_http_helper = options[:http_helper] || DoneDone::Http.new(domain, username, password)
      @response = nil
    end

    def result
      response ?  JSON.parse( response.body ) : ""
    end


    # Get all Projects with the API enabled
    # load_with_issues - Passing true will deep load all of the projects as
    # well as all of their active issues.
    def projects(load_with_issues=false)
      url = load_with_issues ? Constant.url_for('PROJECTS_WITH_ISSUES') : Constant.url_for('PROJECTS')
      api url
    end

    # Get priority levels
    def priority_levels
      api Constant.url_for('PRIORITY_LEVELS')
    end

    # Get all people in a project
    # project_id - project id
    def people_in_project project_id
      api Constant.url_for('PEOPLE_IN_PROJECT', project_id)
    end

    # Get all issues in a project
    # project_id - project id
    def issues_in_project project_id
      api Constant.url_for('ISSUES_IN_PROJECT', project_id)
    end

    # Check if an issue exists
    # project_id - project id
    # issue_id - issue id
    def issue_exist?(project_id, issue_id)
      api Constant.url_for('DOES_ISSUE_EXIST', project_id, issue_id)
      !result.empty? ? result["IssueExists"] : false
    end

    # Get potential statuses for issue
    # Note: If you are an admin, you'll get both all allowed statuses
    # as well as ALL statuses back from the server
    # project_id - project id
    # issue_id - issue id
    def potential_statuses_for_issue( project_id, issue_id)
      api Constant.url_for('POTENTIAL_STATUSES_FOR_ISSUE', project_id, issue_id)
    end

    # Note: You can use this to check if an issue exists as well,
    # since it will return a 404 if the issue does not exist.
    def issue(project_id, issue_id)
      api Constant.url_for('ISSUE', project_id, issue_id)
    end

    # Get a list of people that cane be assigend to an issue
    def people_for_issue_assignment(project_id, issue_id)
      api Constant.url_for('PEOPLE_FOR_ISSUE_ASSIGNMENT', project_id, issue_id)
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
    def create_issue( project_id, title, priority_id, resolver_id, tester_id, options={})
      description=options[:description]
      tags=options[:tags]
      watcher_id=options[:watcher_id]
      attachments=options[:attachments]

      data = {
        'title' => title,
        'priority_level_id' => priority_id,
        'resolver_id' => resolver_id,
        'tester_id' => tester_id,
      }

      data['description'] = description if description
      data['tags'] = tags if tags
      data['watcher_ids'] = watcher_id if watcher_id

      params = {:data => data, :update => false, :post => true}
      params[:attachments] = attachments if attachments
      api Constant.url_for('CREATE_ISSUE', project_id), params
      !result.empty? ? result["IssueID"] : nil
    end

    #Create Comment on issue
    #project_id - project id
    #issue_id - issue id
    #comment - comment string
    #people_to_cc_ids - a string of people to be CCed on this comment,
    #delimited by comma
    #attachments - list of absolute file path.
    def create_comment(project_id, order_number, comment, options={})
      people_to_cc_ids=options[:people_to_cc_ids]
      attachments=options[:attachments]

      data = {'comment' => comment}
      data['people_to_cc_ids']= people_to_cc_ids if people_to_cc_ids

      params = {:data => data, :update => false, :post => true}
      params[:attachments] = attachments if attachments
      api Constant.url_for('COMMENT', project_id, order_number), params
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
    def update_issue(project_id, order_number, options={})
      title=options[:title]
      priority_id=options[:priority_id]
      resolver_id=options[:resolver_id]
      tester_id=options[:tester_id]
      description=options[:description]
      tags=options[:tags]
      state_id=options[:state_id]
      attachments=options[:attachments]

      data = {}
      data['title'] = title if title
      data['priority_level_id'] = priority_id if priority_id
      data['resolver_id'] = resolver_id if resolver_id

      data['tester_id'] = tester_id if tester_id
      data['description'] = description if description
      data['tags'] = tags if tags
      data['state_id'] = state_id if state_id

      params = {:update => true}
      params[:data] = data unless data.empty?
      params[:attachments] = attachments if attachments
      api Constant.url_for('ISSUE', project_id, order_number), params
      !result.empty? ? result["IssueURL"] : nil
    end


    private

    # Perform generic API calling
    #This is the base method for all IssueTracker API calls.
    # method_url - IssueTracker method URL
    # data - optional POST form data
    # attachemnts - optional list of file paths
    # update - flag to indicate if this is a PUT operation
    def api(method_url, options={})
      data = options[:data]
      attachments = options[:attachments]
      update = options.has_key?(:update) ? options[:update] : false
      post = options.has_key?(:post) ? options[:post] : false

      @response = nil
      files = {}
      request_method = nil

      if attachments
        debug { "attachments; using post" }
        request_method = :post
        attachments.each_with_index do |attachment, index|
          files["attachment-#{index}"] = attachment
        end
      else
        request_method = :get
      end

      if update
        debug { "using put" }
        request_method = :put
      end

      if post
        debug { "using post" }
        request_method = :post
      end

      params = { :debug => _debug }
      params[:data] = data if data
      params[:files] = files unless files.empty?

      @response = _http_helper.send(request_method, method_url, params)
      return result
    rescue Exception => e
      warn e.message
      warn e.backtrace.inspect
      return ""
    end

    def debug
      puts(yield) if _debug && block_given?
    end
  end
end

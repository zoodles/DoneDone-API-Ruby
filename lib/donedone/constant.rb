module DoneDone
  class Constant
    PROJECTS_WITH_ISSUES = 'Projects/true' unless const_defined?(:PROJECTS_WITH_ISSUES)
    PROJECTS = 'Projects' unless const_defined?(:PROJECTS)
    PRIORITY_LEVELS = 'PriorityLevels' unless const_defined?(:PRIORITY_LEVELS)
    PEOPLE_IN_PROJECT = "PeopleInProject/%s" unless const_defined?(:PEOPLE_IN_PROJECT)
    ISSUES_IN_PROJECT = "IssuesInProject/%s" unless const_defined?(:ISSUES_IN_PROJECT)
    DOES_ISSUE_EXIST = "DoesIssueExist/%s/%s" unless const_defined?(:DOES_ISSUE_EXIST)
    POTENTIAL_STATUSES_FOR_ISSUE = "PotentialStatusesForIssue/%s/%s" unless const_defined?(:POTENTIAL_STATUSES_FOR_ISSUE)
    CREATE_ISSUE = "Issue/%s" unless const_defined?(:CREATE_ISSUE)
    ISSUE = "#{CREATE_ISSUE}/%s" unless const_defined?(:ISSUE)
    PEOPLE_FOR_ISSUE_ASSIGNMENT = "PeopleForIssueAssignment/%s/%s" unless const_defined?(:PEOPLE_FOR_ISSUE_ASSIGNMENT)
    COMMENT = "Comment/%s/%s" unless const_defined?(:COMMENT)

    HOST = "%s.mydonedone.com" unless const_defined?(:HOST)
    PROTOCOL = "https" unless const_defined?(:PROTOCOL)
    BASE_URL_PATH = "IssueTracker/API" unless const_defined?(:BASE_URL_PATH)
    BASE_URL = "#{PROTOCOL}://%s/#{BASE_URL_PATH}/" unless const_defined?(:BASE_URL)

    SSL_VERIFY_MODE = OpenSSL::SSL::VERIFY_NONE unless const_defined?(:SSL_VERIFY_MODE)
    SSL_VERSION = :SSLv3 unless const_defined?(:SSL_VERSION)

    def self.url_for(name, *args)
      format_str = const_get(name)
      if args.empty?
        format_str
      else
        format_str % args
      end
    end
  end
end


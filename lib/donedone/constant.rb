module DoneDone
  class Constant
    PROJECTS_WITH_ISSUES = 'Projects/true'
    PROJECTS = 'Projects'
    PRIORITY_LEVELS = 'PriorityLevels'
    PEOPLE_IN_PROJECT = "PeopleInProject/%s"
    ISSUES_IN_PROJECT = "IssuesInProject/%s"
    DOES_ISSUE_EXIST = "DoesIssueExist/%s/%s"
    POTENTIAL_STATUSES_FOR_ISSUE = "PotentialStatusesForIssue/%s/%s"
    CREATE_ISSUE = "Issue/%s"
    ISSUE = "#{CREATE_ISSUE}/%s"
    PEOPLE_FOR_ISSUE_ASSIGNMENT = "PeopleForIssueAssignment/%s/%s"
    COMMENT = "Comment/%s/%s"

    HOST = "%s.mydonedone.com"
    PROTOCOL = "https"
    BASE_URL_PATH = "IssueTracker/API"
    BASE_URL = "#{PROTOCOL}://%s/#{BASE_URL_PATH}/"

    SSL_VERIFY_MODE = OpenSSL::SSL::VERIFY_NONE
    SSL_VERSION = :SSLv3

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


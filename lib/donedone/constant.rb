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
    BASE_URL = "https://%s.mydonedone.com/IssueTracker/API/"

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


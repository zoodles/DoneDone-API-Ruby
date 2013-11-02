# DoneDone API Ruby Client Library

## REQUIREMENT
Ruby
gem 'mime-types'

## USAGE
To use the Ruby library with a DoneDone project, you will need to enable the API option under the Project Settings page.

Please see http://www.getdonedone.com/api for more detailed documentation.

The examples below work for projects with the API enabled.


## EXAMPLES
```

# use it in your own code:
require 'issue_tracker.rb'

# or interact via irb
cmd-prompt> irb -r "./issue_tracker.rb"

domain = "YOUR_COMPANY_DOMAIN" #e.g. wearemammoth
username = "YOUR_USERNAME"
password = "YOUR_PASSWORD"

issueTracker = IssueTracker.new(domain, username, password)


results = issueTracker.projects
project_id = results.first["ID"]

results = issueTracker.priority_levels

results = issueTracker.all_people_in_project(project_id)

tester_id = results.first["ID"]
resolver_id = results.last["ID"]

results = issueTracker.all_issues_in_project(project_id)

priority_level_id = results.first["PriorityLevelID"]
issue_id = results.first["OrderNumber"]

results = issueTracker.issue_exist?(project_id, issue_id)

results = issueTracker.potential_statuses_for_issue(project_id, issue_id)
results = issueTracker.issue_details(project_id, issue_id)
results = issueTracker.people_for_issue_assignment(project_id, issue_id)

new_issue_id = issueTracker.create_issue(project_id, title, priority_id,
resolver_id, tester_id, description='', tags=nil, watcher_id=nil, attachments=nil)

comment = "blah blah"
file_name = "./file1.txt"
File.open(file_name, "w") {|f| f.puts "attachment one." }
comment_url = issueTracker.create_comment(project_id, new_issue_id, comment, people_to_cc_ids=nil attachments=[file_name])
puts issueTracker.result["SuccesfullyAttachedFiles"] ? "attachment uploaded successfully" : "failed to upload attachment"
File.unlink(file_name)

issue_url = issueTracker.update_issue(project_id, new_issue_id, title=nil, priority_id=nil, resolver_id=nil, tester_id=nil, description=nil, tags=nil, state_id=nil, attachments=nil)

```

## TODO
Package this as a GEM
move issue_tracker.rb & multipart.rb to lib
move IssueTracker into the DoneDone namespace

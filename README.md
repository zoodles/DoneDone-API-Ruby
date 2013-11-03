# DoneDone API Ruby Client Library (GEM)

## REQUIREMENT
Ruby

## USAGE
To use the Ruby library with a DoneDone project, you will need to enable the API option under the Project Settings page.

Please see http://www.getdonedone.com/api for more detailed documentation.

The examples below work for projects with the API enabled.


## EXAMPLES
```

# use it in your own code:
cmd-prompt> gem install 'donedone'
require 'donedone'

# or interact via donedone ruby-cmd
cmd-prompt> donedone -h

# import your LightHouse CSV:
./examples/lighthouse_csv_importer.rb <domain> <usr> <pwd> <project_id> /path/to/your/light_house.csv

# or via irb
cmd-prompt> irb
require 'donedone'

domain = "YOUR_COMPANY_DOMAIN" #e.g. wearemammoth
username = "YOUR_USERNAME"
password = "YOUR_PASSWORD"

issue_tracker = DoneDone::IssueTracker.new(domain, username, password)

# list all the api calls (plus the 'result' method):
issue_tracker.public_methods(false)

issue_tracker.projects
project_id = issue_tracker.result.first["ID"]

issue_tracker.priority_levels

issue_tracker.people_in_project(project_id)
  tester_id = issue_tracker.result.first["ID"]
  resolver_id = issue_tracker.result.last["ID"]

issue_tracker.issues_in_project(project_id)
  priority_level_id = issue_tracker.result.first["PriorityLevelID"]
  issue_id = issue_tracker.result.first["OrderNumber"]

issue_tracker.issue_exist?(project_id, issue_id)
issue_tracker.potential_statuses_for_issue(project_id, issue_id)
issue_tracker.issue(project_id, issue_id)
issue_tracker.people_for_issue_assignment(project_id, issue_id)

new_issue_id = issue_tracker.create_issue(project_id, title, priority_id,
resolver_id, tester_id, {:description => '', :tags=> nil, :watcher_id=>nil, :attachments=>nil})

comment = "blah blah"
file_name = "./file1.txt"
File.open(file_name, "w") {|f| f.puts "attachment one." }
comment_url = issue_tracker.create_comment(project_id, new_issue_id, comment, {:people_to_cc_ids=>nil :attachments=>[file_name]})
puts issue_tracker.result["SuccesfullyAttachedFiles"] ? "attachment uploaded successfully" : "failed to upload attachment"
File.unlink(file_name)

issue_url = issue_tracker.update_issue(project_id, new_issue_id, {:title=>nil, :priority_id=>nil, :resolver_id=>nil, :tester_id=nil, :description=>nil, :tags=>nil, :state_id=>nil, :attachments=>nil})

```

## TODO
improve design via specs

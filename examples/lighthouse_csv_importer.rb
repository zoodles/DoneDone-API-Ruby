#!/usr/bin/env ruby
# Import projct issues from LightHouse CSV exports
# 
# This is a simple example that migrates data from LightHouse to DoneDone using
# the Ruby client. It makes a couple of assumptions. First, the CSV file must
# contain columns listed below.
# 
# number | state | title | milestone | assigned | created | updated | project | tags
# 
# Second, it also assumes the accounts have already been created for the
# project, and throws an execption if not. Because LightHouse handles things a
# bit different from DoneDone, this script will also create the project with assignee
# as both resolver and tester.

require 'donedone'
require 'csv'

domain = ARGV.shift || "Your company domain"
username = ARGV.shift || "Your donedone username"
password = ARGV.shift || "Your donedone password"
project_id = ARGV.shift || "Your donedone project ID"

CSVFilePath = ARGV.shift || "Path to the CSV file exported from lighthouseapp.com"
priority_id = ARGV.shift || 2 #Assuming medium priority

issue_tracker = DoneDone::IssueTracker.new(domain, username, password)
project_peoples = issue_tracker.all_people_in_project(project_id)


# read file
csv_text = File.binread(CSVFilePath)
# slurp
csv = CSV.parse(csv_text, { :headers => true, :return_headers => false, :col_sep => ',', :quote_char =>  '"'})

# loop over issues
csv.each do |issue|
  person_id = nil
  name = issue['assigned']
  if person = project_peoples.detect{|people| people["Value"] == name}
    person_id = person["ID"]
  else
    fail "Fail to find DoneDone account for #{name}"
  end

  # Create issue with medium priority
  print issue_tracker.create_issue(
    project_id, issue['title'], priority_id,
    person_id, person_id,
    "Created by DoneDone API Ruby client.", issue['tags'])

  # Pause execution for API request wait time.
  sleep(5)
end

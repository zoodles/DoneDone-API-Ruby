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

begin
  require 'rubygems'
  gem 'donedone'
rescue LoadError
end

begin
  require 'donedone'
rescue LoadError
  require_relative '../lib/donedone'
end

require 'csv'

DEFAULT_DOMAIN = "Your company domain"
domain = ARGV.shift || DEFAULT_DOMAIN
username = ARGV.shift || "Your donedone username"
password = ARGV.shift || "Your donedone password"
project_id = ARGV.shift.to_i || "Your donedone project ID"

CSVFilePath = ARGV.shift || "Path to the CSV file exported from lighthouseapp.com"
priority_id = ARGV.shift || 2 #Assuming medium priority

# puts "domain: #{domain.inspect}, username: #{username.inspect}, password: #{password.inspect}, project_id: #{project_id.inspect}, csv: #{CSVFilePath.inspect}"
fail( "unknown file: #{CSVFilePath.inspect}") unless File.exists?(CSVFilePath)
fail( "You must edit pass-in variables or edit the default values in #{$0}" ) if DEFAULT_DOMAIN == domain

issue_tracker = DoneDone::IssueTracker.new(domain, username, password)
project_peoples = issue_tracker.people_in_project(project_id)


# read file
csv_text = File.binread(CSVFilePath)
# slurp
csv = CSV.parse(csv_text, { :headers => true, :return_headers => false, :col_sep => ',', :quote_char =>  '"'})

# loop over issues
csv.each do |issue|
  # puts "i: #{issue.inspect}"
  person_id = nil
  name = issue['assigned']
  next if "" == project_peoples
  # puts "pp: #{project_peoples.inspect}"
  if person = project_peoples.detect{|people| people["Value"] == name}
    person_id = person["ID"]
  else
    fail "Fail to find DoneDone account for #{name}"
  end

  # Create issue with medium priority
  print issue_tracker.create_issue(
    project_id, issue['title'], priority_id,
    person_id, person_id,
    {:description => "Created by DoneDone API Ruby client.", :tags => issue['tags']})

  # Pause execution for API request wait time.
  sleep(5)
end

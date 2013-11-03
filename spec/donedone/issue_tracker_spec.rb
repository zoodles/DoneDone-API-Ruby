require 'spec_helper'

describe DoneDone::IssueTracker do
  let(:bogus_http_helper) { Object.new }
  let(:http_helper) { bogus_http_helper }
  let(:domain) { :domain }
  let(:username) { :username }
  let(:password) { :password }
  let(:http_helper_options) { {:debug=>false} }
  let(:issue_tracker) { DoneDone::IssueTracker.new(domain, username, password, :http_helper => http_helper) }

  describe "init" do
    context 'invalid args' do
      it "raises an Exception for 0-1 args" do
        expect { DoneDone::IssueTracker.new }.to raise_error()
        expect { DoneDone::IssueTracker.new(domain) }.to raise_error()
      end
      it "raises an Exception for >4 args" do
        expect { DoneDone::IssueTracker.new(domain, username, password, {}, :extra1) }.to raise_error()
      end
    end

    context 'valid args' do
      it "requires 2-4 args" do
        expect { DoneDone::IssueTracker.new(domain, username) }.to_not raise_error()
        expect { DoneDone::IssueTracker.new(domain, username, password) }.to_not raise_error()
        expect { DoneDone::IssueTracker.new(domain, username, password, {}) }.to_not raise_error()
      end
    end
  end

  describe "methods" do
    let(:expected_api_methods) { [ :projects, :priority_levels, :people_in_project, :issues_in_project, :issue_exist?, :potential_statuses_for_issue, :issue, :people_for_issue_assignment, :create_issue, :create_comment, :update_issue ] }

    let(:actual_helper_methods) { DoneDone::IssueTracker::HELPER_METHODS }
    let(:actual_api_methods) { DoneDone::IssueTracker.api_methods }

    it "distinguises its api- and helper-methods" do
      expect(actual_api_methods).to_not include(actual_helper_methods)
    end

    it "knows its api methods" do
      expect(DoneDone::IssueTracker.api_methods).to eq(expected_api_methods)
    end

    it "responds to its expected-helper and -api methods" do
      (actual_helper_methods + actual_api_methods).each do |expected_method|
        expect(issue_tracker).to respond_to(expected_method)
      end
    end
  end

  describe "api-requests" do
    it "requests all projects" do
      http_helper.should_receive(:set).with(domain, username, password, DoneDone::Constant::PROJECTS, http_helper_options)
      http_helper.should_receive(:get)

      issue_tracker.projects
    end

    it "requests all projects with their issues" do
      http_helper.should_receive(:set).with(domain, username, password, DoneDone::Constant::PROJECTS_WITH_ISSUES, http_helper_options)
      http_helper.should_receive(:get)

      issue_tracker.projects(true)
    end

    it "requests all priority_levels" do
      http_helper.should_receive(:set).with(domain, username, password, DoneDone::Constant::PRIORITY_LEVELS, http_helper_options)
      http_helper.should_receive(:get)

      issue_tracker.priority_levels
    end

    it "requests all people_in_project" do
      project_id = 1
      http_helper.should_receive(:set).with(domain, username, password, DoneDone::Constant.url_for('PEOPLE_IN_PROJECT', project_id), http_helper_options)
      http_helper.should_receive(:get)

      issue_tracker.people_in_project(project_id)
    end

    it "requests all issues_in_project" do
      project_id = 1
      http_helper.should_receive(:set).with(domain, username, password, DoneDone::Constant.url_for('ISSUES_IN_PROJECT', project_id), http_helper_options)
      http_helper.should_receive(:get)

      issue_tracker.issues_in_project(project_id)
    end

    it "requests if an issue exists for a project" do
      project_id = 1
      issue_order_number = 1
      http_helper.should_receive(:set).with(domain, username, password, DoneDone::Constant.url_for('DOES_ISSUE_EXIST', project_id, issue_order_number), http_helper_options)
      http_helper.should_receive(:get)

      issue_tracker.issue_exist?(project_id, issue_order_number)
    end

    it "requests status for a project's issue" do
      project_id = 1
      issue_order_number = 1
      http_helper.should_receive(:set).with(domain, username, password, DoneDone::Constant.url_for('POTENTIAL_STATUSES_FOR_ISSUE', project_id, issue_order_number), http_helper_options)
      http_helper.should_receive(:get)

      issue_tracker.potential_statuses_for_issue(project_id, issue_order_number)
    end

    it "requests a project's issue's details" do
      project_id = 1
      issue_order_number = 1
      http_helper.should_receive(:set).with(domain, username, password, DoneDone::Constant.url_for('ISSUE', project_id, issue_order_number), http_helper_options)
      http_helper.should_receive(:get)

      issue_tracker.issue(project_id, issue_order_number)
    end

    it "requests people for issue assignment" do
      project_id = 1
      issue_order_number = 1
      http_helper.should_receive(:set).with(domain, username, password, DoneDone::Constant.url_for('PEOPLE_FOR_ISSUE_ASSIGNMENT', project_id, issue_order_number), http_helper_options)
      http_helper.should_receive(:get)

      issue_tracker.people_for_issue_assignment(project_id, issue_order_number)
    end

    it "requests to create an issue" do
      project_id = 1
      title = 'required title'
      priority_level_id = 2 # required
      resolver_id = 2 # required
      tester_id = 2 # required

      data = {
        'title' => title,
        'priority_level_id' => priority_level_id,
        'resolver_id' => resolver_id,
        'tester_id' => tester_id,
      }

      options = http_helper_options.merge(:data => data)
      http_helper.should_receive(:set).with(domain, username, password, DoneDone::Constant.url_for('CREATE_ISSUE', project_id), options)
      http_helper.should_receive(:post)

      issue_tracker.create_issue(project_id, title, priority_level_id, resolver_id, tester_id)
    end

    it "requests to create a comment for a project's issue" do
      project_id = 1
      issue_order_number = 1
      comment = 'required comment'

      data = { 'comment' => comment }

      options = http_helper_options.merge(:data => data)
      http_helper.should_receive(:set).with(domain, username, password, DoneDone::Constant.url_for('COMMENT', project_id, issue_order_number), options)
      http_helper.should_receive(:post)

      issue_tracker.create_comment(project_id, issue_order_number, comment)
    end

    it "requests to update a project's issue" do
      project_id = 1
      issue_order_number = 1

      options = http_helper_options
      http_helper.should_receive(:set).with(domain, username, password, DoneDone::Constant.url_for('ISSUE', project_id, issue_order_number), options)
      http_helper.should_receive(:put)

      issue_tracker.update_issue(project_id, issue_order_number, options)
    end

  end

end

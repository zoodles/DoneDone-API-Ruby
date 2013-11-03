require 'spec_helper'

describe DoneDone::Constant do
  describe ".url_for" do
    context 'valid args' do
      it "generates url with format string" do
        expect(DoneDone::Constant.url_for('PEOPLE_IN_PROJECT')).to eq(DoneDone::Constant::PEOPLE_IN_PROJECT)
        expect(DoneDone::Constant.url_for('PEOPLE_IN_PROJECT', '%s')).to eq(DoneDone::Constant::PEOPLE_IN_PROJECT)
      end

      it "generates url without format string" do
        expect(DoneDone::Constant.url_for('PROJECTS_WITH_ISSUES')).to eq(DoneDone::Constant::PROJECTS_WITH_ISSUES)
        expect(DoneDone::Constant.url_for('PROJECTS_WITH_ISSUES', 'bogus_arg1')).to eq(DoneDone::Constant::PROJECTS_WITH_ISSUES)
      end
    end
  end
end

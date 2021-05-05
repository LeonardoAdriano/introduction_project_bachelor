require 'rails_helper'
require 'factory_bot_rails'

RSpec.describe Course, type: :model do
  xcontext 'create course' do
    it 'cannot create a course without a user' do
      expect {
        c = FactoryBot.build(:course)
        c.save!
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context "has_admin?" do
    it "empty course" do
      c = FactoryBot.create(:course)
      expect(c.has_admin?).to eq false
    end

    it "course with single admin" do
      c = FactoryBot.create(:course)
      u_admin = FactoryBot.create(:user)
      c.participants.create(user: u_admin, member_type: "admin")

      expect(c.has_admin?).to eq true
      expect(c.has_admin_without?(u_admin.id)).to eq false
    end

    it "course with single member" do
      c = FactoryBot.create(:course)
      u_member = FactoryBot.create(:user)
      c.participants.create(user: u_member, member_type: "member")

      expect(c.has_admin?).to eq false
      expect(c.has_admin_without?(u_member.id)).to eq false
    end

    it "course with admin and member" do
      c = FactoryBot.create(:course)
      u_admin = FactoryBot.create(:user)
      c.participants.create(user: u_admin, member_type: "admin")

      u_member = FactoryBot.create(:user)
      c.participants.create(user: u_member, member_type: "member")

      expect(c.has_admin?).to eq true
      expect(c.has_admin_without?(u_admin.id)).to eq false
    end
  end
end
  #context 'update the course' do  # (almost) plain English


  #end

  #context 'delete the course' do  # (almost) plain English

  #end

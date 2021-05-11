require 'rails_helper'

RSpec.describe Participant, type: :model do
  it "marcus testet" do
    admin = FactoryBot.create(:user)
    course = FactoryBot.create(:course, super_admin: admin)
    p2 = FactoryBot.create(:participant, member_type: "member", course_id: course.id)

    expect(Course.count).to eq 1
    expect(User.count).to eq 2
    expect(Participant.count).to eq 1
  end

end

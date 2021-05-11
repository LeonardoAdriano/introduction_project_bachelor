require 'factory_bot_rails'
require 'rails_helper'

RSpec.describe Course, type: :model do

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

  #------- add_user!------- 
  context "add_user!" do
    it "add member as admin in public group" do
      c = FactoryBot.create(:course, public: true)

      current_user = FactoryBot.create(:user)
      c.participants.create(user_id: current_user.id, member_type: "admin")
      
      u_member = FactoryBot.create(:user)

      c.add_user!(current_user, u_member, is_admin: false)

      expect(Participant.count).to eq 2
    end

    it "add member as admin in private group" do
      c = FactoryBot.create(:course, public: false)

      current_user = FactoryBot.create(:user)
      c.participants.create(user: current_user, member_type: "admin")
      
      u_member = FactoryBot.create(:user)

      c.add_user!(current_user, u_member, is_admin: false)

      expect(Participant.count).to eq 2
    end

    it "add user as owner in private group" do
      c = FactoryBot.create(:course, public: false)

      owner = c.super_admin

      u_admin= FactoryBot.create(:user)

      u_member= FactoryBot.create(:user)

      u_non_existing= FactoryBot.build(:user)


      c.add_user!(owner, u_admin, is_admin: true)
      c.add_user!(owner, u_member, is_admin: false)
      expect{c.add_user!(owner, u_non_existing, is_admin: false)}.to raise_error(ArgumentError)
      expect{c.add_user!(owner, u_non_existing, is_admin: true)}.to raise_error(ArgumentError)

      expect(Participant.count).to eq 2
    end

    it "add owner as owner " do
      #private group
      c = FactoryBot.create(:course, public: false)

      owner = c.super_admin

      expect{c.add_user!(owner, owner, is_admin: false)}.to raise_error(ArgumentError)
      expect{c.add_user!(owner, owner, is_admin: true)}.to raise_error(ArgumentError)
      expect(Participant.count).to eq 0

      #public group
      c = FactoryBot.create(:course, public: true)

      owner = c.super_admin

      expect{c.add_user!(owner, owner, is_admin: false)}.to raise_error(ArgumentError)
      expect{c.add_user!(owner, owner, is_admin: true)}.to raise_error(ArgumentError)
      expect(Participant.count).to eq 0

    end

    it "add user as owner in public group" do
      c = FactoryBot.create(:course, public: true)

      owner = c.super_admin

      u_admin= FactoryBot.create(:user)

      u_member= FactoryBot.create(:user)

      u_non_existing= FactoryBot.build(:user)


      c.add_user!(owner, u_admin, is_admin: true)
      c.add_user!(owner, u_member, is_admin: false)
      expect{c.add_user!(owner, u_non_existing, is_admin: false)}.to raise_error(ArgumentError)
      expect{c.add_user!(owner, u_non_existing, is_admin: true)}.to raise_error(ArgumentError)

      expect(Participant.count).to eq 2
    end

    

    it "add admin as admin in public group" do
      c = FactoryBot.create(:course, public: true)

      current_user = FactoryBot.create(:user)
      c.participants.create(user: current_user, member_type: "admin")
      
      u_member = FactoryBot.create(:user)
      c.add_user!(current_user, u_member, is_admin: true)
      
      expect(Participant.count).to eq 2
    end

    it "add admin as admin in private group" do
      c = FactoryBot.create(:course, public: false)

      current_user = FactoryBot.create(:user)
      c.participants.create(user: current_user, member_type: "admin")
      
      u_member = FactoryBot.create(:user)

      c.add_user!(current_user, u_member, is_admin: true)
      
      expect(Participant.count).to eq 2
    end


    it "add member as member in public group" do
      c = FactoryBot.create(:course , public: true)

      current_user = FactoryBot.create(:user)
      c.participants.create(user: current_user, member_type: "participant")
      
      u_member = FactoryBot.create(:user)

      c.add_user!(current_user, u_member, is_admin: false)

      expect(Participant.count).to eq 2
    end

    it "add member as member in private group" do
      c = FactoryBot.create(:course, public: false)

      current_user = FactoryBot.create(:user)
      c.participants.create(user: current_user, member_type: "participant")
      
      u_member = FactoryBot.create(:user)

      expect{c.add_user!(current_user, u_member, is_admin: false)}.to raise_error(SecurityError)
    end
    
    it "add admin as member in public group" do
      c = FactoryBot.create(:course , public: true)

      current_user = FactoryBot.create(:user)
      c.participants.create(user: current_user, member_type: "participant")
      
      u_member = FactoryBot.create(:user)

      expect{c.add_user!(current_user, u_member, is_admin: true)}.to raise_error(SecurityError)
    end

    it "add admin as member in private group" do
      c = FactoryBot.create(:course, public: false)

      current_user = FactoryBot.create(:user)
      c.participants.create(user: current_user, member_type: "participant")
      
      u_member = FactoryBot.create(:user)

      expect{c.add_user!(current_user, u_member, is_admin: true)}.to raise_error(SecurityError)
    end

    it "add owner as user to public group" do 
      c = FactoryBot.create(:course, public: true)

      owner = c.super_admin

      u_admin= FactoryBot.create(:user)
      c.participants.create(user: u_admin, member_type: "admin")

      u_member= FactoryBot.create(:user)
      c.participants.create(user: u_member, member_type: "participant")

      u_non= FactoryBot.create(:user)
      
      u_non_existing= FactoryBot.build(:user)


      expect{c.add_user!(u_admin, owner, is_admin: false)}.to raise_error(ArgumentError)
      expect{c.add_user!(u_admin, owner, is_admin: true)}.to raise_error(ArgumentError)

      expect{c.add_user!(u_member, owner, is_admin: false)}.to raise_error(ArgumentError)
      expect{c.add_user!(u_member, owner, is_admin: true)}.to raise_error(ArgumentError)

      expect{c.add_user!(u_non, owner, is_admin: false)}.to raise_error(ArgumentError)
      expect{c.add_user!(u_non, owner, is_admin: true)}.to raise_error(ArgumentError)

      expect{c.add_user!(u_non_existing, owner, is_admin: false)}.to raise_error(ArgumentError)
      expect{c.add_user!(u_non_existing, owner, is_admin: true)}.to raise_error(ArgumentError)

      expect(Participant.count).to eq 2
    end

    it "add user as non to  public group" do
      c = FactoryBot.create(:course, public: true)


      current_user = FactoryBot.create(:user)
      
      u_member = FactoryBot.create(:user)

      expect{c.add_user!(current_user, u_member, is_admin: true)}.to raise_error(SecurityError)
      expect{c.add_user!(current_user, u_member, is_admin: false)}.to raise_error(SecurityError)
    end

    it "add user as non to private  group" do
      c = FactoryBot.create(:course, public: false)

      current_user = FactoryBot.create(:user)
      
      u_member = FactoryBot.create(:user)

      expect{c.add_user!(current_user, u_member, is_admin: true)}.to raise_error(SecurityError)
      expect{c.add_user!(current_user, u_member, is_admin: false)}.to raise_error(SecurityError)
    end

    it "add same user" do
      c = FactoryBot.create(:course, public: false)

      current_user = FactoryBot.create(:user)
      c.participants.create(user: current_user, member_type: "admin")
      
      u_member = FactoryBot.create(:user)

      c.add_user!(current_user, u_member, is_admin: true)
      expect{c.add_user!(current_user, u_member, is_admin: true)}.to raise_error(ActiveRecord::RecordNotUnique)
      expect(Participant.count).to eq 2
    end

    it "add same user with different role" do
      c = FactoryBot.create(:course, public: false)

      current_user = FactoryBot.create(:user)
      c.participants.create(user: current_user, member_type: "admin")
      
      u_member = FactoryBot.create(:user)

      c.add_user!(current_user, u_member, is_admin: true)
      expect{c.add_user!(current_user, u_member, is_admin: false)}.to raise_error(ActiveRecord::RecordNotUnique)
      expect(Participant.count).to eq 2
      expect(c.participants.find_by(user_id: u_member.id).member_type).to eq "admin"
    end

    it "add a non-existing user" do
      c = FactoryBot.create(:course, public: false)

      current_user = FactoryBot.create(:user)
      c.participants.create(user: current_user, member_type: "admin")
      
      u_member = FactoryBot.build(:user)

      expect{c.add_user!(current_user, u_member, is_admin: true)}.to raise_error(ArgumentError)
      expect{c.add_user!(current_user, u_member, is_admin: false)}.to raise_error(ArgumentError)
    end

    it "add with non-existing user" do
      c = FactoryBot.create(:course, public: false)

      current_user = FactoryBot.build(:user)
      c.participants.create(user_id: current_user.id, member_type: "admin")
      
      u_member = FactoryBot.create(:user)

      expect{c.add_user!(current_user, u_member, is_admin: true)}.to raise_error(ActiveRecord::RecordNotFound)
      expect{c.add_user!(current_user, u_member, is_admin: false)}.to raise_error(ActiveRecord::RecordNotFound)
    end
  end


  #------- remove_user! ------- 
  context "remove_user!" do

    it "remove user as owner" do
      c = FactoryBot.create(:course)

      owner = c.super_admin

      u_admin= FactoryBot.create(:user)
      c.participants.create(user: u_admin, member_type: "admin")

      u_member= FactoryBot.create(:user)
      c.participants.create(user: u_member, member_type: "participant")

      u_non= FactoryBot.create(:user)

      u_non_existing= FactoryBot.build(:user)

     c.remove_user!(owner, u_non_existing)
      c.remove_user!(owner, u_non)
      expect(Participant.count).to eq 2

      c.remove_user!(owner, u_admin)
      expect(c.participants.find_by(user_id: u_admin.id)).to eq nil

      c.remove_user!(owner, u_member)
      expect(c.participants.find_by(user_id: u_member.id)).to eq nil

      c.remove_user!(owner, owner)

      expect(Participant.count).to eq 0

    end

    it "remove member as admin" do
      c = FactoryBot.create(:course, public: true)

      current_user = FactoryBot.create(:user)
      c.participants.create(user_id: current_user.id, member_type: "admin")
      
      u_member = FactoryBot.create(:user)
      c.participants.create(user_id: u_member.id, member_type: "participant")

      c.remove_user!(current_user, u_member)

      expect(c.participants.find_by(user_id: u_member.id)).to eq nil
      expect(Participant.count).to eq 1
    end


    it "remove admin as admin" do
      c = FactoryBot.create(:course, public: true)

      current_user = FactoryBot.create(:user)
      c.participants.create(user: current_user, member_type: "admin")
      
      u_member = FactoryBot.create(:user)
      c.participants.create(user_id: u_member.id, member_type: "admin")
      
      c.remove_user!(current_user, u_member)
      expect(c.participants.find_by(user_id: u_member.id)).to eq nil
      expect(Participant.count).to eq 1
    end

    it "remove member as member" do
      c = FactoryBot.create(:course , public: true)

      current_user = FactoryBot.create(:user)
      c.participants.create(user: current_user, member_type: "participant")
      
      u_member = FactoryBot.create(:user)
      c.participants.create(user_id: u_member.id, member_type: "participant")
  

      expect{c.remove_user!(current_user, u_member)}.to raise_error(SecurityError)
      expect(Participant.count).to eq 2
    end

    
    it "remove admin as member in public group" do
      c = FactoryBot.create(:course , public: true)

      current_user = FactoryBot.create(:user)
      c.participants.create(user: current_user, member_type: "participant")
      
      u_member = FactoryBot.create(:user)
      c.participants.create(user: u_member, member_type: "admin")

      expect{c.remove_user!(current_user, u_member)}.to raise_error(SecurityError)
      expect(Participant.count).to eq 2
    end

    it "remove user as non" do
      c = FactoryBot.create(:course, public: true)

      current_user = FactoryBot.create(:user)
      
      u_member = FactoryBot.create(:user)
      c.participants.create(user_id: u_member.id, member_type: "participant")

      u2_member = FactoryBot.create(:user)
      c.participants.create(user_id: u2_member.id, member_type: "admin")

      expect{c.remove_user!(current_user, u_member)}.to raise_error(SecurityError)
      expect{c.remove_user!(current_user, u2_member)}.to raise_error(SecurityError)
      expect(Participant.count).to eq 2
    end

    
    it "remove same user" do
      c = FactoryBot.create(:course, public: false)

      current_user = FactoryBot.create(:user)
      c.participants.create(user_id: current_user.id, member_type: "admin")
      
      u_member = FactoryBot.create(:user)
      c.participants.create(user_id: u_member.id, member_type: "participant")

      c.remove_user!(current_user, u_member)
      c.remove_user!(current_user, u_member)
      expect(Participant.count).to eq 1
    end

    it "remove user with non-existing user" do
      c = FactoryBot.create(:course, public: false)

      current_user = FactoryBot.build(:user)
      c.participants.create(user_id: current_user.id, member_type: "admin")
      
      u_member = FactoryBot.create(:user)
      c.participants.create(user_id: u_member.id, member_type: "participant")

      expect{c.remove_user!(current_user, u_member)}.to raise_error(ActiveRecord::RecordNotFound)
      expect(Participant.count).to eq 1
    end
  end


  #------- change_user_role! ------- 
  context "chance_user_role!" do

    it "change role of user as owner" do
      c = FactoryBot.create(:course)

      owner = c.super_admin

      u_admin= FactoryBot.create(:user)
      c.participants.create(user: u_admin, member_type: "admin")

      u_member= FactoryBot.create(:user)
      c.participants.create(user: u_member, member_type: "participant")

      u_non= FactoryBot.create(:user)

      u_non_existing= FactoryBot.build(:user)

      expect{c.change_user_role!(owner, u_non_existing, is_admin: true)}.to raise_error(ActiveRecord::RecordNotFound)
      expect{c.change_user_role!(owner, u_non_existing, is_admin: true)}.to raise_error(ActiveRecord::RecordNotFound)

      expect{c.change_user_role!(owner, u_non, is_admin: false)}.to raise_error(ArgumentError)
      expect{c.change_user_role!(owner, u_non, is_admin: true)}.to raise_error(ArgumentError)

      expect{c.change_user_role!(owner, owner, is_admin: false)}.to raise_error(ArgumentError)
      expect{c.change_user_role!(owner, owner, is_admin: true)}.to raise_error(ArgumentError)

      expect(Participant.count).to eq 2

      c.change_user_role!(owner, u_admin, is_admin: true)
      expect(c.participants.find_by(user_id: u_admin.id).member_type).to eq "admin"

      c.change_user_role!(owner, u_admin, is_admin: false)
      expect(c.participants.find_by(user_id: u_admin.id).member_type).to eq "participant"

      c.change_user_role!(owner, u_member, is_admin: true)
      expect(c.participants.find_by(user_id: u_member.id).member_type).to eq "admin"

      c.change_user_role!(owner, u_member, is_admin: false)
      expect(c.participants.find_by(user_id: u_member.id).member_type).to eq "participant"

      expect(Participant.count).to eq 2

    end

    it "change role of  member to admin as admin" do
      c = FactoryBot.create(:course, public: true)

      current_user = FactoryBot.create(:user)
      c.participants.create(user_id: current_user.id, member_type: "admin")
      
      u_member = FactoryBot.create(:user)
      c.participants.create(user_id: u_member.id, member_type: "participant")

      c.change_user_role!(current_user, u_member, is_admin: true)

      expect(c.participants.find_by(user_id: u_member.id).member_type).to eq "admin"
      expect(Participant.count).to eq 2
    end

    it "change role of  admin to member as admin" do
      c = FactoryBot.create(:course, public: true)

      current_user = FactoryBot.create(:user)
      c.participants.create(user_id: current_user.id, member_type: "admin")
      
      u_member = FactoryBot.create(:user)
      c.participants.create(user_id: u_member.id, member_type: "admin")
      
      c.change_user_role!(current_user, u_member, is_admin: false)

      expect(c.participants.find_by(user_id: u_member.id).member_type).to eq "participant"
      expect(Participant.count).to eq 2
    end

    it "change role of  member to admin as member" do
      c = FactoryBot.create(:course , public: true)

      current_user = FactoryBot.create(:user)
      c.participants.create(user_id: current_user.id, member_type: "participant")
      
      u_member = FactoryBot.create(:user)
      c.participants.create(user_id: u_member.id, member_type: "participant")
  
      expect{c.change_user_role!(current_user, u_member, is_admin: true)}.to raise_error(SecurityError)

      expect(c.participants.find_by(user_id: u_member.id).member_type).to eq "participant"
      expect(Participant.count).to eq 2
    end

    
    it "change role of  admin to member as member" do
      c = FactoryBot.create(:course , public: true)

      current_user = FactoryBot.create(:user)
      c.participants.create(user_id: current_user.id, member_type: "participant")
      
      u_member = FactoryBot.create(:user)
      c.participants.create(user_id: u_member.id, member_type: "admin")

      expect{c.change_user_role!(current_user, u_member, is_admin: true)}.to raise_error(SecurityError)

      expect(c.participants.find_by(user_id: u_member.id).member_type).to eq "admin"
      expect(Participant.count).to eq 2
    end

    it "change role of  member to member as admin" do
      c = FactoryBot.create(:course , public: true)

      current_user = FactoryBot.create(:user)
      c.participants.create(user_id: current_user.id, member_type: "admin")
      
      u_member = FactoryBot.create(:user)
      c.participants.create(user_id: u_member.id, member_type: "participant")

      c.change_user_role!(current_user, u_member, is_admin: false)

      expect(c.participants.find_by(user_id: u_member.id).member_type).to eq "participant"
      expect(Participant.count).to eq 2
    end

    it "change role of admin to admin as admin" do
      c = FactoryBot.create(:course , public: true)

      current_user = FactoryBot.create(:user)
      c.participants.create(user_id: current_user.id, member_type: "admin")
      
      u_member = FactoryBot.create(:user)
      c.participants.create(user_id: u_member.id, member_type: "admin")

      c.change_user_role!(current_user, u_member, is_admin: true)

      expect(c.participants.find_by(user_id: u_member.id).member_type).to eq "admin"
      expect(Participant.count).to eq 2
    end

    it "change role  as member" do
      c = FactoryBot.create(:course , public: true)

      current_user = FactoryBot.create(:user)
      c.participants.create(user_id: current_user.id, member_type: "participant")
      
      u_member = FactoryBot.create(:user)
      c.participants.create(user_id: u_member.id, member_type: "admin")

      u2_member = FactoryBot.create(:user)
      c.participants.create(user_id: u2_member.id, member_type: "participant")


      expect{c.change_user_role!(current_user, u_member, is_admin: true)}.to raise_error(SecurityError)
      expect{c.change_user_role!(current_user, u2_member, is_admin: false)}.to raise_error(SecurityError)

      expect(c.participants.find_by(user_id: u_member.id).member_type).to eq "admin"
      expect(c.participants.find_by(user_id: u2_member.id).member_type).to eq "participant"
      expect(Participant.count).to eq 3
    end



    it "change role of  user as non" do
      c = FactoryBot.create(:course, public: false)

      current_user = FactoryBot.create(:user)
      
      u_member = FactoryBot.create(:user)
      c.participants.create(user_id: u_member.id, member_type: "participant")

      u2_member = FactoryBot.create(:user)
      c.participants.create(user_id: u2_member.id, member_type: "admin")

      expect{c.change_user_role!(current_user, u_member, is_admin: true)}.to raise_error(SecurityError)
      expect{c.change_user_role!(current_user, u_member, is_admin: false)}.to raise_error(SecurityError)

      expect{c.change_user_role!(current_user, u2_member, is_admin: true)}.to raise_error(SecurityError)
      expect{c.change_user_role!(current_user, u2_member, is_admin: false)}.to raise_error(SecurityError)

      expect(Participant.count).to eq 2
    end

    it "change role of non user" do
      c = FactoryBot.create(:course, public: false)

      current_user = FactoryBot.create(:user)
      c.participants.create(user_id: current_user.id, member_type: "admin")

      current_user2 = FactoryBot.create(:user)
      c.participants.create(user_id: current_user2.id, member_type: "participant")
      
      u_member = FactoryBot.create(:user)

      expect{c.change_user_role!(current_user, u_member, is_admin: true)}.to raise_error(ArgumentError)
      expect{c.change_user_role!(current_user, u_member, is_admin: false)}.to raise_error(ArgumentError)

      expect{c.change_user_role!(current_user2, u_member, is_admin: true)}.to raise_error(ArgumentError)
      expect{c.change_user_role!(current_user2, u_member, is_admin: false)}.to raise_error(ArgumentError)

      expect(Participant.count).to eq 2
    end



    #TODO: Notwendig ?! 
    it "change role of none existing user" do
      c = FactoryBot.create(:course, public: false)

      current_user = FactoryBot.create(:user)
      c.participants.create(user_id: current_user.id, member_type: "admin")

      current_user2 = FactoryBot.create(:user)
      c.participants.create(user_id: current_user2.id, member_type: "participant")
      
      u_member = FactoryBot.build(:user)

      expect{c.change_user_role!(current_user, u_member, is_admin: true)}.to raise_error(ActiveRecord::RecordNotFound)
      expect{c.change_user_role!(current_user, u_member, is_admin: false)}.to raise_error(ActiveRecord::RecordNotFound)

      expect{c.change_user_role!(current_user2, u_member, is_admin: true)}.to raise_error(ActiveRecord::RecordNotFound)
      expect{c.change_user_role!(current_user2, u_member, is_admin: false)}.to raise_error(ActiveRecord::RecordNotFound)

    end

    it "change role of user as none existing user" do
      c = FactoryBot.create(:course, public: false)

      current_user = FactoryBot.build(:user)
      c.participants.create(user_id: current_user.id, member_type: "admin")

      current_user2 = FactoryBot.build(:user)
      c.participants.create(user_id: current_user2.id, member_type: "participant")
      
      u_member = FactoryBot.create(:user)

      expect{c.change_user_role!(current_user, u_member, is_admin: true)}.to raise_error(ActiveRecord::RecordNotFound)
      expect{c.change_user_role!(current_user, u_member, is_admin: false)}.to raise_error(ActiveRecord::RecordNotFound)

      expect{c.change_user_role!(current_user2, u_member, is_admin: true)}.to raise_error(ActiveRecord::RecordNotFound)
      expect{c.change_user_role!(current_user2, u_member, is_admin: false)}.to raise_error(ActiveRecord::RecordNotFound)

    end
  end

    #-------- change_owner --------
    context "change_owner!" do

      it "change user as owner" do
        c = FactoryBot.create(:course)
        
        owner = c.super_admin

        u_admin = FactoryBot.create(:user)
        c.participants.create(user_id: u_admin.id, member_type: "admin")

        c.change_owner!(owner, u_admin)

        expect(c.participants.find_by(user_id: owner.id).member_type).to eq "admin"
        expect(c.super_admin).to eq u_admin
        expect(Participant.count).to eq 1


        #-----
        c = FactoryBot.create(:course)
        
        owner = c.super_admin

        u_participant = FactoryBot.create(:user)
        c.participants.create(user_id: u_participant.id, member_type: "participant")

        c.change_owner!(owner, u_participant)
        expect(c.participants.find_by(user_id: owner.id).member_type).to eq "admin"
        expect(c.super_admin).to eq u_participant
        expect(Participant.count).to eq 2

        #-----
        c = FactoryBot.create(:course)
        
        owner = c.super_admin

        u_user = FactoryBot.create(:user)
        
        c.change_owner!(owner, u_user)
        expect(c.participants.find_by(user_id: owner.id).member_type).to eq "admin"
        expect(c.super_admin).to eq u_user
        expect(Participant.count).to eq 3

        #-----
        c = FactoryBot.create(:course)
        
        owner = c.super_admin

        u_non_existing = FactoryBot.build(:user)
        
        expect{c.change_owner!(owner, u_non_existing)}.to raise_error(ArgumentError)
        expect(c.super_admin).to eq owner

        #-----
        c = FactoryBot.create(:course)
        
        owner = c.super_admin
        
        c.change_owner!(owner, owner)
        expect(c.super_admin).to eq owner
        expect(Participant.count).to eq 3

      end

      it "change user as admin" do
        c = FactoryBot.create(:course)

        owner = c.super_admin

        u_admin = FactoryBot.create(:user)
        c.participants.create(user_id: u_admin.id, member_type: "admin")

        u_perticipant = FactoryBot.create(:user)
        c.participants.create(user_id: u_perticipant.id, member_type: "participant")

        u_user = FactoryBot.create(:user)

        u_non_existing = FactoryBot.build(:user)


        expect{c.change_owner!(u_admin, owner)}.to raise_error(SecurityError)
        expect{c.change_owner!(u_admin, u_admin)}.to raise_error(SecurityError)
        expect{c.change_owner!(u_admin, u_perticipant)}.to raise_error(SecurityError)
        expect{c.change_owner!(u_admin, u_user)}.to raise_error(SecurityError)
        expect{c.change_owner!(u_admin, u_non_existing)}.to raise_error(SecurityError)

        expect(c.super_admin).to eq owner
        expect(c.participants.find_by(user_id: u_admin).member_type).to eq "admin"
        expect(Participant.count).to eq 2
      end

      it "change user as member" do
        c = FactoryBot.create(:course)

        owner = c.super_admin

        u_admin = FactoryBot.create(:user)
        c.participants.create(user_id: u_admin.id, member_type: "admin")

        u_perticipant = FactoryBot.create(:user)
        c.participants.create(user_id: u_perticipant.id, member_type: "participant")

        u_user = FactoryBot.create(:user)

        u_non_existing = FactoryBot.build(:user)


        expect{c.change_owner!(u_perticipant, owner)}.to raise_error(SecurityError)
        expect{c.change_owner!(u_perticipant, u_admin)}.to raise_error(SecurityError)
        expect{c.change_owner!(u_perticipant, u_perticipant)}.to raise_error(SecurityError)
        expect{c.change_owner!(u_perticipant, u_user)}.to raise_error(SecurityError)
        expect{c.change_owner!(u_perticipant, u_non_existing)}.to raise_error(SecurityError)

        expect(c.super_admin).to eq owner
        expect(c.participants.find_by(user_id: u_perticipant).member_type).to eq "participant"
        expect(Participant.count).to eq 2
      end

      it "change user as non" do
        c = FactoryBot.create(:course)

        owner = c.super_admin

        u_admin = FactoryBot.create(:user)
        c.participants.create(user_id: u_admin.id, member_type: "admin")

        u_perticipant = FactoryBot.create(:user)
        c.participants.create(user_id: u_perticipant.id, member_type: "participant")

        u_user = FactoryBot.create(:user)

        u_non_existing = FactoryBot.build(:user)


        expect{c.change_owner!(u_user, owner)}.to raise_error(SecurityError)
        expect{c.change_owner!(u_user, u_admin)}.to raise_error(SecurityError)
        expect{c.change_owner!(u_user, u_perticipant)}.to raise_error(SecurityError)
        expect{c.change_owner!(u_user, u_user)}.to raise_error(SecurityError)
        expect{c.change_owner!(u_user, u_non_existing)}.to raise_error(SecurityError)

        expect(c.super_admin).to eq owner
        expect(Participant.count).to eq 2
      end

      it "change user as non-existing user" do
        c = FactoryBot.create(:course)

        owner = c.super_admin

        u_admin = FactoryBot.create(:user)
        c.participants.create(user_id: u_admin.id, member_type: "admin")

        u_perticipant = FactoryBot.create(:user)
        c.participants.create(user_id: u_perticipant.id, member_type: "participant")

        u_user = FactoryBot.create(:user)

        u_non_existing = FactoryBot.build(:user)


        expect{c.change_owner!(u_non_existing, owner)}.to raise_error(SecurityError)
        expect{c.change_owner!(u_non_existing, u_admin)}.to raise_error(SecurityError)
        expect{c.change_owner!(u_non_existing, u_perticipant)}.to raise_error(SecurityError)
        expect{c.change_owner!(u_non_existing, u_user)}.to raise_error(SecurityError)
        expect{c.change_owner!(u_non_existing, u_non_existing)}.to raise_error(SecurityError)

        expect(c.super_admin).to eq owner
        expect(Participant.count).to eq 2
      end

    end
end

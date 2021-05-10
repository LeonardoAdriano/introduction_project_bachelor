class Course < ApplicationRecord
  # Course::OneAdminValidator
  class OneAdminValidator < ActiveModel::Validator
    def validate(record)
      admins = record.participants.select {|p| p.member_type == "admin"}
      if admins.size < 1
        record.errors.add :base, "The group need one admin."
      end
    end
  end

  has_many :participants , dependent: :destroy
  has_many :users, through:  :participants
  #belongs_to :course
  #belongs_to :user, :foreign_key => 'super_admin_id'
  # validates_with OneAdminValidator, on: :create

  # Adds the given user to the course
  #
  # Works if the current_user is an admin of this group (can add as any role)
  # Works if the current_user is the given user (can only add as member and if the course is public)
  #
  # Throws an exception (see pundit) if adding of the user is not permitted
  #
  # Call as course.add_user!(user, is_admin: true)
  # Call as course.add_user!(user, is_admin: false)
  def add_user!(current_user , user, is_admin:)
    if(!user_exists?(current_user))
      raise SecurityError.new "No Permissions"
    end

    #check if user is present 
    User.find(user.id)

    current_user_role = participants.where(user_id: current_user.id).first
      if current_user_role.member_type == "admin"
        if is_admin
          participants.create(user_id: user.id, member_type: "admin")
          return true
        else
          participants.create(user_id: user.id, member_type: "participant")
          return true
        end  
      end
      if current_user_role.member_type == "participant" && public && !is_admin
        participants.create(user_id: user.id, member_type: "participant")
        return true
      end
    

    raise SecurityError.new "No Permissions"
  end

  

  def change_user_role!(current_user, user, is_admin:)
    if(!user_exists?(current_user))
      raise SecurityError.new "No Permissions"
    end
    if(!user_exists?(user))
      raise SecurityError.new "User dont exist"
    end

    current_user_role = participants.where(user_id: current_user.id).first
    if current_user_role != nil 
      if current_user_role.member_type == "admin"
        if is_admin
          participants.find_by(user_id: user.id).update( member_type: "admin")
          return true
        else
          participants.find_by(user_id: user.id).update( member_type: "participant")
          return true
        end  
      end
    end

    raise SecurityError.new "No Permissions"
  end

  # check if the user is present and a participant
  #throw ActiveRecord::RecordNotFound if the USER is not exists
  def user_exists?(user)
    User.find(user.id) != nil && participants.where(user_id: user.id).count > 0
  end

  # Removes the given user from the course
  #
  # Works if the current_user is an admin of this group
  # Works if the current_user is the given user
  #
  # Doesn't work if the user would be the last remaining admin
  #
  # Throws an exception if removal of the user is not permitted
  def remove_user!(current_user, user)
    if(!user_exists?(current_user))
      raise SecurityError.new "No Permissions"
    end

    current_user_role = participants.find_by(user_id: current_user.id)
    if current_user_role.member_type == "admin"
        user = participants.find_by(user_id: user.id)
        if(user != nil)
          user.destroy
        end
        #participants.find_by(user_id: user.id).destroy
        return true 
    end  

    raise SecurityError.new "No Permissions"
  end

  def has_admin?
    participants.where(member_type: "admin").count > 0
  end

  def has_admin_without?(user_id)
    participants
      .where(member_type: "admin")
      .where.not(user_id: user_id)
      .count > 0
  end
end

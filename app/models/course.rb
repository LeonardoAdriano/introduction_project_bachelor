class Course < ApplicationRecord
  enum role: { admin: 'admin', participant: 'participant' }
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

  belongs_to :super_admin, :foreign_key => 'super_admin_id', class_name: "User"
  # validates_with OneAdminValidator, on: :create

  def all_users
    query = users.to_sql + "\nUNION\n" + User.where(id: super_admin_id).to_sql
    User.find_by_sql(query)
  end

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
    raise_if_user_is_owner(user)

    if(!user_exists?(current_user))
      raise SecurityError.new "No Permissions"
    end
    #check if user is present
    
    if(!user.persisted?)
      raise ArgumentError.new "The user is not persisted"
    end


    current_user_role = participants.find_by(user_id: current_user.id)
      if super_admin == current_user || current_user_role.member_type == Course.roles["admin"] 
        if is_admin
          participants.create(user_id: user.id, member_type: Course.roles["admin"])
          return true
        else
          participants.create(user_id: user.id, member_type: Course.roles["participant"])
          return true
        end
      end
      if current_user_role.member_type == Course.roles["participant"] && public && !is_admin
        participants.create(user_id: user.id, member_type: Course.roles["participant"])
        return true
      end


    raise SecurityError.new "No Permissions"
  end


  def raise_if_user_is_owner(user)
    if(user == super_admin)
      raise ArgumentError.new "You can not add the owner"
    end
  end
  

  def change_user_role!(current_user, user, is_admin:)
    raise_if_user_is_owner(user)
    if(!user_exists?(current_user))
      raise SecurityError.new "No Permissions"
    end
    if(!user_exists?(user))
      raise ArgumentError.new "User dont exist"
    end

    current_user_role = participants.where(user_id: current_user.id).first
    if super_admin == current_user || current_user_role != nil
      if super_admin == current_user || current_user_role.member_type == Course.roles["admin"]
        if is_admin
          participants.find_by(user_id: user.id).update( member_type: Course.roles["admin"])
          return true
        else
          participants.find_by(user_id: user.id).update( member_type: Course.roles["participant"])
          return true
        end
      end
    end

    raise SecurityError.new "No Permissions"
  end

  # check if the user is present and a participant
  #throw ActiveRecord::RecordNotFound if the USER is not exists
  def user_exists?(user)
    User.find(user.id) != nil && (participants.where(user_id: user.id).count > 0 || user == super_admin)
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
    if super_admin == current_user || current_user_role.member_type == Course.roles["admin"]
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
    participants.where(member_type: Course.roles["admin"]).count > 0
  end

  def has_admin_without?(user_id)
    participants
      .where(member_type: Course.roles["admin"])
      .where.not(user_id: user_id)
      .count > 0
  end

  def exist_user?(user)
    if(!user.persisted?)
      raise ArgumentError.new "The user is not persisted"
    end
    return true
  end


  # change the role of the old owner to admin 
  def change_owner!(user_changing, user_to_be_changed)
    if(!user_changing.persisted? || super_admin != user_changing)
      raise SecurityError.new "No Permissions"
    end  
    exist_user?(user_to_be_changed)
    if(super_admin != user_changing)
    ActiveRecord::Base.transaction do
      remove_user!(user_changing, user_to_be_changed)
      participants.create(user_id: user_changing.id, member_type: Course.roles["admin"])
      update(super_admin: user_to_be_changed)
    end
  end

end

end

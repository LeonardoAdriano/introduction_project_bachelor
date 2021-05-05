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
  validates :private, presence: true
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
  def add_user!(user, is_admin:)

  end

  # Removes the given user from the course
  #
  # Works if the current_user is an admin of this group
  # Works if the current_user is the given user
  #
  # Doesn't work if the user would be the last remaining admin
  #
  # Throws an exception if removal of the user is not permitted
  def renmove_user!(user)

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

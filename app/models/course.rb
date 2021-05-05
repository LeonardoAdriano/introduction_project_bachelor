class OneAdminValidator < ActiveModel::Validator
  def validate(record)
    admins = record.participants.select {|p| p.member_type == "admin"}
    if admins.size < 1
      record.errors.add :base, "The group need one admin."
    end
  end
end

class Course < ApplicationRecord
  has_many :participants , dependent: :destroy
  has_many :users, through:  :participants
  validates :private, presence: true
  validates_with OneAdminValidator, on: :create
end


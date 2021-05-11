class GoodnessValidator < ActiveModel::Validator
    def validate(record)
        record.courses.each do | c |
            if c.participants.where(member_type: "admin").size < 1
                record.errors.add :base, "Cannot delete a user which have a course with only one admin"
            end
        end
    end
end

class User < ApplicationRecord
    #validates_with GoodnessValidator, on: :destory
    has_many :participants , dependent: :destroy

    has_many :courses_member, through: :participants, :source => 'user', class_name: "Course"
    has_many :courses_owner, :foreign_key => 'super_admin_id', class_name: "Course"
    #has_many :courses
    validates  :name, presence: true


    def all_courses
      query = courses_owner.to_sql + "\nUNION\n" + courses_member.to_sql
      Course.find_by_sql(query)
    end

    def destroy
        courses.each do | c |
            if c.participants.where(member_type: "admin").size <= 1
                raise "Cannot delete the last admin of a Group"
            end
        end
        super
    end
end

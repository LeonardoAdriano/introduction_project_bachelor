class OneAdminValidator < ActiveModel::Validator
    def validate(record)
            if record.course.participants.where(member_type: "admin").size <= 1
                record.errors.add :base, "One admin is always needed in a group."
            end
    end
end

class Participant < ApplicationRecord
    belongs_to :user
    belongs_to :course
    #validates_with OneAdminValidator, on: :update
end


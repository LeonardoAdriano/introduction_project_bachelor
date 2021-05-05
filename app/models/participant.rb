class Participant < ApplicationRecord
    belongs_to :user
    belongs_to :course
    # validates_with Course::OneAdminValidator, on: :update
end

class User < ApplicationRecord
    has_many :participants
    has_many :courses, through: :participants
end

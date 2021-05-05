require 'rails_helper'
require 'factory_bot_rails'

RSpec.describe User, type: :model do
  context 'create user' do  # (almost) plain English
    it 'without name' do   #
      expect { 
        u = FactoryBot.build(:user)
        u.save!
      }.to raise_error(ActiveRecord::RecordInvalid)  # test code
    end
  end
end

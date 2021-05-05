require 'rails_helper'
require 'factory_bot_rails'

RSpec.describe Course, type: :model do
  context 'create course' do  
    it 'cannot create a course without a user' do   
      expect { 
        c = FactoryBot.build(:course)
        c.save!
      }.to raise_error(ActiveRecord::RecordInvalid)  
    end
  end
end
  #context 'update the course' do  # (almost) plain English
    
   
  #end

  #context 'delete the course' do  # (almost) plain English
   
  #end


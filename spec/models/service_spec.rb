require 'spec_helper'

describe Service do
  before(:each) do
    @service_category = ServiceCategory.create :name => "Service" 
    @service = Service.create( :name => "Potong")
  end
  
  it 'should only allow uniq service name, regardless of case' do 
    new_service = Service.create(:name => "potong")
    new_service.should_not be_valid  
  end
  
  it 'should create duplicate service name if the new name is the only one being active' do
    @service.delete 
    new_service = Service.create(:name => "potong")
    new_service.should be_valid 
  end
  
  it 'should allow update , like setting is_deleted as true' do
    @service.delete
    @service.is_deleted.should be_true 
  end
  
  it 'should not allow update if it is a duplicate of currently present service name' do
    new_service = Service.create(:name => "monkey")
    new_service.should be_valid
    
    new_service.update_attributes(:name => 'potong')
    new_service.should_not be_valid 
  end
  
  
end

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body
  
  has_many :assignments
  has_many :roles, :through => :assignments
  
  # SUBDOMAIN
  
  
  def self.create_main_user(new_user_params) 
    new_user = User.create( :email => new_user_params[:email], 
                            :password => new_user_params[:password],
                            :password => new_user_params[:password_confirmation] )
                        
    if not new_user.valid?
      return new_user
    end
    # admin_role = Role.find_by_name USER_ROLE[:admin]  
    # purchasing_role = Role.find_by_name USER_ROLE[:purchasing]
    # inventory_role = Role.find_by_name USER_ROLE[:inventory]
    # sales_role = Role.find_by_name USER_ROLE[:sales]
    # new_user.add_role_if_not_exists( admin_role )
    # new_user.add_role_if_not_exists( purchasing_role )
    # new_user.add_role_if_not_exists( inventory_role )
    # new_user.add_role_if_not_exists( sales_role )
    return new_user 
  end
=begin
  ROLE VERIFICATION 
=end


  # def has_role?(role_sym)
  #   roles.any? { |r| r.name.underscore.to_sym == role_sym }
  # end
  # 
  # def add_role_if_not_exists( role )
  #   if roles.map{|x| x.id}.include?(role.id)
  #     return nil
  #   else
  #     # create the role assignment 
  #     Assignment.create(:user_id => self.id, 
  #     :role_id => role.id )
  #   end
  # end 
  # 
  # def add_role( role,  employee)
  #   if not employee.has_role?(:admin)
  #     return false
  #   end
  # 
  #   self.add_role_if_not_exists( role )  
  # end
  # 
  # def remove_role(role,  employee)
  #   if  not employee.has_role?(:admin) 
  #     return nil
  #   end
  # 
  # 
  #   if roles.map{|x| x.id}.include?(role.id)
  #     if self.is_main_user==true  && role.id == Role.find_by_name(USER_ROLE[:admin]).id 
  #       return nil
  #     end
  #     # destroy the role assignment 
  #     assignments = Assignment.find(:all, :conditions => {
  #       :role_id => role.id,
  #       :user_id => self.id 
  #     })
  # 
  #     assignments.each do |assignment|
  #       assignment.destroy
  #     end
  # 
  #   else 
  #     return nil
  #   end 
  # end
  # 
  # def User.with_role(role_list)
  #   role_id_list = role_list.map{|x| x.id } 
  #   
  #   User.joins(:assignments).where(
  #     :assignments => {:role_id => role_id_list}
  #   )
  # end
  
end

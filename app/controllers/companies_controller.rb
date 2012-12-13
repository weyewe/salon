class CompaniesController < ApplicationController
  def edit
    @company = Company.find_by_id params[:id]
  end
    
  def update_company
    @company = Company.find_by_id params[:id]
    @company.update_attributes(params[:company])
  end
end

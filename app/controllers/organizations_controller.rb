class OrganizationsController < ApplicationController
  before_action :set_organization, only: [:show, :edit, :update, :destroy]

  def index
    if admin?
      @organizations = Organization.fetch
    else
      redirect_to users_path
    end
  end

  def mine
    @organizations = Organization.fetch_from('/mine')
  end

  def show
  end

  private

  def set_organization
    organization = Organization.filter(params[:name])
    raise "Ambiguous Organization Name #{params[:name]}" unless organization.size == 1
    @organization = organization.first
  end
end

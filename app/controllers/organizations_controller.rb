class OrganizationsController < ApplicationController
  before_action :set_organization, only: [:show, :edit, :update, :destroy]

  def index
    if admin?
      @organizations = Organization.fetch
    else
      redirect_to my_organizations_path
    end
  end

  def mine
    @organizations = Organization.fetch_from('/mine')
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(params)
    if @organization.save
      redirect_to organization_path(@organization.name)
    else
      render :new
    end
  end

  def edit
  end

  def show
  end

  def update
    modifiable_attributes = [
      :public_email,
      :gravatar_email,
      :billing_email,
      :description,
      :url,
      :location
    ]
    modifiable_attributes.each do |attrib|
      @organization.send("#{attrib}=", params[attrib]) if params[attrib]
    end
    if @organization.save
      redirect_to organization_path(@organization.name)
    else
      render :edit
    end
  end

  private

  def set_organization
    organization = Organization.filter(name: params[:id])
    raise "Ambiguous Organization Name #{params[:id]}" unless organization.size == 1
    @organization = organization.first
  end
end

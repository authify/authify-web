class OrganizationsController < ApplicationController
  before_action :set_organization, only: [:show, :edit, :update, :destroy]

  def index
    if admin?
      @organizations = Organization.via_munson(current_user) { |o| o.fetch }
    else
      redirect_to my_organizations_path
    end
  end

  def mine
    @organizations = Organization.via_munson(current_user) {|o| o.fetch_from('/mine') }
  end

  def new
    @organization = Organization.new
    @organization.document.data[:errors] = {}
  end

  def create
    @organization = Organization.via_munson(current_user) { |o| o.new }
    modifiable_attributes = [
      :name,
      :public_email,
      :gravatar_email,
      :billing_email,
      :description,
      :url,
      :location
    ]
    modifiable_attributes.each do |attrib|
      @organization.send("#{attrib}=", params[:organization][attrib]) if params[:organization][attrib]
    end
    @organization.name = @organization.name.to_s.downcase
    if @organization.save
      redirect_to organization_path(@organization.name)
    else
      render :new
    end
  end

  def edit
  end

  def show
    @users  = safely_fetch(@organization, :users)
    @groups = safely_fetch(@organization, :groups)
    @admins = safely_fetch(@organization, :admins)
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

  def safely_fetch(resource, relation)
    begin
      resource.send(relation.to_sym)
    rescue Munson::RelationshipNotFound => e
      relation.to_s.match(/s$/) ? [] : nil
    end
  end

  def set_organization
    organization = Organization.via_munson(current_user) { |o| o.filter(name: params[:id]).fetch }
    raise "Ambiguous Organization Name #{params[:id]}" unless organization.size == 1
    @organization = Organization.via_munson(current_user) do |o|
      o.include(:users, :groups, :admins).find(organization.first.id)
    end
  end
end

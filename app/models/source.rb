class Source < ApplicationRecord
  attribute :uid, :string, :default => -> { SecureRandom.uuid }

  belongs_to :tenant
  acts_as_tenant(:tenant)

  # Service Catalog Inventory Objects
  has_many :service_credential_types
  has_many :service_credentials
  has_many :service_offerings
  has_many :service_offering_nodes
  has_many :service_offering_icons
  has_many :service_offering_service_credentials, :through => :service_offerings
  has_many :service_offering_node_service_credentials, :through => :service_offering_nodes
  has_many :service_offering_tags, :through => :service_offerings
  has_many :service_instances
  has_many :service_instance_service_credentials, :through => :service_instances
  has_many :service_instance_node_service_credentials, :through => :service_instance_nodes
  has_many :service_instance_nodes
  has_many :service_instance_node_service_credentials, :through => :service_instance_nodes
  has_many :service_inventories
  has_many :service_inventory_tags, :through => :service_inventories
  has_many :service_plans

  # Tasks
  has_many :tasks
end

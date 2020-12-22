class Task < ApplicationRecord
  belongs_to :tenant
  belongs_to :source, :optional => true

  validates :state,  :inclusion => {:in => %w(pending queued running completed)}
  validates :status, :inclusion => {:in => %w(ok warn error)}

  acts_as_tenant(:tenant)

  def service_options
    {:tenant_id => tenant.id, :source_id => source.id, :task => self}
  end

  def dispatch
  end
end

class ExtraMobileDataRequest < ApplicationRecord
  belongs_to :created_by_user, class_name: 'User', optional: true
  belongs_to :mobile_network
  validates :status, presence: true

  enum status: {
    requested: 'requested',
    in_progress: 'in_progress',
    queried: 'queried',
    complete: 'complete',
    cancelled: 'cancelled',
  }

  include ExportableAsCsv

  def self.exportable_attributes
    {
      id: 'ID',
      account_holder_name: 'Account holder name',
      device_phone_number: 'Device phone number',
      created_at: 'Requested',
      updated_at: 'Last updated',
      mobile_network_id: 'Mobile network ID',
      status: 'Status',
    }
  end

  def self.from_approved_users
    joins(:created_by_user).merge(User.approved)
  end

  def self.on_mobile_network(mobile_network_id)
    where(mobile_network_id: mobile_network_id)
  end
end
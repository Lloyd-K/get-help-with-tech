class SchoolDeviceAllocation < ApplicationRecord
  belongs_to  :school
  belongs_to  :created_by_user, class_name: 'User'
  belongs_to  :last_updated_by_user, class_name: 'User'

  enum device_type: {
    'coms_device': 'coms_device',
    'std_device': 'std_device',
  }
end
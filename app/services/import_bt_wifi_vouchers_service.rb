require 'open-uri'
require 'csv'

class ImportBTWifiVouchersService
  def initialize(csv_url)
    @csv_url = csv_url
  end

  def call
    csv = URI.parse(@csv_url).read
    CSV.parse(csv, headers: true).select do |row|
      responsible_body = ResponsibleBody.find_by(name: row['Assigned to responsible body name']) if row['Assigned to responsible body name'].present?
      BTWifiVoucher.create!(
        username: row['Username'],
        password: row['Password'],
        responsible_body: responsible_body,
      )
    end
  end
end
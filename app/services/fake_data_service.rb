class FakeDataService
  def self.generate!(extra_mobile_data_requests: 10, mobile_network_id:, created_by_user_id: nil)
    extra_mobile_data_requests.times do
      name = Faker::Name.name
      r = ExtraMobileDataRequest.create!(
        device_phone_number: Faker::PhoneNumber.cell_phone,
        account_holder_name: name,
        agrees_with_privacy_statement: true,
        mobile_network_id: mobile_network_id,
        status: ExtraMobileDataRequest.statuses.values.sample,
        created_by_user_id: created_by_user_id,
      )
      r.update(created_at: Time.now.utc - rand(500_000).seconds)
      Rails.logger.info "created #{r.id} - #{r.account_holder_name}"
    end
  end
end

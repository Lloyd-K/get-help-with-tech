require 'rails_helper'

RSpec.describe ExtraMobileDataRequest, type: :model do
  describe '.from_approved_users' do
    let(:approved_user) { create(:local_authority_user, :approved) }
    let(:not_approved_user) { create(:local_authority_user, :not_approved) }

    it 'includes entries from approved users only' do
      extra_mobile_data_request_from_approved_user = create(:extra_mobile_data_request, created_by_user: approved_user)
      create(:extra_mobile_data_request, created_by_user: not_approved_user)

      expect(ExtraMobileDataRequest.from_approved_users).to eq([extra_mobile_data_request_from_approved_user])
    end
  end

  describe 'to_csv' do
    let(:requests) { ExtraMobileDataRequest.all }

    context 'when account_holder_name starts with a =' do
      before { create(:extra_mobile_data_request, account_holder_name: '=(1+2)') }

      it 'prepends the = with a .' do
        expect(requests.to_csv).to include('.=(1+2)')
      end
    end

    context 'when account_holder_name does not start with a =' do
      before { create(:extra_mobile_data_request, account_holder_name: 'Ben Benson') }

      it 'does not prepend the account_holder_name with a .' do
        expect(requests.to_csv).to include('Ben Benson')
        expect(requests.to_csv).not_to include('.Ben Benson')
      end
    end
  end

  describe 'validating device_phone_number' do
    context 'a phone number that starts with 07' do
      let(:request) { subject }

      before do
        request.device_phone_number = '077  125 92368'
      end

      it 'is valid' do
        request.valid?
        expect(request.errors).not_to(have_key(:device_phone_number))
      end
    end

    context 'a phone number that does not start with 07' do
      let(:request) { subject }

      before do
        request.device_phone_number = '=077  125 92368'
      end

      it 'is not valid' do
        request.valid?
        expect(request.errors).to(have_key(:device_phone_number))
      end
    end
  end

  describe '#notify_account_holder_later' do
    let(:request) { create(:extra_mobile_data_request) }

    before do
      ActiveJob::Base.queue_adapter = :test
    end

    after do
      ActiveJob::Base.queue_adapter = :inline
    end

    it 'enqueues a job to send the message' do
      expect {
        request.notify_account_holder_later
      }.to have_enqueued_job(NotifyExtraMobileDataRequestAccountHolderJob)
    end
  end

  describe '#notify_account_holder_now' do
    context 'for a mno that is providing extra data' do
      let(:request) { create(:extra_mobile_data_request) }
      let(:notification) { instance_double('ExtraMobileDataRequestAccountHolderNotification') }

      before do
        request.send(:instance_variable_set, :@notification, notification)
        allow(notification).to receive(:deliver_now)
      end

      it 'sends the extra data offer sms message' do
        request.notify_account_holder_now
        expect(notification).to have_received(:deliver_now).once
      end
    end
  end
end

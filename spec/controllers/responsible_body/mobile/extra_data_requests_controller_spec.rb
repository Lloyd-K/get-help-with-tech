require 'rails_helper'

RSpec.describe ResponsibleBody::Mobile::ExtraDataRequestsController, type: :controller do
  let(:local_authority_user) { create(:local_authority_user) }

  context 'when authenticated' do
    before do
      sign_in_as local_authority_user
    end

    describe 'submitting spreadsheet choice' do
      it 'redirects to bulk requests' do
        request_data = {
          extra_mobile_data_submission_form: {
            submission_type: 'bulk',
          },
          commit: 'Continue',
        }
        get :new, params: request_data
        expect(response).to redirect_to(new_responsible_body_mobile_bulk_request_path)
      end
    end

    describe 'submitting manual choice' do
      it 'redirects to the manual requests' do
        request_data = {
          extra_mobile_data_submission_form: {
            submission_type: 'manual',
          },
          commit: 'Continue',
        }
        get :new, params: request_data
        expect(response).to redirect_to(new_responsible_body_mobile_manual_request_path)
      end
    end
  end
end

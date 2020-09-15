require 'rails_helper'

describe Support::SchoolDetailsSummaryListComponent do
  let(:school) { create(:school, :primary, :la_maintained) }
  let(:headteacher) do
    create(:school_contact, :headteacher,
           full_name: 'Davy Jones',
           email_address: 'davy.jones@school.sch.uk',
           phone_number: '12345')
  end

  subject(:result) { render_inline(described_class.new(school: school)) }

  context 'when the school will place device orders' do
    before do
      create(:preorder_information,
             school: school,
             who_will_order_devices: :school,
             school_or_rb_domain: 'school.domain.org',
             recovery_email_address: 'admin@recovery.org',
             will_need_chromebooks: 'yes',
             school_contact: headteacher)

      create(:school_device_allocation, school: school, device_type: 'std_device', allocation: 3)
    end

    it 'confirms that fact' do
      expect(result.css('.govuk-summary-list__row')[1].text).to include('The school orders devices')
    end

    it 'renders the school allocation' do
      expect(result.css('.govuk-summary-list__row')[2].text).to include('3 devices')
    end

    it 'renders the school type' do
      expect(result.css('.govuk-summary-list__row')[4].text).to include('Primary school')
    end

    it 'renders the school details' do
      expect(result.css('.govuk-summary-list__row')[0].text).to include('School will be contacted')
    end

    it 'shows the chromebook details without links to change it' do
      expect(result.css('.govuk-summary-list__row')[6].text).to include('Yes, they will need Chromebooks')
      expect(result.css('.govuk-summary-list__row')[7].text).to include('school.domain.org')
      expect(result.css('.govuk-summary-list__row')[8].text).to include('admin@recovery.org')
    end

    context "when the school isn't under lockdown restrictions or has any shielding children" do
      it 'cannot place orders' do
        expect(result.css('.govuk-summary-list__row')[3].text).to include('Not yet because there are no local coronavirus')
      end
    end

    context 'and the headteacher has been set as the school contact' do
      it 'displays the headteacher details' do
        create(:preorder_information,
               school: school,
               who_will_order_devices: :school,
               school_contact: headteacher)

        expect(result.css('.govuk-summary-list__row')[5].text).to include('School contact')
        expect(result.css('.govuk-summary-list__row')[5].inner_html).to include('Headteacher: Davy Jones<br>davy.jones@school.sch.uk<br>12345')
      end
    end

    context 'and the headteacher has been set as the school contact, the school is ready to be contacted' do
      it 'displays an invite link' do
        create(:preorder_information,
               school: school,
               status: :school_will_be_contacted,
               who_will_order_devices: :school,
               school_contact: headteacher)

        expect(result.css('.govuk-summary-list__row')[5].text).to include('Invite')
      end
    end

    context 'and someone else has been set as the school contact' do
      it "displays the new contact's details" do
        new_contact = create(:school_contact, :contact,
                             full_name: 'Jane Smith',
                             email_address: 'abc@example.com',
                             phone_number: '12345')
        create(:preorder_information,
               school: school,
               who_will_order_devices: :school,
               school_contact: new_contact)

        expect(result.css('.govuk-summary-list__row')[5].text).to include('School contact')
        expect(result.css('.govuk-summary-list__row')[5].text).to include('Jane Smith')
        expect(result.css('.govuk-summary-list__row')[5].text).to include('abc@example.com')
        expect(result.css('.govuk-summary-list__row')[5].text).to include('12345')
      end
    end
  end

  context 'when the responsible body will place device orders' do
    let(:school) { create(:school, :primary, :academy) }

    before do
      create(:preorder_information,
             school: school,
             who_will_order_devices: :responsible_body,
             school_or_rb_domain: 'school.domain.org',
             recovery_email_address: 'admin@recovery.org',
             will_need_chromebooks: 'yes',
             school_contact: headteacher)
    end

    it 'confirms that fact' do
      create(:preorder_information, school: school, who_will_order_devices: :responsible_body)

      expect(result.css('.govuk-summary-list__row')[1].text).to include('The trust orders devices')
    end

    it 'shows the chromebook details with links to change it' do
      expect(result.css('.govuk-summary-list__row')[5].text).to include('Yes, they will need Chromebooks')
      expect(result.css('.govuk-summary-list__row')[6].text).to include('school.domain.org')
      expect(result.css('.govuk-summary-list__row')[7].text).to include('admin@recovery.org')
    end

    it 'does not show the school contact even if the school contact is set' do
      expect(result.css('dl').text).not_to include('School contact')
    end
  end

  context 'when the responsible body has not made a decision about who will order' do
    it 'confirms that fact' do
      expect(result.css('.govuk-summary-list__row')[1].text).to include("#{school.responsible_body.name} hasn’t decided this yet")
      expect(result.css('.govuk-summary-list__row')[1].text).not_to include('Decide who will order')
    end
  end
end
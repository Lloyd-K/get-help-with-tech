module ViewHelper
  def govuk_link_to(body, url, html_options = {}, &_block)
    html_options[:class] = prepend_css_class('govuk-link', html_options[:class])

    return link_to(url, html_options) { yield } if block_given?

    link_to(body, url, html_options)
  end

  def ghwt_contact_mailto(subject: 'Increasing%20internet%20access', label: 'COVID.TECHNOLOGY@education.gov.uk')
    mail_to_url = [
      'mailto:COVID.TECHNOLOGY@education.gov.uk',
      (subject.present? ? "subject=#{subject}" : nil),
    ].compact.join('?')

    govuk_link_to label, mail_to_url
  end

  def govuk_button_link_to(body, url, html_options = {})
    html_options[:class] = prepend_css_class('govuk-button', html_options[:class])

    link_to(body, url, role: 'button', class: html_options[:class], 'data-module': 'govuk-button', draggable: false)
  end

  def title_with_error_prefix(title, error)
    "#{t('page_titles.error_prefix') if error}#{title}"
  end

  def sortable_table_header(title, value = title, opts = params)
    if opts[:sort] == value.to_s
      if opts[:dir] == 'd'
        suffix = '▲'
        dir = 'a'
      else
        suffix = '▼'
        dir = 'd'
      end
      safe_join([govuk_link_to(title, sort: value, dir: dir), suffix], ' ')
    else
      govuk_link_to(title, sort: value)
    end
  end

  def participation_description(mobile_network)
    [
      mobile_network.translated_enum_value(:participation_in_pilot),
      # TODO: uncomment this when we've added the supports_payg field
      # mobile_network.supports_payg? ? '' : 'Does not support Pay-as-you-go customers.'
    ].join('. ')
  end

  def mobile_network_options(mobile_networks)
    mobile_networks.map do |network|
      OpenStruct.new(
        id: network.id,
        label: network.brand,
        description: participation_description(network),
      )
    end
  end

  def humanized_seconds(seconds)
    ActiveSupport::Duration.build(seconds).inspect
  end

  def humanized_token_lifetime
    humanized_seconds(Settings.sign_in_token_ttl_seconds)
  end

private

  def prepend_css_class(css_class, current_class)
    if current_class
      current_class.prepend("#{css_class} ")
    else
      css_class
    end
  end
end

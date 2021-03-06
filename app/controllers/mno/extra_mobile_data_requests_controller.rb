class Mno::ExtraMobileDataRequestsController < Mno::BaseController
  def index
    @extra_mobile_data_requests = extra_mobile_data_request_scope.order(safe_order)

    respond_to do |format|
      format.csv do
        render csv: @extra_mobile_data_requests, filename: "requests-mno-#{@mobile_network.id}-#{Time.now.iso8601}"
      end
      # capybara sends through NullType sometimes
      format.any do
        @pagination, @extra_mobile_data_requests = pagy(@extra_mobile_data_requests)
        @extra_mobile_data_requests_form = Mno::ExtraMobileDataRequestsForm.new(
          extra_mobile_data_requests: @extra_mobile_data_requests,
          extra_mobile_data_request_ids: selected_extra_mobile_data_request_ids(@extra_mobile_data_requests, params),
        )
        @statuses = ExtraMobileDataRequest.translated_enum_values(:statuses).reject { |status| status.value == 'queried' }
      end
    end
  end

  def report_problem
    load_extra_mobile_data_request(params[:extra_mobile_data_request_id])
  end

  def update
    load_extra_mobile_data_request(params[:id])
    @extra_mobile_data_request.update!(extra_mobile_data_request_params.merge(status: :queried))
    redirect_to mno_extra_mobile_data_requests_path
  rescue ActiveModel::ValidationError, ActionController::ParameterMissing
    render :report_problem, status: :unprocessable_entity
  end

  def bulk_update
    ExtraMobileDataRequest.transaction do
      new_attributes = { status: bulk_update_params[:status] }
      new_attributes[:problem] = nil unless bulk_update_params[:status] == 'queried'
      ids = bulk_update_params[:extra_mobile_data_request_ids].reject(&:empty?)
      extra_mobile_data_request_scope
               .where('extra_mobile_data_requests.id IN (?)', ids)
               .update_all(new_attributes)
      redirect_to mno_extra_mobile_data_requests_path
    rescue ActiveRecord::StatementInvalid, ArgumentError => e
      logger.error e
      flash[:error] = "I couldn't apply that update"
      render :index, status: :unprocessable_entity
      raise ActiveRecord::Rollback
    end
  end

private

  def extra_mobile_data_request_scope
    @mobile_network.extra_mobile_data_requests.from_approved_users
  end

  def load_extra_mobile_data_request(emdr_id)
    @extra_mobile_data_request = extra_mobile_data_request_scope.find(emdr_id)
  end

  def selected_extra_mobile_data_request_ids(extra_mobile_data_requests, opts = params)
    if opts[:select] == 'all'
      extra_mobile_data_requests.pluck(:id)
    elsif opts[:select] == 'none'
      []
    else
      opts[:extra_mobile_data_request_ids]
    end
  end

  def bulk_update_params(opts = params)
    opts.require(:mno_extra_mobile_data_requests_form).permit(
      :status,
      extra_mobile_data_request_ids: [],
    )
  end

  def safe_order(opts = params)
    order = db_order_field(opts[:sort])
    if order
      { order => db_dir(opts[:dir]) }
    end
  end

  def db_dir(dir_param)
    dir_param == 'd' ? :desc : :asc
  end

  def db_order_field(order_param)
    {
      'id' => :id,
      'mobile_number' => :device_phone_number,
      'account_holder_name' => :account_holder_name,
      'requested' => :created_at,
      'status' => :status,
    }[order_param]
  end

  def extra_mobile_data_request_params(opts = params)
    opts.require(:extra_mobile_data_request).permit(
      :problem,
    )
  end
end

module Spree
  CheckoutController.class_eval do
    def ipayment_success
      payment = find_or_create_ipayment_payment(@order, params)

      if payment.completed?
        redirect_to completion_route
      else
        if payment.source.success?
          ipayment_finalize
        else
          redirect_to "#{checkout_state_path(:payment)}?payment_method_id=#{params["payment_method_id"]}",
          flash: {error: "#{params["ret_errormsg"]} #{params["ret_additionalmsg"]}"}
        end
      end
    end

    def ipayment_error
      redirect_to "#{checkout_state_path(:payment)}?payment_method_id=#{params["payment_method_id"]}",
      flash: {error: "#{params["ret_errormsg"]} #{params["ret_additionalmsg"]}"}
    end

    def find_or_create_ipayment_payment(order, params)
      # check for manipulation and prevent replay attacks
      unless order.total.to_money("EUR").cents.to_s==params[:trx_amount] && order.number==params[:shopper_id]
        raise StandardError, "Attack detected! Manipulation in return parameters! Should be '#{order.inspect}', was '#{params.inspect}'"
      end
      payment_method = PaymentMethod.find(params[:payment_method_id])
      payment = order.payments.find_by_payment_method_id(params[:payment_method_id])
      transaction = Spree::IpaymentTransaction.build_from_params(payment_method, params)

      if payment.present?
        payment.source.destroy if payment.source
        payment.source = transaction
        payment.save!
      else
        order.payments.destroy_all
        payment = order.payments.create({
          :amount => params[:trx_amount],
          :source => transaction,
          :payment_method => payment_method,
        }, :without_protection => true)
        payment.started_processing!
        payment.pend!
      end
      payment
    end

    def ipayment_finalize
      @order.update_attributes({ :state => 'complete', :completed_at => Time.current }, :without_protection => true)
      @order.finalize!
      flash.notice = t(:order_processed_successfully)
      redirect_to completion_route
    end

    def fail_ipayment_payment(order, payment)
      payment.failure!
    end
  end
end

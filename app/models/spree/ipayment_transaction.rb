require 'wirecard/response'

module Spree
  class IpaymentTransaction < ActiveRecord::Base
    has_many :payments, :as => :source

    attr_accessor :payment_method

    serialize :params, Hash
    serialize :capture_log, Hash
    serialize :void_log, Hash
    serialize :credit_log, Hash

    def self.build_from_params(payment_method, params)
      new do |t|
        t.payment_method = payment_method
        t.trx_paymenttype = params[:trx_paymenttype]
        t.trxuser_id = params[:trxuser_id]
        t.trx_amount = params[:trx_amount].to_f / 100 if params[:trx_amount]
        t.trx_currency = params[:trx_currency]
        t.shopper_id = params[:shopper_id]
        t.invoice_text = params[:invoice_text]
        t.trx_typ = params[:trx_typ]
        t.ret_transdate = params[:ret_transdate]
        t.ret_transtime = params[:ret_transtime]
        t.ret_errorcode = params[:ret_errorcode]
        t.ret_authcode = params[:ret_authcode]
        t.ret_reference = params[:ret_reference]
        t.ret_ip = params[:ret_ip]
        t.ret_booknr = params[:ret_booknr]
        t.ret_trx_number = params[:ret_trx_number]
        t.trx_paymentdata_country = params[:trx_paymentdata_country]
        t.addr_country = params[:addr_country]
        t.ret_status = params[:ret_status]
        t.params = params
      end
    end

    def authorization
      nil # we don't need this, but spree calls this method once
    end

    def success?
      return credit_log[:status]=="SUCCESS" unless credit_log.blank?
      return void_log[:status]=="SUCCESS" unless void_log.blank?
      return capture_log[:status]=="SUCCESS" unless capture_log.blank?
      return self.ret_errorcode==0 && self.ret_status=="SUCCESS"
    end

    def failure?
      !success?
    end

    def actions
      %w{capture void}
    end

    private
    def can_capture? *args
      payment.pending?
    end

    def can_void? *args
      payment.pending?
    end
  end
end

require 'savon'
require 'uri'
require 'net/http'

module Spree
  class BillingIntegration::Ipayment < PaymentMethod
    WDSL = "https://ipayment.de/service/3.0/?wsdl"
    CLIENT = Savon.client(wsdl: WDSL)
    ELV = "elv"
    
    preference :account_id, :string, :default => "99999"
    preference :trxuser_id, :string, :default => "99999"
    preference :trxpassword, :string, :default => "0"
    preference :adminactionpassword, :string, :default => "5cfgRT34xsdedtFLdfHxj7tfwx24fe"
    preference :trx_currency, :string, :default => "EUR"
    preference :security_key, :string, :default => "maximum 32 characters!"

    attr_accessible :preferred_account_id, :preferred_trxuser_id, :preferred_trxpassword,
    :preferred_adminactionpassword, :preferred_trx_currency, :preferred_security_key

    # function to convert a hash to the url format key1=value1&key2=value2
    def parameterize(params)
      URI.escape(params.collect{|k,v| "#{k}=#{v}"}.join('&'))
    end

    def create_session amount, redirect_url, shopper_id, silent_error_url
      response = CLIENT.call(:create_session, message: {
        accountData: {
          accountId: preferences[:account_id],
          trxuserId: preferences[:trxuser_id],
          trxpassword: preferences[:trxpassword],
          adminactionpassword: preferences[:adminactionpassword]
        },
        transactionData: {
          trxAmount: amount,
          trxCurrency: preferences[:trx_currency],
          shopperId: shopper_id,
          invoiceText: shopper_id,
          #trxUserComment: "blabla" # TODO: maybe we use this later
        },
        transactionType: "preauth",
        paymentType: ELV,
        options: {
          advancedStrictIdCheck: "1",
          errorLang: "DE"
        },
        processorUrls: {
          redirectUrl: redirect_url,
          silentErrorUrl: silent_error_url
          #hiddenTriggerUrl
        }
      })
      response.body[:create_session_response][:session_id]
    end

    def get_current_country_code current_city
      case current_city.name
      when "Salzburg"
        "DE"
      when "Hamburg"
        "DE"
      end
    end

    def ipayment_url
      "https://ipayment.de/merchant/#{preferences[:account_id]}/processor/2.0/"
    end

    def payment_profiles_supported?
      true
    end

    def capture payment, source, options
      response = CLIENT.call(:capture, message: {
        accountData: {
          accountId: preferences[:account_id],
          trxuserId: preferences[:trxuser_id],
          trxpassword: preferences[:trxpassword],
          adminactionpassword: preferences[:adminactionpassword]
        },
        origTrxNumber: source.ret_trx_number,
        transactionData: {
          trxAmount: payment.capture_amount.to_money.cents,
          trxCurrency: preferences[:trx_currency],
          invoiceText: source.shopper_id,
          shopperId: source.shopper_id,
          #trxUserComment: "blabla" # TODO: maybe we use this later
        },
        options: {
          #fromIp: "10.0.0.1",
          advancedStrictIdCheck: "0",
          errorLang: "DE"
        }
      })

      res = response.body[:capture_response][:ipayment_return]
      source.capture_log = res
      source.save!
      source
    end

    def void
    end

    def get_details order_number
    end

    def credit(amount, transaction, response_code, order_params, options={})
      response = CLIENT.call(:refund, message: {
        accountData: {
          accountId: preferences[:account_id],
          trxuserId: preferences[:trxuser_id],
          trxpassword: preferences[:trxpassword],
          adminactionpassword: preferences[:adminactionpassword]
        },
        origTrxNumber: transaction.capture_log[:success_details][:ret_trx_number],
        transactionData: {
          trxAmount: amount,
          trxCurrency: preferences[:trx_currency],
          invoiceText: "Gutschrift #{transaction.shopper_id}",
        },
        options: {
          #fromIp: "10.0.0.1",
          advancedStrictIdCheck: "0",
          errorLang: "DE"
        }
      })
      transaction.credit_log = response.body[:refund_response][:ipayment_return]
      transaction.save!
      transaction
    end
  end
end

class CreateIpaymentTransactions < ActiveRecord::Migration
  def change
    create_table :spree_ipayment_transactions do |t|
      t.string :trx_paymenttype
      t.integer :trxuser_id
      t.decimal :trx_amount, precision: 8, scale: 2
      t.string :trx_currency
      t.string :shopper_id
      t.string :invoice_text
      t.string :trx_typ
      t.string :ret_transdate
      t.string :ret_transtime
      t.integer :ret_errorcode
      t.string :ret_authcode
      t.string :ret_reference
      t.string :ret_ip
      t.string :ret_booknr
      t.string :ret_trx_number
      t.string :trx_paymentdata_country
      t.string :addr_country
      t.string :ret_status
      t.text :params
      t.text :capture_log
      t.text :credit_log
      t.text :void_log
      t.timestamps
    end
  end
end
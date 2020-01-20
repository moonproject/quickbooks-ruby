module Quickbooks
  module Model
    module Definition
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # https://developer.intuit.com/docs/0025_quickbooksapi/0050_data_services
        TRANSACTION_ENTITIES = %w{
          Bill
          BillPayment
          CreditMemo
          Estimate
          Invoice
          JournalEntry
          JournalCode
          Payment
          Purchase
          PurchaseOrder
          RefundReceipt
          SalesReceipt
          TimeActivity
          VendorCredit
        }.freeze

        def is_transaction_entity?
          TRANSACTION_ENTITIES.include?(name.demodulize)
        end

        def is_name_list_entity?
          !is_transaction_entity?
        end
      end

      def is_transaction_entity?
        self.class.is_transaction_entity?
      end

      def is_name_list_entity?
        self.class.is_name_list_entity?
      end
    end
  end
end

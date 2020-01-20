module Quickbooks
  module Model
    class BillLineItem < BaseModel
      #== Constants
      ACCOUNT_BASED_EXPENSE_LINE_DETAIL = 'AccountBasedExpenseLineDetail'.freeze
      ITEM_BASED_EXPENSE_LINE_DETAIL = 'ItemBasedExpenseLineDetail'.freeze

      xml_accessor :id, from: 'Id'
      xml_accessor :line_num, from: 'LineNum', as: Integer
      xml_accessor :description, from: 'Description'
      xml_accessor :amount, from: 'Amount', as: BigDecimal, to_xml: to_xml_big_decimal
      xml_accessor :detail_type, from: 'DetailType'

      #== Various detail types
      xml_accessor :account_based_expense_line_detail, from: 'AccountBasedExpenseLineDetail', as: AccountBasedExpenseLineDetail
      xml_accessor :item_based_expense_line_detail, from: 'ItemBasedExpenseLineDetail', as: ItemBasedExpenseLineDetail

      def account_based_expense_item?
        detail_type.to_s == ACCOUNT_BASED_EXPENSE_LINE_DETAIL
      end

      def item_based_expense_item?
        detail_type.to_s == ITEM_BASED_EXPENSE_LINE_DETAIL
      end

      def account_based_expense_item!
        self.detail_type = ACCOUNT_BASED_EXPENSE_LINE_DETAIL
        self.account_based_expense_line_detail = AccountBasedExpenseLineDetail.new

        yield account_based_expense_line_detail if block_given?
      end

      def item_based_expense_item!
        self.detail_type = ITEM_BASED_EXPENSE_LINE_DETAIL
        self.item_based_expense_line_detail = ItemBasedExpenseLineDetail.new

        yield item_based_expense_line_detail if block_given?
      end
    end
  end
end

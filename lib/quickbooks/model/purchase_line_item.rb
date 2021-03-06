module Quickbooks
  module Model
    class PurchaseLineItem < BaseModel
      #== Constants
      ITEM_BASED_EXPENSE_LINE_DETAIL = 'ItemBasedExpenseLineDetail'.freeze
      ACCOUNT_BASED_EXPENSE_LINE_DETAIL = 'AccountBasedExpenseLineDetail'.freeze
      GROUP_LINE_DETAIL = 'GroupLineDetail'.freeze

      xml_accessor :id, from: 'Id'
      xml_accessor :line_num, from: 'LineNum', as: Integer
      xml_accessor :description, from: 'Description'
      xml_accessor :amount, from: 'Amount', as: BigDecimal, to_xml: proc { |val| val.to_f }
      xml_accessor :detail_type, from: 'DetailType'

      #== Various detail types
      xml_accessor :account_based_expense_line_detail, from: ACCOUNT_BASED_EXPENSE_LINE_DETAIL, as: AccountBasedExpenseLineDetail
      xml_accessor :item_based_expense_line_detail, from: ITEM_BASED_EXPENSE_LINE_DETAIL, as: ItemBasedExpenseLineDetail
      xml_accessor :group_line_detail, from: GROUP_LINE_DETAIL, as: GroupLineDetail

      def account_based?
        detail_type.to_s == ACCOUNT_BASED_EXPENSE_LINE_DETAIL
      end

      def item_based?
        detail_type.to_s == ITEM_BASED_EXPENSE_LINE_DETAIL
      end

      def account_based_expense!
        self.detail_type = ACCOUNT_BASED_EXPENSE_LINE_DETAIL
        self.account_based_expense_line_detail = AccountBasedExpenseLineDetail.new

        yield account_based_expense_line_detail if block_given?
      end

      def item_based_expense!
        self.detail_type = ITEM_BASED_EXPENSE_LINE_DETAIL
        self.item_based_expense_line_detail = ItemBasedExpenseLineDetail.new

        yield item_based_expense_line_detail if block_given?
      end
    end
  end
end

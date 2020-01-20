module Quickbooks
  module Model
    # Refer to: https://developer.intuit.com/docs/0100_accounting/0300_developer_guides/change_data_capture
    class VendorChange < ChangeModel
      XML_NODE = 'Vendor'.freeze
    end
  end
end

module Quickbooks
  module Model
    class CompanyCurrency < BaseModel
      include NameEntity::PermitAlterations

      XML_COLLECTION_NODE = 'CompanyCurrency'.freeze
      XML_NODE = 'CompanyCurrency'.freeze
      REST_RESOURCE = 'companycurrency'.freeze

      xml_name XML_NODE
      xml_accessor :id, from: 'Id'
      xml_accessor :sync_token, from: 'SyncToken', as: Integer
      xml_accessor :meta_data, from: 'MetaData', as: MetaData
      xml_accessor :name, from: 'Name'
      xml_accessor :code, from: 'Code'
      xml_accessor :active?, from: 'Active'
    end
  end
end

module Quickbooks
  module Model
    class JournalCode < BaseModel
      XML_COLLECTION_NODE = "JournalCode"
      XML_NODE = "JournalCode"
      REST_RESOURCE = "journalcode"
      MINORVERSION = 5

      xml_accessor :id, :from => "Id"
      xml_accessor :sync_token, :from => "SyncToken", :as => Integer
      xml_accessor :meta_data, :from => "MetaData", :as => MetaData
      xml_accessor :custom_field, :from => "CustomField", :as => [CustomField]
      xml_accessor :name, :from => "Name"
      xml_accessor :Type, :from => "Active"
      xml_accessor :description, :from => "Description"

    end
  end
end

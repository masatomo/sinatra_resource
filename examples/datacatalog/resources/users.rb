require File.expand_path(File.dirname(__FILE__) + '/users_keys')

module DataCatalog

  class Users
    include Resource

    model User

    # == Permissions

    permission :read   => :basic
    permission :modify => :owner

    # == Properties
  
    property :name,       :r => :basic
    property :email,      :r => :owner
    property :role,       :r => :owner, :w => :admin

    property :id,         :r => :basic, :w => :nobody
    property :created_at, :r => :owner, :w => :nobody
    property :updated_at, :r => :owner, :w => :nobody

    # == Callbacks
    
  end

end
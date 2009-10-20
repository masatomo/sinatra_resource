module DataCatalog
    
  module Resource
    
    def self.included(includee)
      includee.instance_eval do
        include SinatraResource::Resource
      end
      includee.helpers do
        def before_authorization(action, role)
          unless role
            error 401, display({ "errors" => ["invalid_api_key"] })
          end
          if role == :anonymous && minimum_role(action) != :anonymous
            error 401, display({ "errors" => ["missing_api_key"] })
          end
        end

        def display(object)
          object.nil? ? nil : object.to_json
        end

        def lookup_role(document=nil)
          api_key = lookup_api_key
          return :anonymous unless api_key
          user = user_for(api_key)
          return nil unless user
          return :owner if document && owner?(user, document)
          user.role.intern
        end

        protected

        def lookup_api_key
          @api_key ||= params.delete("api_key")
        end

        # Is +user+ the owner of +document+?
        #
        # First, checks to see if +user+ and +document+ are the same. After
        # that, try to follow the +document.user+ relationship, if present, to
        # see if that points to +user+.
        #
        # @param [DataCatalog::User] user
        #
        # @param [MongoMapper::Document] user
        #
        # @return [Boolean]
        def owner?(user, document)
          return true if user == document
          return false unless document.respond_to?(:user)
          document.user == user
        end

        def user_for(api_key)
          user = User.first(:conditions => { :_api_key => api_key })
          return nil unless user
          raise "API key found, but user has no role" unless user.role
          user
        end
      end
    end

  end
  
end
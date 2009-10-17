module SinatraResource
  
  module Resource
    def self.included(includee)
      includee.extend ClassMethods
      includee.setup
    end
    
    def config
      self.class.instance_variable_get("@resource_config")
    end
    
    module ClassMethods
      def setup
        @resource_config = {
          :model      => nil,
          :permission => {},
          :property   => {},
          :roles      => nil,
        }
      end

      def model(name)
        if @resource_config[:model]
          raise DefinitionError, "model already declared" 
        end
        @resource_config[:model] = name
      end
      
      def permission(access_rules)
        access_rules.each_pair do |verb, role|
          @resource_config[:permission][verb] = role
        end
      end
      
      def property(name, access_rules={})
        access_rules.each_pair do |kind, role|
          @resource_config[:property][name] ||= {}
          @resource_config[:property][name][kind] = role
        end
      end
      
      def roles(klass)
        if @resource_config[:roles]
          raise DefinitionError, "roles already declared"
        end
        @resource_config[:roles] = klass
      end
      
      def build
        validate
        builder = Builder.new(
          :klass  => self,
          :config => @resource_config
        )
        builder.build
      end

      def validate
        unless @resource_config[:model]
          raise ValidationError, "model required"
        end
      end
      
    end
  end
  
end

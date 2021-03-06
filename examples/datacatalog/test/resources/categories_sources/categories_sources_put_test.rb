require File.expand_path(File.dirname(__FILE__) + '/../../helpers/resource_test_helper')

class CategoriesSourcesPutResourceTest < ResourceTestCase

  include DataCatalog

  def app; Categories end
  
  before do
    @category = create_category
    @source = create_source
    @source_copy = @source.dup
    @categorization = create_categorization(
      :source_id   => @source.id,
      :category_id => @category.id
    )
    @other_category = create_category
    @other_source = create_source
    @other_categorization = create_categorization(
      :source_id   => @other_source.id,
      :category_id => @other_category.id
    )
    @valid_params = {
      :title   => "Changed Source",
      :url     => "http://updated.com/details/7"
    }
    @extra_admin_params = { :raw => { "key" => "value" } }
  end

  after do
    @other_categorization.destroy
    @other_source.destroy
    @other_category.destroy
    @categorization.destroy
    @source.destroy
    @category.destroy
  end

  context "put /:id/sources/:id" do
    context "anonymous" do
      before do
        put "/#{@category.id}/sources/#{@source.id}"
      end
    
      use "return 401 because the API key is missing"
      use "source unchanged"
    end
  
    context "incorrect API key" do
      before do
        put "/#{@category.id}/sources/#{@source.id}", :api_key => BAD_API_KEY
      end
      
      use "return 401 because the API key is invalid"
      use "source unchanged"
    end
  end

  %w(basic).each do |role|
    context "#{role} : put /:fake_id/sources/:fake_id" do
      before do
        put "/#{FAKE_ID}/sources/#{FAKE_ID}", :api_key => api_key_for(role)
      end
    
      use "return 404 Not Found with empty response body"
      use "source unchanged"
    end
    
    context "#{role} : put /:fake_id/sources/:id" do
      before do
        put "/#{FAKE_ID}/sources/#{@source.id}", :api_key => api_key_for(role)
      end
    
      use "return 404 Not Found with empty response body"
      use "source unchanged"
    end
    
    context "#{role} : put /:id/sources/:fake_id" do
      before do
        put "/#{@category.id}/sources/#{FAKE_ID}", :api_key => api_key_for(role)
      end
    
      use "return 401 because the API key is unauthorized"
      use "source unchanged"
    end
  
    context "#{role} : put /:id/sources/:not_related_id" do
      before do
        put "/#{@category.id}/sources/#{@other_source.id}",
          :api_key => api_key_for(role)
      end
      
      use "return 401 because the API key is unauthorized"
      use "source unchanged"
    end
  
    context "#{role} : put /:id/sources/:id" do
      before do
        put "/#{@category.id}/sources/#{@source.id}", :api_key => api_key_for(role)
      end
      
      use "return 401 because the API key is unauthorized"
      use "source unchanged"
    end
  end

  %w(curator).each do |role|
    context "#{role} : put /:fake_id/sources/:fake_id" do
      before do
        put "/#{FAKE_ID}/sources/#{FAKE_ID}", :api_key => api_key_for(role)
      end
    
      use "return 404 Not Found with empty response body"
      use "source unchanged"
    end
    
    context "#{role} : put /:fake_id/sources/:id" do
      before do
        put "/#{FAKE_ID}/sources/#{@source.id}", :api_key => api_key_for(role)
      end
    
      use "return 404 Not Found with empty response body"
      use "source unchanged"
    end
    
    context "#{role} : put /:id/sources/:fake_id" do
      before do
        put "/#{@category.id}/sources/#{FAKE_ID}", :api_key => api_key_for(role)
      end
    
      use "return 404 Not Found with empty response body"
      use "source unchanged"
    end
  
    context "#{role} : put /:id/sources/:not_related_id" do
      before do
        put "/#{@category.id}/sources/#{@other_source.id}",
          :api_key => api_key_for(role)
      end
      
      use "return 404 Not Found with empty response body"
      use "source unchanged"
    end

    [:raw, :created_at, :updated_at, :junk].each do |invalid|
      context "#{role} : put /:id/sources/:id with #{invalid}" do
        before do
          put "/#{@category.id}/sources/#{@source.id}",
            valid_params_for(role).merge(invalid => 9)
        end
  
        use "return 400 Bad Request"
        use "source unchanged"
        invalid_param invalid
      end
    end

    [:title, :url].each do |erase|
      context "#{role} : put /:id/sources/:id but blanking out #{erase}" do
        before do
          put "/#{@category.id}/sources/#{@source.id}",
            valid_params_for(role).merge(erase => "")
        end
      
        use "return 400 Bad Request"
        use "source unchanged"
        missing_param erase
      end
    end

    [:title, :url].each do |missing|
      context "#{role} : put /:id/sources/:id without #{missing}" do
        before do
          put "/#{@category.id}/sources/#{@source.id}",
            valid_params_for(role).delete_if { |k, v| k == missing }
        end
      
        use "return 200 Ok"
        doc_properties %w(title url raw id created_at updated_at)

        test "should change correct fields in database" do
          source = Source.find_by_id(@source.id)
          @valid_params.each_pair do |key, value|
            assert_equal(value, source[key]) if key != missing
          end
          assert_equal @source_copy[missing], source[missing]
        end
      end
    end
  
    context "#{role} : put /:id/sources/:id with valid params" do
      before do
        put "/#{@category.id}/sources/#{@source.id}", valid_params_for(role)
      end

      use "return 200 Ok"
      doc_properties %w(title url raw id created_at updated_at)
          
      test "should change correct fields in database" do
        source = Source.find_by_id(@source.id)
        @valid_params.each_pair do |key, value|
          assert_equal value, source[key]
        end
      end
    end
  end

  %w(admin).each do |role|
    context "#{role} : put /:fake_id/sources/:fake_id" do
      before do
        put "/#{FAKE_ID}/sources/#{FAKE_ID}",
          valid_params_for(role).merge(@extra_admin_params)
      end
    
      use "return 404 Not Found with empty response body"
      use "source unchanged"
    end
    
    context "#{role} : put /:fake_id/sources/:id" do
      before do
        put "/#{FAKE_ID}/sources/#{@source.id}",
          valid_params_for(role).merge(@extra_admin_params)
      end
    
      use "return 404 Not Found with empty response body"
      use "source unchanged"
    end
    
    context "#{role} : put /:id/sources/:fake_id" do
      before do
        put "/#{@category.id}/sources/#{FAKE_ID}",
          valid_params_for(role).merge(@extra_admin_params)
      end
    
      use "return 404 Not Found with empty response body"
      use "source unchanged"
    end
      
    context "#{role} : put /:id/sources/:not_related_id" do
      before do
        put "/#{@category.id}/sources/#{@other_source.id}",
          valid_params_for(role).merge(@extra_admin_params)
      end
      
      use "return 404 Not Found with empty response body"
      use "source unchanged"
    end

    context "#{role} : put /:id/sources/:id with no params" do
      before do
        put "/#{@category.id}/sources/#{@source.id}", 
          :api_key => api_key_for(role)
      end
    
      use "return 400 because no params were given"
      use "source unchanged"
    end
    
    [:title, :url].each do |missing|
      context "#{role} : put /:id/sources/:id without #{missing}" do
        before do
          put "/#{@category.id}/sources/#{@source.id}",
            valid_params_for(role).merge(@extra_admin_params).delete_if { |k, v| k == missing }
        end
      
        use "return 200 Ok"
        doc_properties %w(title url raw id created_at updated_at)
    
        test "should change correct fields in database" do
          source = Source.find_by_id(@source.id)
          @valid_params.merge(@extra_admin_params).each_pair do |key, value|
            assert_equal(value, source[key]) if key != missing
          end
          assert_equal @source_copy[missing], source[missing]
        end
      end
    end

    [:title, :url].each do |erase|
      context "#{role} : put /:id/sources/:id but blanking out #{erase}" do
        before do
          put "/#{@category.id}/sources/#{@source.id}",
            valid_params_for(role).merge(@extra_admin_params).merge(erase => "")
        end
      
        use "return 400 Bad Request"
        use "source unchanged"
        missing_param erase
      end
    end

    [:created_at, :updated_at, :junk].each do |invalid|
      context "#{role} : put /:id/sources/:id but with #{invalid}" do
        before do
          put "/#{@category.id}/sources/#{@source.id}",
            valid_params_for(role).merge(@extra_admin_params).merge(invalid => 9)
        end
      
        use "return 400 Bad Request"
        use "source unchanged"
        invalid_param invalid
      end
    end

    context "#{role} : put /:id/sources/:id" do
      before do
        put "/#{@category.id}/sources/#{@source.id}",
          valid_params_for(role).merge(@extra_admin_params)
      end
      
      use "return 200 Ok"
      doc_properties %w(title url raw id created_at updated_at)
      
      test "should change all fields in database" do
        source = Source.find_by_id(@source.id)
        @valid_params.merge(@extra_admin_params).each_pair do |key, value|
          assert_equal value, source[key]
        end
      end
    end
  end
  
end

require File.expand_path(File.dirname(__FILE__) + '/../../helpers/resource_test_helper')

class SourcesGetManyResourceTest < ResourceTestCase

  include DataCatalog

  def app; Sources end

  before do
    Source.destroy_all unless Source.count == 0
    @sources = 3.times.map do |i|
      create_source(:title => "Source #{i}")
    end
    @source_titles = ["Source 0", "Source 1", "Source 2"].sort
  end

  after do
    @sources.each { |x| x.destroy } if @sources
  end

  context "title='Source 2'" do
    before do
      @search_params = { :filter => "title='Source 2'" }
    end

    context "get /" do
      context "anonymous" do
        before do
          get "/", @search_params
        end

        use "return 401 because the API key is missing"
      end

      context "incorrect API key" do
        before do
          get "/", @search_params.merge(:api_key => BAD_API_KEY)
        end

        use "return 401 because the API key is invalid"
      end
    end

    %w(basic curator admin).each do |role|
      context "#{role} : get /" do
        before do
          get "/", @search_params.merge(:api_key => api_key_for(role))
        end

        use "return 200 Ok"

        test "body should have 1 source" do
          assert_equal 1, parsed_response_body.length
        end

        test "body should have correct source" do
          assert_equal 'Source 2', parsed_response_body[0]['title']
        end

        docs_properties %w(title url raw categories id created_at updated_at)
      end
    end
  end

  context "title:Source" do
    before do
      @search_params = { :filter => "title:Source" }
    end

    %w(basic curator admin).each do |role|
      context "#{role} : get /" do
        before do
          get "/", @search_params.merge(:api_key => api_key_for(role))
        end

        use "return 200 Ok"

        test "body should have 3 sources" do
          assert_equal 3, parsed_response_body.length
        end

        test "body should have correct source titles" do
          actual = parsed_response_body.map { |e| e["title"] }
          assert_equal @source_titles, actual.sort
        end

        docs_properties %w(title url raw categories id created_at updated_at)
      end
    end
  end

end
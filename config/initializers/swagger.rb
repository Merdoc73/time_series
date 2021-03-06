Swagger::Docs::Config.register_apis({
  "1.0" => {
    # the extension used for the API
    :api_extension_type => nil,
    # the output location where your .json files are written to
    :api_file_path => Rails.root.join("public/"),
    :base_path => "https://time-series-1.herokuapp.com/",
    # if you want to delete all .json files at each generation
    :clean_directory => true,
    # add custom attributes to api-docs
    :attributes => {
      :info => {
        "title" => "Time Series App",
        "description" => "This is a sample description.",
        "termsOfServiceUrl" => "http://helloreverb.com/terms/",
        "contact" => "apiteam@wordnik.com",
        "license" => "Apache 2.0",
        "licenseUrl" => "http://www.apache.org/licenses/LICENSE-2.0.html"
      }
    }
  }
})
GrapeSwaggerRails.options.url      = 'api-docs.json'
GrapeSwaggerRails.options.app_url  = 'https://time-series-1.herokuapp.com/'
module Swagger
  module Docs
    class Config
      def self.base_api_controller
        Api::ApplicationController
      end
    end
  end
end

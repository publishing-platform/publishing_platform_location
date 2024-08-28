RSpec.describe PublishingPlatformLocation do
  context "overriding the uri for a service" do
    it "looks for an env variable matching the service name and returns its value when present" do
      ClimateControl.modify PUBLISHING_PLATFORM_LOCATION_SERVICE_FOO_URI: "http://foo.localhost:5001" do
        expect(PublishingPlatformLocation.find("foo")).to eql "http://foo.localhost:5001"
      end
    end
  end
end

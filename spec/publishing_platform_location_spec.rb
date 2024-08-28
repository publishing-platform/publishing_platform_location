# frozen_string_literal: true

RSpec.describe PublishingPlatformLocation do
  it "has a version number" do
    expect(PublishingPlatformLocation::VERSION).not_to be nil
  end

  describe "#find" do
    it "uses dev domain by default" do
      url = PublishingPlatformLocation.find("publisher")
      expect(URI.parse(url).host).to eql "publisher.dev.publishing-platform.co.uk"
    end

    it "uses http for dev domain" do
      url = PublishingPlatformLocation.find("publisher")
      expect(URI.parse(url).scheme).to eql "http"
    end

    it "uses provided domain" do
      url = PublishingPlatformLocation.new("test.publishing-platform.co.uk").find("publisher")
      expect(URI.parse(url).host).to eql "publisher.test.publishing-platform.co.uk"
    end

    it "uses environment set domain" do
      ClimateControl.modify PUBLISHING_PLATFORM_APP_DOMAIN: "provided-by-env.co.uk" do
        url = PublishingPlatformLocation.find("publisher")
        expect(url).to eql "https://publisher.provided-by-env.co.uk"
      end
    end

    it "uses https for provided domain" do
      url = PublishingPlatformLocation.new("test.publishing-platform.co.uk").find("publisher")
      expect(URI.parse(url).scheme).to eql "https"
    end

    it "uses http for provided domain if forced" do
      url = PublishingPlatformLocation.new("test.publishing-platform.co.uk").find("publisher", force_http: true)
      expect(URI.parse(url).scheme).to eql "http"
    end

    it "uses single label domains for empty app domain" do
      ClimateControl.modify PUBLISHING_PLATFORM_APP_DOMAIN: "" do
        expect(PublishingPlatformLocation.find("publisher")).to eql "http://publisher"
      end

      expect(PublishingPlatformLocation.new("").find("publisher")).to eql "http://publisher"
    end

    it "raises an error if service name is invalid" do
      expect { PublishingPlatformLocation.find("invalid name") }.to raise_error(ArgumentError)
    end

    it "prefixes hostname with value from environment variable" do
      ClimateControl.modify PUBLISHING_PLATFORM_LOCATION_HOSTNAME_PREFIX: "draft-" do
        expect(PublishingPlatformLocation.new("test.publishing-platform.co.uk").find("router")).to eql "https://draft-router.test.publishing-platform.co.uk"
      end
    end

    it "does not prefix unprefixable hosts" do
      ClimateControl.modify PUBLISHING_PLATFORM_LOCATION_HOSTNAME_PREFIX: "draft-",
                            PUBLISHING_PLATFORM_LOCATION_UNPREFIXABLE_HOSTS: "signon,feedback" do
        loc = PublishingPlatformLocation.new("test.publishing-platform.co.uk")
        expect(loc.find("content-store")).to eql "https://draft-content-store.test.publishing-platform.co.uk"
        expect(loc.find("signon")).to eql "https://signon.test.publishing-platform.co.uk"
        expect(loc.find("feedback")).to eql "https://feedback.test.publishing-platform.co.uk"
      end
    end
  end

  describe "#website_root" do
    it "uses www on dev domain by default" do
      expect(PublishingPlatformLocation.website_root).to eql "http://www.dev.publishing-platform.co.uk"
    end

    it "uses environment set domain" do
      ClimateControl.modify PUBLISHING_PLATFORM_WEBSITE_ROOT: "https://provided-by-env.co.uk" do
        expect(PublishingPlatformLocation.website_root).to eql "https://provided-by-env.co.uk"
      end
    end
  end

  describe "#external_url_for" do
    it "uses dev domain by default" do
      url = PublishingPlatformLocation.external_url_for("frontend")
      expect(URI.parse(url).host).to eql "frontend.dev.publishing-platform.co.uk"
    end

    it "uses http for dev domain" do
      url = PublishingPlatformLocation.external_url_for("frontend")
      expect(URI.parse(url).scheme).to eql "http"
    end

    it "uses provided external domain" do
      url = PublishingPlatformLocation.new(nil, "external.co.uk").external_url_for("frontend")
      expect(URI.parse(url).host).to eql "frontend.external.co.uk"
    end

    it "uses environment set external domain" do
      ClimateControl.modify PUBLISHING_PLATFORM_APP_DOMAIN_EXTERNAL: "external.co.uk" do
        url = PublishingPlatformLocation.external_url_for("frontend")
        expect(URI.parse(url).host).to eql "frontend.external.co.uk"
      end
    end

    it "uses https for provided external domain" do
      url = PublishingPlatformLocation.new(nil, "external.co.uk").external_url_for("frontend")
      expect(URI.parse(url).scheme).to eql "https"
    end

    it "uses https for environment set external domain" do
      ClimateControl.modify PUBLISHING_PLATFORM_APP_DOMAIN_EXTERNAL: "external.co.uk" do
        url = PublishingPlatformLocation.external_url_for("frontend")
        expect(URI.parse(url).scheme).to eql "https"
      end
    end

    it "uses http for provided external domain if forced" do
      url = PublishingPlatformLocation.new(nil, "external.co.uk").external_url_for("frontend", force_http: true)
      expect(URI.parse(url).scheme).to eql "http"
    end

    it "uses http for environment set external domain if forced" do
      ClimateControl.modify PUBLISHING_PLATFORM_APP_DOMAIN_EXTERNAL: "external.co.uk" do
        url = PublishingPlatformLocation.external_url_for("frontend", force_http: true)
        expect(URI.parse(url).scheme).to eql "http"
      end
    end
  end
end

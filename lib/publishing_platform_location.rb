# frozen_string_literal: true

require_relative "publishing_platform_location/version"
require "forwardable"

class PublishingPlatformLocation
  # Raised when a required environment variable is not set.
  class NoConfigurationError < StandardError; end

  # The fallback parent domain to use in development mode.
  DEV_DOMAIN = "dev.publishing-platform.co.uk"

  attr_reader :parent_domain, :external_domain

  # Construct a new PublishingPlatformLocation instance.
  def initialize(domain_to_use = nil, external_domain = nil)
    @parent_domain = domain_to_use || env_var_or_fallback("PUBLISHING_PLATFORM_APP_DOMAIN", DEV_DOMAIN) # empty string for internal services
    @external_domain = external_domain || ENV.fetch("PUBLISHING_PLATFORM_APP_DOMAIN_EXTERNAL", @parent_domain)
    @host_prefix = ENV.fetch("PUBLISHING_PLATFORM_LOCATION_HOSTNAME_PREFIX", "")
    @unprefixable_hosts = ENV.fetch("PUBLISHING_PLATFORM_LOCATION_UNPREFIXABLE_HOSTS", "").split(",").map(&:strip)
  end

  # Find the base URL for a service/application.
  def find(service, options = {})
    name = valid_service_name(service)

    if (service_uri = defined_service_uri_for(name))
      return service_uri
    end

    name = "#{host_prefix}#{name}" unless unprefixable_hosts.include?(name)

    domain = options[:external] ? external_domain : parent_domain
    domain_suffix = domain.empty? ? "" : ".#{domain}" # empty string for internal services

    scheme = if options[:force_http] || http_domain?(domain)
               "http:"
             else
               "https:"
             end

    "#{scheme}//#{name}#{domain_suffix}".freeze
  end

  # Find the external URL for a service/application.
  def external_url_for(service, options = {})
    find(service, options.merge(external: true))
  end

  # Find the base URL for the public website frontend.
  def website_root
    env_var_or_fallback("PUBLISHING_PLATFORM_WEBSITE_ROOT") { find("www") }
  end

  class << self
    extend Forwardable

    def_delegators :new, :find, :external_url_for, :website_root
  end

private

  attr_reader :host_prefix, :unprefixable_hosts

  def valid_service_name(name)
    service_name = name.to_s
    return service_name if service_name.match?(/\A[a-z1-9.-]+\z/)

    raise ArgumentError, "PublishingPlatformLocation expects a service name to only contain lowercase a-z, numbers . (period) and - (dash) characters."
  end

  def http_domain?(domain)
    [DEV_DOMAIN, ""].include?(domain) # internal services
  end

  def env_var_or_fallback(var_name, fallback_str = nil)
    if (var = ENV[var_name])
      var
    elsif ENV["RAILS_ENV"] == "production" || ENV["RACK_ENV"] == "production"
      raise(NoConfigurationError, "Expected #{var_name} to be set.")
    elsif block_given?
      yield
    else
      fallback_str
    end
  end

  # Overrides the URL for a given service via a corresponding
  # environment variable.
  #
  # e.g. if PUBLISHING_PLATFORM_LOCATION_SERVICE_CHEESE_THING_URI
  # was set, +PublishingPlatformLocation.new.find('cheese-thing')+
  # would return the value of that variable.
  def defined_service_uri_for(service)
    service_name = service.upcase.tr("-", "_")
    uri = ENV.fetch("PUBLISHING_PLATFORM_LOCATION_SERVICE_#{service_name}_URI", "")
    uri.empty? ? nil : uri
  end
end

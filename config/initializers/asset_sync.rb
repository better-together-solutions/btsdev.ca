# frozen_string_literal: true

if defined?(AssetSync)
  AssetSync.configure do |config|
    # Disabled by default; pass ASSET_SYNC_ENABLED=true as a build arg to enable.
    # Internal/S3-compatible endpoints (e.g. Garage on 172.17.0.1) are not reachable
    # at Docker build time, so asset_sync must be disabled for those deployments.
    config.enabled = ENV.fetch('ASSET_SYNC_ENABLED', 'false') == 'true'

    config.fog_provider = 'AWS'

    config.aws_access_key_id = ENV.fetch('AWS_ACCESS_KEY_ID', nil)
    config.aws_secret_access_key = ENV.fetch('AWS_SECRET_ACCESS_KEY', nil)

    config.aws_session_token = ENV['AWS_SESSION_TOKEN'] if ENV.key?('AWS_SESSION_TOKEN')

    config.aws_iam_roles = ENV['AWS_IAM_ROLES'] == 'true'

    config.fog_directory = ENV.fetch('FOG_DIRECTORY', nil)
    config.fog_region = ENV.fetch('FOG_REGION', nil)

    # For S3-compatible providers (e.g. Garage, MinIO), set a custom endpoint via
    # ASSET_SYNC_ENDPOINT or FOG_HOST. Strip any scheme prefix from the host value
    # since fog constructs its own URL; derive the scheme separately.
    s3_endpoint = ENV.fetch('ASSET_SYNC_ENDPOINT', nil) || ENV.fetch('FOG_HOST', nil)
    if s3_endpoint && s3_endpoint !~ /amazonaws\.com/i
      scheme = s3_endpoint =~ /^http:\/\// ? 'http' : 'https'
      config.fog_scheme = scheme
      config.fog_host = s3_endpoint.sub(%r{^https?://}, '')
      config.fog_options = { path_style: true }
    else
      config.fog_scheme = 'https'
    end

    config.cdn_distribution_id = ENV['CDN_DISTRIBUTION_ID'] if ENV.key?('CDN_DISTRIBUTION_ID')
    config.fail_silently = true
    config.log_silently = true
    config.concurrent_uploads = true
  end
end

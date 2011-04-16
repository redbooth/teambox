require 'vcr'

VCR.config do |c|
  c.cassette_library_dir     = 'features/vcr_cassettes'
  c.stub_with                :fakeweb
  c.ignore_localhost         = true
  c.allow_http_connections_when_no_cassette = false
  c.default_cassette_options = { :record => :once }
end
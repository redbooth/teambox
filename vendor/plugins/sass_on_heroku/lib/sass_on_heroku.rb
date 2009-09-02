class SassOnHeroku
	def self.original_css_location
		@@original_css_location ||= nil
	end

	def self.original_css_location=(location)
		@@original_css_location = location
	end

	def initialize(app)
		@app = app
		initialize_sass unless self.class.original_css_location
	end

	def initialize_sass
		# get the original location of compiled css files (ie: stylesheets/compiled)
		# and replace it to a location in tmp
		if Sass::Plugin.options[:template_location].is_a?(Hash)
			self.class.original_css_location = Sass::Plugin.options[:template_location].values.first
			Sass::Plugin.options[:template_location].keys.each do |k|
				Sass::Plugin.options[:template_location][k] = css_location_on_heroku
			end
		else
			self.class.original_css_location = Sass::Plugin.options[:css_location]
			Sass::Plugin.options[:css_location] = css_location_on_heroku
		end

		# compile Sass once, and set it to not compile again
		Sass::Plugin.options[:always_update] = true
		Sass::Plugin.options[:never_update] = false
		Sass::Plugin.update_stylesheets
		Sass::Plugin.options[:never_update] = true
	end

	def call(env)
		if !stylesheets.empty? && env['REQUEST_PATH'] =~ css_request_regexp
			return render_sass($1)
		end
		@app.call(env)
	end

	def render_sass(name)
		css_file = "#{css_location_on_heroku}/#{name}"
		[
			200,
			{
				'Cache-Control'  => 'public, max-age=86400',
				'Content-Length' => File.size(css_file).to_s,
				'Content-Type'   => 'text/css'
			},
			File.read(css_file)
		]
	end

	def css_location_on_heroku
		"#{RAILS_ROOT}/tmp/sass-output"
	end

	def stylesheets
		@stylesheets ||= Dir[css_location_on_heroku + '/*.css'].map { |f| f.split('/').last }
	end

	def css_request_regexp
		@css_request_regexp ||= build_regexp
	end

	# builds a regexp that matches requests for Sass stylesheets
	# ie : \/stylesheets\/sass\/(file1\.css|file2\.css)
	def build_regexp
		files = stylesheets.map { |f| Regexp.escape(f) }
		path  = Regexp.escape(self.class.original_css_location.gsub("#{RAILS_ROOT}/public", '') + '/')
		regexp = Regexp.new("^#{path}(" + files.join('|') + ')(\?.*)?$')
	end
end

# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{acts_as_versioned}
  s.version = "0.5.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["technoweenie"]
  s.date = %q{2009-01-20}
  s.description = %q{TODO}
  s.email = %q{technoweenie@bidwell.textdrive.com}
  s.files = ["VERSION.yml", "lib/acts_as_versioned.rb", "test/abstract_unit.rb", "test/database.yml", "test/fixtures", "test/fixtures/authors.yml", "test/fixtures/landmark.rb", "test/fixtures/landmark_versions.yml", "test/fixtures/landmarks.yml", "test/fixtures/locked_pages.yml", "test/fixtures/locked_pages_revisions.yml", "test/fixtures/migrations", "test/fixtures/migrations/1_add_versioned_tables.rb", "test/fixtures/page.rb", "test/fixtures/page_versions.yml", "test/fixtures/pages.yml", "test/fixtures/widget.rb", "test/migration_test.rb", "test/schema.rb", "test/versioned_test.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/technoweenie/acts_as_versioned}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{TODO}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

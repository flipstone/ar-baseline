module FixtureHelper
  def reset_fixtures
    FileUtils.rm_rf fixture_base_dir
    FileUtils.cp_r'spec/fixtures', fixture_base_dir
  end

  def fixture_base_dir
    'tmp/fixtures'
  end

  def fixture_path(name)
    File.join(fixture_base_dir, name)
  end
end


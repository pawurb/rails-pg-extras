# frozen_string_literal: true

module RailsPGExtras
  def self.extensions_description
    "Available and installed extensions"
  end

  def self.extensions_sql
    <<-EOS
SELECT * FROM pg_available_extensions ORDER BY installed_version;
EOS
  end
end

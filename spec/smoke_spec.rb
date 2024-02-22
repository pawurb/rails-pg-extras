# frozen_string_literal: true

require "spec_helper"
require "rails-pg-extras"

describe RailsPgExtras do
  RailsPgExtras::QUERIES.each do |query_name|
    it "#{query_name} query can be executed" do
      expect do
        RailsPgExtras.run_query(
          query_name: query_name,
          in_format: :hash,
        )
      end.not_to raise_error
    end
  end

  it "runs the custom methods" do
    expect do
      RailsPgExtras.diagnose(in_format: :hash)
    end.not_to raise_error

    expect do
      RailsPgExtras.index_info(in_format: :hash)
    end.not_to raise_error

    expect do
      RailsPgExtras.table_info(in_format: :hash)
    end.not_to raise_error
  end

  it "collecting queries data works" do
    output = RailsPgExtras.measure_queries { RailsPgExtras.diagnose(in_format: :hash) }
    expect(output.fetch(:count)).to eq 10
  end

  it "supports custom RAILS_PG_EXTRAS_DATABASE_URL" do
    ENV["RAILS_PG_EXTRAS_DATABASE_URL"] = ENV["DATABASE_URL"]

    expect do
      RailsPgExtras.calls
    end.not_to raise_error

    ENV["RAILS_PG_EXTRAS_DATABASE_URL"] = nil
  end
end

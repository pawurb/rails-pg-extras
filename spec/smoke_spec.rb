# frozen_string_literal: true

require 'spec_helper'

describe RailsPGExtras do
  PG_STATS_DEPENDENT_QUERIES = %i(calls outliers)

  before(:all) do
    RailsPGExtras.connection.execute("CREATE EXTENSION IF NOT EXISTS pg_buffercache;")
  end

  (RailsPGExtras::QUERIES - PG_STATS_DEPENDENT_QUERIES).each do |query_name|
    it "#{query_name} query can be executed" do
      expect do
        RailsPGExtras.run_query(
          query_name: query_name,
          in_format: :hash
        )
      end.not_to raise_error
    end
  end
end

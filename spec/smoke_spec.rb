# frozen_string_literal: true

require 'spec_helper'

describe RailsPGExtras do
  RailsPGExtras::QUERIES.each do |query_name|
    it "#{query_name} query can be executed" do
      expect do
        RailsPGExtras.run_query(
          query_name: query_name,
          in_format: :hash
        )
      end.not_to raise_error
    end
  end

  it "runs the custom methods" do
    expect do
      RailsPGExtras.diagnose(in_format: :hash)
    end.not_to raise_error

    expect do
      RailsPGExtras.index_info(in_format: :hash)
    end.not_to raise_error

    expect do
      RailsPGExtras.table_info(in_format: :hash)
    end.not_to raise_error
  end
end

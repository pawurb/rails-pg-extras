require 'spec_helper'

describe RailsPGExtras do
  RailsPGExtras::QUERIES.each do |query_name|
    it "#{query_name} description can be read" do
      expect do
        RailsPGExtras.description_for(
          query_name: query_name
        )
      end.not_to raise_error
    end
  end
end

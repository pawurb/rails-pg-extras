# frozen_string_literal: true

require 'spec_helper'
require 'rails-pg-extras'

describe RailsPgExtras do
  RailsPgExtras::QUERIES.each do |query_name|
    it "#{query_name} query can be executed" do
      expect do
        RailsPgExtras.run_query(
          query_name: query_name,
          in_format: :hash
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

  context 'with multiple connections' do
    let(:connection_1) do
      ActiveRecord::Base.establish_connection(
        ENV.fetch("DATABASE_URL")
      )
      ActiveRecord::Base.connection
    end

    let(:connection_2) do
      ActiveRecord::Base.establish_connection(
        ENV.fetch("DATABASE_URL")
      )
      ActiveRecord::Base.connection
    end

    before do
      RailsPgExtras.connections = [
        connection_1,
        connection_2
      ]
      connection_1.reconnect!
    end

    RailsPgExtras::QUERIES.each do |query_name|
      it "#{query_name} query can be executed for the first database" do
        expect do
          RailsPgExtras.run_query(
            query_name: query_name,
            in_format: :hash,
            db_name: connection_1.current_database
          )
        end.not_to raise_error
      end
    end
  
    it "runs the custom methods for the first database" do
      expect do
        RailsPgExtras.diagnose(in_format: :hash, db_name: connection_1.current_database)
      end.not_to raise_error
  
      expect do
        RailsPgExtras.index_info(in_format: :hash, db_name: connection_1.current_database)
      end.not_to raise_error
  
      expect do
        RailsPgExtras.table_info(in_format: :hash, db_name: connection_1.current_database)
      end.not_to raise_error
    end
  end

  context 'with one overridden connection' do
    let(:connection_1) do
      ActiveRecord::Base.establish_connection(
        ENV.fetch("DATABASE_URL")
      )
      ActiveRecord::Base.connection
    end

    before do
      RailsPgExtras.connections = [
        connection_1
      ]
      connection_1.reconnect!
    end

    RailsPgExtras::QUERIES.each do |query_name|
      it "#{query_name} query can be executed for the only database" do
        expect do
          RailsPgExtras.run_query(
            query_name: query_name,
            in_format: :hash,
            db_name: connection_1.current_database
          )
        end.not_to raise_error
      end
    end
  
    it "runs the custom methods for the only database" do
      expect do
        RailsPgExtras.diagnose(in_format: :hash, db_name: connection_1.current_database)
      end.not_to raise_error
  
      expect do
        RailsPgExtras.index_info(in_format: :hash, db_name: connection_1.current_database)
      end.not_to raise_error
  
      expect do
        RailsPgExtras.table_info(in_format: :hash, db_name: connection_1.current_database)
      end.not_to raise_error
    end
  end
end

# frozen_string_literal: true

require 'rails-pg-extras/locks'
require 'rails-pg-extras/index_size'

module RailsPGExtras
  def self.connection
    ActiveRecord::Base.connection
  end

  private_class_method :connection
end

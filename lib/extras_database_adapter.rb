class ExtrasDatabaseAdapter < ActiveRecord::Base
  self.abstract_class = true

  def self.database_list
    base_configurations = ActiveRecord::Base.configurations.configurations.filter{|t| t.env_name == ActiveRecord::ConnectionHandling::DEFAULT_ENV.call.to_s}
    base_configurations.map{|config| config.name}
  end

  def self.connect_databases
    database_config = {}
    # create a connects_to database hash with the roles being the name of the database config
    # e.g. what will be called: connects_to database {primary: primary, primary_replica: primary_replica}
    self.database_list.each do |database_name|
      database_config[database_name.to_sym] = database_name.to_sym
    end

    ExtrasDatabaseAdapter.connects_to database: database_config
    self
  end
end

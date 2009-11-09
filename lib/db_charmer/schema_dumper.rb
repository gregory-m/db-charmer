module ActiveRecord
  class SchemaDumper
    include DbCharmer::MultiDbMigrations
    
    def dump_with_sub_tables(stream)
      header(stream)
      tables(stream)
      sub_tables(stream)
      trailer(stream)
      stream
    end
    alias_method_chain :dump, :sub_tables
    
    def sub_tables(stream)
      configurations = ActiveRecord::Base.configurations[RAILS_ENV]
      configurations.each do |name, config|
        next unless config.is_a?(Hash)
        next unless config["dump"]
        stream.puts "  on_db :#{name} do"
        on_db name.to_sym do
          @connection = ActiveRecord::Base.connection
          tmp_stream = StringIO.new
          tables(tmp_stream)
          tmp_stream.rewind
          fixed_str = ""
          
          #fix indintation
          tmp_stream.each do |line|
            next if line == "\n"
            fixed_str << "  " + line
          end
          stream.puts fixed_str
        end
        stream.puts "  end"
      end
    end
  end
end

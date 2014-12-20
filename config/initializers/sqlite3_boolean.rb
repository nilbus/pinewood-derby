require 'active_record/connection_adapters/sqlite3_adapter'

class ActiveRecord::ConnectionAdapters::SQLite3Adapter
  QUOTED_TRUE, QUOTED_FALSE = "'t'".freeze, "'f'".freeze

  def quoted_true; QUOTED_TRUE end
  def quoted_false; QUOTED_FALSE end
end

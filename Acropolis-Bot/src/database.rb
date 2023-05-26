require "sqlite3"

class DatabaseNotFoundError < StandardError
  def initialize
    super("Database not found")
  end
end

class Database
  attr_reader :database

  def initialize
    unless File.exist?("./database/database.db")
      Thread.new {
        puts "Создание файла базы данных..."
        FileUtils.mkdir("./database") unless Dir.exist?("./database")
        FileUtils.touch("./database/database.db")
        @database = SQLite3::Database.open("database/database.db")
        @database.execute("CREATE TABLE IF NOT EXISTS warnings(userid TEXT, reason TEXT, by TEXT, timestamp INTEGER)")
        sleep(3) # Let it think a bit
        puts "База данных создана"
      }
    else
      Thread.new {
        @database = SQLite3::Database.open("database/database.db")
        sleep(3) # Let it think a bit
        puts "База данных загружена"
      }
    end
  end

  def refresh_data
    # Delete warnings that are older than 30 days
    @database.execute("DELETE FROM warnings WHERE timestamp < ?", (Time.now.to_i - 2592000))
  end

  def add_warning(userid, reason, by, timestamp)
    raise DatabaseNotFoundError if @database.nil?
    refresh_data

    warncount = @database.execute("SELECT COUNT (*) FROM warnings WHERE userid = ?", userid)
    @database.execute("INSERT INTO warnings(userid, reason, by, timestamp) VALUES (?, ?, ?, ?)", userid, reason, by, timestamp) if warncount[0][0] < 5

    return warncount[0][0] # Warn count before the last warning, add one to get the actual count
  end

  def remove_warning(userid)
    raise DatabaseNotFoundError if @database.nil?
    refresh_data

    warncount = @database.execute("SELECT COUNT (*) FROM warnings WHERE userid = ?", userid)
    return 0 if warncount[0][0].zero? # No warnings found

    timestamps = @database.execute("SELECT timestamp FROM warnings WHERE userid = ?", userid) # Removes the last warning
    @database.execute("DELETE FROM warnings WHERE timestamp = ?", timestamps[-1])
    return warncount[0][0] # Warn count before removal of the warning
  end

  def get_warnings(userid)
    raise DatabaseNotFoundError if @database.nil?
    refresh_data

    warncount = @database.execute("SELECT COUNT (*) FROM warnings WHERE userid = ?", userid)
    warnings = @database.execute("SELECT reason, by, timestamp FROM warnings WHERE userid = ?", userid)

    return [warncount[0][0], warnings] # Returns warncount and all warnings of a user
  end
end

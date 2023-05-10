require "sqlite3"

module Database
  @@database = nil

  def self.open_db
    @@database = SQLite3::Database.open("database/database.db")
  end

  def self.check_db
    unless File.exist?("database/database.db")
      FileUtils.touch("database.db")
      FileUtils.mv("database.db", "database/database.db")
      db = SQLite3::Database.open("database/database.db")
      db.execute("CREATE TABLE IF NOT EXISTS warnings(userid TEXT, reason TEXT, by TEXT, timestamp INTEGER)")
      sleep(3) # Let it think a bit
      db.close if db
      self.open_db
    else
      self.open_db
    end
  end

  def self.refresh_data
    time = Time.now.to_i - 2592000 # Delete warnings that are older than 30 days
    @@database.execute("DELETE FROM warnings WHERE timestamp < ?", time)
  end

  def self.add_warning(userid, reason, by, timestamp)
    (puts "База данных не найдена"; return) if @@database.nil?
    self.refresh_data

    warncount = @@database.execute("SELECT COUNT (*) FROM warnings WHERE userid = ?", userid)
    @@database.execute("INSERT INTO warnings(userid, reason, by, timestamp) VALUES (?, ?, ?, ?)", userid, reason, by, timestamp) if warncount[0][0] < 5

    return warncount[0][0] # Warn count before the last warning, add one to get the actual count
  end

  def self.remove_warning(userid)
    (puts "База данных не найдена"; return) if @@database.nil?
    self.refresh_data

    warncount = @@database.execute("SELECT COUNT (*) FROM warnings WHERE userid = ?", userid)
    return 0 if warncount[0][0].zero? # No warnings found

    timestamps = @@database.execute("SELECT timestamp FROM warnings WHERE userid = ?", userid) # Removes the last warning
    @@database.execute("DELETE FROM warnings WHERE timestamp = ?", timestamps[-1])
    return warncount[0][0] # Warn count before removal of the warning
  end

  def self.get_warnings(userid)
    (puts "База данных не найдена"; return) if @@database.nil?
    self.refresh_data

    warncount = @@database.execute("SELECT COUNT (*) FROM warnings WHERE userid = ?", userid)
    warnings = @@database.execute("SELECT reason, by, timestamp FROM warnings WHERE userid = ?", userid)

    return [warncount[0][0], warnings] # Returns warncount and all warnings of a user
  end
end

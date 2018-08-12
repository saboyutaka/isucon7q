require 'mysql2'
require 'mysql2-cs-bind'

def db
  return @db_client if defined?(@db_client)

  @db_client = Mysql2::Client.new(
    host: ENV.fetch('ISUBATA_DB_HOST') { 'localhost' },
    port: ENV.fetch('ISUBATA_DB_PORT') { '3306' },
    username: ENV.fetch('ISUBATA_DB_USER') { 'root' },
    password: ENV.fetch('ISUBATA_DB_PASSWORD') { '' },
    database: 'isubata',
    encoding: 'utf8mb4'
  )
  @db_client.query('SET SESSION sql_mode=\'TRADITIONAL,NO_AUTO_VALUE_ON_ZERO,ONLY_FULL_GROUP_BY\'')
  @db_client
end

ids = db.query('SELECT id FROM image').to_a.map {|i| i['id'] }

ids.each do |id|
  image = db.xquery('SELECT * FROM image WHERE id = ? LIMIT 1', id).to_a.first
  path = "../public/icons/" + image['name']
  File.write(path, image['data'])
  print '.'
end

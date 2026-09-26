path = File.dirname(__FILE__)

class Obj::FantasyBaseball
end

load "#{path}/app/migrations.rb"
load "#{path}/app/objects.rb"
load "#{path}/app/commands.rb"

Obj::Database.migrate(Obj::FantasyBaseball::Setup.migrations, @db)
Obj::FantasyBaseball::Setup.register_classes(@db, Obj::FantasyBaseball::Setup.classes)

path = File.dirname(__FILE__)

load "#{path}/migrations/add_base_classes.rb"

class Obj::FantasyBaseball
  module Setup
    def self.migrations
      [
        Obj::FantasyBaseball::AddBaseClasses
      ]
    end

    def self.register_classes(db, classes)
      classes.each { |klass| db.register_class(klass) }
    end
  end
end


require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def initialize(option={})
    option.each{|k,v|
      self.send("#{k}=", v)
    }
  end

  def self.table_name #=> "students"
    self.to_s.downcase.pluralize #pluralize
  end

  def self.column_names #=> ["id", "name", "grade"]
    DB[:conn].execute("PRAGMA table_info(#{table_name})").map{|r| r["name"]} #PRAGMA table_info(#{table_name})
  end

  def table_name_for_insert #=> "students"
    self.class.table_name
  end

  def col_names_for_insert #=> "name, grade"
    self.class.column_names.delete_if{|c| c=="id"}.join(", ")
  end

  def values_for_insert #=> "'sam', '11'"
    values = []
    self.class.column_names.delete_if{|c| c=="id"}.each{|c|
      values << "'#{self.send(c)}'"
    }
    values.join(", ")
  end

  def save

    DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})") #need () for values
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{table_name} WHERE name ='#{name}'") # only need one = and '' around #{name}
  end

  def self.find_by(hash)
    # binding.pry
    DB[:conn].execute("SELECT * FROM #{table_name} WHERE #{hash.keys[0].to_s} ='#{hash.values[0].to_s}'")
  end

end

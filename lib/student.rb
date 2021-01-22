require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade, :id

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(id=nil, name, grade)
    @id = id 
    @name = name 
    @grade = grade 
  end 

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT, 
        grade TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end 

  def self.drop_table 
    sql = <<-SQL
      DROP TABLE IF EXISTS students
    SQL
    DB[:conn].execute(sql)
  end 

  # #save
  # saves an instance of the Student class to the database 
  # and then sets the given students `id` attribute

  def save 
    if self.id #   updates a record if called on an object that is already persisted
      self.update
    else 
      sql = <<-SQL
       INSERT INTO students (name, grade)
       VALUES (?, ?)
      SQL

     DB[:conn].execute(sql, self.name, self.grade)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end 
  end 

  # #update
  # updates the record associated with a given instance

  def update 
    sql = <<-SQL 
     UPDATE students 
     SET name = ?, grade = ?, id = ?
     SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end 


  # .create
  # creates a student with two attributes, name and grade, 
  # and saves it into the students table. 

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save 
    student 
  end 

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    self.new(id, name, grade)
  end 
  

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students 
      WHERE name = ?
      LIMIT 1
    SQL
    DB[:conn].execute(sql, name).map do |row| 
      self.new_from_db(row)
    end.first
  end
end

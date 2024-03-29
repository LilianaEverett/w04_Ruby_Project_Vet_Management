require_relative( '../db/sql_runner' )
require_relative('./patient')

class Vet

  attr_reader :id
  attr_accessor :first_name, :last_name

  def initialize( options )
    @id = options['id'].to_i if options['id']
    @first_name = options['first_name']
    @last_name = options['last_name']
  end

  def save()
    sql = "INSERT INTO vets
    (
      first_name,
      last_name
    )
    VALUES
    (
      $1, $2
    )
    RETURNING id"
    values = [@first_name, @last_name]
    results = SqlRunner.run(sql, values)
    @id = results.first()['id'].to_i
  end

  def update()
    sql = "UPDATE vets
    SET
    (
      first_name,
      last_name
    ) =
    (
      $1, $2
    )
    WHERE id = $3"
    values = [@first_name, @last_name, @id]
    SqlRunner.run(sql, values)
  end

  def self.all()
    sql = "SELECT * FROM vets"
    results = SqlRunner.run( sql )
    return results.map { |vet| Vet.new( vet ) }
  end

  def self.delete_all()
    sql = "DELETE FROM vets"
    SqlRunner.run( sql )
  end

  def delete
    sql = "DELETE FROM vets
    WHERE id = $1"
    values = [id]
    SqlRunner.run( sql, values )
  end

  def self.find_by_id( id )
    sql = "SELECT * FROM vets
    WHERE id = $1"
    values = [id]
    results = SqlRunner.run( sql, values )
    return self.new( results.first )
  end

  def format_name
    return "#{@first_name.capitalize} #{@last_name.capitalize}"
  end

  def patients
    sql = "SELECT * FROM patients WHERE vet_id = $1"
    values = [@id]
    patients_data = SqlRunner.run(sql, values)
    patients = Patient.map_items(patients_data)
    return patients
  end

end

require 'pg'

class Database
	def initialize(logger)
		@db = if Sinatra::Base.production?
						 PG.connect(ENV['DATABASE_URL'])
          else
            PG.connect(dbname: "smd")
          end
    @logger = logger
  end

  def disconnect
    @db.close
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def get_all_schools
  	sql = "SELECT * FROM school ORDER BY name"

  	result = query(sql)

  	result.map do |tuple|
  		{id: tuple["id"], name: tuple["name"]}
  	end
  end

  def add_school(school_name)
    sql = "INSERT INTO school(name) VALUES ($1)"

    query(sql, school_name)
  end

  def get_one_school(id)
    sql = "SELECT * FROM school WHERE id = $1"

    result = query(sql, id)

    result.map do |tuple|
      {id: tuple["id"], name: tuple["name"]}
    end.first
  end

  def get_pieces(school_id)
    sql = "SELECT * FROM pieces WHERE school_id = $1 ORDER BY title"

    result = query(sql, school_id)

    result.map do |tuple|
      {id: tuple["id"], title: tuple["title"], composer: tuple["composer"]}
    end
  end

  def add_piece(title, composer, school_id)
    sql = "INSERT INTO pieces(title, composer, school_id) VALUES ($1, $2, $3)"

    query(sql, title, composer, school_id)
  end
end
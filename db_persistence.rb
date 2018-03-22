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

end
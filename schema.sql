CREATE TABLE school (
	id serial PRIMARY KEY,
	name text NOT NULL
);

CREATE TABLE pieces (
	id serial PRIMARY KEY,
	title text NOT NULL,
	composer text NOT NULL,
	school_id integer NOT NULL REFERENCES school (id)
);


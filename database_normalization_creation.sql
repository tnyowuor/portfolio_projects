/*GOAL: To create a relational database from spotify_annual dataset in order to clean, normalize and prepare the data for analyzing */

/*creating tables, defining the attributes and data types as well as defining the primary and foreign keys */

USE spotify_annual;
DROP TABLE IF EXISTS time_table;
DROP TABLE IF EXISTS track_table;
DROP TABLE IF EXISTS artist_table;
CREATE TABLE artist_table (
		artist_id		INT NOT NULL AUTO_INCREMENT,
        artist_name		VARCHAR(50) NOT NULL,
        CONSTRAINT		artistPK
			PRIMARY KEY	(artist_id) 
        );
CREATE TABLE track_table (
        track_id  		INT NOT NULL AUTO_INCREMENT,
        track_name 		VARCHAR(250) NOT NULL,
        minutes_played 	INT NOT NULL,
        artist_id		INT NOT NULL,
        CONSTRAINT track_tablePK
			PRIMARY KEY (track_id),
        CONSTRAINT track_tableFK
			FOREIGN KEY (artist_id)
			REFERENCES	artist_table	(artist_id)
		);
CREATE TABLE time_table (
		track_id		INT NOT NULL,
        track_name		VARCHAR(250) NOT NULL,
        date_listened	DATETIME,
		CONSTRAINT		time_tableFK
			FOREIGN KEY	(track_id)
            REFERENCES	track_table		(track_id)
		);

/* Inserting data into the tables by pulling the data from the original streaminghistory0 table */
ALTER TABLE artist_table
AUTO_INCREMENT = 605;
INSERT INTO artist_table (artist_name)
	SELECT DISTINCT(artistName)
	FROM streaminghistory0
;
ALTER TABLE track_table
AUTO_INCREMENT = 73592,
ADD CONSTRAINT		trackFK
	FOREIGN KEY			(artist_id)
    REFERENCES			artist_table		(artist_id)
    ;
INSERT INTO track_table (track_name, minutes_played, artist_id)
SELECT DISTINCT(s.trackName),
/* Original msPlayed column was in milliseconds, this following line converts that into minutes */
                SUM(s.msPlayed / (1000 * 60)) % 60, 
                a.artist_id
	FROM streaminghistory0 s
		JOIN artist_table a
				ON s.artistName = a.artist_name
	GROUP BY s.trackName;
    

ALTER TABLE time_table
ADD CONSTRAINT		time_tblFK
    FOREIGN KEY			(track_id)
    REFERENCES			track_table			(track_id)
    ;
    
INSERT INTO time_table (track_id, track_name, date_listened)
SELECT tb.track_id,
		s.trackName,
        s.endTime
	FROM track_table tb
		JOIN streaminghistory0 s
			ON s.trackName = tb.track_name
            ;

/* Relational Database complete with no duplicate keys or identifiers, ready to be analyzed for insights */
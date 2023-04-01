SET SERVEROUTPUT ON SIZE 1000000

CREATE OR REPLACE PROCEDURE get_time (movie_title IN VARCHAR2, hour OUT NUMBER, minute OUT NUMBER)
AS
    time NUMBER;
    intermission NUMBER;
begin
  SELECT MOV_TIME INTO time FROM MOVIE WHERE MOV_TITLE = movie_title;
  intermission := TRUNC (time/ (70+15));
  time:= time+(intermission*15);
  hour := TRUNC(time/60);
  minute:= time-(hour*60);
    DBMS_OUTPUT.PUT_LINE('Movie Title: '|| movie_title || ' and RUNNING TIME: ' || hour || ' hours ' || minute || ' minutes');
end;
/


DECLARE 
hour NUMBER;
minute NUMBER;

begin
  get_time('Beyond the Sea',hour,minute);
end;
/







CREATE OR REPLACE PROCEDURE get_movies(rating IN NUMBER)
AS
    CURSOR top_rated_cursor IS 
        SELECT MOV_TITLE, AVG(REV_STARS) AS STARS
        FROM MOVIE, RATING
        WHERE MOVIE.MOV_ID=RATING.MOV_ID
        GROUP BY MOV_TITLE
        ORDER BY STARS DESC;
    
    mov_title top_rated_cursor%ROWTYPE;
    cnt NUMBER;

begin
  cnt:=0;

  OPEN top_rated_cursor;

  loop
    FETCH top_rated_cursor INTO mov_title;
    EXIT WHEN top_rated_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(mov_title.mov_title);
    cnt := cnt+1;
    EXIT WHEN cnt = rating;
  end loop;

    CLOSE top_rated_cursor;

    IF cnt<rating THEN
        DBMS_OUTPUT.PUT_LINE('Error: N is greater than number of movies');
    END IF;
end;
/

begin
  get_movies(4);
end;
/









CREATE OR REPLACE FUNCTION get_yearly_earning(mov_id NUMBER, current_date DATE, release_date DATE)
RETURN NUMBER
AS
  rev_stars NUMBER;
  total_earning NUMBER;
BEGIN
  SELECT AVG(rev_stars) INTO rev_stars
  FROM REVIEW
  WHERE MOV_ID = mov_id;
  
  IF rev_stars >= 6 THEN
    total_earning := (current_date - release_date) * 10;
  ELSE
    total_earning := 0;
  END IF;
  
  RETURN total_earning / (current_date - release_date);
END;
/

begin
DBMS_OUTPUT.PUT_LINE(get_yearly_earning(902,1962-02-19,1962-12-11));
end;
/











CREATE OR REPLACE FUNCTION get_genre_status(g_id IN NUMBER) RETURN VARCHAR2
AS 

    status VARCHAR2(20);
    review_cnt NUMBER;
    avg_rating NUMBER;

begin
  SELECT GEN_TITLE into status FROM GENRES WHERE gen_id=g_id;
  if status IS NOT NULL THEN 
    status:= 'Exists';
  else
    status:= 'Not Exists';
  end if;

  SELECT COUNT(*) AS review_cnt, AVG(REV_STARS) AS avg_stars
  INTO review_cnt, avg_rating
  FROM MOVIE
  JOIN MTYPE on movie.MOV_ID=mtype.MOV_ID
  JOIN RATING on movie.mov_id = rating.mov_id
  where mtype.gen_id=g_id;

  RETURN status || ' | ' || review_cnt || ' | ' || avg_rating;
end;
/

begin
  DBMS_OUTPUT.PUT_LINE(get_genre_status(1));
end;
/












CREATE OR REPLACE FUNCTION get_count_genre_in_range(start_date DATE, end_date DATE) 
RETURN VARCHAR2
AS
  most_frequent_genre VARCHAR2(20);
  movie_count INT;
BEGIN
  SELECT GEN_TITLE, COUNT(*) INTO most_frequent_genre, movie_count
  FROM MOVIE,MTYPE,GENRES
  WHERE MOVIE.MOV_ID=MTYPE.MOV_ID AND MTYPE.GEN_ID=GENRES.GEN_ID AND
  MOV_RELEASEDATE BETWEEN start_date AND end_date
  GROUP BY GEN_TITLE
  ORDER BY COUNT(*) DESC
  FETCH FIRST ROW ONLY;
  
  RETURN most_frequent_genre || ' (' || movie_count || ')';
END;
/

begin
  DBMS_OUTPUT.PUT_LINE(get_count_genre_in_range(1962-02-19,1962-12-11));
end;
/
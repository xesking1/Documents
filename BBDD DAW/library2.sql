use library;

-- JOINs I - INNER vs LEFT, cardinalidades y "huérfanos"

-- Show all the books with their author's information
select * from BOOK;
select * from BOOK inner join AUTHOR on(BOOK.author_code=AUTHOR.author_code);
-- join entre las dos tablas seguido de un on(relacion de columnas). inner join solo coge las filas con valor no nulo en la columna comun
-- si las columnas se llaman igual, se puede usar using()
select * from BOOK inner join AUTHOR using(author_code);
-- usando left join coge todas las filas de lo que haya a la izquierda, no solo las que tienen valor no nulo en la columna en comun
select * from BOOK left join AUTHOR using(author_code);
-- o right join
select * from AUTHOR right join BOOK using(author_code);


-- (Q113) Books without author (IS NULL)
select * from BOOK left join AUTHOR using(author_code) where author_code is null;

-- Author without a book
-- con TABLA.* muestro solo las columnas de esa tabla. 
select AUTHOR.* from AUTHOR left join BOOK using(author_code) where BOOK.AUTHOR_CODE is null;
-- (Q114) Books and their authors' including the books without an author.
select title, name, surnames from BOOK left join AUTHOR using(author_code);

-- Books and their authors' including the books without an author. Show title, 
-- name and surnames only of the spanish authors
-- esto esta mal. se pierde la funcionalidad del left/right join
select title, name, surnames from BOOK left join AUTHOR using(author_code) where nationality like 'ES';
-- debe hacerse con on() y añadir la condicion dentro
select title, name, surnames from BOOK left join AUTHOR on(AUTHOR.author_code=BOOK.author_code and nationality like 'ES');

-- (Q115) Books titles and their authors' complete names including the books without an author.
select title, concat(name, ' ', surnames) as author from BOOK left join AUTHOR on (BOOK.author_code=AUTHOR.author_code);
-- (Q116) Authors without a book.
select concat_ws(' ', name, surnames) author from AUTHOR left join BOOK on(AUTHOR.author_code=BOOK.author_code) where book_code is null;
-- (Q117) Members that never borrowed a book. 
SELECT 
    MEMBER.*, BORROW_DATE
FROM
    library.MEMBER
        LEFT JOIN
    BORROW ON (MEMBER.MEMBER_CODE = BORROW.MEMBER_CODE) where BORROW.member_code is null;
-- (Q118) Genres without books and books without genre.

-- (Q119) Publishers without books published. 
select * from PUBLISHER;
select * from BOOK;
select PUBLISHER.* from PUBLISHER left join BOOK on(PUBLISHER.publisher_code=BOOK.publisher_code) where book_code is null;

-- (Q120) Books with no copies in the library. 
select * from BOOK;
select * from COPY;
select BOOK.* from BOOK left join COPY on(BOOK.BOOK_CODE=COPY.BOOK_CODE) where COPY_CODE is null;

-- I. All data of genres without a book
-- Como genre y book no están unidas, usamos la tabla intermedia genrebook para hacerlo. Lo hacemos con dos left join seguidos
SELECT 
    *
FROM
    GENRE
        LEFT JOIN
    GENREBOOK ON (GENRE.GENRE_CODE = GENREBOOK.GENRE_CODE)
        LEFT JOIN
    BOOK ON (GENREBOOK.BOOK_CODE = BOOK.BOOK_CODE)
WHERE
    BOOK.BOOK_CODE IS NULL;
    
-- II. All data of books without a genre
SELECT 
    *
FROM
    GENRE
        RIGHT JOIN
    GENREBOOK ON (GENRE.GENRE_CODE = GENREBOOK.GENRE_CODE)
        RIGHT JOIN
    BOOK ON (GENREBOOK.BOOK_CODE = BOOK.BOOK_CODE)
WHERE
    GENRE.GENRE_CODE IS NULL;
    
-- III. 
(SELECT 
    GENRE.name genre, BOOK.title
FROM
    GENRE
        LEFT JOIN
    GENREBOOK ON (GENRE.GENRE_CODE = GENREBOOK.GENRE_CODE)
        LEFT JOIN
    BOOK ON (GENREBOOK.BOOK_CODE = BOOK.BOOK_CODE)
WHERE
    BOOK.BOOK_CODE IS NULL) UNION 
(SELECT 
    GENRE.name genre, BOOK.title
FROM
    GENRE
        RIGHT JOIN
    GENREBOOK ON (GENRE.GENRE_CODE = GENREBOOK.GENRE_CODE)
        RIGHT JOIN
    BOOK ON (GENREBOOK.BOOK_CODE = BOOK.BOOK_CODE)
WHERE
    GENRE.GENRE_CODE IS NULL);
    
-- (Q121) Name of the authors distinct to NOAH GORDON who have written any history book. (MULTIPLES INNER JOIN)
select * from GENRE;
SELECT 
    CONCAT(AUTHOR.name, ' ', AUTHOR.surnames) author, GENRE.name
FROM
    AUTHOR
        INNER JOIN
    BOOK ON (AUTHOR.author_code = BOOK.author_code)
        INNER JOIN
    GENREBOOK ON (BOOK.BOOK_CODE = GENREBOOK.BOOK_CODE)
        INNER JOIN
    GENRE ON (GENREBOOK.GENRE_CODE = GENRE.GENRE_CODE)
WHERE
    UPPER(AUTHOR.name) NOT LIKE 'NOAH'
        OR UPPER(AUTHOR.surnames) NOT LIKE 'GORDON'
        AND UPPER(GENRE.name) LIKE 'HISTORIA';
        

-- Group by
select count(*), CITY from MEMBER group by CITY;
-- (Q100) Authors code and the number of books written by them
select author_code, count(*) numberBooks from BOOK group by author_code;

-- (Q101) Books code and the amount of copies of each book.
-- es innecesario el uso de la tabla book, esto era lo que me salió hacer la primera vez
select COPY.book_code, count(*) copyCount from BOOK left join COPY on(BOOK.book_code=COPY.book_code) group by COPY.book_code;
-- esta es la buena
select book_code, count(copy_code) copyCount from COPY group by book_code;

-- (Q102) Genres code and the number of books of each genre.
-- otra vez innecesario
select genre_code, count(GENREBOOK.book_code) bookCount from GENREBOOK join BOOK on(GENREBOOK.BOOK_CODE=BOOK.BOOK_CODE) group by genre_code;
-- la buena
select genre_code, count(book_code) bookCount from GENREBOOK group by GENRE_CODE;

-- (Q103) Author's name and the number of books written by them. 
select concat_ws(" ", name, surnames) fullName, count(book_code) bookCount from BOOK join AUTHOR using(author_code) group by author_code;

-- (Q104) Books title and the amount of copies of each book. 
select title, count(book_code) copyAmount from BOOK join COPY using(book_code) group by book_code;

-- (Q105) Genres name and the number of books of that genre. 
select name, count(book_code) bookCount from GENRE join GENREBOOK using(genre_code) group by genre_code;

-- (Q106) Members name and the number of borrows for each member. 
select concat_ws(" ", name, surnames) fullName, count(copy_code) borrowCount from MEMBER join BORROW using(member_code) group by member_code;

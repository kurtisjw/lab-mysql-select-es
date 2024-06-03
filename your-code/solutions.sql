use publications;

/* Desafío 1 - ¿Quién ha publicado qué y dónde?

En este desafío escribirás una consulta SELECT de MySQL que una varias tablas para descubrir qué títulos ha publicado cada autor en qué editoriales. Tu salida debe tener al menos las siguientes columnas:

AUTHOR ID - el ID del autor
LAST NAME - apellido del autor
FIRST NAME - nombre del autor
TITLE - nombre del título publicado
PUBLISHER - nombre de la editorial donde se publicó el título
*/

select
    ta.au_id as 'author id',
    au.au_lname as 'last name',
    au.au_fname as 'first name',
    t.title as 'title',
    p.pub_name as 'publisher'
from	
    authors as au
left join 
    titleauthor as ta on au.au_id = ta.au_id
left join 
    titles as t on ta.title_id = t.title_id
left join 
    publishers as p on t.pub_id = p.pub_id
where
    ta.au_id is not null
order by ta.au_id asc;

-- Si tu consulta es correcta, el total de filas en tu salida debería ser el mismo que el total de registros en la Tabla titleauthor.

with authorinfo as (
    select
        ta.au_id as 'author id',
        au.au_lname as 'last name',
        au.au_fname as 'first name',
        t.title as 'title',
        p.pub_name as 'publisher'
    from
        authors as au
    left join 
        titleauthor as ta on au.au_id = ta.au_id
    left join 
        titles as t on ta.title_id = t.title_id
    left join 
        publishers as p on t.pub_id = p.pub_id
    where
        ta.au_id is not null
    order by 
        ta.au_id asc
)
select 
    count(*) as total_author_id_count,
    (select count(*) from titleauthor) as total_titleauthor_rows,
    case 
        when (select count(*) from titleauthor) = (select count(*) from authorinfo) then 'same' 
        else 'different' 
    end as comparison_result
from authorinfo;



/*
desafío 2 - ¿quién ha publicado cuántos y dónde?

partiendo de tu solución en el desafío 1, consulta cuántos títulos ha publicado cada autor en cada editorial.
*/

    
select
	ta.au_id as 'author id',
	au.au_lname as 'last name',
	au.au_fname as 'first name',
    p.pub_name as 'publisher',
    count(t.title_id) as 'title count'
from	
    authors as au
left join 
    titleauthor as ta on au.au_id = ta.au_id
left join 
    titles as t on ta.title_id = t.title_id
left join 
    publishers as p on t.pub_id = p.pub_id
where
    ta.au_id is not null
group by
    ta.au_id, au.au_lname, au.au_fname, p.pub_name
order by
    ta.au_id asc, p.pub_name asc;
    
-- Para verificar si tu salida es correcta, suma la columna TITLE COUNT. El número sumado debería ser el mismo que el total de registros en la Tabla titleauthor.


with authortitlecounts as (
    select
        ta.au_id as 'author id',
        au.au_lname as 'last name',
        au.au_fname as 'first name',
        p.pub_name as 'publisher',
        count(t.title_id) as title_count
    from
        authors as au
    left join 
        titleauthor as ta on au.au_id = ta.au_id
    left join 
        titles as t on ta.title_id = t.title_id
    left join 
        publishers as p on t.pub_id = p.pub_id
    where
        ta.au_id is not null
    group by
        ta.au_id, au.au_lname, au.au_fname, p.pub_name
    order by
        ta.au_id asc, p.pub_name asc
)
select 
	sum(title_count) as total_title_count,
    (select count(*) from titleauthor) as total_titleauthor_rows,
    case 
        when (select count(*) from titleauthor) = (select sum(title_count)  from authortitlecounts) then 'same' 
        else 'different' 
    end as comparison_result
from authortitlecounts;


/*
desafío 3 - autores más vendidos

¿quiénes son los 3 principales autores que han vendido el mayor número de títulos? escribe una consulta para averiguarlo.

requisitos:

    tu salida debería tener las siguientes columnas:
        author id - el id del autor
        last name - apellido del autor
        first name - nombre del autor
        total - número total de títulos vendidos de este autor
    tu salida debería estar ordenada basándose en total de mayor a menor.
    solo muestra los 3 mejores autores en ventas.
*/

select 
    ta.au_id as 'author id',
    au.au_lname as 'last name',
    au.au_fname as 'first name',
    sum(s.qty) as 'total'
from 
    authors as au
join 
    titleauthor as ta on au.au_id = ta.au_id
join 
    titles as t on ta.title_id = t.title_id
left join 
    sales as s on t.title_id = s.title_id
where
    s.qty is not null
group by 
    ta.au_id
order by 
    sum(s.qty) desc
limit 3;


/*
desafío 4 - ranking de autores más vendidos

ahora modifica tu solución en el desafío 3 para que la salida muestre a todos los 23 autores en lugar de solo los 3 principales. ten en cuenta que los autores que han vendido 0 títulos también deben aparecer en tu salida (idealmente muestra 0 en lugar de null como total). también ordena tus resultados basándose en total de mayor a menor.
*/

select 
    au.au_id as 'author id',
    au.au_lname as 'last name',
    au.au_fname as 'first name',
    coalesce(sum(s.qty), 0) as 'total'
from 
    authors as au
left join 
    titleauthor as ta on au.au_id = ta.au_id
left join 
    titles as t on ta.title_id = t.title_id
left join 
    sales as s on t.title_id = s.title_id
group by 
    au.au_id
order by 
    coalesce(sum(s.qty), 0) desc;
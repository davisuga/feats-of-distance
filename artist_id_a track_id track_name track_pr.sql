
create table relevant_artists as
select * from artists where artists.followers > 1000

create table bla as
select *
from relevant_artists a
join r_track_artist l on
a.id = l.artist_id
join tracks t on
t.id = l.track_id


select a.artist_id, b.artist_id from bla a
join bla b on
a.track_id = b.track_id and a.artist_id != b.artist_id
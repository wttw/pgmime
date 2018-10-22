-- -*-sql-*-
begin;

create or replace function decode_rfc_2047(input text) returns text as $f$
declare
    part text[];
    output text := '';
    len int := 0;
    charset text;
    encoding text;
    encoded_payload text;
    payload bytea;
begin
    for part in select * from regexp_matches(input, $$(.*?)=\?([!#$%&'*+0-9a-z^_`{|}~-]+)\?([qb])\?([^ \t?]{1,70})\?=$$, 'gi') loop
        charset := upper(part[2]);
        encoding := upper(part[3]);
        encoded_payload := part[4];
        
        len := len + length(part[1]) + length(charset) + length(encoded_payload) + 7;
        if output = '' or part[1] ~ '\S' then
            output = output || part[1];
        end if;
        if encoding = 'B' then
           payload = coalesce(decode(encoded_payload, 'base64'), ('=?' || part[2] || '?' || part[3] || '?' || part[4] || '?=')::bytea);
        else
           if encoded_payload ~* '=[0-9a-f](?![0-9a-f])' then
              -- bad Q encoding
               payload = ('=?' || part[2] || '?' || part[3] || '?' || part[4] || '?=')::bytea;
           else
           WITH STR AS (
               SELECT
               -- array with all non hex-encoded parts
               regexp_split_to_array (replace(encoded_payload, '_', ' ') ,'(=[0-9a-f]{2})+', 'i') plain,
      
               -- array with all hex-encoded parts
               array(select (regexp_matches (encoded_payload,'((?:=[0-9a-f]{2})+)', 'gi'))[1]) || array[''] encoded
           )
           SELECT  string_agg(plain[i]::bytea || coalesce( decode(replace(encoded[i], '=',''), 'hex'),''),'')
           FROM STR, 
             (SELECT  generate_series(1, array_upper(encoded,1)+2) i FROM STR) blah
           INTO payload;
           end if;
        end if;
        output := output || convert_from(payload, charset);
    end loop;
    return output || substr(input, len+1);
end;
$f$ language plpgsql immutable strict;

commit;

-- -*-sql-*-

\unset ECHO
\set QUIET 1

\pset format unaligned
\pset tuples_only true
\pset pager off

\set ON_ERROR_ROLLBACK 1
\set ON_ERROR_STOP true

begin;
\i pgtap.sql

select plan(25);

-- Test vectors stolen from https://golang.org/src/mime/encodedword_test.go

create or replace function _is(text, text) returns text as $$select is($1, $2, 'decode: ' || $2)$$ language sql;

select _is(decode_rfc_2047(E'=?UTF-8?Q?=C2=A1Hola,_se=C3=B1or!?='), '¡Hola, señor!');
select _is(decode_rfc_2047(E'=?UTF-8?Q?Fran=C3=A7ois-J=C3=A9r=C3=B4me?='), 'François-Jérôme');
select _is(decode_rfc_2047(E'=?UTF-8?q?ascii?='), 'ascii');
select _is(decode_rfc_2047(E'=?utf-8?B?QW5kcsOp?='), 'André');
select _is(decode_rfc_2047(E'=?_ISO-8859-1?Q?Rapha=EBl_Dupont?='), 'Raphaël Dupont');
select _is(decode_rfc_2047(E'Jean'), 'Jean');
select _is(decode_rfc_2047(E'=?utf-8?b?IkFudG9uaW8gSm9zw6kiIDxqb3NlQGV4YW1wbGUub3JnPg==?='), '"Antonio José" <jose@example.org>');
select _is(decode_rfc_2047(E'=?UTF-8?A?Test?='), '=?UTF-8?A?Test?=');
select _is(decode_rfc_2047(E'=?UTF-8?Q?A=B?='), '=?UTF-8?Q?A=B?=');
select _is(decode_rfc_2047(E'=?UTF-8?Q?=A?='), '=?UTF-8?Q?=A?=');
select _is(decode_rfc_2047(E'=?UTF-8?A?A?='), '=?UTF-8?A?A?=');
-- Incomplete words
select _is(decode_rfc_2047(E'=?'), '=?');
select _is(decode_rfc_2047(E'=?UTF-8?'), '=?UTF-8?');
select _is(decode_rfc_2047(E'=?UTF-8?='), '=?UTF-8?=');
select _is(decode_rfc_2047(E'=?UTF-8?Q'), '=?UTF-8?Q');
select _is(decode_rfc_2047(E'=?UTF-8?Q?'), '=?UTF-8?Q?');
select _is(decode_rfc_2047(E'=?UTF-8?Q?='), '=?UTF-8?Q?=');
select _is(decode_rfc_2047(E'=?UTF-8?Q?A'), '=?UTF-8?Q?A');
select _is(decode_rfc_2047(E'=?UTF-8?Q?A?'), '=?UTF-8?Q?A?');
-- Tests from RFC 2047
select _is(decode_rfc_2047(E'=?_ISO-8859-1?Q?a?='), 'a');
select _is(decode_rfc_2047(E'=?_ISO-8859-1?Q?a?= b'), 'a b');
select _is(decode_rfc_2047(E'=?_ISO-8859-1?Q?a?= =?_ISO-8859-1?Q?b?='), 'ab');
select _is(decode_rfc_2047(E'=?_ISO-8859-1?Q?a?=  =?_ISO-8859-1?Q?b?='), 'ab');
select _is(decode_rfc_2047(E'=?_ISO-8859-1?Q?a?= \r\n\t =?_ISO-8859-1?Q?b?='), 'ab');
select _is(decode_rfc_2047(E'=?_ISO-8859-1?Q?a_b?='), 'a b');

drop function if exists _is(text, text);

select * from finish();
rollback;

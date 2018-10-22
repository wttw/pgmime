# pgmime
RFC 2047 MIME header decoding for postgresql

This currently contains a single function that will decode
[RFC 2047](https://tools.wordtothewise.com/rfc/2047) encoded
email headers from using either Q or B encoding.

### Usage

    steve=# select decode_rfc_2047(E'=?_ISO-8859-1?Q?Rapha=EBl_Dupont?=');
     decode_rfc_2047
    -----------------
     Raphaël Dupont
    (1 row)
    
### Installation

`psql -f pgmime.sql`

### Testing

Once the function is installed you can run the [pgtap](https://pgtap.org)
based tests with `psql -Xf test.sql`

### Future

It'd be nice to have some variants of encode\_rfc\_2047() too.

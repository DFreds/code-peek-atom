-- Note: This package won't actually compile but showcases how you can test code-peak in atom and is syntatically correct
create or replace package body oracle_plsql_test_call
as
  procedure my_test
  as
    -- These won't work as they're in the spec file and since it has a different file extension won't be found
    -- See https://github.com/DFreds/code-peek-atom/issues/31
    l_some_var my_type;
    l_my_number number := oracle_plsql_test.gc_vara;

    -- These will work but won't compile as it references "private" types and constants but will work with peek
    l_ref_int_type oracle_plsql_test.my_internal_type;
    l_ref_int_var number := oracle_plsql_test.gc_internal_a;
  begin

    oracle_plsql_test.create_session();

    oracle_plsql_test.is_developer();

  end my_test;


end oracle_plsql_test_call;
/

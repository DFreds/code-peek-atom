create or replace package oracle_plsql_test
as
  type my_type is record (
    f_name varchar2(255),
    sal number
  );

  type my_type_tab is table of my_type;

  gc_vara constant number := 1;
  gc_varb constant number := 2;

  function is_developer
    return boolean;

  function is_developer_yn
    return varchar2;

  function is_session_valid(
    p_session_id in apex_workspace_sessions.apex_session_id%type)
    return boolean;

  function is_session_valid_yn(
    p_session_id in apex_workspace_sessions.apex_session_id%type)
    return varchar2;

  procedure create_session(
    p_app_id in apex_applications.application_id%type,
    p_user_name in apex_workspace_sessions.user_name%type,
    p_page_id in apex_application_pages.page_id%type default null,
    p_session_id in apex_workspace_sessions.apex_session_id%type default null);

  procedure join_session(
    p_session_id in apex_workspace_sessions.apex_session_id%type,
    p_app_id in apex_applications.application_id%type default null);

  procedure trim_page_items(
    p_page_id in apex_application_pages.page_id%type default apex_application.g_flow_step_id);

  function is_page_item_rendered(
    p_item_name in apex_application_page_items.item_name%type)
    return boolean;

end oracle_plsql_test;
/

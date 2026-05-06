prompt --application/pages/page_00002
begin
--   Manifest
--     PAGE: 00002
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>32147286929531095
,p_default_application_id=>103
,p_default_id_offset=>0
,p_default_owner=>'MAXPRINT_DEMO'
);
wwv_flow_imp_page.create_page(
 p_id=>2
,p_name=>'for cicd 3'
,p_alias=>'FOR-CICD-3'
,p_step_title=>'for cicd 3'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
);
wwv_flow_imp.component_end;
end;
/

prompt --application/pages/page_00005
begin
--   Manifest
--     PAGE: 00005
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
 p_id=>5
,p_name=>'Product Info'
,p_alias=>'PRODUCT-INFO'
,p_step_title=>'Product Info'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'11'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(55007772404392312)
,p_button_sequence=>20
,p_button_name=>'Product_Info'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Product Info'
,p_warn_on_unsaved_changes=>null
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(55007622713392311)
,p_name=>'P5_CATEGORY'
,p_item_sequence=>10
,p_prompt=>'Category'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT DISTINCT category AS display_value,',
'                category AS return_value',
'FROM demo_product_info',
'ORDER BY 1;'))
,p_lov_display_null=>'YES'
,p_cHeight=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(55007891936392313)
,p_name=>'MaxPrint Info'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(55007772404392312)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(55007935923392314)
,p_event_id=>wwv_flow_imp.id(55007891936392313)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'PLUGIN_COM.PLUGIN.MAXPRINT_V2'
,p_attribute_01=>'R'
,p_attribute_02=>'SQL'
,p_attribute_03=>'S'
,p_attribute_05=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT product_id,',
'       product_name,',
'       product_description,',
'       CATEGORY,',
'       list_price,',
'       apex_web_service.blob2clobbase64 (PRODUCT_IMAGE) PRODUCT_IMAGE',
'FROM demo_product_info',
'WHERE category = :P5_CATEGORY;'))
,p_attribute_07=>'T'
,p_attribute_09=>'febeb84c-8e09-42f5-a545-5209a60bd994'
,p_attribute_10=>'P5_CATEGORY'
,p_attribute_11=>'pdf'
,p_attribute_13=>'P'
,p_wait_for_result=>'Y'
);
wwv_flow_imp.component_end;
end;
/

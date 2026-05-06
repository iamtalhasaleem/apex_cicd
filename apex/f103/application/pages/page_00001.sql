prompt --application/pages/page_00001
begin
--   Manifest
--     PAGE: 00001
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
 p_id=>1
,p_name=>'Home'
,p_alias=>'HOME'
,p_step_title=>'demo'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'13'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(32970216815992086)
,p_plug_name=>'demo'
,p_region_template_options=>'#DEFAULT#'
,p_escape_on_http_output=>'Y'
,p_plug_template=>2674017834225413037
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_plug_query_num_rows=>15
,p_region_image=>'#APP_FILES#icons/app-icon-512.png'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(12165049420764349)
,p_button_sequence=>10
,p_button_name=>'Invoice'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Invoice'
,p_warn_on_unsaved_changes=>null
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(36209179383877813)
,p_button_sequence=>20
,p_button_name=>'Testing'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Testing'
,p_warn_on_unsaved_changes=>null
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(33010665173006002)
,p_name=>'P1_DEPARTMENT'
,p_item_sequence=>30
,p_prompt=>'Department'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT DEPARTMENT_NAME, DEPARTMENT_ID',
'FROM DEPARTMENTS D',
'WHERE EXISTS (',
'    SELECT 1 ',
'    FROM employees e ',
'    WHERE e.department_id = d.department_id',
');'))
,p_lov_display_null=>'YES'
,p_cHeight=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(12165175654764350)
,p_name=>'New'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(12165049420764349)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(33010574485006001)
,p_event_id=>wwv_flow_imp.id(12165175654764350)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'PLUGIN_COM.PLUGIN.MAXPRINT_V2'
,p_attribute_01=>'C'
,p_attribute_02=>'SQL'
,p_attribute_03=>'J'
,p_attribute_05=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT json_object(',
'       ''customer_id''   VALUE c.customer_id,',
'       ''customer_name'' VALUE c.cust_first_name || '' '' || c.cust_last_name,',
'       ''email''         VALUE c.cust_email,',
'       ''phone''         VALUE c.phone_number1,',
'       ''address''       VALUE c.cust_street_address1 || '', '' || c.cust_city,',
'       ''order_id''      VALUE o.order_id,',
'       ''order_date''    VALUE o.order_timestamp,',
'    --    ''order_date''    VALUE CAST(o.order_timestamp AS VARCHAR2(30)),',
'    --    ''order_date_to_char''    VALUE TO_CHAR(o.order_timestamp, ''YYYY-MM-DD''),',
'       ''order_total''   VALUE o.order_total,',
'       ''items'' VALUE (',
'         SELECT json_arrayagg(',
'                  json_object(',
'                    ''product_id''    VALUE p.product_id,',
'                    ''product_name''  VALUE p.product_name,',
'                    ''unit_price''    VALUE oi.unit_price,',
'                    ''quantity''      VALUE oi.quantity,',
'                    ''product_total'' VALUE (oi.unit_price * oi.quantity)',
'                  )',
'                  ORDER BY p.product_id',
'                  RETURNING CLOB',
'                )',
'         FROM demo_order_items oi',
'         JOIN demo_product_info p ON oi.product_id = p.product_id',
'         WHERE oi.order_id = o.order_id',
'       )',
'       RETURNING CLOB',
'     ) AS order_details_json',
'FROM demo_customers c',
'JOIN demo_orders o ON c.customer_id = o.customer_id',
'WHERE c.customer_id = 1 ',
'AND o.order_id = 2;'))
,p_attribute_10=>'P1_DEPARTMENT'
,p_wait_for_result=>'Y'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(36209299519877814)
,p_name=>'New_1'
,p_event_sequence=>20
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(36209179383877813)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36209361283877815)
,p_event_id=>wwv_flow_imp.id(36209299519877814)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'PLUGIN_COM.PLUGIN.MAXPRINT_V2'
,p_attribute_01=>'C'
,p_attribute_02=>'SQL'
,p_attribute_03=>'S'
,p_attribute_05=>'select EMPLOYEE_ID, SALARY from employees;'
,p_wait_for_result=>'Y'
);
wwv_flow_imp.component_end;
end;
/

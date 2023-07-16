XSS Attack Test
====

#. Login to *APP* node and deploy ``vs-2.yaml``

    .. code-block::

      $ kubectl apply -f vs-2.yaml

#. Open another terminal and do ``ssh app`` then monitor the syslog

    .. code-block::

      $ ssh app

      $ podname=`kubectl get pods | awk '/^syslog/{print $1}'`; kubectl exec -it $podname -- tail -f /var/log/messages

#. Back to Firefox browser, open http://app.arcadia.com/ then click *Login* button

    .. image:: img/test-a1.png

   You can see the request logging start to scroll

#.  Try to attack by type ``<script>`` in *Username* input then click *Log me in* button

    .. image:: img/test-a2.png

#. *Rejected Request* page displayed in the browser and see the log match the support ID

    .. image:: img/test-a3.png

    If we see at the log

    .. image:: img/test-a4.png

    This is the log text example

    .. code-block::

      Jul 16 12:15:03 nginx-ingress-p9jx6 ASM:attack_type="Abuse of Functionality,Cross Site Scripting (XSS),Other Application Activity",blocking_exception_reason="N/A",date_time="2023-07-16 12:15:03",dest_port="80",ip_client="10.1.1.6",is_truncated="false",method="POST",policy_name="dataguard-alarm",protocol="HTTP",request_status="blocked",response_code="0",severity="Critical",sig_cves="N/A,N/A",sig_ids="200001475,200000098",sig_names="XSS script tag end (Parameter) (2),XSS script tag (Parameter)",sig_set_names="{Cross Site Scripting Signatures;High Accuracy Signatures},{Cross Site Scripting Signatures;High Accuracy Signatures}",src_port="60226",sub_violations="N/A",support_id="6698972626801609997",threat_campaign_names="N/A",unit_hostname="nginx-ingress-p9jx6",uri="/trading/auth.php",violation_rating="5",vs_name="53-app.arcadia.com:8-/",x_forwarded_for_header_value="N/A",outcome="REJECTED",outcome_reason="SECURITY_WAF_VIOLATION",violations="Illegal meta character in value,Attack signature detected,Violation Rating Threat detected",json_log="{""id"":""6698972626801609997"",""violations"":[{""enforcementState"":{""isBlocked"":true,""isAlarmed"":true,""isInStaging"":false,""isLearned"":false,""isLikelyFalsePositive"":false},""violation"":{""name"":""VIOL_ATTACK_SIGNATURE""},""signature"":{""name"":""XSS script tag end (Parameter) (2)"",""signatureId"":200001475},""snippet"":{""buffer"":""dXNlcm5hbWU9PHNjcmlwdD4="",""offset"":10,""length"":7}},{""enforcementState"":{""isBlocked"":true,""isAlarmed"":true,""isInStaging"":false,""isLearned"":false,""isLikelyFalsePositive"":false},""violation"":{""name"":""VIOL_ATTACK_SIGNATURE""},""signature"":{""name"":""XSS script tag (Parameter)"",""signatureId"":200000098},""snippet"":{""buffer"":""dXNlcm5hbWU9PHNjcmlwdD4="",""offset"":9,""length"":7}},{""enforcementState"":{""isBlocked"":false},""violation"":{""name"":""VIOL_PARAMETER_VALUE_METACHAR""}},{""enforcementState"":{""isBlocked"":true},""violation"":{""name"":""VIOL_RATING_THREAT""}}],""enforcementAction"":""block"",""method"":""POST"",""clientPort"":60226,""clientIp"":""10.1.1.6"",""host"":""nginx-ingress-p9jx6"",""responseCode"":0,""serverIp"":""10.42.0.47"",""serverPort"":80,""requestStatus"":""blocked"",""url"":""L3RyYWRpbmcvYXV0aC5waHA="",""virtualServerName"":""53-app.arcadia.com:8-/"",""enforcementState"":{""isBlocked"":true,""isAlarmed"":true,""rating"":5,""attackType"":[{""name"":""Abuse of Functionality""},{""name"":""Cross Site Scripting (XSS)""},{""name"":""Other Application Activity""}]},""requestDatetime"":""2023-07-16T12:15:03Z"",""rawRequest"":{""actualSize"":547,""httpRequest"":""UE9TVCAvdHJhZGluZy9hdXRoLnBocCBIVFRQLzEuMQ0KSG9zdDogYXBwLmFyY2FkaWEuY29tDQpVc2VyLUFnZW50OiBNb3ppbGxhLzUuMCAoWDExOyBVYnVudHU7IExpbnV4IHg4Nl82NDsgcnY6MTA5LjApIEdlY2tvLzIwMTAwMTAxIEZpcmVmb3gvMTE1LjANCkFjY2VwdDogdGV4dC9odG1sLGFwcGxpY2F0aW9uL3hodG1sK3htbCxhcHBsaWNhdGlvbi94bWw7cT0wLjksaW1hZ2UvYXZpZixpbWFnZS93ZWJwLCovKjtxPTAuOA0KQWNjZXB0LUxhbmd1YWdlOiBlbi1VUyxlbjtxPTAuNQ0KQWNjZXB0LUVuY29kaW5nOiBnemlwLCBkZWZsYXRlDQpDb250ZW50LVR5cGU6IGFwcGxpY2F0aW9uL3gtd3d3LWZvcm0tdXJsZW5jb2RlZA0KQ29udGVudC1MZW5ndGg6IDMxDQpPcmlnaW46IGh0dHA6Ly9hcHAuYXJjYWRpYS5jb20NCkNvbm5lY3Rpb246IGtlZXAtYWxpdmUNClJlZmVyZXI6IGh0dHA6Ly9hcHAuYXJjYWRpYS5jb20vdHJhZGluZy9sb2dpbi5waHANClVwZ3JhZGUtSW5zZWN1cmUtUmVxdWVzdHM6IDENCg0KdXNlcm5hbWU9JTNDc2NyaXB0JTNFJnBhc3N3b3JkPQ=="",""isTruncated"":false},""requestPolicy"":{""fullPath"":""dataguard-alarm""}}",violation_details="<?xml version='1.0' encoding='UTF-8'?><BAD_MSG><violation_masks><block>410000000200c00-3a03030c30000072-8000000000000000-0</block><alarm>2477f0ffcbbd0fea-befbf35cb000007e-8000000000000000-0</alarm><learn>0-0-0-0</learn><staging>0-0-0-0</staging></violation_masks><request-violations><violation><viol_index>42</viol_index><viol_name>VIOL_ATTACK_SIGNATURE</viol_name><context>parameter</context><parameter_data><value_error/><enforcement_level>global</enforcement_level><name>dXNlcm5hbWU=</name><auto_detected_type>alpha-numeric</auto_detected_type><value>PHNjcmlwdD4=</value><location>form-data</location><is_base64_decoded>false</is_base64_decoded><param_name_pattern>*</param_name_pattern><staging>0</staging></parameter_data><staging>0</staging><sig_data><sig_id>200001475</sig_id><blocking_mask>3</blocking_mask><kw_data><buffer>dXNlcm5hbWU9PHNjcmlwdD4=</buffer><offset>10</offset><length>7</length></kw_data></sig_data><sig_data><sig_id>200000098</sig_id><blocking_mask>3</blocking_mask><kw_data><buffer>dXNlcm5hbWU9PHNjcmlwdD4=</buffer><offset>9</offset><length>7</length></kw_data></sig_data></violation><violation><viol_index>24</viol_index><viol_name>VIOL_PARAMETER_VALUE_METACHAR</viol_name><parameter_data><value_error/><enforcement_level>global</enforcement_level><name>dXNlcm5hbWU=</name><auto_detected_type>alpha-numeric</auto_detected_type><value>PHNjcmlwdD4=</value><location>form-data</location><is_base64_decoded>false</is_base64_decoded></parameter_data><wildcard_entity>*</wildcard_entity><staging>0</staging><language_type>4</language_type><metachar_index>60</metachar_index><metachar_index>62</metachar_index></violation><violation><viol_index>93</viol_index><viol_name>VIOL_RATING_THREAT</viol_name></violation></request-violations></BAD_MSG>",bot_signature_name="N/A",bot_category="N/A",bot_anomalies="N/A",enforced_bot_anomalies="N/A",client_class="Browser",client_application="FireFox",client_application_version="115",request="POST /trading/auth.php HTTP/1.1\r\nHost: app.arcadia.com\r\nUser-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8\r\nAccept-Language: en-US,en;q=0.5\r\nAccept-Encoding: gzip, deflate\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: 31\r\nOrigin: http://app.arcadia.com\r\nConnection: keep-alive\r\nReferer: http://app.arcadia.com/trading/login.php\r\nUpgrade-Insecure-Requests: 1\r\n\r\nusername=%3Cscript%3E&password=",transport_protocol="HTTP/1.1"
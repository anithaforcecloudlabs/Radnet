@isTest
public class DH_PatientInfoWrapperTest {
    
    @isTest
    static void testParseMethod() {
        // Sample JSON string to test the parse method
        String sampleJson = '{' +
            '"patient": {' +
                '"object_state": "modified",' +
                '"health_cloud_id": "p12345",' +
                '"system_id": "CA",' +
                '"data": {' +
                    '"patient_Key": 1,' +
                    '"first_name": "John",' +
                    '"last_name": "Doe",' +
                    '"middle_name": "M",' +
                    '"patient_id": "P001",' +
                    '"issuer_of_patient_id": "Issuer",' +
                    '"birth_date": "1990-01-01",' +
                    '"gender_code": "M",' +
                    '"primary_address_line1": "123 Main St",' +
                    '"primary_address_line2": "Apt 4B",' +
                    '"primary_address_city": "Anytown",' +
                    '"primary_address_state": "CA",' +
                    '"primary_address_zipcode": "12345",' +
                    '"primary_language_code": "EN",' +
                    '"master_patient_key": "MP001",' +
                    '"patientEmailAddresses": [],' +
                    '"patientPhones": [],' +
                    '"patientExtraInfo": [],' +
                    '"patientAlerts": [],' +
                    '"patient_class_code": "A",' +
                    '"order_key": "O001",' +
                    '"um_required_flag": "N",' +
                    '"um_complete_flag": "N",' +
                    '"requested_date": null,' +
                    '"entered_date": null,' +
                    '"order_category_code": "CAT001",' +
                    '"status_code": "NEW",' +
                    '"scheduling_next_fup_type_code": "TYPE001",' +
                    '"scheduling_next_fup_date": null,' +
                    '"confirmed_flag": "Y",' +
                    '"filler_site_code": "SITE001",' +
                    '"filler_practice_code": "PRACT001",' +
                    '"primary_carrier_code": "PC001",' +
                    '"secondary_carrier_code": "SC001",' +
                    '"orderAlerts": [],' +
                    '"orderExtraInfo": [],' +
                    '"orderItems": [],' +
                    '"referring_practices": [],' +
                    '"requested_by": null,' +
                    '"requested_by_address": null,' +
                    '"study_key": "62858",' +
                    '"accession_number": "38670DA2",' +
                    '"scheduled_start_date": "2024-02-07T10:45:00Z",' +
                    '"scheduled_modality_code": "CT1FH",' +
                    '"studyItems": [],' +
                    '"studyExtraInfo": [],' +
                    '"created_date": null,' +
                    '"cancelled_reason_code": null,' +
                    '"cancelled_date": null,' +
                    '"tech_only_flag": "N",' +
                    '"reading_stat_flag": "N",' +
                    '"exam_stat_flag": "N",' +
                    '"site_code": "SITE001",' +
                    '"practice_code": "PRACT001"' +
                '}' +
            '},' +
            '"order": {' +
                '"object_state": "modified",' +
                '"health_cloud_id": "o12345",' +
                '"rescheduled_flag": "N",' +
                '"created_with_study_flag": "Y",' +
                '"icode_eligible": true,' +
                '"new_or_rescheduled": "new",' +
                '"shortened_icode_url": "http://example.com",' +
                '"data": null' +
            '},' +
            '"study": {' +
                '"object_state": "modified",' +
                '"health_cloud_id": "s67890",' +
                '"data": null' +
            '}' +
        '}';

        // Parse the JSON string
        DH_PatientInfoWrapper parsedWrapper = DH_PatientInfoWrapper.parse(sampleJson);

        // Assertions to verify the parsing logic
        System.assertNotEquals(null, parsedWrapper, 'Parsed wrapper should not be null');
        System.assertEquals('modified', parsedWrapper.patient.object_state, 'Patient object_state should match');
        System.assertEquals('p12345', parsedWrapper.patient.health_cloud_id, 'Patient health_cloud_id should match');
        System.assertEquals('John', parsedWrapper.patient.data.first_name, 'Patient first_name should match');
        System.assertEquals('Doe', parsedWrapper.patient.data.last_name, 'Patient last_name should match');
        System.assertEquals('62858', parsedWrapper.patient.data.study_key, 'Study key should match');
        System.assertEquals('CA', parsedWrapper.patient.system_id, 'Patient system_id should match');
        System.assertEquals('O001', parsedWrapper.patient.data.order_key, 'Order key should match');
        System.assertEquals('CT1FH', parsedWrapper.patient.data.scheduled_modality_code, 'Scheduled modality code should match');
    }
}
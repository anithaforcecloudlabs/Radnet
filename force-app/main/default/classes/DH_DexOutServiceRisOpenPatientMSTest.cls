@IsTest
public class DH_DexOutServiceRisOpenPatientMSTest {

    // --- MOCK CLASS FOR SUCCESS SCENARIO ---
    private class FakeHttpResponseGenerator implements HttpCalloutMock {
      public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);

            // 1. Define the patient data string (the value that will be inside the "data" key)
            String innerPatientData = 
                '[' +
                    '{"patient_key": "PAT123", "first_name": "Test", "last_name": "Patient", "patientPhones": [{"phone_number": "5551234567", "display_order": 1}]}' +
                ']';

            // 2. Construct the root JSON structure to satisfy resultList[1] access.
            // Structure: [null, [ { "data": "..." } ] ]
            String responseBody = 
                '[' + 
                    'null,' + // Element at index 0 (Placeholder)
                    '[' + // Element at index 1 (The list the parser targets)
                        '{' +
                            // JSON.serialize() escapes the inner string for the 'data' value.
                            '"data": ' + JSON.serialize(innerPatientData) + 
                        '}' + 
                    ']' + 
                ']';
            
            res.setBody(responseBody);
            
            return res;
        }
    }

    // --- TEST SETUP METHOD ---
    @TestSetup
    static void setupData() {
        // Placeholder statement to ensure a valid method body.
        System.debug('Test setup complete.'); 
    }

    // --- TEST METHOD: SUCCESS ---
    @IsTest
    static void testInvokeRisOpenPatientApi_success() {
        Test.setMock(HttpCalloutMock.class, new FakeHttpResponseGenerator());

        // Prepare input wrapper
        DH_DexOutServiceRisOpenPatientRequest req = new DH_DexOutServiceRisOpenPatientRequest();
        req.recordId = '001xx000003DGXAAA4';
        req.patientKey = 'PAT123';
        req.systemId = 'RIS_123';

        Test.startTest();
        String accId = DH_DexOutServiceRisOpenPatientMS.invokeRisOpenPatientApi(req);
        Test.stopTest();

        System.assertNotEquals(null, accId, 'Account Id should be returned');
    }

    // --- TEST METHOD: NEGATIVE/INVALID INPUT ---
    @IsTest 
    static void testInvokeRisOpenPatientApiNegative() {
        // Create an instance of the request wrapper with null or invalid data
        DH_DexOutServiceRisOpenPatientRequest invalidRequest = new DH_DexOutServiceRisOpenPatientRequest();
        invalidRequest.systemId = null;   // null systemId to simulate missing required param
        
        // No callout mock is needed here since invalid input should be handled before the callout
        
        Test.startTest();
        // Call the method under test
        String result = DH_DexOutServiceRisOpenPatientMS.invokeRisOpenPatientApi(invalidRequest);
        Test.stopTest();

        // Assert that result is null or empty for negative case
        System.assertEquals(null, result, 'Invoke method should return null for invalid input');

        // Optional: Assert that logging occurred for the missing info
        // Integer logCount = [SELECT count() FROM DH_PayloadData__c WHERE DH_Error__c LIKE '%systemId%' LIMIT 1];
        // System.assert(logCount > 0, 'An error log should be created for invalid input.');
    }
}
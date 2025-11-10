@isTest(seealldata=true)
public class DH_DexOutServiceRisOpenParsnerMSTest {

    @isTest
    static void testConstructResponse() {
         Case c = new Case(Subject = 'Test Case');
        insert c;
        // Query an existing channel + end user from your org setup
        MessagingChannel channel = [SELECT Id FROM MessagingChannel LIMIT 1];
        MessagingEndUser endUser = [SELECT Id FROM MessagingEndUser LIMIT 1];
 Conversation conv = [SELECT Id FROM Conversation LIMIT 1];
        // Create a MessagingSession
        MessagingSession session = new MessagingSession(
            Status = 'Active',
            MessagingChannelId = channel.Id,
            MessagingEndUserId = endUser.Id,
            ConversationId = conv.Id,
            CaseId=c.id,
            OwnerId=userinfo.getuserid()
        );
        insert session;
        // Prepare JSON string for response with expected structure
        List<Object> outerList = new List<Object>();
        outerList.add(null);
        
        // Create patientList with patientMap containing 'data' JSON string
        List<Object> patientList = new List<Object>();
        
        // Create example JSON for patient data list
        List<DH_DexOutServiceRisOpenPatientResponse.Data> patientDataList = new List<DH_DexOutServiceRisOpenPatientResponse.Data>();
        DH_DexOutServiceRisOpenPatientResponse.Data patientData = new DH_DexOutServiceRisOpenPatientResponse.Data();
        patientData.patient_key = 'PKEY123';
        patientData.first_name = 'John';
        patientData.last_name = 'Doe';
       String patientDataJson = JSON.serialize(new List<DH_DexOutServiceRisOpenPatientResponse.Data>{patientData});
    
    // 3. Create the Map containing the 'data' key. The value MUST be the raw string, 
    //    not serialized as an object, for the parser's logic to work.
    Map<String, Object> patientMap = new Map<String, Object>{'data' => patientDataJson};
        patientList.add(patientMap);
        outerList.add(patientList);
        
        String responseJson = JSON.serialize(outerList);
        
       DH_DexOutServiceRisOpenPatientRequest req = new DH_DexOutServiceRisOpenPatientRequest();
        req.recordId = '001xx000003DGXAAA4';
        req.patientKey = 'PAT123';
        req.systemId = 'RIS_123';
        
        Test.startTest();
       Id accountId = DH_DexOutServiceRisOpenPatientParserMS.constructResponse(responseJson, req);
        Test.stopTest();
        
      //System.assertNotEquals(null, accountId, 'Account Id should be returned');
    }
    
    @isTest
    static void testUpsertPatientAccountForMessaging_NegativeCases() {
        DH_DexOutServiceRisOpenPatientResponse.Data patientData = new DH_DexOutServiceRisOpenPatientResponse.Data();
        patientData.patient_key = null; // missing patient_key
        
        DH_DexOutServiceRisOpenPatientRequest req = new DH_DexOutServiceRisOpenPatientRequest();
        req.systemId = null; // missing systemId
        
        Test.startTest();
        Id result = DH_DexOutServiceRisOpenPatientParserMS.upsertPatientAccountForMessaging(patientData, req);
        Test.stopTest();
        
        System.assertEquals(null, result, 'Should return null for missing parameters');
    }
    
    @isTest
    static void testIsValidEmail() {
        System.assertEquals(false, DH_DexOutServiceRisOpenPatientParserMS.isValidEmail(null));
        System.assertEquals(false, DH_DexOutServiceRisOpenPatientParserMS.isValidEmail('invalidemail'));
        System.assertEquals(true, DH_DexOutServiceRisOpenPatientParserMS.isValidEmail('test@example.com'));
    }
    
    @isTest
    static void testCreateContactPhoneAndEmail() {
        // Setup valid patientId and systemId
        Id patientId = UserInfo.getUserId();
        String systemId = 'SYS';
        
        // Patient phones list
        List<DH_DexOutServiceRisOpenPatientResponse.PatientPhones> phoneList = new List<DH_DexOutServiceRisOpenPatientResponse.PatientPhones>();
        DH_DexOutServiceRisOpenPatientResponse.PatientPhones phone = new DH_DexOutServiceRisOpenPatientResponse.PatientPhones();
        phone.patient_phone_key = 234565432;
        phone.phone_number = '1234567890';
        phone.mobile_flag = 'Y';
        phone.primary_flag = 'Y';
        phone.display_order = 1;
        phoneList.add(phone);
        
        // Patient emails list
        List<DH_DexOutServiceRisOpenPatientResponse.PatientEmailAddresses> emailList = new List<DH_DexOutServiceRisOpenPatientResponse.PatientEmailAddresses>();
        DH_DexOutServiceRisOpenPatientResponse.PatientEmailAddresses email = new DH_DexOutServiceRisOpenPatientResponse.PatientEmailAddresses();
       // email.patient_email_key = 'EMKEY1';
        email.email_address = 'test@example.com';
        email.primary_flag = 'Y';
        email.display_order = 1;
        emailList.add(email);
        
        Test.startTest();
        DH_DexOutServiceRisOpenPatientParserMS.createContactPhone(phoneList, patientId, systemId);
        DH_DexOutServiceRisOpenPatientParserMS.createContactEmail(emailList, patientId, systemId);
        Test.stopTest();
    }
    
   
}
/*
* ***************************************************************************************************************************
* Apex Class Name - DH_VoiceCallTriggerHeplerTest
* Created Date - 24-July-2024
* @description : Test Class for DH_VoiceCallTriggerHandler and DH_VoiceCallTriggerHepler.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-526                   24-July-2024         Added makeData and createVoiceCallShareRecordTest methods.
* CC-691                   10-August-2024       Added publishEventOnDispositionChageTest1 method.
* CC-692                   02-September-2024    Added updateVoiceCallFunctionTest method.
* CC-603                   08-October-2024      Added runinvokeCloseTabEventTest, runudpateVoiceCallFieldsTest,runudpateVoiceCallFieldsTestElseCondition1,runudpateVoiceCallFieldsTestElseCondition2,runudpateVoiceCallFieldsTestElseCondition3runudpateVoiceCallFieldsTestElseCondition3 and runcreateVoiceCallShareRecordTest and did changes related to code optimization and code coverage 
* CC-1439                  30-October-2024		Added F9_Call_ANI__c field while creating Voice Call record.
* CC-1453				   29-November-2024		Updated runinvokeCloseTabEventTest method
* *****************************************************************************************************************************
*/
@istest
public class DH_VoiceCallTriggerHeplerTest {
    /**
    * @Jira CC-691,692
    * @description - Creates reusable test data that can be used across multiple test methods within the same class.
    * @param       - None
    **/
    @testSetup
    public static void makeData() {
        User radnetSchedulerWest = DH_TestDataFactory.createRadNetWestSchedulerUser();
        User radnetSystemAdmin = DH_TestDataFactory.createRadNetMarketingUser();
        radnetSystemAdmin.DH_User_Region__c = 'East';
        update radnetSystemAdmin;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User radnetSystemAdmin1 = new User(
            Alias = 'mtuser', 
            Email='systemadminWest@gmail.com', 
            LastName='admin west', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='systemadminWest1@gmail.com',
            IsActive = true,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            DH_User_Region__c = 'West'
            );
        insert radnetSystemAdmin1;
        User radnetManagerWest = DH_TestDataFactory.createRadNetWestManagerUser();
        User radnetSchedulerEast = DH_TestDataFactory.createRadNetEastSchedulerUser();
        User radnetManagerEast = DH_TestDataFactory.createRadNetEastManagerUser();
        DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerWest);
        DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerEast);
        DH_TestDataFactory.assignCCManagerPermissionSetGroup(radnetManagerWest);
        DH_TestDataFactory.assignCCManagerPermissionSetGroup(radnetManagerEast);
    }
    /**
    * @Jira CC-691
    * @description - tests the functionality of invokeCloseTabEventTest class.
    * @param       - None
    **/
    @isTest
    public static void invokeCloseTabEventTest() {  
        User radnetSchedulerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestscheduler@radnet.com' limit 01];
        User radnetSchedulerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastscheduler@radnet.com' limit 01];
        User radnetManagerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestmanager@radnet.com' limit 01];
        User radnetManagerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastmanager@radnet.com' limit 01];
        Map<Id, User> userEastMap = new Map<Id,User>();
        Map<Id, User> userWestMap = new Map<Id,User>();
        userWestMap.put(radnetSchedulerWest.Id,radnetSchedulerWest);
        userEastMap.put(radnetSchedulerEast.Id,radnetSchedulerEast);
        userWestMap.put(radnetManagerWest.Id,radnetManagerWest);
        userEastMap.put(radnetManagerEast.Id,radnetManagerEast);  
        Test.startTest();
        List<String> statusList1 = runinvokeCloseTabEventTest(userEastMap);
        System.assertEquals(statusList1[0],'Closed', 'Error occured while changing the case status to closed');
        System.assertEquals(statusList1[1],'Closed', 'Error occured while changing the case status to closed');
        List<String> statusList2 = runinvokeCloseTabEventTest(userWestMap);
        System.assertEquals(statusList2[0],'Closed', 'Error occured while changing the case status to closed');
        System.assertEquals(statusList2[1],'Closed', 'Error occured while changing the case status to closed');
        Test.stopTest();
    }
    /**
    * @Jira CC-691
    * @description - tests the functionality of invokeCloseTabEventTest class.
    * @param       - None
    **/
    public static List<string> runinvokeCloseTabEventTest(Map<Id, User> userMap) {  
        Account acc = new Account(FirstName='Prasanna',LastName='Anjankar',recordTypeId=DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID);
        insert acc;
        CallCenter callCenterId = [SELECT Id FROM CallCenter LIMIT 1];
        Case cs = new Case();
        VoiceCall vc0 = new VoiceCall(FromPhoneNumber='+1649693498',F9_Call_ANI__c = '+1649693498',callCenterId=callCenterId.Id, VendorType='ContactCenter',CallStartDateTime=datetime.now(), CallEndDateTime=datetime.now(), ToPhoneNumber='+1578782168', CallType='transfer',DH_TransferNotesSummary__c='note');
        insert vc0;
        VoiceCall vc1 = new VoiceCall(FromPhoneNumber='+1649693498',F9_Call_ANI__c = '+1649693498',callCenterId=callCenterId.Id, VendorType='ContactCenter',CallStartDateTime=datetime.now(), CallEndDateTime=datetime.now(), ToPhoneNumber='+1578782168', CallType='Inbound', NextCallId = vc0.Id,Five9BYOT__F9_AgentName__c = 'testagent@gmail.com');
        insert vc1;
        DH_GeneralUtility.createContactCenterCase(acc.id,vc1.id);
        Case c = [SELECT id,Subject,AccountId,DH_VoiceCall__c,Status from Case where DH_VoiceCall__c=:vc1.id  LIMIT 1];
        List<String> statusList = new List<String>();
        for(User u : userMap.values()){
            vc1.F9_Call_disposition_name__c='No Disposition';
            vc1.RelatedRecordId=acc.Id;
            vc1.F9_DH_SystemId__c='CA';
            update vc1;
            cs = [SELECT id,Subject,AccountId,DH_VoiceCall__c,Status from Case where id=:c.id];
            cs.OwnerId=u.Id;
            update cs;
            List<Case> caseList = new List<Case>();
            caseList.add(cs);
            DH_VoiceCallTriggerHepler.closeCase(caseList);
            System.runAs(u) {
                statusList.add(cs.Status);
            }
        }
        return statusList;
        }
    @isTest
    public static void udpateVoiceCallFieldsTest(){ 
        User radnetSchedulerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestscheduler@radnet.com' limit 01];
        User radnetSchedulerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastscheduler@radnet.com' limit 01];
        User radnetManagerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestmanager@radnet.com' limit 01];
        User radnetManagerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastmanager@radnet.com' limit 01];
        Map<Id, User> userEastMap = new Map<Id,User>();
        Map<Id, User> userWestMap = new Map<Id,User>();
        userWestMap.put(radnetSchedulerWest.Id,radnetSchedulerWest);
        userEastMap.put(radnetSchedulerEast.Id,radnetSchedulerEast);
        userWestMap.put(radnetManagerWest.Id,radnetManagerWest);
        userEastMap.put(radnetManagerEast.Id,radnetManagerEast); 
        Test.startTest();
        List<String> notesList1 = runudpateVoiceCallFieldsTest(userEastMap);
        System.assertEquals(notesList1[0],'note', 'Notes are not populated');
        System.assertEquals(notesList1[1],'note', 'Notes are not populated');
        List<String> notesList2 = runudpateVoiceCallFieldsTest(userWestMap);
        System.assertEquals(notesList2[0],'note', 'Notes are not populated');
        System.assertEquals(notesList2[1],'note', 'Notes are not populated');
        Test.stopTest();
    }
    public static List<String> runudpateVoiceCallFieldsTest(Map<Id, User> userMap){ 
        Account acc = new Account(FirstName='Prasanna',LastName='Anjankar',recordTypeId=DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID);
        insert acc;
        CallCenter callCenterId = [SELECT Id FROM CallCenter LIMIT 1];
        VoiceCall vc0 = new VoiceCall(FromPhoneNumber='+1649693498',F9_Call_ANI__c = '+1649693498',callCenterId=callCenterId.Id, VendorType='ContactCenter',CallStartDateTime=datetime.now(), CallEndDateTime=datetime.now(), ToPhoneNumber='+1578782168', CallType='transfer',DH_TransferNotesSummary__c='note');
        insert vc0;
        VoiceCall vc1 = new VoiceCall(FromPhoneNumber='+1649693498',F9_Call_ANI__c = '+1649693498',callCenterId=callCenterId.Id, VendorType='ContactCenter',CallStartDateTime=datetime.now(), CallEndDateTime=datetime.now(), ToPhoneNumber='+1578782168', CallType='transfer',DH_TransferNotesSummary__c='note',NextCallId=vc0.Id);
        insert vc1;
        VoiceCall vc = new VoiceCall(FromPhoneNumber='+1649693498',F9_Call_ANI__c = '+1649693498',callCenterId=callCenterId.Id, VendorType='ContactCenter',CallStartDateTime=datetime.now(), CallEndDateTime=datetime.now(), ToPhoneNumber='+1578782168', CallType='transfer',CallDisposition='In-progress',PreviousCallId=vc1.Id);
        insert vc;
        vc.RelatedRecordId=acc.personcontactId;
        vc.F9_DH_SystemId__c='CA';
        Update vc;
        DH_VoiceCallTriggerHepler.validatePreviousVerifiedCaller(vc1.Id);
       List<String> noteSummaryList = new List<String>();
        for(User u : userMap.values()){
            System.runAs(u) {
                VoiceCall vcNew = [Select Id,DH_TransferNotesSummary__c from VoiceCall where Id = :vc.Id];
                noteSummaryList.add(vcNew.DH_TransferNotesSummary__c);
             }
        }
        return noteSummaryList;
    }
    @isTest
    public static void udpateVoiceCallFieldsTestElseCondition1(){
        User radnetSchedulerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestscheduler@radnet.com' limit 01];
        User radnetSchedulerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastscheduler@radnet.com' limit 01];
        User radnetManagerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestmanager@radnet.com' limit 01];
        User radnetManagerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastmanager@radnet.com' limit 01];
        Map<Id, User> userEastMap = new Map<Id,User>();
        Map<Id, User> userWestMap = new Map<Id,User>();
        userWestMap.put(radnetSchedulerWest.Id,radnetSchedulerWest);
        userEastMap.put(radnetSchedulerEast.Id,radnetSchedulerEast);
        userWestMap.put(radnetManagerWest.Id,radnetManagerWest);
        userEastMap.put(radnetManagerEast.Id,radnetManagerEast);  
        Test.startTest();
        List<String> notesList1= runudpateVoiceCallFieldsTestElseCondition1(userEastMap);
        System.assertEquals(notesList1[0],'note1 | note', 'Notes are not populated');
        System.assertEquals(notesList1[1],'note1 | note', 'Notes are not populated');
        List<String> notesList2= runudpateVoiceCallFieldsTestElseCondition1(userWestMap);
        System.assertEquals(notesList2[0],'note1 | note', 'Notes are not populated');
        System.assertEquals(notesList2[1],'note1 | note', 'Notes are not populated');
        Test.stopTest();
    }
    public static List<String> runudpateVoiceCallFieldsTestElseCondition1(Map<Id, User> userMap){
        Account acc = new Account(FirstName='Prasanna',LastName='Anjankar',recordTypeId=DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID);
        insert acc;
        CallCenter callCenterId = [SELECT Id FROM CallCenter LIMIT 1];
        VoiceCall vc0 = new VoiceCall(FromPhoneNumber='+1649693498',F9_Call_ANI__c = '+1649693498',callCenterId=callCenterId.Id, VendorType='ContactCenter',CallStartDateTime=datetime.now(), CallEndDateTime=datetime.now(), ToPhoneNumber='+1578782168', CallType='transfer');
        insert vc0;
        VoiceCall vc1 = new VoiceCall(FromPhoneNumber='+1649693498',F9_Call_ANI__c = '+1649693498',callCenterId=callCenterId.Id, VendorType='ContactCenter',CallStartDateTime=datetime.now(), CallEndDateTime=datetime.now(), ToPhoneNumber='+1578782168', CallType='transfer',DH_TransferNotesSummary__c='note',DH_TransferNotes__c='note1',NextCallId=vc0.Id);
        insert vc1;
        VoiceCall vc = new VoiceCall(FromPhoneNumber='+1649693498',F9_Call_ANI__c = '+1649693498',callCenterId=callCenterId.Id, VendorType='ContactCenter',CallStartDateTime=datetime.now(), CallEndDateTime=datetime.now(), ToPhoneNumber='+1578782168', CallType='transfer',CallDisposition='In-progress',PreviousCallId=vc1.Id);
        insert vc;
        vc.RelatedRecordId=acc.personcontactId;
        vc.F9_DH_SystemId__c='CA';
        Update vc;
        List<String> notesList = new List<String>();
        for(User u : userMap.values()){
            System.runAs(u) {
                VoiceCall vcNew = [Select Id,DH_TransferNotesSummary__c from VoiceCall where Id = :vc.Id];
                notesList.add(vcNew.DH_TransferNotesSummary__c);
    }
        }
        return notesList;
    }
    @isTest
    public static void udpateVoiceCallFieldsTestElseCondition2(){
        User radnetSchedulerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestscheduler@radnet.com' limit 01];
        User radnetSchedulerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastscheduler@radnet.com' limit 01];
        User radnetManagerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestmanager@radnet.com' limit 01];
        User radnetManagerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastmanager@radnet.com' limit 01];
        Map<Id, User> userEastMap = new Map<Id,User>();
        Map<Id, User> userWestMap = new Map<Id,User>();
        userWestMap.put(radnetSchedulerWest.Id,radnetSchedulerWest);
        userEastMap.put(radnetSchedulerEast.Id,radnetSchedulerEast);
        userWestMap.put(radnetManagerWest.Id,radnetManagerWest);
        userEastMap.put(radnetManagerEast.Id,radnetManagerEast); 
        Test.startTest();
        List<String> notesList1= runudpateVoiceCallFieldsTestElseCondition2(userEastMap);
        System.assertEquals(notesList1[0],'note1', 'Notes are not populated');
        System.assertEquals(notesList1[1],'note1', 'Notes are not populated');
        List<String> notesList2= runudpateVoiceCallFieldsTestElseCondition2(userWestMap);
        System.assertEquals(notesList2[0],'note1', 'Notes are not populated');
        System.assertEquals(notesList2[1],'note1', 'Notes are not populated');
        Test.stopTest();
    }
    public static List<String> runudpateVoiceCallFieldsTestElseCondition2(Map<Id, User> userMap){
        Account acc = new Account(FirstName='Prasanna',LastName='Anjankar',recordTypeId=DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID);
        insert acc;
        CallCenter callCenterId = [SELECT Id FROM CallCenter LIMIT 1];
        VoiceCall vc0 = new VoiceCall(FromPhoneNumber='+1649693498',F9_Call_ANI__c = '+1649693498',callCenterId=callCenterId.Id, VendorType='ContactCenter',CallStartDateTime=datetime.now(), CallEndDateTime=datetime.now(), ToPhoneNumber='+1578782168', CallType='transfer');
        insert vc0;
        VoiceCall vc1 = new VoiceCall(FromPhoneNumber='+1649693498',F9_Call_ANI__c = '+1649693498',callCenterId=callCenterId.Id, VendorType='ContactCenter',CallStartDateTime=datetime.now(), CallEndDateTime=datetime.now(), ToPhoneNumber='+1578782168', CallType='transfer',DH_TransferNotes__c='note1',NextCallId=vc0.Id);
        insert vc1;
        VoiceCall vc = new VoiceCall(FromPhoneNumber='+1649693498',F9_Call_ANI__c = '+1649693498',callCenterId=callCenterId.Id, VendorType='ContactCenter',CallStartDateTime=datetime.now(), CallEndDateTime=datetime.now(), ToPhoneNumber='+1578782168', CallType='transfer',CallDisposition='In-progress',PreviousCallId=vc1.Id);
        insert vc;
        vc.RelatedRecordId=acc.personcontactId;
        vc.F9_DH_SystemId__c='CA';
        Update vc;
        List<String> notesList = new List<String>();
        for(User u : userMap.values()){
            System.runAs(u) {
                VoiceCall vcNew = [Select Id,DH_TransferNotesSummary__c from VoiceCall where Id = :vc.Id];
                notesList.add(vcNew.DH_TransferNotesSummary__c);
             }
        }
        return notesList;
    }
    @isTest
    public static void udpateVoiceCallFieldsTestElseCondition3(){
        User radnetSchedulerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestscheduler@radnet.com' limit 01];
        User radnetSchedulerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastscheduler@radnet.com' limit 01];
        User radnetManagerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestmanager@radnet.com' limit 01];
        User radnetManagerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastmanager@radnet.com' limit 01];
        Map<Id, User> userEastMap = new Map<Id,User>();
        Map<Id, User> userWestMap = new Map<Id,User>();
        userWestMap.put(radnetSchedulerWest.Id,radnetSchedulerWest);
        userEastMap.put(radnetSchedulerEast.Id,radnetSchedulerEast);
        userWestMap.put(radnetManagerWest.Id,radnetManagerWest);
        userEastMap.put(radnetManagerEast.Id,radnetManagerEast); 
        Test.startTest();
        runudpateVoiceCallFieldsTestElseCondition3(userEastMap);
        runudpateVoiceCallFieldsTestElseCondition3(userWestMap);
        List<String> notesList1= runudpateVoiceCallFieldsTestElseCondition3(userEastMap);
        System.assertEquals(notesList1[0],null, 'Notes are not populated');
        System.assertEquals(notesList1[1],null, 'Notes are not populated');
        List<String> notesList2= runudpateVoiceCallFieldsTestElseCondition3(userWestMap);
        System.assertEquals(notesList2[0],null, 'Notes are not populated');
        System.assertEquals(notesList2[1],null, 'Notes are not populated');
        Test.stopTest();
    }
    public static List<String> runudpateVoiceCallFieldsTestElseCondition3(Map<Id, User> userMap){
        Account acc = new Account(FirstName='Prasanna',LastName='Anjankar',recordTypeId=DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID);
        insert acc;
        CallCenter callCenterId = [SELECT Id FROM CallCenter LIMIT 1];
        VoiceCall vc0 = new VoiceCall(FromPhoneNumber='+1649693498',F9_Call_ANI__c = '+1649693498',callCenterId=callCenterId.Id, VendorType='ContactCenter',CallStartDateTime=datetime.now(), CallEndDateTime=datetime.now(), ToPhoneNumber='+1578782168', CallType='transfer');
        insert vc0;
        VoiceCall vc1 = new VoiceCall(FromPhoneNumber='+1649693498',F9_Call_ANI__c = '+1649693498',callCenterId=callCenterId.Id, VendorType='ContactCenter',CallStartDateTime=datetime.now(), CallEndDateTime=datetime.now(), ToPhoneNumber='+1578782168', CallType='transfer',NextCallId=vc0.Id);
        insert vc1;
        VoiceCall vc = new VoiceCall(FromPhoneNumber='+1649693498',F9_Call_ANI__c = '+1649693498',callCenterId=callCenterId.Id, VendorType='ContactCenter',CallStartDateTime=datetime.now(), CallEndDateTime=datetime.now(), ToPhoneNumber='+1578782168', CallType='transfer',CallDisposition='In-progress',PreviousCallId=vc1.Id);
        insert vc;
        vc.RelatedRecordId=acc.personcontactId;
        vc.F9_DH_SystemId__c='CA';
        Update vc;
        List<String> notesList = new List<String>();
        for(User u : userMap.values()){
            System.runAs(u) {
                VoiceCall vcNew = [Select Id,DH_TransferNotesSummary__c from VoiceCall where Id = :vc.Id];
                notesList.add(vcNew.DH_TransferNotesSummary__c);
             }
        }
        return notesList;
    }
    
    @isTest
    public static void getGroupNumberForUserTest(){ 
        User radnetSchedulerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestscheduler@radnet.com' limit 01];
        User radnetSchedulerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastscheduler@radnet.com' limit 01];
        List<Group> groups = [SELECT Id FROM Group WHERE DeveloperName = 'DH_AgentGroup10' LIMIT 1];
		List<GroupMember> groupMembers = new List<GroupMember>();
		groupMembers.add(new GroupMember(GroupId = groups[0].Id, UserOrGroupId = radnetSchedulerWest.Id));
		insert groupMembers;
        Test.startTest();
        Integer num = DH_VoiceCallTriggerHepler.getGroupNumberForUser(radnetSchedulerWest.Id);
        Integer num1 = DH_VoiceCallTriggerHepler.getGroupNumberForUser(radnetSchedulerEast.Id);
        System.assertEquals(10, num,'Group not assigned correctly');
        System.assertEquals(1, num1,'Group not assigned correctly');
        Test.stopTest();
    }
    
    @isTest
    public static void removePhoneFormatTest(){ 
        Test.startTest();
        String num = DH_VoiceCallTriggerHepler.removePhoneFormat('(213) 207-0175');
        System.assertEquals('2132070175', num,'Phone Format not removed correctly');
        Test.stopTest();
    }
    
    @isTest
    public static void createVoiceCallShareRecordTest(){
        User radnetSchedulerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestscheduler@radnet.com' limit 01];
        User radnetSchedulerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastscheduler@radnet.com' limit 01];
        User radnetManagerWest = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radnetwestmanager@radnet.com' limit 01];
        User radnetManagerEast = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='radneteastmanager@radnet.com' limit 01];
        Map<Id, User> userEastMap = new Map<Id,User>();
        Map<Id, User> userWestMap = new Map<Id,User>();
        userWestMap.put(radnetSchedulerWest.Id,radnetSchedulerWest);
        userEastMap.put(radnetSchedulerEast.Id,radnetSchedulerEast);
        userWestMap.put(radnetManagerWest.Id,radnetManagerWest);
        userEastMap.put(radnetManagerEast.Id,radnetManagerEast); 
        Test.startTest();
        List<List<VoiceCallShare>> voiceCallShareList1 = runcreateVoiceCallShareRecordTest(userEastMap);
        System.assertNotEquals(null, voiceCallShareList1[0],'Error occurred while creating Voice call');
        System.assertNotEquals(null, voiceCallShareList1[1],'Error occurred while creating Voice call');
        List<List<VoiceCallShare>> voiceCallShareList2 = runcreateVoiceCallShareRecordTest(userWestMap);
        System.assertNotEquals(null, voiceCallShareList2[0],'Error occurred while creating Voice call');
        System.assertNotEquals(null, voiceCallShareList2[1],'Error occurred while creating Voice call');
        Test.stopTest();
    }
    /**
    * @Jira CC-526
    * @description - Tests the invocation of the createVoiceCallShareRecord which create VoiceCallShare record when a voice call is updated.
    * @param       - None
    **/
    public static List<List<VoiceCallShare>> runcreateVoiceCallShareRecordTest(Map<Id, User> userMap) {  
        VoiceCall voiceCallRecord1 = DH_TestDataFactory.createVoiceCallRecord('+1578782168','+1649693498','+1649693498','ContactCenter',datetime.now(),datetime.now(),'Inbound',null);
        insert voiceCallRecord1;
        VoiceCall vc = new VoiceCall();
        vc.Id = voiceCallRecord1.Id;
        vc.F9_DH_SystemId__c = 'CA';
        update vc;
        Group caGroupId= [SELECT Id,DeveloperName, Type FROM Group WHERE Type='Regular' AND DeveloperName=:'CA_Region_Team' With SECURITY_ENFORCED];
        List<List<VoiceCallShare>> voiceCallShareList = new List<List<VoiceCallShare>>();
        for(User u : userMap.values()){
            System.runAs(u){
                List<VoiceCallShare> voiceCallShareRec= [SELECT Id,ParentId, UserOrGroupId FROM VoiceCallShare WHERE ParentId =: voiceCallRecord1.Id AND RowCause = 'Manual' With SECURITY_ENFORCED];
            	voiceCallShareList.add(voiceCallShareRec);
            	System.assertEquals(caGroupId.Id, voiceCallShareRec[0].UserOrGroupId,'Error occurred while creating voice call');
        }
        }
        return voiceCallShareList;
    }  
    
     @isTest
    public static void createVoiceCallShareRecordAdminTest(){
        User radnetSystemAdmin = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='marketingUser@PatientEngagementControllerTest.com' limit 01];
        User radnetSystemAdmin1 = [SELECT ID, Username,FederationIdentifier,DH_User_Region__c FROM USER WHERE Email='systemadminWest@gmail.com' limit 01];
        Map<Id, User> admin = new Map<Id,User>();
        admin.put(radnetSystemAdmin.Id,radnetSystemAdmin); 
        admin.put(radnetSystemAdmin1.Id,radnetSystemAdmin1); 
        Test.startTest();
        runcreateVoiceCallShareRecordaAdminTest(admin);
        Test.stopTest();
    }
    /**
    * @Jira CC-526
    * @description - Tests the invocation of the createVoiceCallShareRecord which create VoiceCallShare record when a voice call is updated.
    * @param       - None
    **/
    public static void runcreateVoiceCallShareRecordaAdminTest(Map<Id, User> userMap) {  
        
        VoiceCall voiceCallRecord1 = DH_TestDataFactory.createVoiceCallRecord('+1578782168','+1649693498','+1649693498','ContactCenter',datetime.now(),datetime.now(),'Outbound',null);
        insert voiceCallRecord1;
        VoiceCall vc = new VoiceCall();
        vc.Id = voiceCallRecord1.Id;
        vc.F9_DH_SystemId__c = 'CA';
        for(User u : userMap.values()){
         System.runAs(u){
        	update vc;
        }
        }
    } 
    
      public static void validatePreviousVerifiedCallerTest(){ 
        Account acc = new Account(FirstName='Prasanna',LastName='Anjankar',recordTypeId=DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID);
        insert acc;
        CallCenter callCenterId = [SELECT Id FROM CallCenter LIMIT 1];
        VoiceCall vc0 = new VoiceCall(FromPhoneNumber='+1649693498',F9_Call_ANI__c = '+1649693498',callCenterId=callCenterId.Id, VendorType='ContactCenter',CallStartDateTime=datetime.now(), CallEndDateTime=datetime.now(), ToPhoneNumber='+1578782168', CallType='transfer',DH_TransferNotesSummary__c='note');
        insert vc0;
        VoiceCall vc1 = new VoiceCall(FromPhoneNumber='+1649693498',F9_Call_ANI__c = '+1649693498',callCenterId=callCenterId.Id, VendorType='ContactCenter',CallStartDateTime=datetime.now(), CallEndDateTime=datetime.now(), ToPhoneNumber='+1578782168', CallType='transfer',DH_TransferNotesSummary__c='note',NextCallId=vc0.Id);
        insert vc1;
        VoiceCall vc = new VoiceCall(FromPhoneNumber='+1649693498',F9_Call_ANI__c = '+1649693498',callCenterId=callCenterId.Id, VendorType='ContactCenter',CallStartDateTime=datetime.now(), CallEndDateTime=datetime.now(), ToPhoneNumber='+1578782168', CallType='transfer',CallDisposition='In-progress',PreviousCallId=vc1.Id);
        insert vc;
        vc.RelatedRecordId=acc.personcontactId;
        vc.F9_DH_SystemId__c='CA';
        Update vc;
        Test.startTest();
        DH_VoiceCallTriggerHepler.validatePreviousVerifiedCaller(vc1.Id);
        Test.stopTest();
    }
       
      public static void updatePhoneFormattingTest(){ 
        Account acc = new Account(FirstName='Prasanna',LastName='Anjankar',recordTypeId=DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID);
        insert acc;
        CallCenter callCenterId = [SELECT Id FROM CallCenter LIMIT 1];
        VoiceCall vc0 = new VoiceCall(FromPhoneNumber='+1649693498',F9_Call_ANI__c = '+1649693498',callCenterId=callCenterId.Id, VendorType='ContactCenter',CallStartDateTime=datetime.now(), CallEndDateTime=datetime.now(), ToPhoneNumber='+1578782168', CallType='transfer',DH_TransferNotesSummary__c='note');
        insert vc0;
        VoiceCall vc1 = new VoiceCall(FromPhoneNumber='+1649693498',F9_Call_ANI__c = '+1649693498',callCenterId=callCenterId.Id, VendorType='ContactCenter',CallStartDateTime=datetime.now(), CallEndDateTime=datetime.now(), ToPhoneNumber='+1578782168', CallType='transfer',DH_TransferNotesSummary__c='note',NextCallId=vc0.Id);
        insert vc1;
        VoiceCall vc = new VoiceCall(FromPhoneNumber='+1649693498',F9_Call_ANI__c = '+1649693498',callCenterId=callCenterId.Id, VendorType='ContactCenter',CallStartDateTime=datetime.now(), CallEndDateTime=datetime.now(), ToPhoneNumber='+1578782168', CallType='transfer',CallDisposition='In-progress',PreviousCallId=vc1.Id);
        insert vc;
        vc.RelatedRecordId=acc.personcontactId;
        vc.F9_DH_SystemId__c='CA';
        Update vc;
        Test.startTest();
          DH_VoiceCallTriggerHepler.updatePhoneFormat(new List<VoiceCall>{vc1});
        Test.stopTest();
    }
}
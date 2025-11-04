/*
* ***************************************************************************************************************************
* Apex Class Name - DH_TestDataFactory
* Created Date - 27-May-2024
* @description       : Utility class for test data setup for all functionalities.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-430                   27-May-2024          Addded createRadnetManagerUser,createRadNetScheduler,createRisPatientWrapper,createMockResponse methods.
* CC-426                   25-May-2024          Addded createPayLoadRecord,createVoiceCallRecord,assignPermissionSet,createDexOutServiceRisNewPatientRequest methods.
* CC-428                   27-May-2024          Addded createLogWrapperContentDocSucess,createLogWrapperThreeFieldSucess,createLogWrapperDoubleFieldSucess,createLogWrapperSingleFieldSucess methods.
* CC-482-507-520           25-July-2024         Removed createLogWrapperContentDocSucess,createLogWrapperThreeFieldSucess,createLogWrapperDoubleFieldSucess,createLogWrapperSingleFieldSucess, added createLogWrapper method, updated createDexOutGeneralServiceRequest method
* CC-520                   09-August-2024       Removed createLogWrapper methods
* CC-940                   16-August-2024       Added createPatientRecord method
* CC-633, CC-664           21-August-2024       Added createContactPointPhone and createContactPointEmail methods
* CC-691                   28-August-2024       Added createCaseRecord method
* CC-520                   18-August-2024       Added createPayLoad method
* CC-481                   27-August-2024       Added draftPatientAccount method
* CC-1247                  04-September-2024    Added request.apiErrorSetting parameter in createDexOutGeneralServiceRequest
* CC-1203                  08-September-2024    Added UserWrapper class and createUser,createRadNetWestManagerUser,createRadNetEastManagerUser,createRadNetWestSchedulerUser and createRadNetEastSchedulerUser methods
* CC-1204                  09-September-2024    Added UserWrapper class and getProfileId,assignCCSchedulerPermissionSetGroup,assignCCManagerPermissionSetGroup methods
* CC-527                   15-August-2025       Created Marketing user,assignMarketingPermissionSet method. Updated recently due to SObject error
* CC-1154                  18-September-2024    Added createFixedEngagementInteractionRecords method.
* CC-1203                  18-September-2024    Added createRadNetBatchSchedulerUser method
* CC-491                   18-September-2024    Added creatEiRec,creatIER and creatTriggerSend methods
* CC-1204                  23-September-2024    Added createPermissionSetList, updated assignCCSchedulerPermissionSetGroup and assignCCManagerPermissionSetGroup methods.
* CC-482-507               10-October-2024      Added getEastUsers and getWestUsers methods
* CC-1439                  30-October-2024		Added with F9_Call_ANI__c in createVoiceCallRecord method
* *******************************************************************************************************************************************
*/
@isTest
public class DH_TestDataFactory {
    /**
	* @Jira CC-430
    * @description - Creates a DH_DexOutServiceRisPatientSearchRequest wrapper with customizable attributes based on the provided parameters. This method is used to generate test data for RIS patient objects.
    * @param       - Boolean,Boolean,Boolean,Boolean,Boolean,Boolean,Boolean,Boolean,Boolean
    * @return      - DH_DexOutServiceRisPatientSearchRequest
	**/
    public static DH_DexOutServiceRisPatientSearchRequest createRisPatientWrapper(Boolean recordId, Boolean firstName, Boolean lastName, Boolean phoneNumber, Boolean email, 
                                                                Boolean dateOfBirth, Boolean patientMRN, Boolean accessionNumber,Boolean systemId) {
        DH_DexOutServiceRisPatientSearchRequest wrapper = new DH_DexOutServiceRisPatientSearchRequest();       
        if(recordId){wrapper.recordId = '540';}
        if(firstName){wrapper.firstName = 'Test';}
        if(lastName){wrapper.lastName = 'Patient';}
        if(phoneNumber){wrapper.phoneNumber = '1234567890';}
        if(email){wrapper.email = 'TestPatient@example.com';}
        if(dateOfBirth){wrapper.dateOfBirth = '2022-01-01';}
        if(patientMRN){wrapper.patientMRN = 'MRN12345';}
        if(accessionNumber){wrapper.accessionNumber = 'ACC456';}
        if(systemId){wrapper.systemId = '0';}
    
        return wrapper;
    }
    /**
	* @Jira CC-426
    * @description - Creates a DH_DexOutServiceRisNewPatientRequest wrapper with customizable attributes based on the provided parameters. This method is used to generate test data for RIS patient objects.
    * @param       - String,String,String,String,String,String,String
    * @return      - DH_DexOutServiceRisPatientSearchRequest
	**/
    public static DH_DexOutServiceRisNewPatientRequest createDexOutServiceRisNewPatientRequest(String recordId, String userId, String expiryInSeconds, String firstName, String lastName, String phoneNumber, String emailAddress) {
        DH_DexOutServiceRisNewPatientRequest request = new DH_DexOutServiceRisNewPatientRequest();
        request.recordId = recordId;
        DH_DexOutServiceRisNewPatientRequest.Parameters params = new DH_DexOutServiceRisNewPatientRequest.Parameters();
        request.parameters = params;
        DH_DexOutServiceRisNewPatientRequest.Data data = new DH_DexOutServiceRisNewPatientRequest.Data();
        data.userID = userId;
        data.expiryInSeconds = expiryInSeconds;
        params.data = data;
        DH_DexOutServiceRisNewPatientRequest.PatientClass patient = new DH_DexOutServiceRisNewPatientRequest.PatientClass();
        patient.firstName = firstName;
        patient.lastName = lastName;
        patient.phoneNumber = phoneNumber;
        patient.emailAddress = emailAddress;
        data.Patient = patient;
        return request;
    }
    /**
	* @Jira CC-430,426
    * @description - Creates a mock HTTP response with the provided status code and body content. This method is used to simulate HTTP responses during testing.
    * @param       - Integer,String
    * @return      - HttpResponse
	**/
    public static HttpResponse createMockResponse(Integer statusCode, String body) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        response.setBody(body);
        return response;
    }
    /**
	* @Jira CC-430,426,425
    * @description - Allows to return user object with specified paramaters with Radnet Scheduler Profile.
    * @param       - String,String,String,String,String
    * @return      - User
	**/
    public static User createRadNetScheduler(String alias, String email, String lastName, String username,String federationIdentifier) {
        Profile managerProfile = [SELECT Id FROM Profile WHERE Name = 'RadNet Scheduler East' LIMIT 1];
        return new User(
            Alias = alias,
            Email = email,
            EmailEncodingKey = 'UTF-8',
            LastName = lastName,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = managerProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive = true,
            FederationIdentifier = federationIdentifier,
            UserName = username
        );
    }
    /**
	* @Jira CC-430,426,425
    * @description - Allows to return PermissionSetAssignment object with specified paramaters.
    * @param       - String
    * @return      - PermissionSetAssignment
	**/
    public static PermissionSetAssignment assignPermissionSet(String userId) {
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'DH_GeneralContactCenter'];  
        return new PermissionSetAssignment(
            AssigneeId = userId,
            PermissionSetId = ps.Id
        );
    }
    /**
	* @Jira CC-430,426,425
    * @description - Allows to return user object with specified paramaters with Radnet Manager Profile.
    * @param       - String,String,String,String,String
    * @return      - User
	**/
    public static User createRadnetManagerUser(String alias, String email, String lastName, String username, String federationIdentifier) {
        Profile managerProfile = [SELECT Id FROM Profile WHERE Name = 'Radnet Manager' LIMIT 1];
        return new User(
            Alias = alias,
            Email = email,
            EmailEncodingKey = 'UTF-8',
            LastName = lastName,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = managerProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive = true,
            FederationIdentifier = federationIdentifier,
            UserName = username
        );
    } 
    /**
	* @Jira CC-426
    * @description - Returns the voice call record.
    * @param       - String,String,String,DateTime,DateTime,String,String
    * @return      - VoiceCall
	**/
    public static VoiceCall createVoiceCallRecord(String toPhoneNumber, String fromPhoneNumber, String five9CallAni, String vendorType,DateTime callStartDateTime,DateTime callEndDateTime,String callType,String systemId) {
        CallCenter callCenterId = [SELECT Id FROM CallCenter LIMIT 1];
        return new VoiceCall(
            ToPhoneNumber = toPhoneNumber,
            FromPhoneNumber = fromPhoneNumber,
            F9_Call_ANI__c = five9CallAni,
            CallCenterId = callCenterId.Id,
            VendorType = vendorType,
            CallStartDateTime = callStartDateTime,
            CallEndDateTime = callEndDateTime,
            CallType = callType,
            F9_DH_SystemId__c = systemId
        );
    }
    /**
	* @Jira CC-426
    * @description -  Returns the voice call record.
    * @param       - Id
    * @return      - VoiceCall
	**/
    public static VoiceCall updateVoiceCallRecord(Id vcId,Id relatedId) {
        VoiceCall vcRec = new VoiceCall();
        vcRec.Id =vcId;
        vcRec.Five9BYOT__F9_AgentName__c = 'Test Agent';
        vcRec.RelatedRecordId = relatedId;
        return vcRec;
    }    
    /**
	* @Jira CC-426
    * @description - Returns the voice call record.
    * @param       - String,String,String,String
    * @return      - VoiceCall
	**/
    public static Account createAccount(String firstName, String lastName,String region,String recordTypeId) {
        return new Account(
            FirstName = firstName,
            LastName = lastName,
            Region__c = region,
            DH_Patient_Key__c = '123',
            RecordTypeId = recordTypeId
        );
    }   
    /**
	* @Jira CC-426
    * @description - Returns the voice call record.
    * @param       - String,String,String,String
    * @return      - VoiceCall
	**/
    public static Case createCase(String description, String accountId){
        return new Case(
            Description = description,
            AccountId = accountId,
            Status = 'New'
        );
    }    
    /**
	* @Jira CC-426
    * @description - Returns the DH_PayloadData__c record.
    * @param       - String,String,String
    * @return      - DH_PayloadData__c
	**/
    public static DH_PayloadData__c createPayLoadRecord(String apiEndPoint, String relatedToID, String payLoad) {
        return new DH_PayloadData__c(
            DH_APIEndPoint__c = apiEndPoint,
            DH_Payload1__c = payLoad,
            DH_RelatedTo__c = relatedToID
        );
    }
    /**
	* @Jira CC-425
    * @description - Assigns the owner to voicecall record.
    * @param       - String,String
    * @return      - VoiceCall
	**/
    public static VoiceCall assignVcOwner(String vcId,String ownerId){
        VoiceCall vc = new VoiceCall();
        vc.Id = vcId;
        vc.OwnerId = ownerId;
        return vc;
    }
    
    /**
	* @Jira CC-482-507
    * @description - Creates a DH_DexOutServiceRisNewPatientRequest wrapper with customizable attributes based on the provided parameters. This method is used to generate test data for RIS patient objects.
    * @param       - Wrapper
    * @return      - DH_DexOutServiceRisPatientSearchRequest
	**/
    public static DH_DexOutGeneralServiceRequest createDexOutGeneralServiceRequest(DH_DexOutServiceRisPatientSearchRequest wrapper, DH_IntegrationSetting__mdt integrationSettingMetadata ) {
        DH_DexOutGeneralServiceRequest request = new DH_DexOutGeneralServiceRequest();
        String param = DH_DexOutServiceRisPatientSearch.constructApiUrl(wrapper);
        request.recordId = wrapper.recordId;
        request.requestUrlParameter = param;
        request.apiSetting = integrationSettingMetadata;
        request.apiErrorSetting= DH_CustomMetadataDao.getErrorCodeVsErrorMap(integrationSettingMetadata.DH_ServiceName__c);
        return request;
    }
    /**
	* @Jira CC-426
    * @description - Creates a DH_DexOutServiceRisOpenPatientRequest wrapper with customizable attributes based on the provided parameters. This method is used to generate test data for RIS patient objects.
    * @param       - String,String,String
    * @return      - DH_DexOutServiceRisOpenPatientRequest
	**/
    public static DH_DexOutServiceRisOpenPatientRequest createDexOutServiceRisOpenPatientRequest(String recordId, String patientKey, String systemId) {
        DH_DexOutServiceRisOpenPatientRequest request = new DH_DexOutServiceRisOpenPatientRequest();
        request.recordId = recordId;
        request.patientKey = patientKey;
        request.systemId = systemId;
        return request;
    }
    /**
	* @Jira CC-633
    * @description - Returns the ContactPointPhone record.
    * @param       - String,String,String
    * @return      - ContactPointPhone
	**/
    public static ContactPointPhone createContactPointPhone(String phoneRisKey, String phoneNumber,String patientId) {
        return new ContactPointPhone(
            DH_Patient_Phone_Key__c = phoneRisKey,
            DH_RIS_PhoneKey__c = phoneRisKey,
            TelephoneNumber = phoneNumber,
			ParentId = patientId
        );
    }
    /**
	* @Jira CC-664
    * @description - Returns the ContactPointEmail record.
    * @param       - String,String,String
    * @return      - ContactPointEmail
	**/
    public static ContactPointEmail createContactPointEmail(String emailRisKey, String emailAddress,String patientId) {
        return new ContactPointEmail(
            DH_Email_Key__c = emailRisKey,
            DH_RIS_EmailKey__c = emailRisKey,
            EmailAddress = emailAddress,
			ParentId = patientId
        );
    }   
    /**
	* @Jira CC-940
    * @description - Returns a patient account record.
    * @param       -  
    * @return      - ContactPointEmail
	**/
    public static List<Account> createPatientRecord(){
        List<Account> accList=new List<Account>();  
        Account testAccount1 = new Account(
            Name = 'Test Account1',
            DH_Patient_Key__c = '123451',
            Region__c = 'FL',
            DH_RIS_Unique_Code__c='FL_123451_Person Account'
        );
        Account testAccount2 = new Account(
            Name = 'Test Account2',
            DH_Patient_Key__c = '123452',
            Region__c = 'CA',
            DH_RIS_Unique_Code__c='CA_123452_Person Account'
        );
        Account testAccount3 = new Account(
            Name = 'Test Account3',
            DH_Patient_Key__c = '123453',
            Region__c = 'AZ',
            DH_RIS_Unique_Code__c='AZ_123453_Person Account'
        );
        accList.add(testAccount1);
        accList.add(testAccount2);
        accList.add(testAccount3);
        insert accList;
        return accList;
    }
    /**
	* @Jira CC-691
    * @description - Returns  case records.
    * @param       -  
    * @return      - ContactPointEmail
	**/
    public static void createCaseRecord(Id accId, Id vcId){
        DH_GeneralUtility.createContactCenterCase(accId,vcId);
    }
    /**
	* @Jira CC-520
    * @description - Returns the DH_PayloadData__c record.
    * @param       - String,String
    * @return      - DH_PayloadData__c
	**/
    public static DH_PayloadData__c createPayLoad(String errorCode, String serviceName) {
        return new DH_PayloadData__c(
            DH_ResponseCode__c = String.valueOf(Integer.valueOf(errorCode)),
            DH_ServiceName__c = serviceName
        );
    }
    /**
	* @Jira CC-481
    * @description - This method will returns Draft Account
    * @param       - none
    * @return      - Account
	**/
    public static Account draftPatientAccount(){
        Account testAccount = new Account(
            lastName ='+1649693498',
			firstName = ' +1649693498',
			DH_Status__c = DH_GlobalConstants.PERSON_ACCOUNT_STATUS,
			DH_System_Id__c = 'CA',
			recordTypeId = DH_GlobalConstants.PERSON_ACCOUNT_RECORD_TYPE_ID
        );
        return testAccount;
    }
    /**
	* @Jira CC-1203,1204
    * @description - this method will creates RadNet East Scheduler.
    * @param       - None
    * @return      - User
	** */
    public static User createRadNetEastSchedulerUser() {
        UserWrapper userRec = new UserWrapper();
        userRec.profileId = getProfileId('RadNet Scheduler East');
        userRec.email = 'radneteastscheduler@radnet.com';
        userRec.alias = 'rSchEast';
        userRec.federationIdentifier = 'radneteastscheduler@radnet.rdlx.pvt';
        userRec.lastName = 'Scheduler';
        userRec.userName = 'radneteastscheduler@radnet.com';
        userRec.userRegion ='East';

        User u = createUser(userRec);
        insert u;
        return u;

    }
    /**
	* @Jira CC-1203,1204
    * @description - this method will creates RadNet East Manager.
    * @param       - None
    * @return      - User
	** */
    public static User createRadNetEastManagerUser() {
        UserWrapper userRec = new UserWrapper();
        userRec.profileId = getProfileId('RadNet Manager East');
        userRec.email = 'radneteastmanager@radnet.com';
        userRec.alias = 'rmEast';
        userRec.federationIdentifier = 'radneteastmanager@radnet.rdlx.pvt';
        userRec.lastName = 'Manager';
        userRec.userName = 'radneteastmanager@radnet.com';
        userRec.userRegion ='East';
        User u = createUser(userRec);
        insert u;
        return u;

    }
    /**
	* @Jira CC-1203,1204
    * @description - this method will creates RadNet West Scheduler.
    * @param       - None
    * @return      - User
	** */
    public static User createRadNetWestSchedulerUser() {
        UserWrapper userRec = new UserWrapper();
        userRec.profileId = getProfileId('RadNet Scheduler West');
        userRec.email = 'radnetwestscheduler@radnet.com';
        userRec.alias = 'rSchWest';
        userRec.federationIdentifier = 'radnetwestscheduler@radnet.rdlx.pvt';
        userRec.lastName = 'West Scheduler';
        userRec.userName = 'radnetwestscheduler@radnet.com';
        userRec.userRegion ='West';
        User u = createUser(userRec);
        insert u;
        return u;

    }
    /**
	* @Jira CC-1203,1204
    * @description - this method will creates RadNet West Manager.
    * @param       - None
    * @return      - User
	** */
    public static User createRadNetWestManagerUser() {
        UserWrapper userRec = new UserWrapper();
        userRec.profileId = getProfileId('RadNet Manager West');
        userRec.email = 'radnetwestmanager@radnet.com';
        userRec.alias = 'rmWest';
        userRec.federationIdentifier = 'radnetwestmanager@radnet.rdlx.pvt';
        userRec.lastName = 'West Manager';
        userRec.userName = 'radnetwestmanager@radnet.com';
        userRec.userRegion ='West';
        User u = createUser(userRec);
        insert u;
        return u;
    }
    /**
	* @Jira CC-1203,1204
    * @description - Allows to return user object with specified paramaters with Radnet Scheduler Profile.
    * @param       - User
    * @return      - User
	**/
    public static User assignCCSchedulerPermissionSetGroup(User user) {
        Set<String> permissionSetNamesSet=new Set<String>();
        if(user.DH_User_Region__c == 'East'){
            permissionSetNamesSet.add('ContactCenterAgentExternalTelephony');
            permissionSetNamesSet.add('DH_GeneralContactCenter');
            permissionSetNamesSet.add('DH_EastCoastContactCenter');
            createPermissionSetList(permissionSetNamesSet,user);
        }else if(user.DH_User_Region__c== 'West'){
            permissionSetNamesSet.add('ContactCenterAgentExternalTelephony');
            permissionSetNamesSet.add('DH_GeneralContactCenter');
            permissionSetNamesSet.add('DH_WestCoastContactCenter');
            createPermissionSetList(permissionSetNamesSet,user);
        }else{
            throw new DMLException('Please Specify User Region');
        }
        return user;
    }
    /**
	* @Jira CC-1203,1204
    * @description - this method will Assings Admin based Permission Set to the user.
    * @param       - User
    * @return      - User
	**/
    public static void assignCCAdminPermissions(User user){
        Set<String> permissionSetNamesSet=new Set<String>();
        permissionSetNamesSet.add('DH_ContactCenterBatchAdmin');
        Map<String,PermissionSet> permissionSets= new Map<String,PermissionSet>();    
        permissionSets = DH_ContactCenterCachingUtility.getPermissionSetMap(permissionSetNamesSet);

        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = user.Id,
            PermissionSetId = permissionSets.get('DH_ContactCenterBatchAdmin').Id
        );
        insert psa;
    }
    /**
	* @Jira CC-1203,1204
    * @description - this method will Assings permission set list to the user.
    * @param       - Set<String> permissionSetNameSet, User
    * @return      - User
	**/
    public static void createPermissionSetList(Set<String> permissionSetNameSet, User user){
        List<PermissionSetAssignment> permissionSetList=new List<PermissionSetAssignment>();
        Map<String,PermissionSet> permissionSetMap= DH_ContactCenterCachingUtility.getPermissionSetMap(permissionSetNameSet);
        for(String psRec : permissionSetNameSet){
            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = user.Id,
                PermissionSetId = permissionSetMap.get(psRec).Id
            );
            permissionSetList.add(psa);
        }        
        if(permissionSetList != null && permissionSetList.size()>0){
            insert permissionSetList;
        }
    }
    /**
	* @Jira CC-1203,1204
    * @description - Allows to return user object with specified paramaters with Radnet Scheduler Profile.
    * @param       - String,String,String,String,String
    * @return      - User
	**/
    public static User assignCCManagerPermissionSetGroup(User user) {
        Set<String> permissionSetNamesSet=new Set<String>();
        if(user.DH_User_Region__c == 'East'){
            permissionSetNamesSet.add('ContactCenterAgentExternalTelephony');
            permissionSetNamesSet.add('DH_ContactCenterRadNetManager');
            permissionSetNamesSet.add('DH_EastCoastContactCenter');
            permissionSetNamesSet.add('DH_GeneralContactCenter');
            createPermissionSetList(permissionSetNamesSet,user);
        }
        else if(user.DH_User_Region__c== 'West'){
            permissionSetNamesSet.add('ContactCenterAgentExternalTelephony');
            permissionSetNamesSet.add('DH_ContactCenterRadNetManager');
            permissionSetNamesSet.add('DH_GeneralContactCenter');
            permissionSetNamesSet.add('DH_WestCoastContactCenter');
            createPermissionSetList(permissionSetNamesSet,user);
        }else{
            throw new DMLException('Please Specify User Region');
        }
        return user;
    }
    /**
	* @Jira CC-1203,1204
    * @description - Allows to return user object with specified paramaters with Radnet Scheduler Profile.
    * @param       - String,String,String,String,String
    * @return      - User
	**/
    public static Id getProfileId(String profileName) {
        Map<String, Profile> profileMap= DH_ContactCenterCachingUtility.getProfileNameVsProfileMap(new Set<String>{profileName});
        Profile profile = profileMap.get(profileName);
        return profile.Id;        
    }
    /**
	* @Jira CC-527
    * @description - this method will creates RadNet Marketibng User.
    * @param       - None
    * @return      - User
	** */
    public static User createRadNetMarketingUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User radnetMarketingUser = new User(
            Alias = 'marcUser', 
            Email='marketingUser@PatientEngagementControllerTest.com', 
            LastName='MarketingTesting', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='marketingUser@PatientEngagementControllerTest.com',
            IsActive = true,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8'
            );
        insert radnetMarketingUser;
        return radnetMarketingUser;
    }
    /**
	* @Jira CC-527
    * @description - this method will assign general marketing cloud permission set to Marketibng User.
    * @param       - None
    * @return      - User
	** */
    public static void assignMarketingPermissionSet(Id userId) {
    List<PermissionSet> psList = [
        SELECT Id FROM PermissionSet
        WHERE Name = 'DH_GeneralMarketingCloud'
        LIMIT 1
    ];
    if (psList.isEmpty()) {
        if (Test.isRunningTest()) {
            System.debug(LoggingLevel.WARN,
                'Test setup: PermissionSet DH_GeneralMarketingCloud not found; skipping assignment.');
        }
        return;
    }
    Id psId = psList[0].Id;
    Integer existing = [
        SELECT COUNT()
        FROM PermissionSetAssignment
        WHERE AssigneeId = :userId AND PermissionSetId = :psId
    ];
    if (existing == 0) {
        insert new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = psId);
    }
}
    /**
	* @Jira CC-1154
    * @description -This method will create the engagement records for test.
    * @param       - Id
    * @return      - void
	**/ 
    public static void createFixedEngagementInteractionRecords(Id accountId,String Region){
        List<EngagementInteraction> engagementList = new List<EngagementInteraction>();
        if(Region == 'FL' || Region == 'MA' ||Region == 'NE'){
        EngagementInteraction engagement1 = new EngagementInteraction(
            DH_Account__c = accountId,
            Reason = 'Test Reason',
            StartDateTime = Datetime.now(),
            CommunicationChannel = 'DH_Email'
        );
        EngagementInteraction engagement2 = new EngagementInteraction(
            DH_Account__c = accountId,
            DH_Content_Body__c = 'SMS',
            StartDateTime = Datetime.now(),
            CommunicationChannel = 'DH_SMS',
            Type = 'Inbound',
            DH_MessageTrackingId__c = 2,
            DH_ResponseToMessageTrackingId__c = 1
        );
        EngagementInteraction engagement3 = new EngagementInteraction(
            DH_Account__c = accountId,
            DH_Content_Body__c = 'SMS',
            StartDateTime = Datetime.now(),
            CommunicationChannel = 'DH_SMS',
            Type = 'Outbound',
            DH_MessageTrackingId__c = 1
        );
        EngagementInteraction engagement4 = new EngagementInteraction(
            DH_Account__c = accountId,
            DH_Content_Body__c = 'SMS',
            StartDateTime = Datetime.now(),
            CommunicationChannel = 'DH_SMS',
            Type = 'Inbound',
            DH_MessageTrackingId__c = 3,
            DH_ResponseToMessageTrackingId__c = 1
        );
        engagementList.add(engagement1);
        engagementList.add(engagement2);
        engagementList.add(engagement3);
        engagementList.add(engagement4);
        }else{
            EngagementInteraction engagement1 = new EngagementInteraction(
                DH_Account__c = accountId,
                Reason = 'Test Reason',
                StartDateTime = Datetime.now(),
                CommunicationChannel = 'DH_Email'
            );
            EngagementInteraction engagement2 = new EngagementInteraction(
                DH_Account__c = accountId,
                DH_Content_Body__c = 'SMS',
                StartDateTime = Datetime.now(),
                CommunicationChannel = 'DH_SMS',
                Type = 'Inbound',
                DH_MessageTrackingId__c = 5,
                DH_ResponseToMessageTrackingId__c = 4
            );
            EngagementInteraction engagement3 = new EngagementInteraction(
                DH_Account__c = accountId,
                DH_Content_Body__c = 'SMS',
                StartDateTime = Datetime.now(),
                CommunicationChannel = 'DH_SMS',
                Type = 'Outbound',
                DH_MessageTrackingId__c = 4
            );
            EngagementInteraction engagement4 = new EngagementInteraction(
                DH_Account__c = accountId,
                DH_Content_Body__c = 'SMS',
                StartDateTime = Datetime.now(),
                CommunicationChannel = 'DH_SMS',
                Type = 'Inbound',
                DH_MessageTrackingId__c = 6,
                DH_ResponseToMessageTrackingId__c = 4
            );
            engagementList.add(engagement1);
            engagementList.add(engagement2);
            engagementList.add(engagement3);
            engagementList.add(engagement4); 
        }
        insert engagementList;
    }
    /**
	* @Jira CC-1203,1204
    * @description - Allows to return user object with specified paramaters with Radnet Scheduler Profile.
    * @param       - String,String,String,String,String
    * @return      - User
	**/
    public static User createUser(UserWrapper userDetails) {
        return new User(
            Alias = userDetails.alias,
            Email = userDetails.email,
            EmailEncodingKey = 'UTF-8',
            LastName = userDetails.lastName,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = userDetails.profileId,
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive = true,
            FederationIdentifier = userDetails.federationIdentifier,
            UserName = userDetails.userName,
            DH_User_Region__c = userDetails.userRegion
        );
    }
    public class UserWrapper{
        ID profileId;
        String alias; 
        String email; 
        String lastName;
        String federationIdentifier;
        String userName;
        String userRegion;
    }
    /**
	* @Jira CC-1203
    * @description - this method will creates RadNet Batch Scheduler
    * @param       - None
    * @return      - User
	** */
    public static User createRadNetBatchSchedulerUser() {
        UserWrapper userRec = new UserWrapper();
        userRec.profileId = getProfileId('System Administrator');
        userRec.email = 'radnetbatchscheduler@radnet.com';
        userRec.alias = 'schBatch';
        userRec.federationIdentifier = 'radnetbatchscheduler@radnet.rdlx.pvt';
        userRec.lastName = 'RadNet Batch Scheduler';
        userRec.userName = 'radnetbatchscheduler@radnet.com';
        userRec.userRegion ='East';
        User u = createUser(userRec);
        Insert u;   
        return u;
    }
	
    /**
	* @Jira CC-491
    * @description - This method will returns the EngagementInteraction
    * @param       - String,String,String,String,String,String,String,String,String,String
    * @return      - EngagementInteraction
	**/
    public static EngagementInteraction createEiRec(String batchId,String jobId,String channel,String emailAdd,String emailId,String exId,String reason,String content,String accId,String csr){
        EngagementInteraction eI = new EngagementInteraction(
            DH_BatchId__c = batchId,
            DH_JobId__c = jobId,
            CommunicationChannel = channel,
            DH_EmailAddress__c = emailAdd,
            DH_EmailId__c = emailId,
            ExternalIdentifier = exId,
            StartDateTime = datetime.now(),
            Reason = reason,
            DH_Account__c = accId,
            DH_Content_Body__c = content,
            DH_ClinicalServiceRequest__c = csr
        );
        return eI;
    }
    /**
	* @Jira CC-491
    * @description - This method will returns the et4ae5__IndividualEmailResult__c
    * @param       - String,String,String,String,Integer,String
    * @return      - et4ae5__IndividualEmailResult__c
	**/
    public static et4ae5__IndividualEmailResult__c creatIER(String batchId,String emailId,String subId,String jobId,Integer clicks,String triggerSend){
        et4ae5__IndividualEmailResult__c ier = new et4ae5__IndividualEmailResult__c(
        et4ae5__BatchId__c = batchId,
        et4ae5__DateSent__c = dateTime.now(),
        et4ae5__Email_ID__c = emailId,
        et4ae5__SubscriberId__c = subId,
        et4ae5__JobId__c = jobId,
        et4ae5__NumberOfTotalClicks__c = clicks,
        et4ae5__TriggeredSendDefinition__c = triggerSend
        );
        return ier;
    }
    /**
	* @Jira CC-491
    * @description - This method will returns the et4ae5__Automated_Send__c
    * @param       - String
    * @return      - et4ae5__Automated_Send__c
	**/
    public static et4ae5__Automated_Send__c creatTriggerSend(String emailId){
        et4ae5__Automated_Send__c eI = new et4ae5__Automated_Send__c(
            et4ae5__EmailId__c = emailId
        );
        return eI;
    }
    /**
	 * @Jira CC-482-507
	 * @description - This methods returns East Coast users with assigned permissions
	 * @param       - None
	 * @return Map<Id, User>
	 **/
	public static map<Id, User> getEastUsers() {
		Map<Id, User> userEastMap = new Map<Id, User>();

		User radnetSchedulerEast = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radneteastscheduler@radnet.com' LIMIT 1];
		User radnetManagerEast = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radneteastmanager@radnet.com' LIMIT 1];

		userEastMap.put(radnetSchedulerEast.iD, radnetSchedulerEast);
		userEastMap.put(radnetManagerEast.iD, radnetManagerEast);

		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerEast);
		DH_TestDataFactory.assignCCManagerPermissionSetGroup(radnetManagerEast);

		return userEastMap;
	}
	/**
	 * @Jira CC-482-507
	 * @description - This methods returns West Coast users with assigned permissions
	 * @param       - None
	 * @return Map<Id, User>
	 **/
	public static Map<Id, User> getWestUsers() {
		Map<Id, User> userWestMap = new Map<Id, User>();

		User radnetSchedulerWest = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetwestscheduler@radnet.com' LIMIT 1];
		User radnetManagerWest = [SELECT ID, Username, FederationIdentifier, DH_User_Region__c FROM USER WHERE Email = 'radnetwestmanager@radnet.com' LIMIT 1];

		userWestMap.put(radnetSchedulerWest.iD, radnetSchedulerWest);
		userWestMap.put(radnetManagerWest.iD, radnetManagerWest);
		DH_TestDataFactory.assignCCSchedulerPermissionSetGroup(radnetSchedulerWest);
		DH_TestDataFactory.assignCCManagerPermissionSetGroup(radnetManagerWest);

		return userWestMap;
	}

}
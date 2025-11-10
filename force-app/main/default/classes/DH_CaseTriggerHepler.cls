/*
 * ***************************************************************************************************************************
 * Apex Class Name - DH_CaseTriggerHepler
 * Created Date - 24-July-2024
 * @description : Helper class for DH_CaseTriggerHandler.
 * Modification Log :
 * --------------------------------------------------------------------------------
 * Jira#                    Date                 Description
 * ----------------         --------------       ------------------------------
 * CC-526                   24-July-2024         Added updateCaseSystemId method.
 * SC-29                    08-Oct-2025          Added handleCaseEntitlementSetup method.
 * *******************************************************************************************************************************************
 */
public class DH_CaseTriggerHepler {
    /**
     * @Jira CC-526
     * @description - This method will populate the System Id on the Case record based on the RIS Instance / RIS System of the related Account record.
     * @param       - List<Case>
     * @return      - None
     **/
    public static void updateCaseSystemId(List<Case> newCaseList){
        Map<Id,Id> accIdVsCaseIdMap = new Map<Id,Id>();
        List<Case> caseList = new List<Case>();
        Map<Id,String> caseIdVsAccRegionMap = new Map<Id,String>();
        if(newCaseList != null){
            for(Case caseRec : newCaseList){
                accIdVsCaseIdMap.put(caseRec.AccountId,caseRec.Id);
            }
        }
        if(accIdVsCaseIdMap != null && !accIdVsCaseIdMap.isEmpty()){
            for(Account acc : DH_ContactCenterCachingUtility.getAccountsMap(accIdVsCaseIdMap.keySet()).values()){
                caseIdVsAccRegionMap.put(accIdVsCaseIdMap.get(acc.Id),acc.Region__c);
            }
        }
        if(caseIdVsAccRegionMap != null && newCaseList != null && !caseIdVsAccRegionMap.isEmpty()){
            for(Case caseRec : newCaseList){
                caseRec.DH_SystemId__c = caseIdVsAccRegionMap.get(caseRec.Id);
            }
        }
    }
    
    /**
     * @Jira SC-29
     * @description - This method will handle the entitlement setup for newly creating cases.
     * @param       - List<Case>
     * @return      - None
     **/
    
    public static void handleCaseEntitlementSetup(List<Case> newCases) {
        if (newCases == null || newCases.isEmpty()) return;
        
        // Step 1: Filter eligible cases
        List<Case> eligibleCases = new List<Case>();
        Set<String> emails = new Set<String>();
        Set<String> phones = new Set<String>();
        
        for (Case c : newCases) {
            if (c.Origin == 'Chat' && String.isNotBlank(c.Inquiry_Type__c)) {
                eligibleCases.add(c);
                if (String.isNotBlank(c.Email__c))
                    emails.add(c.Email__c.trim().toLowerCase());
                if (String.isNotBlank(c.Phone__c))
                    phones.add(normalizePhone(c.Phone__c));
            }
        }
        if (eligibleCases.isEmpty()) return;
        
        // Step 2: Load metadata config
        Map<String, Case_Entitlement_Config__mdt> configMap = new Map<String, Case_Entitlement_Config__mdt>();
        for (Case_Entitlement_Config__mdt cfg : [
        SELECT DeveloperName, CaseRecordTypeDeveloperName__c, InquiryType__c,
               AccountRecordType__c, EntitlementProcessDeveloperName__c, IsActive__c
        FROM Case_Entitlement_Config__mdt
        WHERE IsActive__c = TRUE]) {
            configMap.put(cfg.CaseRecordTypeDeveloperName__c + '|' + cfg.InquiryType__c.toLowerCase(), cfg);
        }
        
        // Step 3: Load record type maps
        Map<String, Id> accountRecordTypeMap = getRecordTypeMap('Account');
        Map<String, Id> caseRecordTypeMap = getRecordTypeMap('Case');
        
        // Step 4: Load SLA processes
        Map<String, SlaProcess> entitlementProcessMap = getEntitlementProcessMap();
        
        // Step 5: Load accounts
        Map<String, Account> emailAccountMap = new Map<String, Account>();
        Map<String, Account> phoneAccountMap = new Map<String, Account>();
        if (!emails.isEmpty() || !phones.isEmpty()) {
            for (Account acc : [
            SELECT Id, Name, DH_Contact_Point_Email__c, DH_Contact_Point_Phone__c
            FROM Account
            WHERE DH_Contact_Point_Email__c IN :emails
               OR DH_Contact_Point_Phone__c IN :phones
        ]) {
                if (String.isNotBlank(acc.DH_Contact_Point_Email__c))
                    emailAccountMap.put(acc.DH_Contact_Point_Email__c.trim().toLowerCase(), acc);
                if (String.isNotBlank(acc.DH_Contact_Point_Phone__c))
                    phoneAccountMap.put(normalizePhone(acc.DH_Contact_Point_Phone__c), acc);
            }
        }
        
        // Step 6: Load entitlements
        Set<Id> accountIds = new Set<Id>();
        for (Account a : emailAccountMap.values()) {
            accountIds.add(a.Id);
        }
        for (Account a : phoneAccountMap.values()) {
            accountIds.add(a.Id);
        }
        
        
        Map<Id, List<Entitlement>> accountEntitlements = new Map<Id, List<Entitlement>>();
        if (!accountIds.isEmpty()) {
            for (Entitlement e : [
            SELECT Id, Name, AccountId, SlaProcessId, Status, EndDate
            FROM Entitlement
            WHERE AccountId IN :accountIds
        ]) {
                if (!accountEntitlements.containsKey(e.AccountId)) {
                    accountEntitlements.put(e.AccountId, new List<Entitlement>());
                }
                accountEntitlements.get(e.AccountId).add(e);
            }
        }
        
        // Step 7: Process cases
        List<Account> accountsToInsert = new List<Account>();
        List<Entitlement> entitlementsToInsert = new List<Entitlement>();
        Map<Case, Account> caseToAccountMap = new Map<Case, Account>();
        Map<Case, Entitlement> caseToEntitlementMap = new Map<Case, Entitlement>();
        for (Case c : eligibleCases) {
            String caseRecordTypeDevName = getCaseRecordTypeDeveloperName(c.RecordTypeId, caseRecordTypeMap);
            String key = caseRecordTypeDevName + '|' + c.Inquiry_Type__c.toLowerCase();
            Case_Entitlement_Config__mdt cfg = configMap.get(key);
            if (cfg == null) continue;
            
            Account account = null;
            if (String.isNotBlank(c.Email__c) && emailAccountMap.containsKey(c.Email__c.trim().toLowerCase())) {
                account = emailAccountMap.get(c.Email__c.trim().toLowerCase());
            } else if (String.isNotBlank(c.Phone__c) && phoneAccountMap.containsKey(normalizePhone(c.Phone__c))) {
                account = phoneAccountMap.get(normalizePhone(c.Phone__c));
            }
            
            SlaProcess ep = entitlementProcessMap.get(cfg.EntitlementProcessDeveloperName__c.toLowerCase());

            Entitlement entitlement = null;
            
            // Account exists
            if (account != null) {
                List<Entitlement> entList = accountEntitlements.get(account.Id);
                Boolean activeEntFound = false;
                if (entList != null && ep != null) {
                    for (Entitlement e : entList) {
                        if (e.Status == 'Active' && e.SlaProcessId == ep.Id) {
                            activeEntFound = true;
                            entitlement = e;
                            break;
                        }
                    }
                }
                if (!activeEntFound && ep != null) {
                    entitlement = createEntitlement(account.Id, account.Name, ep);
                    entitlementsToInsert.add(entitlement);
                }
                
                // **Assign immediately for existing account**
                c.AccountId = account.Id;
                c.EntitlementId = entitlement != null ? entitlement.Id : null;
            }
            // Account not found
            else {
                account = new Account();
                account.RecordTypeId = accountRecordTypeMap.get(cfg.AccountRecordType__c);
                account.Name = c.First_Name__c + ' ' + c.Last_Name__c;
                account.DH_Contact_Point_Phone__c = c.Phone__c;
                account.DH_Contact_Point_Email__c = c.Email__c;
                account.DH_Birth_Date__c = String.isNotBlank(c.Date_of_Birth__c) ? Date.valueOf(c.Date_of_Birth__c) : null;
                account.DH_Patient_Id__c = c.Account_Number__c ;
                account.Source_Type__c = 'Chat';
                accountsToInsert.add(account);
                
                if (ep != null) {
                    entitlement = createEntitlement(null, c.First_Name__c + ' ' + c.Last_Name__c, ep);
                    entitlementsToInsert.add(entitlement);
                 }
                // Save mapping to assign after insert
                caseToAccountMap.put(c, account);
                caseToEntitlementMap.put(c, entitlement);
            }
            
            // Also store mapping for later
            caseToAccountMap.put(c, account);
            caseToEntitlementMap.put(c, entitlement);
        }
        
        // Step 8: Insert accounts & entitlements
        if (!accountsToInsert.isEmpty()) insert accountsToInsert;
        for (Integer i = 0; i < accountsToInsert.size(); i++) {
            Account acc = accountsToInsert[i];
            Entitlement ent = entitlementsToInsert[i];
            ent.AccountId = acc.Id;
        }
        if (!entitlementsToInsert.isEmpty()) insert entitlementsToInsert;
        
        // Step 9: Assign IDs to cases
        for (Case c : eligibleCases) {
            Account acc = caseToAccountMap.get(c);
            Entitlement ent = caseToEntitlementMap.get(c);
            c.AccountId = acc != null ? acc.Id : null;
            c.EntitlementId = ent != null ? ent.Id : null;
        }
    }
    
    private static Entitlement createEntitlement(Id accountId, String accountName, SlaProcess ep) {
        Entitlement e = new Entitlement();
        e.Name = 'Auto SLA - '  + (String.isNotBlank(accountName) ? accountName : 'Unassigned');
        e.AccountId = accountId;
        e.StartDate = Date.today();
        e.IsPerIncident = false;
        e.SlaProcessId = ep != null ? ep.Id : null;
        return e;
    }
    
    private static String normalizePhone(String phone) {
        return phone != null ? phone.replaceAll('[^0-9]', '') : null;
    }
    
   private static Map<String, Id> getRecordTypeMap(String sobjectName) {
    Map<String, Id> recordTypeMap = new Map<String, Id>();

    try {
        Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(sobjectName);
        if (sObjType != null) {
            Schema.DescribeSObjectResult describeResult = sObjType.getDescribe();
            for (Schema.RecordTypeInfo rtInfo : describeResult.getRecordTypeInfos()) {
                if (rtInfo.isAvailable() && !rtInfo.isMaster()) {
                    recordTypeMap.put(rtInfo.getDeveloperName(), rtInfo.getRecordTypeId());
                }
            }
        }
    } catch (Exception e) {
    }

    // Fallback: if map is empty, use SOQL
    if (recordTypeMap.isEmpty()) {
        try {
            for (RecordType rt : [
                SELECT Id, DeveloperName
                FROM RecordType
                WHERE SObjectType = :sobjectName
            ]) {
                recordTypeMap.put(rt.DeveloperName, rt.Id);
            }
        } catch (Exception ex) {
        }
    }

    return recordTypeMap;
}

    
    private static Map<String, SlaProcess> getEntitlementProcessMap() {
        Map<String, SlaProcess> epMap = new Map<String, SlaProcess>();
        for (SlaProcess ep : [SELECT Id, Name, NameNorm, IsActive FROM SlaProcess WHERE IsActive = TRUE]) {
            epMap.put(ep.NameNorm.toLowerCase(), ep);
        }
        return epMap;
    }
    
    private static String getCaseRecordTypeDeveloperName(Id recordTypeId, Map<String, Id> caseRecordTypeMap) {
        for (String devName : caseRecordTypeMap.keySet()) {
            if (caseRecordTypeMap.get(devName) == recordTypeId) return devName;
        }
        return null;
    }

    /** JIRA SC-29 End */


    /**
     * @Jira SC-36
     * Marks the given milestone as completed for the provided Cases.
     *
     * @param cases List of Case records to check for completion.
     * @param milestoneName API Name of the milestone type (e.g., 'Resolution Time')
     * @param complDate Completion DateTime (e.g., System.now())
     */
    public static void completeMilestone(List<Case> cases, String milestoneName, Datetime complDate) {
        if (cases == null || cases.isEmpty()) {
            return;
        }

        List<Id> caseIds = new List<Id>();
        for (Case c : cases) {
            if ((c.IsClosed || c.Status == 'Closed') &&
                (c.SlaStartDate <= complDate) &&
                (c.SlaExitDate == null)) {
                caseIds.add(c.Id);
            }
        }

        if (caseIds.isEmpty()) {
            return;
        }

        // Fetch open milestones for those cases matching the given milestone name
        List<CaseMilestone> cmsToUpdate = [
            SELECT Id, CompletionDate
            FROM CaseMilestone
            WHERE CaseId IN :caseIds
            AND CompletionDate = NULL
            AND MilestoneType.Name = :milestoneName
        ];

        if (cmsToUpdate.isEmpty()) {
            return;
        }

        // Update milestones
        for (CaseMilestone cm : cmsToUpdate) {
            cm.CompletionDate = complDate;
        }
        update cmsToUpdate;
    }
}
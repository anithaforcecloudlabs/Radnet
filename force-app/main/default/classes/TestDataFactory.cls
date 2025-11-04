@isTest
public with sharing class TestDataFactory implements HttpCalloutMock{

	public static string additionalFields;
	public static string httpCalloutMockBody;
	
	public static List<Account> returnAccounts(Integer numberOfRecords, String recTypeDevName){
		List<Account> returnList = new List<Account>();
		if(numberOfRecords!=null && numberOfRecords>0){
			for(Integer count = 0; count < numberOfRecords; count++){
				Account testAccRec = new Account();
				testAccRec.Name = 'Test Acc '+ String.valueOf(count);
				if(recTypeDevName!=null && recTypeDevName!=''){
					testAccRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recTypeDevName).getRecordTypeId();
				}
				returnList.add(testAccRec);
			}
		}
		return returnList;
	}

	public static List<Contact> returnContacts(Integer numberOfRecords, String recTypeDevName, Set<Id> testAccIdSet){
		List<Contact> returnList = new List<Contact>();
		if(numberOfRecords!=null && numberOfRecords>0 && testAccIdSet!=null && !testAccIdSet.isEmpty()){
			for(Id testAccId : testAccIdSet){
				for(Integer count = 0; count < numberOfRecords; count++){

					Contact testConRec = new Contact();
					testConRec.FirstName = 'Test Con F '+ String.valueOf(count);
					testConRec.LastName = 'Test Con L '+ String.valueOf(count);
					testConRec.Email = 'testCon'+String.valueOf(count)+'@testCon.com';
					testConRec.AccountId = testAccId;
					if(recTypeDevName!=null && recTypeDevName!=''){
						testConRec.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(recTypeDevName).getRecordTypeId();
					}
					returnList.add(testConRec);
				}
			}
			
		}
		return returnList;
	}

	public static List<AccountContactRelation> returnAccountContactRelations(List<Contact> listTestContacts){
		List<AccountContactRelation> returnList = new List<AccountContactRelation>();
		if(listTestContacts!=null && !listTestContacts.isEmpty()){
			for(Contact testConRec : listTestContacts){
				AccountContactRelation testAccConRec = new AccountContactRelation();
				testAccConRec.AccountId = testConRec.AccountId;
				testAccConRec.ContactId = testConRec.Id;
				returnList.add(testAccConRec);
			}
		}
		return returnList;
	}

	public static List<AccountContactRelation> returnAccountContactPracLocRelations(Set<Id>testAccIdSet, Set<Id>testConIdSet){
		List<AccountContactRelation> returnList = new List<AccountContactRelation>();
		if(testAccIdSet!=null && !testAccIdSet.isEmpty()){
			for(Id testAccId : testAccIdSet){
				for(Id testConId : testConIdSet){
					AccountContactRelation testAccConRec = new AccountContactRelation();
					testAccConRec.AccountId = testAccId;
					testAccConRec.ContactId = testConId;
					returnList.add(testAccConRec);
				}
			}
		}
		return returnList;
	}



	public static List<Referral__c> returnReferrals(Integer numberOfRecords, List<AccountContactRelation> listTestAccConRelations){
		List<Referral__c> returnList = new List<Referral__c>();
		if(numberOfRecords!=null && numberOfRecords>0 && listTestAccConRelations!=null && !listTestAccConRelations.isEmpty()){
			for(AccountContactRelation testAccConRelRec : listTestAccConRelations){
				for(Integer count = 0; count < numberOfRecords; count++){
					Referral__c testRefRec = new Referral__c();
					testRefRec.Physician__c = testAccConRelRec.ContactId;
					testRefRec.Practice_Name__c = testAccConRelRec.AccountId;
					testRefRec.Master_Location__c = 'Test location ' + string.valueOf(count);
					testRefRec.Modality__c = 'DEXA';
					testRefRec.Volume__c = 1;
					testRefRec.Encounter_Date__c = Date.today();
					returnList.add(testRefRec);
				}
			}
			
		}
		return returnList;
	}

	public static List<RIS_Requests__c> returnRISRequests(Integer numberOfRecords, Set<Id> practiceLocIdSet){
		List<RIS_Requests__c> returnList = new List<RIS_Requests__c>();
		if(numberOfRecords!=null && numberOfRecords>0){
			if(practiceLocIdSet!=null && !practiceLocIdSet.isEmpty()){
				for(Integer count = 0; count < numberOfRecords; count++){
					for(Id pracLocId : practiceLocIdSet){
						RIS_Requests__c testRisReq = new RIS_Requests__c();
						testRisReq.Status__c = 'New';
						testRisReq.Type__c = 'Physician Removed';
						testRisReq.Subject__c = 'Removing a Physician from a location';
						testRisReq.Description__c = 'Physician(s) were removed from'; 
						testRisReq.Account_Name__c = pracLocId;
						returnList.add(testRisReq);
					}
				}
			}
		}
		return returnList;
	}

	public static List<Related_Request__c> returnRelatedRequests(List<RIS_Requests__c> listLocRisRequestsToInsert, List<AccountContactRelation> listAccConRelRecs){
		List<Related_Request__c> returnList = new List<Related_Request__c>();
		if(listAccConRelRecs!=null && !listAccConRelRecs.isEmpty()){
			for(AccountContactRelation testAccConRelRec : listAccConRelRecs){
				for(RIS_Requests__c testRISReq : listLocRisRequestsToInsert){
					if(testRISReq.Account_Name__c == testAccConRelRec.AccountId){
						Related_Request__c testRelReq = new Related_Request__c();
						testRelReq.Physician__c = testAccConRelRec.ContactId;
						testRelReq.RIS_Request__c = testRISReq.Id;
						testRelReq.Description__c = 'Physician(s) were removed from'; 
						testRelReq.AcrId__c = testAccConRelRec.Id;
						returnList.add(testRelReq);
					}
				}
			}
		}
		return returnList;
	}

	public static List<RIS_Requests__c> returnRISPAPSubmissionRequests(Integer numberOfRecords, Id practiceLocId, String contactIds){
		List<RIS_Requests__c> returnList = new List<RIS_Requests__c>();
		if(numberOfRecords!=null && numberOfRecords>0){
			for(Integer count = 0; count < numberOfRecords; count++) {
				RIS_Requests__c testRisReq = new RIS_Requests__c();
				testRisReq.Status__c = 'New';
				testRisReq.Type__c = 'PAP Submission';
				testRisReq.Subject__c = 'PAP Submission';
				testRisReq.Description__c = 'PAP Document was submitted:';
				testRisReq.Account_Name__c = practiceLocId;
				testRisReq.Physicians_PAP_List__c = contactIds;
				returnList.add(testRisReq);
			}
		}
		return returnList;
	}

	 public static List<RIS_Requests__c> returnRISImageNotesRequests(Integer numberOfRecords, Id contactId){
		List<RIS_Requests__c> returnList = new List<RIS_Requests__c>();
		if(numberOfRecords!=null && numberOfRecords>0){
			for(Integer count = 0; count < numberOfRecords; count++) {
				RIS_Requests__c testRisReq = new RIS_Requests__c();
				testRisReq.Status__c = 'New';
				testRisReq.Type__c = 'Image preference notes';
				testRisReq.Subject__c = 'Image preference notes';
				testRisReq.Description__c = 'Previous IP Notes:';
				testRisReq.ContactId__c = contactId;
				testRisReq.New_Image_Preference_Notes__c = 'New IP Notes Requested';
				returnList.add(testRisReq);
			}

		}
		return returnList;
	}

	public static string getTestSOQLQuery(string objectApiName){
		List<String> listFields = new List<String>();
		listFields.addAll(Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().keySet());
		string query = '';
		string query1 = 'SELECT';
		string query2 = String.Join(listFields, ',');
		if(additionalFields!=null && additionalFields!=''){
			query2 = query2 + ',' + additionalFields; 
		}
		string query3 = ' FROM ' + objectApiName;

		query = query + query1;
		query = query +' '+ query2;
		query = query +' '+ query3;
		return query;
	}
	
	public HTTPResponse respond(HttpRequest req){
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody(httpCalloutMockBody);
		res.setStatusCode(200);
		return res;
	}
}
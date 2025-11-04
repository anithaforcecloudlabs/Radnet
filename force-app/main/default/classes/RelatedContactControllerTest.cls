@isTest
public class RelatedContactControllerTest {

	public static final Id PRACTICE_LOCATION = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Practice Location').getRecordTypeId();
	public static final Id PHYSICIANS = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Physicians').getRecordTypeId();

	@testSetup
	static void setup() {
		User currentUser = new User(Id = UserInfo.getUserId(), RIS_Data_Manager__c = true);
		update currentUser;

		System.runAs(currentUser) {
			Account practice1 = new Account(
				Name = 'TestAcc',
				ShippingCity = 'New York',
				ShippingStreet = '645 10th Avenue',
				ShippingState = 'NY',
				ShippingPostalCode = '10036',
				RecordTypeId = PRACTICE_LOCATION
			);
			Account practice2 = new Account(
				Name = 'TestAcc2',
				ShippingCity = 'New York',
				ShippingStreet = '645 10th Avenue',
				ShippingState = 'NY',
				ShippingPostalCode = '10036',
				RecordTypeId = PRACTICE_LOCATION
			);
			Account practice3 = new Account(
				Name = 'TestAcc3',
				ShippingCity = 'New York',
				ShippingStreet = '45 10th Avenue',
				ShippingState = 'NY',
				ShippingPostalCode = '10736',
				RecordTypeId = PRACTICE_LOCATION
			);

			insert new List <Account> {
				practice1,
				practice2,
				practice3
			};

			Contact contactPracticeDirect = new Contact(
				AccountId = practice1.Id,
				LastName = 'TestCont',
				RecordTypeId = PHYSICIANS
			);
			Contact contactPracticeDirect2 = new Contact(
				AccountId = practice2.Id,
				LastName = 'TestSecCont1',
				RecordTypeId = PHYSICIANS
			);
			Contact contactPractice2 = new Contact(
				AccountId = practice2.Id,
				LastName = 'TestSecCont2',
				RecordTypeId = PHYSICIANS
			);
			Contact contactPractice3 = new Contact(
				AccountId = practice3.Id,
				LastName = 'TestSecCont3',
				RecordTypeId = PHYSICIANS
			);
			Contact contactPractice4 = new Contact(
				AccountId = practice3.Id,
				LastName = 'TestSecCont4',
				RecordTypeId = PHYSICIANS
			);

			Contact contactPractice5 = new Contact(
				AccountId = practice3.Id,
				LastName = 'TestSecCont5',
				RecordTypeId = PHYSICIANS
			);

			insert new List <Contact> {
				contactPracticeDirect,
				contactPracticeDirect2,
				contactPractice2,
				contactPractice3,
				contactPractice4,
				contactPractice5
			};

			AccountContactRelation acr1 = new AccountContactRelation(
				AccountId = practice2.Id,
				ContactId = contactPractice3.Id
			);
			insert acr1;

			AccountContactRelation acr2 = new AccountContactRelation(
				AccountId = practice2.Id,
				ContactId = contactPractice4.Id,
				Email_Reports__c = true,
				Mail_Reports__c = false
			);
			insert acr2;

			AccountContactRelation acr3 = new AccountContactRelation(
				AccountId = practice1.Id,
				ContactId = contactPractice4.Id,
				Email_Reports__c = true
			);
			insert acr3;

			AccountContactRelation acr4 = new AccountContactRelation(
				AccountId = practice3.Id,
				ContactId = contactPractice2.Id,
				Email_Reports__c = true
			);
			insert acr4;
		}
	}

	@IsTest
	public static void testGetContacts() {
		Test.StartTest();
		Account pageAccount = [SELECT Id FROM Account WHERE Name = 'TestAcc2' LIMIT 1];
		List <AccountContactRelation> relatedContacts = RelatedContactController.getContacts((String) pageAccount.Id);
		Assert.areEqual(4, relatedContacts.size());
		List <Id> contactForRenameList = new List <Id> ();
		for (AccountContactRelation acr: relatedContacts) {
			contactForRenameList.add(acr.ContactId);
		}
		List <Contact> contactsRename = RelatedContactController.getContactsForRename(contactForRenameList);
		List <Contact> contactsPINotesRename = RelatedContactController.getContactsForEditNotes(contactForRenameList);
		List<Ris_Requests__c> contactsIPNotesUpdates = new List<Ris_Requests__c>();
		for (Contact contact: contactsPINotesRename) {
				contactsIPNotesUpdates.add(new Ris_Requests__c(
				ContactId__c = contact.Id,
				Type__c = 'Image preference notes',
				Subject__c = 'Image preference notes',
				Description__c = 'Previous IP Notes: <b>'+contact.Image_Preference_Notes__c +'</b><br/> New IP Notes Requested: <b>test </b>',
				New_Image_Preference_Notes__c = 'test'
			));
		}
		try {
			RelatedContactController.createRisRequestImageNotes(contactsIPNotesUpdates);
		} catch (Exception ex) {
			system.debug(ex.getMessage());
		}
		
		Assert.areEqual(4, contactsRename.size());
		Test.StopTest();
	}
	
	@IsTest
	public static void testGetAcrs() {
		Account pageAccount = [SELECT Id FROM Account WHERE Name = 'TestAcc2' LIMIT 1];
		List<AccountContactRelation> relatedContacts = RelatedContactController.getContacts((String) pageAccount.Id);
		List<String> acrIds = new List<String>();
		for(AccountContactRelation acr : relatedContacts){
			acrIds.add(acr.Id);
		}
		List <AccountContactRelation> relatedAcrContacts = RelatedContactController.getACRContactsForRemove(acrIds);
	
		Test.StartTest(); 
		List<RelatedContactController.PhysicianWrapperCls> acrList = new List<RelatedContactController.PhysicianWrapperCls>();
	
		RelatedContactController.updateRemoveComment(physWrp(relatedAcrContacts));
		Test.StopTest(); 
	}

	public static List<RelatedContactController.PhysicianWrapperCls> physWrp(List <AccountContactRelation> relatedAcrContacts) {
		List<RelatedContactController.PhysicianWrapperCls> strList = new List<RelatedContactController.PhysicianWrapperCls>();
		for(AccountContactRelation acr : relatedAcrContacts){
			RelatedContactController.PhysicianWrapperCls pf = new RelatedContactController.PhysicianWrapperCls();
			pf.phyAccId = (String) acr.ContactId;
			pf.phyComment ='test';
			pf.phyReason ='test';
			strList.add(pf);
		}
		return strList;
	}
	
	@IsTest
	public static void removedContacts() {
		Account pageAccount = [SELECT Id FROM Account WHERE Name = 'TestAcc2' LIMIT 1];
		List <AccountContactRelation> relatedContacts = RelatedContactController.getContacts((String) pageAccount.Id);
		List <String> listForRemove = new List <String> ();
		listForRemove.add(relatedContacts[1].Id);
		Assert.areEqual(4, relatedContacts.size());

		Test.startTest();
		try {
			List <AccountContactRelation> removeContactRelationList = RelatedContactController.removeContactRelation(listForRemove, (String) pageAccount.Id);
		} catch (Exception ex) {}
		Test.stopTest();

		List <AccountContactRelation> relatedAfterRemoveContacts = RelatedContactController.getContacts((String) pageAccount.Id);
		Assert.areEqual(4, relatedAfterRemoveContacts.size());
	}

	@IsTest
	public static void updateContact() {
		test.startTest();
		Account pageAccount = [SELECT Id, Name,
			ShippingAddress,
			ShippingCountry,
			ShippingCity,
			ShippingStreet,
			ShippingState,
			ShippingPostalCode
			FROM Account WHERE Name = 'TestAcc2'
			LIMIT 1
		];
		List <AccountContactRelation> acrUpdate = getAcrsToUpdate(pageAccount.Id);
		String getPhysicianUpdates = '[{"key":' + acrUpdate[0] + ',"value":["PAP : true","Fax Reports : true"]},{"key": ' + acrUpdate[1] + ',"value":["PAP : true","Mail Reports : true"]}]';
		List <RelatedContactController.Physician> listAcrs = sendPhy();
		List <String> acrIds = RelatedContactController.getAcrsIds(listAcrs);
		Map <String, AccountContactRelation> acrsUpdate = RelatedContactController.getAcrsRecords(acrIds);

		try {
			RIS_Requests__c createdRisRequest = RelatedContactController.createRisRequest(pageAccount.Id, null, 'desc', 'Change Physician Details', 'subject');
			Related_Request__c  addNewRRS = createRelatedRisRequest (acrUpdate[0], String.valueOf(createdRisRequest.Id));
			Related_Request__c addNewRRS1 = createRelatedRisRequest (acrUpdate[1],String.valueOf(createdRisRequest.Id));
			
			List<Related_Request__c> risRequestUpdates = new List<Related_Request__c>{addNewRRS, addNewRRS1};
			RelatedContactController.createRelatedRequest(createdRisRequest, new Map <String, AccountContactRelation> (acrUpdate), listAcrs, risRequestUpdates);
			RIS_Requests__c caseResult = RelatedContactController.createCaseRecord(pageAccount.Id, getPhysicianUpdates, risRequestUpdates);
		} catch (Exception ex) {
			system.debug(ex.getMessage());
		}
		test.stopTest();
	}

	@IsTest
	public static void testCreateRISRequestOnACRRemove() {
		test.startTest();
		Account pageAccount = [SELECT Id FROM Account WHERE Name = 'TestAcc2' LIMIT 1];
		List<AccountContactRelation> relatedContacts = RelatedContactController.getContacts((String) pageAccount.Id);
		RelatedContactController.RemoveInfo removeInfo = new RelatedContactController.RemoveInfo();
		removeInfo.contactId = relatedContacts[0].ContactId;
		removeInfo.comment = 'Test';
		removeInfo.reason = 'Test';
		
		RelatedContactController.RemoveInfo removeInfoAdd = new RelatedContactController.RemoveInfo();
		removeInfoAdd.contactId = relatedContacts[1].ContactId;
		removeInfoAdd.comment = 'Test';
		removeInfoAdd.reason = 'Test';

		List<Id> acrIds = new List<Id>();
 		acrIds.add(relatedContacts[0].Id);
		List<Id> acrIds2 = new List<Id>();
 		acrIds2.add(relatedContacts[0].Id);
		acrIds2.add(relatedContacts[1].Id);
		try {
			RelatedContactController.checkExistsRisRequest(pageAccount.Id, acrIds, new List<RelatedContactController.RemoveInfo>{removeInfo});
			RelatedContactController.checkExistsRisRequest(pageAccount.Id, acrIds2, new List<RelatedContactController.RemoveInfo>{removeInfo, removeInfoAdd});
			RelatedContactController.createRISRequestOnACRRemove(pageAccount.Id, acrIds, new List<RelatedContactController.RemoveInfo>{removeInfo});
		} catch (Exception ex) {
			system.debug(ex.getMessage());
		}
		test.stopTest();
	}
	
	@IsTest
	public static void fetchREcords() {
		test.startTest();
		RelatedContactController.fetchRecords(searchWrap());
		test.stopTest();
	}

	@IsTest
	public static void moveLocationTest() {
		test.startTest();
		Account pageAccount = [SELECT Id, ShippingStreet, ShippingCountry, ShippingCity, ShippingState, ShippingPostalCode FROM Account WHERE Name = 'TestAcc2' LIMIT 1];
		Account moveToAccount = [SELECT Id, Name, ShippingStreet, ShippingCountry, ShippingCity, ShippingState, ShippingPostalCode FROM Account WHERE Name = 'TestAcc3' LIMIT 1];
		Account moveToAccount2 = [SELECT Id, Name, ShippingStreet, ShippingCountry, ShippingCity, ShippingState, ShippingPostalCode FROM Account WHERE Name = 'TestAcc' LIMIT 1];
		List <AccountContactRelation> acrUpdate = getAcrsToUpdate(pageAccount.Id);
		Related_Request__c  addNewRRS = createRelatedRisRequest (acrUpdate[0], null);
		Related_Request__c addNewRRS1 = createRelatedRisRequest (acrUpdate[1], null);	  
		List <String> acrIds = new List<String>(new Map<String, AccountContactRelation>(acrUpdate).keySet());
		List<Related_Request__c> risRequestUpdates = new List<Related_Request__c>{addNewRRS, addNewRRS1}; 
		Map<String, AccountContactRelation> selectedContactMap = RelatedContactController.getAcrsRecords(acrIds);
		try {
			Map<String, Map<String, List<Sobject>>> createdRisRequest = RelatedContactController.getRelatedRisRequests(
				pageAccount.Id, 
				moveToAccount.Id, 
				new List<String> (new Map<String, AccountContactRelation>(acrUpdate).keySet()),
				risRequestUpdates
			);
		} catch (Exception ex) {
			system.debug(ex.getMessage());
		}
		
		RelatedContactController.movePhysiciansToLocation(
			pageAccount.Id, 
			moveToAccount.Id, 
			new List<String> (new Map<String, AccountContactRelation>(acrUpdate).keySet()),
			risRequestUpdates
		);
		try {
			RelatedContactController.createMovePhysicianRequest(
				pageAccount,
				moveToAccount,
				String.valueOf(moveToAccount.Id),
				new Set<String> (new Map<String, AccountContactRelation>(acrUpdate).keySet()),
				selectedContactMap,
				risRequestUpdates
			);
		} catch (Exception ex) {
				system.debug(ex.getMessage());
		}

		AccountContactRelation updateAcr = RelatedContactController.populateACRtoCreate(addNewRRS, moveToAccount.Id);
		 RelatedContactController.movePhysiciansToLocation(
			pageAccount.Id, 
			moveToAccount2.Id, 
			new List<String> (new Map<String, AccountContactRelation>(acrUpdate).keySet()),
			risRequestUpdates
		);
		test.stopTest();
	}

	public static List<RelatedContactController.Physician> sendPhy() {
		Account pageAccount = [SELECT Id FROM Account WHERE Name = 'TestAcc2' LIMIT 1];
		List <AccountContactRelation> acrUpdate = [
			SELECT  Id,
					AccountId,
					ContactId,
					Contact.Name,
					Email_Reports__c,
					Mail_Reports__c,
					Fax_Reports__c,
					PAP__c,
					Account.Name
			FROM	AccountContactRelation
			WHERE   AccountId =: pageAccount.Id
		];
		RelatedContactController.Physician pf = new RelatedContactController.Physician();
		List <String> vb = new List <String> ();
		String st1 = 'PAP : true';
		String St = 'Fax Reports : true';
		vb.add(st1);
		vb.add(St);
		pf.key = String.valueOf(acrUpdate[0]);
		pf.value = vb;
		RelatedContactController.Physician pf1 = new RelatedContactController.Physician();
		List <String> vb1 = new List <String> ();
		String st3 = 'PAP : true';
		String St4 = 'Fax Reports : true';
		vb.add(st3);
		vb.add(St4);
		pf1.key = String.valueOf(acrUpdate[1]);
		pf1.value = vb1;
		return new List <RelatedContactController.Physician> {pf1,pf};
	}

	public static RelatedContactController.SearchWrapper searchWrap() {
		Account pageAccount = [SELECT Id FROM Account WHERE Name = 'TestAcc2' LIMIT 1]; 
		RelatedContactController.SearchWrapper pf = new RelatedContactController.SearchWrapper();	
		pf.objectApiName =  'Account';
		pf.fieldApiName = 'Name';
		pf.searchString = 'test';
		pf.selectedRecordId = pageAccount.Id;
		return pf;
	}

	public static List <AccountContactRelation> getAcrsToUpdate(Id accountId) {
		return [
			SELECT 	Id,
					AccountId,
					ContactId,
					Contact.Name,
					Phone__c,
					FAX__c,
					PAP__c,
					Contact_Email__c,
					Preferred_Reader__c,
					Image_Preference_Notes__c,
					Email_Reports__c,
					isDirect,
					Account.Name
			FROM 	AccountContactRelation
			WHERE 	AccountId = :accountId
		];
	}
	
	public static Related_Request__c createRelatedRisRequest(AccountContactRelation acrUpdate, String createdRisRequest) {
		Related_Request__c newRelatedRisRequest = new Related_Request__c(
		Physician__c = acrUpdate.ContactId,
		RIS_Request__c = createdRisRequest,
		AcrId__c = acrUpdate.Id,
		Description__c = 'description',
		Contact_Fax__c = acrUpdate.FAX__c,
		PAP__c = acrUpdate.PAP__c,
		Contact_Phone__c = acrUpdate.Phone__c,
		Preferred_Reader__c = acrUpdate.Preferred_Reader__c,
		Image_Preference_Notes__c = acrUpdate.Image_Preference_Notes__c,
		Email_Reports__c = acrUpdate.Email_Reports__c,
		Contact_Phone_New__c = '1231231233' 
	);
		return  newRelatedRisRequest;	 
	}
}
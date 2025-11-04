public with sharing class RelatedContactController {

	@AuraEnabled
	public static List<Contact> getContactsForRename(List<String> contactIds) {
		return [SELECT Id, FirstName, LastName FROM Contact WHERE Id IN: contactIds WITH SECURITY_ENFORCED];
	}

	@AuraEnabled
	public static List<Contact> getContactsForEditNotes(List<String> contactIds) {
		return [SELECT Id, Name, Image_Preference_Notes__c FROM Contact WHERE Id IN: contactIds WITH SECURITY_ENFORCED];
	}

	@AuraEnabled
	public static List<AccountContactRelation> getACRContactsForRemove(List<String> contactRelations) {
		return [SELECT Id, Contact.FirstName, ContactId, Contact.LastName, Contact.RemovedComment__c, IsDirect FROM AccountContactRelation WHERE Id IN: contactRelations WITH SECURITY_ENFORCED];
	}

	@AuraEnabled
	public static void updateRemoveComment(List<PhysicianWrapperCls> listPhysic) {
		List<String> contactIds = new List<String>();
		for(PhysicianWrapperCls phys : listPhysic){
			contactIds.add(phys.phyAccId);
		}
		List<Contact> contacts = [SELECT Id, RemovedComment__c FROM Contact WHERE Id IN : contactIds];
		for(Contact cont : contacts){
			for(PhysicianWrapperCls phys : listPhysic){
				if(phys.phyAccId == cont.Id){
					cont.RemovedComment__c = phys.phyReason + '\n' + phys.phyComment;
				}
			}
		}
		update contacts;
	}

	public class PhysicianWrapperCls{
		@AuraEnabled
		public string phyAccId{get;set;}
		@AuraEnabled
		public string phyComment{get;set;}
		@AuraEnabled
		public string phyReason{get;set;}
	}

	@AuraEnabled
	public static List<AccountContactRelation> removeContactRelation(List<String> contactRelations, String recordId) {
		List<AccountContactRelation> conObjItem = new List<AccountContactRelation> ();
		List<AccountContactRelation> conObjList = [SELECT Id FROM AccountContactRelation WHERE Id IN: contactRelations];
		for (AccountContactRelation con: conObjList) {
			conObjItem.add(con);
		}
		if (conObjItem.size()> 0) {
			try {
				delete conObjItem;
			} catch (Exception exp) {
				throw new AuraHandledException(exp.getMessage());
			}
		}
		return getContacts(recordId);
	}

	@AuraEnabled
	public static List<AccountContactRelation> getContacts(String recordId) {
		return [
			SELECT  Id,
					AccountId,
					Account.Name,
					Account.RecordType.DeveloperName,
					ContactId,
					Contact.RecordType.DeveloperName,
					Contact.Name,
					Contact.Image_Preference_Notes__c,
					Contact.PAP__c,
					Roles,
					IsDirect,
					IsActive,
					FAX__c,
					External_ID__c,
					Phone__c,
					Contact_Email__c,
					PAP_New__c,
					Contact.Budget_Spent__c,
					Fax_Reports__c,
					Mail_Reports__c,
					Reports_Email_Address__c,
					Preferred_Reader__c,
					Contact.Physician_NPI__c
			FROM	AccountContactRelation
			WHERE   AccountId =: recordId
			AND	 Contact.RecordType.DeveloperName = 'Physicians'
		];
	}

	@AuraEnabled
	public static RIS_Requests__c createCaseRecord(
		String accountId,
		String getPhysicianUpdates,
		List<Related_Request__c> risRequestUpdates
	) {

		Account location = getLocation(accountId);
		List<Physician> listAcrsUpdate;
		if (Test.isRunningTest()) {
			listAcrsUpdate = RelatedContactControllerTest.sendPhy();
		} else {
			listAcrsUpdate = (List<Physician>) JSON.deserialize(getPhysicianUpdates, List<Physician>.class);
		}
		List<String> acrIdsUpdatedList = getAcrsIds(listAcrsUpdate); 
		Map<String, AccountContactRelation> selectedContactMap = getAcrsRecords(acrIdsUpdatedList);
		String address = getAddressLine(location);
		String type = 'Change Physician Details';
		String subject = 'Requesting to Change Physician Contact Details';
		String description = 'Changes Requested for Physicians at Location : ' + location.Name + ' ' + address;

		RIS_Requests__c createRisRequest = createRisRequest(location.Id, null, description, type, subject);
		RIS_Requests__c createdCaseResult = [SELECT Id, Name FROM RIS_Requests__c WHERE Id =: createRisRequest.Id];
		createRelatedRequest(createdCaseResult, selectedContactMap, listAcrsUpdate, risRequestUpdates);
		return createdCaseResult;
	}

	@AuraEnabled
	public static Map<String, Map<String, List<Sobject>>> checkExistsRisRequest( 
		String accountId,
		List<Id> acrIds,
		List<RemoveInfo> removeInfos
	) {
		Map<String, Map<String, List<Sobject>>> allRisReqquestMap = new  Map<String, Map<String, List<Sobject>>>();
		Map<String, List<Related_Request__c>> risRequestExists = new Map<String, List<Related_Request__c>>();
		Map<String, List<Related_Request__c>> risRequestCreated = new Map<String, List<Related_Request__c>>();
		Map<String, AccountContactRelation> acrs = getAcrsRecords(acrIds);
		Account account = [SELECT Id, Name FROM Account WHERE Id = :accountId LIMIT 1];
		Set<String> physiciancToRemove = new Set<String>();
		Set<String> newRemovedPhysicians = new Set<String>();
		for (AccountContactRelation relation : acrs.values()) {
			newRemovedPhysicians.add(String.valueOf(relation.ContactId));
		}

		Map<String, Related_Request__c> relatedPhysycianRemovedRequest = new Map<String, Related_Request__c> ([
			SELECT  Id, Name,  RIS_Request__c, RIS_Request__r.Name,Physician__r.Name 
			FROM	Related_Request__c 
			WHERE   RIS_Request__r.Status__c NOT IN ('Closed', 'Rejected')
			AND	 RIS_Request__r.Subject__c = 'Removing a Physician from a location' 
			AND	 RIS_Request__r.Type__c= 'Physician removed' 
			AND	 Status__c = null 
			AND	 Physician__c IN :newRemovedPhysicians
			AND	 RIS_Request__r.Account_Name__c = :accountId
			WITH SECURITY_ENFORCED
		]);

		if (relatedPhysycianRemovedRequest.size()>0) {
			Set<String> removedPhysicians = new Set<String>();
			for (Related_Request__c rr : relatedPhysycianRemovedRequest.values()) {
				removedPhysicians.add(String.valueOf(rr.Physician__c));
			}
	
			List<Related_Request__c> existACRtoRemove = new List<Related_Request__c>();
			risRequestExists = populateRelatedRisRequests(relatedPhysycianRemovedRequest);
			if (!removedPhysicians.containsAll(newRemovedPhysicians)) {
				for(String physId: newRemovedPhysicians){
					if(removedPhysicians.contains(physId)){
						newRemovedPhysicians.remove(physId);
					}
				}
				risRequestCreated = createRelatedRisRequests(account, newRemovedPhysicians, acrs, removeInfos);
			}
		} else {
			risRequestCreated = createRelatedRisRequests(account, newRemovedPhysicians, acrs, removeInfos);
		}

		allRisReqquestMap.put('exist', risRequestExists);
		allRisReqquestMap.put('new', risRequestCreated);

		return allRisReqquestMap;

	}

	public static Map<String, List<Related_Request__c>> populateRelatedRisRequests( Map<String, Related_Request__c> relatedPhysycianRemovedRequest) {
		Map<String, List<Related_Request__c>> relatedRisRequestPhysicianRemoveMap = new Map<String, List<Related_Request__c>>();
		for (Related_Request__c relatedRequest : relatedPhysycianRemovedRequest.values()) {
			String risRequestId = relatedRequest.RIS_Request__c;
			if (relatedRisRequestPhysicianRemoveMap.containsKey(risRequestId)) {
				relatedRisRequestPhysicianRemoveMap.get(risRequestId).add(relatedRequest);
			} else {
				relatedRisRequestPhysicianRemoveMap.put(risRequestId, new List<Related_Request__c>{relatedRequest});
			}	
		}
		return relatedRisRequestPhysicianRemoveMap;
	}

	public static Map<String, List<Related_Request__c>> createRelatedRisRequests(
		Account account, 
		Set<String> newRemovedPhysicians,
		Map<String, AccountContactRelation> acrs,
		List<RemoveInfo> removeInfos
	) {
		List<Related_Request__c> newRelatedRequests = new List<Related_Request__c>();
		String type = 'Physician removed';
		String subject = 'Removing a Physician from a location';
		String description = 'Physicians were <span style="color:#da1616; font-weight:bold;">removed</span> from ' + account.Name;
		RIS_Requests__c createRisRequest = createRisRequest(account.Id, null, description, type, subject);
		for (AccountContactRelation relation : acrs.values()) {
			if (newRemovedPhysicians.contains(relation.ContactId)) {
				RemoveInfo info = new RemoveInfo();
				for (RemoveInfo item : removeInfos) {
					if (item.contactId == relation.ContactId) {
						info = item;
						break;
					}
				}
	
				Related_Request__c newRequest = new Related_Request__c(
					RIS_Request__c = createRisRequest.Id,
					Physician__c = relation.ContactId,
					Contact_Phone__c = relation.Phone__c,
					Contact_Fax__c = relation.FAX__c,
					AcrId__c = relation.Id,
					Description__c = info.reason + ' ' + info.comment
				);
	
				newRelatedRequests.add(newRequest);
			}
		}

		insert newRelatedRequests;

		Map<String, Related_Request__c> newRelatedRequestsMap = new Map<String, Related_Request__c> ([
			SELECT  Id, Name,  RIS_Request__c, RIS_Request__r.Name, Physician__r.Name 
			FROM	Related_Request__c 
			WHERE   RIS_Request__c =: createRisRequest.Id
		   
		]);
		Map<String, List<Related_Request__c>> risRequestCreated = populateRelatedRisRequests(newRelatedRequestsMap);

		return risRequestCreated;
	}

	@AuraEnabled
	public static RIS_Requests__c createRISRequestOnACRRemove(
		String accountId,
		List<Id> acrIds,
		List<RemoveInfo> removeInfos
	) {
		List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id = :accountId];
		Map<String, AccountContactRelation> acrs = getAcrsRecords(acrIds);
		String type = 'Physician removed';
		String subject = 'Removing a Physician from a location';
		List<Related_Request__c> newRelatedRequests = new List<Related_Request__c>();
		RIS_Requests__c createRisRequest;

		if (acrIds.size() == 1) {
			String description = 'Physician were  <span style="color:#da1616; font-weight:bold;">removed</span> from ' + accounts[0].Name;// TODO: Brock should update the description
			createRisRequest = createRisRequest(accountId, acrIds[0], description, type, subject);
		} else {
			String description = 'Physicians were <span style="color:#da1616; font-weight:bold;">removed</span> from ' + accounts[0].Name;
			createRisRequest = createRisRequest(accountId, null, description, type, subject);
		}

		for (AccountContactRelation relation : acrs.values()) {
			RemoveInfo info = new RemoveInfo();

			for (RemoveInfo item : removeInfos) {
				if (item.contactId == relation.ContactId) {
					info = item;
					break;
				}
			}

			Related_Request__c newRequest = new Related_Request__c(
				RIS_Request__c = createRisRequest.Id,
				Physician__c = relation.ContactId,
				Contact_Phone__c = relation.Phone__c,
				Contact_Fax__c = relation.FAX__c,
				AcrId__c = relation.Id,
				Description__c = info.reason + ' ' + info.comment
			);

			newRelatedRequests.add(newRequest);
		}

		insert newRelatedRequests;

		return createRisRequest;
	}
	
	private static Account getLocation(String accountId) {
		return [
			SELECT  Id,
					Name,
					ShippingAddress,
					ShippingCountry,
					ShippingCity,
					ShippingStreet,
					ShippingState,
					ShippingPostalCode
			FROM	Account
			WHERE   Id =: accountId
		];
	}

	public static List<String> getAcrsIds(List<Physician> physicianList) {
		List<String> acrIdsUpdatedList = new List<String>();
		for (Physician physicianUpdate: physicianList) {
			acrIdsUpdatedList.add(physicianUpdate.key);
		}
		return acrIdsUpdatedList;
	}

	public static Map<String, AccountContactRelation> getAcrsRecords(List<String> acrsIds) {
		Map<String, AccountContactRelation> selectedContact = new Map<String, AccountContactRelation> ([
			SELECT  Id,
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
					Account.Name,
					isDirect
			FROM	AccountContactRelation
			WHERE   Id IN: acrsIds
			WITH SECURITY_ENFORCED
		]);

		return selectedContact;
	}
	
	@AuraEnabled
	public static String createRisRequestImageNotes(List<RIS_Requests__c> createRisRequestList) {
		try {
			insert createRisRequestList;		   
			return 'success';
		} catch (Exception exp) {
			system.debug('createRisRequest err' +  exp.getMessage());
			throw new AuraHandledException(exp.getMessage());
		}

	}

	public static RIS_Requests__c createRisRequest(Id accId, Id contactId, String description, String type, String subject) {
		Group selectGroup = [SELECT Id, Name, Type, DeveloperName FROM Group WHERE DeveloperName = 'RISRequest' AND Type = 'Queue'];
		RIS_Requests__c createRisRequest = new RIS_Requests__c(
			Status__c = 'New',
			Type__c = type,
			Subject__c = subject,
			Description__c = description,
			OwnerId = selectGroup.Id,
			Date_Time_opened__c = Date.today(),
			Account_Name__c = accId//,
			//ContactId__c = contactId
		);

		try {
			insert createRisRequest;
		} catch (Exception exp) {
			system.debug('createRisRequest err' +  exp.getMessage());
			throw new AuraHandledException(exp.getMessage());
		}

		return createRisRequest;
	}

	public static void createRelatedRequest(
		RIS_Requests__c createRisRequest, 
		Map <String, AccountContactRelation> selectedContact, 
		List <Physician> listAcrsUpdate,
		List<Related_Request__c> risRequestUpdates
	) {
		List<Related_Request__c> relatedRequestList = new List<Related_Request__c>();
		for (Related_Request__c createRelatedRequest: risRequestUpdates) {			   
			Related_Request__c rrs = new Related_Request__c(
				Physician__c = selectedContact.get(createRelatedRequest.AcrId__c).ContactId,
				RIS_Request__c = createRisRequest.Id,
				AcrId__c = createRelatedRequest.AcrId__c,
				Description__c = String.join(getDescription( createRelatedRequest.AcrId__c, listAcrsUpdate), '\n'),
				Contact_Fax__c = selectedContact.get(createRelatedRequest.AcrId__c).FAX__c,							 
				PAP__c = selectedContact.get(createRelatedRequest.AcrId__c).PAP__c,
				Contact_Phone__c = selectedContact.get(createRelatedRequest.AcrId__c).Phone__c,
				Preferred_Reader__c = selectedContact.get(createRelatedRequest.AcrId__c).Preferred_Reader__c,
				Image_Preference_Notes__c = selectedContact.get(createRelatedRequest.AcrId__c).Image_Preference_Notes__c,
				Email_Reports__c = selectedContact.get(createRelatedRequest.AcrId__c).Email_Reports__c,
				Contact_Phone_New__c = createRelatedRequest.Contact_Phone_New__c,
				PAP_New__c =  createRelatedRequest.PAP_New__c,
				Contact_Fax_New__c = createRelatedRequest.Contact_Fax_New__c,
				Email_Reports_New__c = createRelatedRequest.Email_Reports_New__c,
				//Image_Preference_Notes_New__c = createRelatedRequest.Image_Preference_Notes_New__c,
				Preferred_Reader_New__c = createRelatedRequest.Preferred_Reader_New__c,
				Contact_Email_New__c = createRelatedRequest.Contact_Email_New__c
			);
			relatedRequestList.add(rrs);   
		}
		try {
			insert relatedRequestList;
		} catch (Exception exp) {
			throw new AuraHandledException(exp.getMessage());
		}
	}

	@AuraEnabled
	public static Map<String, Map<String, List<Sobject>>> getRelatedRisRequests(
		String accountId,
		String moveToAccount,
		List<String> selectedACRs,
		List<Related_Request__c> risRequestUpdates
	) {
		Account location = getLocation(accountId);
		Account newLocation = getLocation(moveToAccount);
		Map<String, Map<String, List<Sobject>>> allRisRequestMap = new  Map<String, Map<String, List<Sobject>>>();
		Map<String, List<Related_Request__c>> risRequestExists = new Map<String, List<Related_Request__c>>();
		Map<String, List<Related_Request__c>> risRequestCreated = new Map<String, List<Related_Request__c>>();
		Map<String, AccountContactRelation> selectedContactMap = getAcrsRecords(selectedACRs);
		Account account = [SELECT Id, Name FROM Account WHERE Id = :accountId LIMIT 1];
		Set<String> physiciancToRemove = new Set<String>();
		Set<String> newMovedPhysicians = new Set<String>();
		for (AccountContactRelation relation : selectedContactMap.values()) {
			newMovedPhysicians.add(String.valueOf(relation.ContactId));
		}

		Map<String, Related_Request__c> relatedPhysycianMovedRequest = new Map<String, Related_Request__c> ([
			SELECT  Id, Name,  RIS_Request__c, RIS_Request__r.Name, Physician__r.Name 
			FROM	Related_Request__c 
			WHERE   RIS_Request__r.Status__c NOT IN ('Closed', 'Rejected')
			AND	 RIS_Request__r.Subject__c = 'Moving Physicians' 
			AND	 RIS_Request__r.Type__c= 'Moving Physicians'
			AND	 Physician__c IN :newMovedPhysicians
			AND	 RIS_Request__r.Account_Name__c = :accountId
			AND	 Future_Practice_Location__c = :moveToAccount  
		]);

		if (relatedPhysycianMovedRequest.size()>0) {
			Set<String> movedPhysicians = new Set<String>();
			for (Related_Request__c rr : relatedPhysycianMovedRequest.values()) {
				movedPhysicians.add(String.valueOf(rr.Physician__c));
			}
	
			List<Related_Request__c> existACRtoMove = new List<Related_Request__c>();
			risRequestExists = populateRelatedRisRequests(relatedPhysycianMovedRequest);
			if (!movedPhysicians.containsAll(newMovedPhysicians)) {
				for(String physId: newMovedPhysicians){
					if(movedPhysicians.contains(physId)){
						newMovedPhysicians.remove(physId);
					}
				}
				risRequestCreated = createMovePhysicianRequest(location, newLocation, moveToAccount, newMovedPhysicians, selectedContactMap, risRequestUpdates);
			}
		} else {
			risRequestCreated = createMovePhysicianRequest(location, newLocation, moveToAccount, newMovedPhysicians, selectedContactMap, risRequestUpdates);
		}

		allRisRequestMap.put('exist', risRequestExists);
		allRisRequestMap.put('new', risRequestCreated);
		
		return allRisRequestMap;
	}

	public static Map<String, List<Related_Request__c>> createMovePhysicianRequest(
		Account location,
		Account newLocation,
		String moveToAccount,
		Set<String> movedPhysicians,
		Map<String, AccountContactRelation> selectedContactMap,			
		List<Related_Request__c> risRequestUpdates
	) {
		String address = getAddressLine(location);
		String newAddress = getAddressLine(newLocation);
		String type = 'Moving Physicians';
		String subject = 'Moving Physicians';
		String description = '<p>Physicians are being moved </p> <p>from <strong>' + location.Name + '</strong> ' + address + '</p><p>to : <strong style="color: rgb(47, 17, 195);"><a href=/' + newLocation.Id + '>'+  newLocation.Name + '</a></strong> ' + newAddress;

		RIS_Requests__c createRisRequest = createRisRequest(location.Id, null, description, type, subject);

		RIS_Requests__c createdCaseResult = [SELECT Id, Name FROM RIS_Requests__c WHERE Id =: createRisRequest.Id];
		if (!risRequestUpdates.isEmpty()) {			
			List<Related_Request__c> relatedRequestList = new List<Related_Request__c>();			
			for (Related_Request__c createRelatedRequest: risRequestUpdates) {
				if (movedPhysicians.contains(selectedContactMap.get(createRelatedRequest.AcrId__c).ContactId)) {
				Related_Request__c rrs = new Related_Request__c(
					Physician__c = selectedContactMap.get(createRelatedRequest.AcrId__c).ContactId,
					RIS_Request__c = createRisRequest.Id,
					AcrId__c = createRelatedRequest.AcrId__c,
					isDirect__c = selectedContactMap.get(createRelatedRequest.AcrId__c).IsDirect,
					Future_Practice_Location__c = moveToAccount,
					//Description__c = String.join(getDescription( createRelatedRequest.AcrId__c, listAcrsUpdate), '\n'),
					Contact_Fax__c = selectedContactMap.get(createRelatedRequest.AcrId__c).FAX__c,							 
					PAP__c = selectedContactMap.get(createRelatedRequest.AcrId__c).PAP__c,
					Contact_Phone__c = selectedContactMap.get(createRelatedRequest.AcrId__c).Phone__c,
					Preferred_Reader__c = selectedContactMap.get(createRelatedRequest.AcrId__c).Preferred_Reader__c,
					Image_Preference_Notes__c = selectedContactMap.get(createRelatedRequest.AcrId__c).Image_Preference_Notes__c,
					Email_Reports__c = selectedContactMap.get(createRelatedRequest.AcrId__c).Email_Reports__c,
					Contact_Phone_New__c =  createRelatedRequest.Contact_Phone_New__c,
					PAP_New__c =  createRelatedRequest.PAP_New__c,
					Contact_Fax_New__c = createRelatedRequest.Contact_Fax_New__c,
					Email_Reports_New__c =  createRelatedRequest.Email_Reports_New__c,
					//Image_Preference_Notes_New__c =  createRelatedRequest.Image_Preference_Notes_New__c,
					Preferred_Reader_New__c =  createRelatedRequest.Preferred_Reader_New__c
				);

				relatedRequestList.add(rrs); 
				}
			}
			insert relatedRequestList;
		}

		Map<String, Related_Request__c> newRelatedRequestsMap = new Map<String, Related_Request__c> ([
			SELECT  Id, Name,  RIS_Request__c, RIS_Request__r.Name, Physician__r.Name 
			FROM	Related_Request__c 
			WHERE   RIS_Request__c =: createRisRequest.Id
		]);
		Map<String, List<Related_Request__c>> risRequestCreated = populateRelatedRisRequests(newRelatedRequestsMap);
		return risRequestCreated;
	}

	@AuraEnabled
	public static String movePhysiciansToLocation(
		String accountId,
		String moveToAccount,
		List<String> selectedACRs,	
		List<Related_Request__c> risRequestUpdates
	) {
		Account location = getLocation(accountId);
		Account newLocation = getLocation(moveToAccount);
		Map<String, AccountContactRelation> selectedContactMap = getAcrsRecords(selectedACRs);

		List<AccountContactRelation> acrToRemove = new List<AccountContactRelation>();
		List<AccountContactRelation> acrToCreate = new List<AccountContactRelation>();
		List<Related_Request__c> directRelationToUpdate = new List<Related_Request__c>();
		Map<Id, Id> contactIdToAccountUpdate = new Map<Id, Id>();

		for (Related_Request__c createRelatedRequest: risRequestUpdates) {		  
			if (selectedContactMap.get(createRelatedRequest.AcrId__c).IsDirect) {
				contactIdToAccountUpdate.put(createRelatedRequest.Physician__c, moveToAccount);
			} else {
				acrToRemove.add(new AccountContactRelation(Id = createRelatedRequest.AcrId__c));
				acrToCreate.add(populateACRtoCreate(createRelatedRequest, moveToAccount));
			}	

		}
		if (!contactIdToAccountUpdate.isEmpty() && contactIdToAccountUpdate != null) {
			updateContacts(contactIdToAccountUpdate);
		}
		try {
			insert acrToCreate;
			delete acrToRemove;
			return 'success';
		} catch (Exception exp) {
			throw new AuraHandledException(exp.getMessage());
		}
	}

	public static AccountContactRelation populateACRtoCreate(Related_Request__c relatedRequest, String moveToAccount) {
		AccountContactRelation acr = new AccountContactRelation (
			ContactId = Id.valueOf(relatedRequest.Physician__c),
			AccountId = Id.valueOf(moveToAccount),
			Phone__c = (relatedRequest.Contact_Phone_New__c != null ) ? relatedRequest.Contact_Phone_New__c : relatedRequest.Contact_Phone__c,
			FAX__c = (relatedRequest.Contact_Fax_New__c != null ) ?relatedRequest.Contact_Fax_New__c : relatedRequest.Contact_Fax__c,
			PAP__c = relatedRequest.PAP_New__c,
			Preferred_Reader__c = (relatedRequest.Preferred_Reader_New__c != null ) ? relatedRequest.Preferred_Reader_New__c : relatedRequest.Preferred_Reader__c,
			//Image_Preference_Notes__c = (relatedRequest.Image_Preference_Notes_New__c != null ) ? relatedRequest.Image_Preference_Notes_New__c : relatedRequest.Image_Preference_Notes__c,
			Email_Reports__c = relatedRequest.Email_Reports_New__c				
		);
		return acr;
	}

	public static void updateContacts(Map<Id, Id> contactIdToAccountUpdate) {
		List<Contact> getDirectContacts = [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIdToAccountUpdate.keySet()];
		List<Contact> contactsToUpdate = new  List<Contact>();
		for (Id contactId : contactIdToAccountUpdate.keySet()) {
			contactsToUpdate.add(new Contact (Id =contactId, AccountId = contactIdToAccountUpdate.get(contactId)));
		}
		update contactsToUpdate;
	}


	public static List<String> getDescription(String acrValue, List <Physician> listAcrsUpdate) {
		List<String> returnDescription = new List<String>();
		for (Physician phys : listAcrsUpdate) {
			if (phys.key == acrValue) {
				return phys.value;
			}
		}
		return returnDescription;
	}

	public static String getAddressLine(Account location){
		String address = (location.ShippingStreet != null ? location.ShippingStreet : ' ') +
			+' ' + (location.ShippingCity != null ? location.ShippingCity : ' ') +
			+' ' + (location.ShippingState != null ? location.ShippingState : ' ') +
			+' ' + (location.ShippingPostalCode != null ? location.ShippingPostalCode : ' ') +
			+' ' + (location.ShippingCountry != null ? location.ShippingCountry : '');
			return  address;
	}
	
	public class RemoveInfo {
		@AuraEnabled
		public Id contactId {get;set;}
		@AuraEnabled
		public String reason {get;set;}
		@AuraEnabled
		public String comment {get;set;}
	}

	public class Physician {
		@AuraEnabled
		public String key;
		@AuraEnabled
		public List<String> value;
	}

	@AuraEnabled
	public static List<ResultWrapper> fetchRecords(SearchWrapper inputWrapper) {
		String Practice_Location = 'Practice_Location';
		try {
			if(inputWrapper != null){
				String fieldsToQuery = 'SELECT Id, Name, ShippingAddress, ShippingCountry, ShippingCity, ShippingStreet, ShippingState,ShippingPostalCode';
				
				String query = fieldsToQuery + ' FROM Account';
				query += ' WHERE Id !=' + '\'' + inputWrapper.selectedRecordId + '\'';
				query += ' AND RecordType.DeveloperName ='+ '\'' + Practice_Location + '\'';
				String filterCriteria = 'Name LIKE ' + '\'' + String.escapeSingleQuotes(inputWrapper.searchString.trim()) + '%\' LIMIT 10';
				if(String.isNotBlank(filterCriteria)) {
					query += ' AND ' + filterCriteria;
				}
				List<ResultWrapper> returnWrapperList = new List<ResultWrapper>();
				String accountIcon = 'standard:account';
				Account[] accounts = (List<Account>) Database.query(query);
				for(Account resultAccount :accounts) {
					ResultWrapper wrap = new ResultWrapper();
					String subtitle = resultAccount.ShippingStreet == null ? '' : ' • ' + resultAccount.ShippingStreet;
					subtitle += resultAccount.ShippingCity == null ? '' : ', ' + resultAccount.ShippingCity;
					subtitle += resultAccount.ShippingPostalCode == null ? '' : ', ' + resultAccount.ShippingPostalCode;
					wrap.mainField = resultAccount.Name;
					wrap.subField = subtitle;
					wrap.id = resultAccount.Id;
					wrap.iconName = accountIcon;
					returnWrapperList.add(wrap);
				}
				return returnWrapperList;
			}
			return null;
		} catch (Exception err) {
			throw new AuraHandledException(err.getMessage());
		}
	}

	public class ResultWrapper{
		@AuraEnabled public String mainField{get;set;}
		@AuraEnabled public String subField{get;set;}
		@AuraEnabled public String id{get;set;}
		@AuraEnabled public String iconName{get;set;}
	}

	public class SearchWrapper {
		@AuraEnabled public String objectApiName{get;set;}
		@AuraEnabled public String fieldApiName{get;set;}
		@AuraEnabled public String searchString{get;set;}
		@AuraEnabled public String selectedRecordId{get;set;}
	}
}
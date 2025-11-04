public without sharing class RISRequestTriggerHelper {

	public final static String CLOSED_STATUS = 'Closed';
	public final static String REJECTED_STATUS = 'Rejected';
	public final static String PAP_SUBMISSION_TYPE = 'PAP Submission';
	public final static String IMAGE_PREFERENCE_NOTES_TYPE = 'Image preference notes';
	public final static String PRIVATE_CONTACT_TYPE = 'Private Contact';

	public static void closedPAPSubmission(List<RIS_Requests__c> newRISRequests, Map<Id, RIS_Requests__c> oldRIsRequestMap) {
		List<RIS_Requests__c> setClosedStatus = new List<RIS_Requests__c>();
		Set<String> contactIdsPAPtoTrue = new set<String>();	

		for (RIS_Requests__c newRisRequest : newRISRequests) {
			if (oldRIsRequestMap != null) {
				RIS_Requests__c previousRisRequest = oldRIsRequestMap.get(newRisRequest.Id);
				if (newRisRequest.Status__c != previousRisRequest.Status__c && newRisRequest.Type__c == PAP_SUBMISSION_TYPE) {
					if (newRisRequest.Status__c == CLOSED_STATUS) {
						setClosedStatus.add(newRisRequest);
						contactIdsPAPtoTrue.addAll(newRisRequest.Physicians_PAP_List__c.split(';') );
					}

				}
			}
		}
		
		if (!contactIdsPAPtoTrue.isEmpty()) {
			List<Contact> contactToUpdatePAP = new List<Contact>();
			for (String contactId : contactIdsPAPtoTrue) {
				contactToUpdatePAP.add(new COntact (Id = Id.valueOf(contactId), PAP__c = true));
			}

			update contactToUpdatePAP;
		}

	}

public static void closedImagePreferenceNotes(List<RIS_Requests__c> newRISRequests, Map<Id, RIS_Requests__c> oldRIsRequestMap) {
		List<RIS_Requests__c> setClosedStatus = new List<RIS_Requests__c>();
		List<Contact> contactToImagePrefNotes = new List<Contact>();
		for (RIS_Requests__c newRisRequest : newRISRequests) {
			if (oldRIsRequestMap != null) {
				RIS_Requests__c previousRisRequest = oldRIsRequestMap.get(newRisRequest.Id);
				if (newRisRequest.Status__c != previousRisRequest.Status__c && newRisRequest.Type__c == IMAGE_PREFERENCE_NOTES_TYPE) {
					if (newRisRequest.Status__c == CLOSED_STATUS && newRisRequest.ContactId__c != null) {
						contactToImagePrefNotes.add(new Contact (Id = newRisRequest.ContactId__c, Image_Preference_Notes__c = newRisRequest.New_Image_Preference_Notes__c));
					}

				}
			}
		}
		
		if (!contactToImagePrefNotes.isEmpty()) {
			update contactToImagePrefNotes;
		}

	}

	public static void closedPrivateContacts(List<RIS_Requests__c> newRISRequests, Map<Id, RIS_Requests__c> oldRIsRequestMap) {
		List<RIS_Requests__c> setClosedStatus = new List<RIS_Requests__c>();
		Set<Id> privateContacts = new Set<Id>();
		for (RIS_Requests__c newRisRequest : newRISRequests) {
			if (oldRIsRequestMap != null) {
				RIS_Requests__c previousRisRequest = oldRIsRequestMap.get(newRisRequest.Id);
				if (newRisRequest.Status__c != previousRisRequest.Status__c && newRisRequest.Type__c == PRIVATE_CONTACT_TYPE) {
					if (newRisRequest.Status__c == CLOSED_STATUS && newRisRequest.ContactId__c != null) {
						privateContacts.add(newRisRequest.ContactId__c);
					}
				}
			}
		}

		List<Contact> approvedContacts = [SELECT Id, Physician_NPI__c FROM Contact WHERE Id IN :privateContacts];
		for (Contact contact : approvedContacts) {
			Map<String, Object> requestBody = new Map<String, Object>{
				'npi' => contact.Physician_NPI__c,
				'ris_server' => 'FL'
			};
			sendToEnpSnowflacke(JSON.serialize(requestBody));
		}
	}

	@future(callout=true)
	public static void sendToEnpSnowflacke(String requestBody) {
		HttpRequest req = new HttpRequest();
		req.setEndpoint('callout:TriggerFastAPI/trigger-physician');
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/json');
		req.setBody(requestBody);
		req.setTimeout(120000); 
		Http http = new Http();
		try {
			HttpResponse res = http.send(req);
		} catch (Exception e) {
			System.debug('Error sending to ENP Snowflake: ' + e.getMessage());
		}
	}
}
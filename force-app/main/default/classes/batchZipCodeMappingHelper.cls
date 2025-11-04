public class batchZipCodeMappingHelper {
	
	public static Set<String> collectCompetitionZipCodes(List<Competition__c> competitions) {
		Set<String> listZipCodes = new Set<String>();
		for(Competition__c competition : competitions){
			listZipCodes.add(competition.Address__PostalCode__s);		
		}
        system.debug('listZipCodes ' + listZipCodes);
		return listZipCodes;
	}
	
	public static List<Account> collectAccountZipCodes(Set<String> competitionZipCodes) {
		return [SELECT Id, ShippingPostalCode FROM Account WHERE ShippingPostalCode IN : competitionZipCodes LIMIT 50000];
	}

	public static List<Competition__c> collectCompetitiveWithZipCodes(Set<String> competitionZipCodes) {
		return [SELECT Id, Address__PostalCode__s FROM Competition__c WHERE Address__PostalCode__s IN : competitionZipCodes LIMIT 50000];
	}

	public static List<Account_Competition_Relationship__c> collectAccountCompetitionRelationship() {
		return [
			SELECT 	Id,
					Related_Competition__c, 
					Related_Competition__r.Address__PostalCode__s, 
					Related_Account__c, 
					Related_Account__r.ShippingPostalCode
			FROM 	Account_Competition_Relationship__c 
			WHERE 	Related_Competition__r.Address__PostalCode__s != null 
			AND 	Related_Account__r.ShippingPostalCode != null
		];
	}
	
	public static List<Account_Competition_Relationship__c> populateAccountCompetitionRelationship(
		List<Competition__c> competitions,
		List<Account> accounts,
		List<Account_Competition_Relationship__c> existAccountCompetitionRelationship
	) {
		Map<String, String> existAccountCompetitiveMap = new Map<String, String>();
		Map<String, List<String>> postalCodeWithAccountIds = groupRecords('ShippingPostalCode', accounts );
        system.debug('postalCodeWithAccountIds ' + postalCodeWithAccountIds);

		for(Account_Competition_Relationship__c acr : existAccountCompetitionRelationship) {
			String keyAccountCompetitive = acr.Related_Competition__c +'-' + acr.Related_Account__c;
			if(!existAccountCompetitiveMap.containsKey(keyAccountCompetitive)){
				existAccountCompetitiveMap.put(keyAccountCompetitive, acr.Id);
			}
		}

        system.debug('existAccountCompetitiveMap ' + existAccountCompetitiveMap);
		List<Account_Competition_Relationship__c> createAccountCompetitiveRelations = new List<Account_Competition_Relationship__c>();
		Map<String, List<String>> comepetitiveIdToAccountIdsMap = new Map<String, List<String>>();
		
		for(Competition__c acr : competitions) {
			String key = acr.Address__PostalCode__s;
			if (postalCodeWithAccountIds.containsKey( key )) {                
				comepetitiveIdToAccountIdsMap.put( acr.Id, postalCodeWithAccountIds.get(key));
			}
		}

		for(String competitiveId : comepetitiveIdToAccountIdsMap.keySet()) {
			for(String accountId : comepetitiveIdToAccountIdsMap.get(competitiveId)){				
				String keyRelationToInsert = competitiveId +'-' + accountId;
				if (existAccountCompetitiveMap == null || existAccountCompetitiveMap.isEmpty()) {
                    if(!existAccountCompetitiveMap.containsKey( keyRelationToInsert )) {
                        createAccountCompetitiveRelations.add(
                            new Account_Competition_Relationship__c(
                                Related_Account__c = accountId,
                                Related_Competition__c = competitiveId
                            )
                        );
                    }
                } else {
                    if(!existAccountCompetitiveMap.containsKey( keyRelationToInsert )) {
                        createAccountCompetitiveRelations.add(
                            new Account_Competition_Relationship__c(
                                Related_Account__c = accountId,
                                Related_Competition__c = competitiveId
                            )
                        );
                    }
                }
               
			}
		}
        system.debug('createAccountCompetitiveRelations ' + createAccountCompetitiveRelations);
		return createAccountCompetitiveRelations;
	}

	public static Map<String, List<String>> groupRecords(String field, List<Account> records ) {
		Map<String, List<String>> returnMap = new Map<String, List<String>>();
		for ( Account record : records ) {
			String key = (String)record.get( field );
			if (!returnMap.containsKey( key ))
				returnMap.put( key, new List<String> ());
			returnMap.get( key ).add( record.Id );
		}
		return returnMap;
	}
	/**   Map<Id,List<Account>> franchiseToAccounts = group('ShippingPostalCode', [
			SELECT ShippingPostalCode
			FROM Account 
			WHERE ShippingPostalCode IN (:franchise_accounts)
	]); */
}
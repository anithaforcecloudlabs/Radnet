public with sharing class LwcRenamePracticeLocationController {

	private static final Id PRACTICE_LOCATION = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Practice_Location').getRecordTypeId();
    private static final Id PRACTICE_OVERVIEW = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Practice_Overview').getRecordTypeId();
	
	@AuraEnabled(cacheable=true)
	public static List<Account> searchPracticeLocations(SearchPracticeLocations searchPracticeLoc) {
		List <Account> matchingAccountList = new List<Account>();
		String filterCriteria = 'Latitude__c LIKE ' + '\'' + '%'  + String.escapeSingleQuotes(searchPracticeLoc.matchingLatitude.trim()) +  '%'  + '\'';	
		String filterCriteria2 = 'Longitude__c LIKE ' + '\''  + '%'  + String.escapeSingleQuotes(searchPracticeLoc.matchingLongitude.trim()) +  '%'  +  '\'';
		String fieldsToQuery = 'SELECT  Id, Name, ShippingPostalCode, ShippingCity, ShippingStreet, Practice_Overview__c, Practice_Overview__r.Name, Latitude__c,Longitude__c, RIS_Server__c';
		String query = fieldsToQuery + ' FROM Account ';
		query += ' WHERE ' + filterCriteria + ' and ' + filterCriteria2;
		query += ' AND Practice_Overview__c =' + '\'' + searchPracticeLoc.selectedPracticeOverviewId + '\'';
		query += ' AND RecordTypeId ='+ '\'' + PRACTICE_LOCATION + '\'';
		matchingAccountList = (List<Account>) Database.query(query);		
		return matchingAccountList;		
	}

	@AuraEnabled
	public static List<ResultWrapper> fetchPracticeOverviewAccounts(SearchWrapper inputWrapper) {
		try {
			if(inputWrapper != null){
				String fieldsToQuery = 'SELECT Id, Name, Referring_Practice_Key__c, RIS_Server__c';				
				String query = fieldsToQuery + ' FROM Account';				
				query += ' WHERE RecordTypeId ='+ '\'' + PRACTICE_OVERVIEW + '\'';				
				String filterCriteria = 'Name LIKE ' + '\'' + String.escapeSingleQuotes(inputWrapper.searchString.trim()) +  '%'  +  '\'' +'LIMIT 50';
				if(String.isNotBlank(filterCriteria)) {
					query += ' AND ' + filterCriteria;
				}
				List<ResultWrapper> returnWrapperList = new List<ResultWrapper>();
				String accountIcon = 'standard:query';
				Account[] accounts = (List<Account>) Database.query(query);
				for(Account resultAccount :accounts) {
					ResultWrapper wrap = new ResultWrapper();
					String subtitle = resultAccount.Referring_Practice_Key__c;
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

	@AuraEnabled
	public static List<RIS_Requests__c> getRelatedRisRequests(List<String> selectedAccountIds, String risRequestType) {
		List<RIS_Requests__c> relatedMergeRisRequesrs = [
			SELECT  Id, Name, Account_Name__c, Account_Name__r.Name
			FROM	RIS_Requests__c 
			WHERE   Status__c NOT IN ('Closed', 'Rejected')
			AND	 	Type__c = :risRequestType
			AND	 	Account_Name__c IN :selectedAccountIds
			WITH 	SECURITY_ENFORCED
		];
		
		return relatedMergeRisRequesrs;
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

	public class SearchPracticeLocations {
		@AuraEnabled public String matchingLatitude{get;set;}
		@AuraEnabled public String matchingLongitude{get;set;}
		@AuraEnabled public String selectedPracticeOverviewId{get;set;}
	}
}
@IsTest
public class LwcRelatedPhysiciansTest {

    @IsTest
    static void getContactsShouldReturnACRS() {
        List<Account> accs = TestDataFactory.returnAccounts(1, 'Practice_Overview');
        insert accs;

        List<Contact> contacts = TestDataFactory.returnContacts(1, 'Physicians', new Set<Id>{accs[0].Id});
        insert contacts;

        RIS_Requests__c risRequests = new RIS_Requests__c(
            Account_Name__c = accs[0].Id
        );

        insert risRequests;

        List<AccountContactRelation> acrs = LwcRelatedPhysiciansAPX.getContacts(risRequests.Id);

        System.assert(!acrs.isEmpty());
    }

    @IsTest
    static void getContactsCountShouldReturnInteger() {
        List<Account> accs = TestDataFactory.returnAccounts(1, 'Practice_Overview');
        insert accs;

        List<Contact> contacts = TestDataFactory.returnContacts(1, 'Physicians', new Set<Id>{accs[0].Id});
        insert contacts;

        RIS_Requests__c risRequests = new RIS_Requests__c(
            Account_Name__c = accs[0].Id
        );

        insert risRequests;

        Integer count = LwcRelatedPhysiciansAPX.getContactsCount(risRequests.Id);

        System.assert(count == 1);
    }
}
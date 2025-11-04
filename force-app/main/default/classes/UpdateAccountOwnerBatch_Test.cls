@isTest
public class UpdateAccountOwnerBatch_Test {
    @isTest static void testAccount(){
        Account acc = new Account(Name='test');
        insert acc;
        
        Task tsk1 = new Task(WhatId = acc.Id, Subject = 'Email: apex test', ActivityDate = date.today(), Status = 'Completed');
Task tsk2 = new Task(WhatId = acc.Id, Subject = 'Call: apex test', ActivityDate = date.today(), Status = 'Completed');
Task tsk3 = new Task(WhatId = acc.Id, Subject = 'Email: apex test', ActivityDate = date.today().addYears(-2), Status = 'Completed');
Task[] tskList = new List<Task>{ tsk1, tsk2, tsk3 };
insert tskList;
        
        
        System.debug('acc'+acc);
        System.debug('task'+tskList);
        
        Test.startTest();
        UpdateAccountOwnerBatch ba = new UpdateAccountOwnerBatch();
        Database.executeBatch(ba);
        Test.stopTest();
    }
}
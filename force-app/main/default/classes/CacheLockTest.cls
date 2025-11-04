/*
* ***************************************************************************************************************************
* Apex Class Name - CacheLockTest
* Version - 0.1
* Created Date - 21-Jan-2024
* @description : Test class for CacheLock class.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-1501                   21-Jan-2025         Added test method testCacheLock.
* ************************************************************************************************************************************
*/
@IsTest
public class CacheLockTest {
    @IsTest
    static void testCacheLock() {
        Test.startTest();

        CacheLock cacheLock = new CacheLock('local.five9analytics', 'test');
        cacheLock.lock();
        Assert.areEqual(true, cacheLock.isLocked(), 'cache lock must be locked');

        cacheLock.unlock();
        Assert.areEqual(false, cacheLock.isLocked(), 'cache lock must be unlocked');

        Long startTime = Datetime.now().getTime();
        cacheLock.lock();
        while (Datetime.now().getTime() < startTime + 6000) {}
        Assert.areEqual(false, cacheLock.isLocked(), 'cache lock must expire');

        Test.stopTest();
    }
}
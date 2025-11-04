/*
* ***************************************************************************************************************************
* Apex Class Name - CacheLock
* Version - 0.1
* Created Date - 21-Jan-2024
* @description       : Class for implementation of Platform Cache for Five9
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                    Date                 Description
* ----------------         --------------       ---------------------
* CC-1501                   21-Jan-2025         Enhancements for all Five9 BYOT functions 
* ************************************************************************************************************************************
*/
public class CacheLock {
    private static final Integer CACHE_EXPIRY_LOCK = 5;
    private static final Integer CACHE_EXPIRY_LOCK_DEFAULT = 300;

    private Cache.OrgPartition cachePartition;
    private String cacheLockKey;

    public CacheLock(String partition, String key) {
        this.cachePartition = Cache.Org.getPartition(partition);

        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(key));
        this.cacheLockKey = EncodingUtil.convertToHex(hash);
    }

    public Boolean isLocked() {
        if (this.cachePartition.contains(cacheLockKey)) {
            Long lockSetTime = (Long) this.cachePartition.get(cacheLockKey);
            if (Datetime.now().getTime() - lockSetTime < CACHE_EXPIRY_LOCK * 1000) {
                return true;
            }
            unlock();
        }
        return false;
    }

    public void lock() {
        this.cachePartition.put(cacheLockKey, Datetime.now().getTime(), CACHE_EXPIRY_LOCK_DEFAULT, Cache.Visibility.ALL, false);
    }

    public void unlock() {
        this.cachePartition.remove(cacheLockKey);
    }
}
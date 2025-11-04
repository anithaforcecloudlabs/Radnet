public class SearchPhoneDirectoryApex {
	@AuraEnabled(cacheable=true)
    public static List<String> getRegion()
    {
        List<String> region = new List<String>();
        List<Phone_Directory__c> regionList = [SELECT Region__c from Phone_Directory__c] ;
        for(Phone_Directory__c r :regionList){
            if(!region.contains(r.Region__c))
            	region.add(r.Region__c);
        }
        return region ;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getEntryPointName()
    {
        List<String> entryPointName = new List<String>();
        List<Phone_Directory__c> entryPointNameList = [SELECT Entry_Point_Name__c from Phone_Directory__c] ;
        for(Phone_Directory__c r : entryPointNameList){
            entryPointName.add(r.Entry_Point_Name__c);
        }
        return entryPointName ;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Phone_Directory__c> getRecords(String reg, String entry)
    {
        System.debug(reg+' '+entry);
        List<Phone_Directory__c> records;
        if(reg!=null && entry!=null)
        	records=[select Entry_Point_Name__c,Region__c,Phone_Number__c,Comments__c from Phone_Directory__c where Region__c=:reg AND Entry_Point_Name__c=:entry];
        else if(reg==null && entry!=null)
            records=[select Entry_Point_Name__c,Region__c,Phone_Number__c,Comments__c from Phone_Directory__c where Entry_Point_Name__c=:entry];
        else if(reg!=null && entry==null)
            records=[select Entry_Point_Name__c,Region__c,Phone_Number__c,Comments__c from Phone_Directory__c where Region__c=:reg];
        else
            records=[select Entry_Point_Name__c,Region__c,Phone_Number__c,Comments__c from Phone_Directory__c];
        System.debug(records);
        return records ;
    }
}
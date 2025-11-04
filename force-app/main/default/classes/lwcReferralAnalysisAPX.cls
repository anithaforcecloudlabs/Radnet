public with sharing class lwcReferralAnalysisAPX {

    @AuraEnabled
    public static List<Contact> getPhysicianAPX(string recordId){
        List<Contact> listPhyConRecs = new List<Contact>();
        if(recordId != null && recordId != ''){
            listPhyConRecs = [
                SELECT  Physician_NPI__c
                FROM    Contact
                WHERE   Id =: recordId
                AND     Physician_NPI__c != null
                LIMIT 1
            ];
        }
        return listPhyConRecs;
    }

    @AuraEnabled
    public static string getReferralsFromIntegrationPlatformAPX(String objectApiName, String payloadToPOST){
        string respBody = '';
        if(objectApiName != null && objectApiName != ''){
            if(objectApiName=='Contact'){
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:AWS_Radnet_Referrals/dev/radnet/physicians');
                req.setMethod('POST');
                req.setBody(payloadToPOST);               
                req.setTimeout(20000);
                Http http = new Http();
                HttpResponse res = http.send(req);               
                if(res.getStatusCode() == 200){                   
                    respBody = res.getBody();
                }
            } else if(objectApiName == 'Account'){
                HttpRequest req = new HttpRequest();                      
                req.setEndpoint('callout:AWS_Radnet_Referrals/dev/radnet/locations');
                req.setMethod('POST');
                req.setBody(payloadToPOST);
                req.setTimeout(20000);
                Http http = new Http();
                HttpResponse res = http.send(req);
                if(res.getStatusCode() == 200){                   
                    respBody = res.getBody();
                }
            }
        }
        return respBody;
    }
}
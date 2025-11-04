public with sharing class lwcSolomoSurfacePageAPX {
    
    @AuraEnabled
    public static UserCls getUserInfoApx(){
        List<Organization> listOrganizations = [Select Id,IsSandbox 
        FROM Organization
        ];
        UserCls usrClsRec = new UserCls();
        usrClsRec.userId = UserInfo.getUserId();
        usrClsRec.userName = UserInfo.getUserName();
        usrClsRec.sessionId = UserInfo.getSessionId();
        usrClsRec.orgId = UserInfo.getOrganizationId();
        usrClsRec.prodVal = 0;
        if(listOrganizations!=null && !listOrganizations.isEmpty() && listOrganizations[0].IsSandbox==false){
            usrClsRec.prodVal = 1;
        }
        return usrClsRec;
    }

    public class UserCls{
        @AuraEnabled
        public string userId;
        @AuraEnabled
        public string userName;
        @AuraEnabled
        public string sessionId;
        @AuraEnabled
        public string orgId;
        @AuraEnabled
        public integer prodVal;
    }
}
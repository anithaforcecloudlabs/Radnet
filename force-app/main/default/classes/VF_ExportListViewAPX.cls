public with sharing class VF_ExportListViewAPX {
    
    public string listViewId{get;set;}
    public VF_ExportListViewAPX(ApexPages.StandardSetController stdSetCon){
        this.listViewId = stdSetCon.getFilterId();
    }

    public PageReference redirectToExportListView(){
        system.debug('this.listViewId = ' + this.listViewId);
        // PageReference pgRef = new PageReference('http://localhost:8501/?session_id='+UserInfo.getSessionId()+ '&username=solomo@radnet.dev.salesdpro&prod=0&orgId=00DVG000001WQq12AG&listviewId='+this.listViewId);
        PageReference pgRef = new PageReference('/lightning/n/Downloader?c__listviewId='+this.listViewId);
        pgRef.setRedirect(true);
        return pgRef;
    }
}
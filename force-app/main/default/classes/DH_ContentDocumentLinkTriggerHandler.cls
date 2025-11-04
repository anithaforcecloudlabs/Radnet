/*

*********************************************************

Apex Class         : DH_ContentDocumentLinkTriggerHandler

Created Date       : 19-07-2024

@description       : Handler Class for DH_ContentDocumentLinkTrigger

@jiraid            : CC-949

*********************************************************

*/
public with sharing class DH_ContentDocumentLinkTriggerHandler {
    /**
    * @description                             This method is used to update the visibility from 'Internal' to 'External' 
    * @param          cdlList                  List of ContentDocumentLink object to update the visiblity
    **/
	public static void updateVisibility(List<ContentDocumentLink> cdlList){
        for(ContentDocumentLink cdl : cdlList){
            if(cdl.Visibility == DH_KMConstants.INTERNALUSERS){
                cdl.Visibility = DH_KMConstants.ALLUSERS;
            }
        }
    }
}
/******************************************************************************************************************************************************
 * 
 * LWC Component Name : PreviewFileThumbnails
 * 
 * Created Date    :   4/15/2024
 * 
 * @description    : This class serves as a container for displaying all the site images 
 * 
 * @Jira Id        : CC-236
 * */
import { LightningElement, wire, api, track } from "lwc";
//import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getFileVersions from "@salesforce/apex/DH_LinkSiteImages.getVersionFiles";

export default class PreviewFileThumbnails extends LightningElement {
  loaded = false;
  @track fileList;
  @api recordId;
  @track files = [];
  get acceptedFormats() { 
    return [".pdf", ".png", ".jpg", ".jpeg"];
  }
  @track sitePageMap=[];
  @track lexOrigin;



  connectedCallback(){
    // fetches recordId from url for guest user
    const origin = window.location.origin;
    if(origin.endsWith('site.com')){
      const url = window.location.href;
      const regex = /\/account\/([a-zA-Z0-9]{18}|[a-zA-Z0-9]{15})\//;
      const matches = url.match(regex);
      if(matches && matches.length > 1){
        this.recordId = matches[1];
      }
    }

    //this method is used to fetch all the images of the site
    getFileVersions({recordId : this.recordId})
    .then(data => {

      this.fileList = "";
      this.files = [];
      if (data) {
        this.fileList = data;
        for (let i = 0; i < this.fileList.length; i++) {
          let file;
          if(window.location.origin.endsWith('site.com')){
            file = {
              Id: this.fileList[i].Id,
              Title: this.fileList[i].Title,
              Extension: this.fileList[i].FileExtension,
              ContentDocumentId: this.fileList[i].ContentDocumentId,
              ContentDocument: this.fileList[i].ContentDocument,
              CreatedDate: this.fileList[i].CreatedDate,
              thumbnailFileCard:
                origin + "/radnetcommunityportal/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=" +
                this.fileList[i].Id +
                "&operationContext=CHATTER&contentId=" +
                this.fileList[i].ContentDocumentId,
              downloadUrl:
              origin + "/radnetcommunityportal/sfc/servlet.shepherd/document/download/" +
                this.fileList[i].ContentDocumentId,
              pagenumber:i+1
            };
          }
          else{
            file = {
              Id: this.fileList[i].Id,
              Title: this.fileList[i].Title,
              Extension: this.fileList[i].FileExtension,
              ContentDocumentId: this.fileList[i].ContentDocumentId,
              ContentDocument: this.fileList[i].ContentDocument,
              CreatedDate: this.fileList[i].CreatedDate,
              thumbnailFileCard:
                "/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=" +
                this.fileList[i].Id +
                "&operationContext=CHATTER&contentId=" +
                this.fileList[i].ContentDocumentId,
              downloadUrl:
                "/sfc/servlet.shepherd/document/download/" +
                this.fileList[i].ContentDocumentId,
              pagenumber:i+1
            };
          }
          this.files.push(file);
        }
        this.loaded = true;
      }
    })
    .catch(error => {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error loading Files",
          message: error.body.message,
          variant: "error"
        })
      );
    })

  }

  renderedCallback(){
    for(let i=0;i<this.files.length;i++){
      this.sitePageMap.push({str:this.files[i]});
    }
  }

  //this method handles the finish upload functionality
  handleUploadFinished(event) {
    const uploadedFiles = event.detail.files;
    //refreshApex(this.wiredActivities);
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Success!",
        message: uploadedFiles.length + " Files Uploaded Successfully.",
        variant: "success"
      })
    );
  }
}
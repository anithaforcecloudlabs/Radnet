import { LightningElement, api,track } from "lwc";

export default class PreviewFileThumbnailCard extends LightningElement {
  @api file;
  @api recordId;
  @api thumbnail;
  @api files;
  @api pagenumber;

  filePreview() {
    const showPreview = this.template.querySelector("c-preview-file-modal");
    showPreview.show();
  }
}
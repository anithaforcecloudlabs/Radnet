import { LightningElement, api, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class LwcRenamePracticeLocation extends LightningElement {
	@api objectApiName;
	@api recordId;
	@api closeAction;
	@track isRenameMergeModal = false;
	@track openRenemeMerge;
	isModalOpened = true;

	closeModal() {
		this.isRenameMergeModal = false;
		this.isModalOpened = false;
		this.dispatchEvent(new CloseActionScreenEvent());
	}
}
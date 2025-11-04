import getCompetitions from '@salesforce/apex/lwcCompetitionsAPX.getCompetitions';

const getRelatedCompetitions_helper1 = async (parentCmp) => { 
	getCompetitions({
		recordId: parentCmp.recordId
	}).then((data) => {
		parentCmp.showComp = false;
		parentCmp.competitions = data;
		let resp = JSON.parse(JSON.stringify(data));
		resp.forEach(item => {
			console.log('item ', item);
			item['competitionLink'] = parentCmp.a_Record_URL + '/lightning/r/Competition__c/' + item['Related_Competition__c'] + '/view';
			item['zipCode'] = item.Related_Competition__r.Address__PostalCode__s;
			item['name'] = item.Related_Competition__r.Name;
			item['status'] = item.Related_Competition__r.Status__c;
			item['mr'] = item.Related_Competition__r.MR_Equipments__c;
			item['ct'] = item.Related_Competition__r.CT_Equipment__c;
			item['petct'] = item.Related_Competition__r.PETCT_Equipment__c;
			item['petmr'] = item.Related_Competition__r.PETMR_Equipment__c;
			
		});
		parentCmp.competitions = resp;
		parentCmp.competitionsLabel = 'Related Competitions (' + parentCmp.competitions.length + ')';
		parentCmp.showComp = true;
	}).catch(error => {
		parentCmp.error = error;
	});
}

export {getRelatedCompetitions_helper1}
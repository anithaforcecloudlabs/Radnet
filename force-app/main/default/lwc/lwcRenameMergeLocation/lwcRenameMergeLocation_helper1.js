import searchPracticeLocationsByPractice from '@salesforce/apex/LwcRenamePracticeLocationController.searchPracticeLocations';

const getPracticeLocationsByPractice_helper1 = async (parentCmp) => {
	await searchPracticeLocationsByPractice({
		searchPracticeLoc: parentCmp.methodPrcticeLocationInput
	}).then((data) => {
		parentCmp.matchingAccountList = data;
		let resp = JSON.parse(JSON.stringify(data));
		resp.forEach(item => {
			item['practiceName'] = item['Name'];
			item['accountLink'] = '/lightning/r/Account/' + item['Id'] + '/view';
			
		});
		parentCmp.selectedRows.push(parentCmp.recordId);
		parentCmp.matchingAccountList = resp;
		parentCmp.showMatchingLocations = (parentCmp.matchingAccountList.length) ? true : false;
		parentCmp.showMessageForSelectedLocation = (parentCmp.matchingAccountList.length) ? false : true;
	}).catch(error => {
		console.log('error =', error);
	});
}


export { getPracticeLocationsByPractice_helper1 }
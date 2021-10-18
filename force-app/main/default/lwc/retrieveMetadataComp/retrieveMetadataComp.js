import {LightningElement,track,api} from 'lwc';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import {loadScript} from 'lightning/platformResourceLoader';
import jsZipData from '@salesforce/resourceUrl/jsZipFile';
import fileServerJsLib from '@salesforce/resourceUrl/fileServerJsLib';

import litsOfMetadata from "@salesforce/apex/RetrieveMetadataController.litsOfMetadata";
import saveNewAccessToken from "@salesforce/apex/RetrieveMetadataController.saveNewAccessToken";
import listMetadataItems from "@salesforce/apex/RetrieveMetadataController.listMetadataItems";
import retrieveMetadataItem from "@salesforce/apex/RetrieveMetadataController.retrieveMetadataItem";
import checkAsyncRequest from "@salesforce/apex/RetrieveMetadataController.checkAsyncRequest";



export default class RetrieveMetadataComp extends LightningElement {
	@api recordId;
	@track options;
	@track metaListItem;
	@track metaDataType;
	@track metaDataItemList;
	@track jsZipContent;
	@track timeInterval;
	@track filesList;
	@track showHideSpinner = false;

	renderedCallback() { // invoke the method when component rendered or loaded
		//console.log('rendered');
/*
		loadScript(this, jsZipData) // jquery script
			.then(() => {
				//console.log('js file upload sucess');
			})
			.catch(error => {
				let errorMessage;
				if (error) {
					if (Array.isArray(error.body)) {
						errorMessage = error.body.map(e => e.message).join(", ");
					} else if (typeof error.body.message === "string") {
						errorMessage = error.body.message;
					}
				}
				if (errorMessage) {
					this.customShowToast("Error", errorMessage, "error", "pester");
				}

			});
			*/
			Promise.all([
				loadScript(this, jsZipData),
				loadScript(this, fileServerJsLib)
			]).then(() => {
				console.log('Files loaded.');
			}).catch(error => {
				let errorMessage;
				if (error) {
					if (Array.isArray(error.body)) {
						errorMessage = error.body.map(e => e.message).join(", ");
					} else if (typeof error.body.message === "string") {
						errorMessage = error.body.message;
					}
				}
				if (errorMessage) {
					this.customShowToast("Error", errorMessage, "error", "pester");
				}

			});

	}
	connectedCallback() {
		this.doInit();
	}

	doInit() {
		let self = this;
		console.log('doInit');
		self.showHideSpinner = true;
		litsOfMetadata({
				recId: self.recordId
			})
			.then(result => {
				console.log('result=', result);
				if (result) {
					console.log('result=bool', result.expireAccessTokenCheck);
					if (result.expireAccessTokenCheck) {
						let metaList = [];
						for (let recObj in result.dataList) {
							metaList.push({
								label: result.dataList[recObj],
								value: result.dataList[recObj]
							});
						}
						console.log('metaList=', metaList);
						self.options = metaList;
						self.showHideSpinner = false;
					} else {
						console.log('result.dataList[0]=', result.dataList[0]);
						self.saveAccessToken(result.dataList[0]);
					}
				} else {
					self.customShowToast("Error", 'Your Session is Expire Please again Authorized', "error", "pester");
				}
			})
			.catch(error => {
				let errorMessage;
				if (error) {
					if (Array.isArray(error.body)) {
						errorMessage = error.body.map(e => e.message).join(", ");
					} else if (typeof error.body.message === "string") {
						errorMessage = error.body.message;
					}
				}
				if (errorMessage) {
					self.showHideSpinner = false;
					self.customShowToast("Error", errorMessage, "error", "pester");
				}
			});

	}

	saveAccessToken(newAccessToken) {
		let self = this;
		console.log('saveAccessToken=', newAccessToken);
		saveNewAccessToken({
				recId: self.recordId,
				accessToken: newAccessToken
			})
			.then(result => {
				console.log('saveAccessToken res=', result);
				if (result) {
					self.options = undefined;
					self.metaListItem = undefined;
					self.filesList =undefined;
					self.customShowToast("Error", 'Your Session is Expire Please Fill Again Information', "error", "pester");
					self.doInit();
				} 
			})
			.catch(error => {
				let errorMessage;
				if (error) {
					if (Array.isArray(error.body)) {
						errorMessage = error.body.map(e => e.message).join(", ");
					} else if (typeof error.body.message === "string") {
						errorMessage = error.body.message;
					}
				}
				if (errorMessage) {
					self.showHideSpinner = false;
					self.customShowToast("Error", errorMessage, "error", "pester");
				}
			});


	}

	handleMetadataChange(event) {
		let self = this;
		self.showHideSpinner = true;
		self.metaListItem = undefined;
		self.filesList = undefined;
		self.metaDataItemList = undefined;
		console.log('handle');
		console.log('value=', event.target.value);
		self.metaDataType = event.target.value;
	
		listMetadataItems({
				recId: self.recordId,
				MetaDataType: self.metaDataType
			})
			.then(result => {
				console.log('myresult=', result);
				if (result) {
					console.log('result=bool', result.expireAccessTokenCheck);
					if (result.expireAccessTokenCheck) {
						let metaList = [];
						for (let recObj in result.dataList) {
							metaList.push({
								label: result.dataList[recObj],
								value: result.dataList[recObj]
							});
						}
						console.log('metaList=', metaList);
						if(metaList.length > 0){
							self.metaListItem = metaList;
						}
					
						self.showHideSpinner = false;
					} else {
						console.log('result.dataList[0]=', result.dataList[0]);
						self.saveAccessToken(result.dataList[0]);
					}
				} else {
					self.customShowToast("Error", 'Your Session is Expire Please again Authorized', "error", "pester");
				}
			})
			.catch(error => {
				let errorMessage;
				if (error) {
					if (Array.isArray(error.body)) {
						errorMessage = error.body.map(e => e.message).join(", ");
					} else if (typeof error.body.message === "string") {
						errorMessage = error.body.message;
					}
				}
				if (errorMessage) {
					self.showHideSpinner = false;
					self.customShowToast("Error", errorMessage, "error", "pester");
				}
			});
	}

	handleMetadataItemChange(event) {
		this.metaDataItemList = [];
		this.metaDataItemList = event.target.value;
	}

	handleView() {
		let self = this;
		self.showHideSpinner = true;
		console.log('handleView');
		retrieveMetadataItem({
				recId: self.recordId,
				MetaDataType: self.metaDataType,
				MetaDataItem: self.metaDataItemList
			})
			.then(result => {
				console.log('myresult=', result);
				if(result){
					if (result.expireAccessTokenCheck && result.dataList) {
						console.log('trueeee');
						console.log('result.dataList[0]=', result.dataList[0]);
						self.asyncRequest(result.dataList[0]);
					} else {
						self.saveAccessToken(result.dataList[0]);
						self.showHideSpinner = false;
					}
				}else{
					self.showHideSpinner = false;
					self.customShowToast("Error", "Your Session Is Expire", "error", "pester");
				}
			})
			.catch(error => {
				let errorMessage;
				if (error) {
					if (Array.isArray(error.body)) {
						errorMessage = error.body.map(e => e.message).join(", ");
					} else if (typeof error.body.message === "string") {
						errorMessage = error.body.message;
					}
				}
				if (errorMessage) {
					self.showHideSpinner = false;
					self.customShowToast("Error", errorMessage, "error", "pester");
				}
			});

	}

	asyncRequest(asyncResId) {
		let self = this;
		self.showHideSpinner = true;
		let checkJobStatus = function(){
			checkAsyncRequest({
				recId: self.recordId,
				asyncResultId: asyncResId
			})
			.then(result => {
				if (result.expireAccessTokenCheck) {
					if (result.asynCheck) {
						self.jsZipContent = result.dataList[0];
						var myzip = new JSZip();
						let filesList = [];
						console.log('step1');
						myzip.loadAsync(self.jsZipContent, {
							base64: true
						}).then(function (zip) {
							console.log('step2');
							let filesName = [];
							Object.keys(zip.files).forEach(function (filename) {
								filesName.push(filename);
							});
							console.log(filesName);
							let loadedFiles = [];
							filesName.forEach(function (filename) {
								loadedFiles.push(zip.files[filename].async('string'));
							});
							console.log("loaded files");
							Promise.all(loadedFiles).then(function (files) {
								files.forEach(function (fileData, index) {
									// if(index < files.length - 1){
										let lastIndex = filesName[index].lastIndexOf("/");
										filesList.push({
											fileNames: filesName[index].slice(lastIndex+1,filesName[index].length),
											data: fileData
										});
									//}
									
								});
								console.log("filesList=",filesList);
								self.filesList = filesList;
								self.showHideSpinner = false;
								clearInterval(self.timeInterval);
							});
						});
					}
				} else {
					self.showHideSpinner = false;
					clearInterval(self.timeInterval);
					console.log("expired");
					self.saveAccessToken(result.dataList[0])
					
				}	
			})
			.catch(error => {
				clearInterval(self.timeInterval);
				console.error(error);
				let errorMessage;
				if (error) {
					if (Array.isArray(error.body)) {
						errorMessage = error.body.map(e => e.message).join(", ");
					} else if (typeof error.body.message === "string") {
						errorMessage = error.body.message;
					}
				}
				if (errorMessage) {
					self.showHideSpinner = false;
					self.customShowToast("Error", errorMessage, "error", "pester");
				}
			});
		};
		self.timeInterval = setInterval(checkJobStatus, 5000);
	}

	handleDownloadZip() {
		console.log("Download=", this.jsZipContent);
		//let tempcontent = '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';
			/*	
		var zip = new JSZip();
		zip.file("hello1.txt", tempcontent);
		zip.generateAsync({type:"blob"}).then(function (blob) { // 1) generate the zip file
			saveAs(blob, "hello.zip");                          // 2) trigger the download
		}, function (err) {
			console.log('erororor=',err);
		});
		*/
		var element = document.createElement('a');
		element.setAttribute('href', 'data:text/plain;base64,' + this.jsZipContent );
		element.setAttribute('download', 'metadatafile.zip');
		element.style.display = 'none';
		document.body.appendChild(element);
		element.click();
		document.body.removeChild(element);

		 this.customShowToast("success", "Your File Successfully Download", "success", "pester");
		 this.closeQuickAction();
	}

	customShowToast(title, message, variant, mode) {
		const evt = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: mode
		});
		this.dispatchEvent(evt);
	}

	closeQuickAction() {
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }
}
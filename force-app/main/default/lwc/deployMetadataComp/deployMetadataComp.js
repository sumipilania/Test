import { LightningElement, api, track } from 'lwc';
import deployZip from "@salesforce/apex/RetrieveMetadataController.deployZip";
import checkAsyncRequestDeploy from "@salesforce/apex/RetrieveMetadataController.checkAsyncRequestDeploy";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import saveNewAccessToken from "@salesforce/apex/RetrieveMetadataController.saveNewAccessToken";

export default class DeployMetadataComp extends LightningElement {
    @api recordId;
    @track runSpecificDisable = true;
    @track deployOption;
    @track showHideSpinner = false;
    @track fileName;
    filesUploaded = [];
    testLevel = 'NoTestRun';
    runTest;

    connectedCallback(){
        let self = this;
        let deployOption = [
            {label : 'Allow Missing Files', variableName : 'allowMissingFiles'},
            {label : 'Auto Update Package', variableName : 'autoUpdatePackage'},
            {label : 'Check Only', variableName : 'checkOnly'},
            {label : 'Ignore Warnings', variableName : 'ignoreWarnings'},
            {label : 'Perform Retrieve', variableName : 'performRetrieve'},
            {label : 'Purge On Delete', variableName : 'purgeOnDelete'},
            {label : 'Rollback On Error', variableName : 'rollbackOnError'},
            {label : 'Single Package', variableName : 'singlePackage'}
        ];
        self.deployOption = deployOption;
    }
    get testLevelOption() {
        return [
            { label: 'NoTestRun', value: 'NoTestRun' },
            { label: 'RunSpecifiedTests', value: 'RunSpecifiedTests' },
            { label: 'RunLocalTests', value: 'RunLocalTests' },
            { label: 'RunAllTestsInOrg', value: 'RunAllTestsInOrg' }
        ];
    }
    
     handleUpload(event){
        if(event && event.target){
              this.filesUploaded = event.target.files;
              console.log(' this.filesUploaded[0].type=', this.filesUploaded[0].type);
              if(this.filesUploaded[0].type === "application/x-zip-compressed" || this.filesUploaded[0].type === "application/zip"){
                console.log(' this.filesUploaded=', this.filesUploaded);
                this.fileName = event.target.files[0].name
              }else{
                this.filesUploaded = [];
                alert("Please select only zip file");
                return;
              }           
        }
    }

    handleSubmit(){
        let self = this;
        self.showHideSpinner = true;
        if(self.filesUploaded.length > 0) {
          /*
                let allInputData = self.template.querySelectorAll('lightning-input');
                let deployOption = {};
                for(let i = 0; i < allInputData.length; i++) {
                    if(allInputData[i].type === 'checkbox') {
                        deployOption[allInputData[i].value]  = allInputData[i].checked;
                    }
                }

                let tempRunTest = [];
                console.log('this.runTest=',self.runTest);
                if(self.runTest && self.testLevel==='RunSpecifiedTests'){
                        let runSpecificList = self.runTest.split(",");
                        for(let i in runSpecificList){
                            tempRunTest.push(runSpecificList[i].trim());
                        }
                        deployOption['runTests'] = tempRunTest;
                }else{
                    if(self.testLevel==='RunSpecifiedTests'){
                        alert("Please fill Run Test field other wise select other test level");
                        return;
                    }
                   
                }
                deployOption['testLevel'] = self.testLevel;
                */
                let file = self.filesUploaded[0];
                let fileReader= new FileReader();
                let fileContents;
                fileReader.onloadend = (() => {
                    fileContents = fileReader.result;
                    console.log(" this.fileContents  : " ,fileContents);
                    let base64 = 'base64,';
                    let content = fileContents.indexOf(base64) + base64.length;
                    console.log("  this.content  : " , content);
                    fileContents = fileContents.substring(content);
                    console.log(" after  this.fileContents   : " ,  fileContents );
                    self.deployZipData(fileContents);
                });
                fileReader.readAsDataURL(file);
        }else{
            self.showHideSpinner = false;
            alert("Please select any zip file");
            return;
        }
       
    }
    
    deployZipData(fileContents){  
        let self = this;
        self.showHideSpinner = true;
        let allowMissingFiles;
        let autoUpdatePackage;
        let checkOnly;
        let ignoreWarnings;
        let performRetrieve;
        let rollbackOnError;
        let singlePackage;
        let runTests;
        let purgeOnDelete;

        let allInputData = self.template.querySelectorAll('lightning-input');
        for(let i = 0; i < allInputData.length; i++) {
            if(allInputData[i].type === 'checkbox' && allInputData[i].value === "allowMissingFiles") {
              allowMissingFiles  = allInputData[i].checked;
            }else if(allInputData[i].type === 'checkbox' && allInputData[i].value === "autoUpdatePackage"){
              autoUpdatePackage  = allInputData[i].checked;
            }else if(allInputData[i].type === 'checkbox' && allInputData[i].value === "checkOnly"){
              checkOnly  = allInputData[i].checked;
            }else if(allInputData[i].type === 'checkbox' && allInputData[i].value === "ignoreWarnings"){
              ignoreWarnings  = allInputData[i].checked;
            }else if(allInputData[i].type === 'checkbox' && allInputData[i].value === "performRetrieve"){
              performRetrieve  = allInputData[i].checked;
            }else if(allInputData[i].type === 'checkbox' && allInputData[i].value === "rollbackOnError"){
              rollbackOnError  = allInputData[i].checked;
            }else if(allInputData[i].type === 'checkbox' && allInputData[i].value === "singlePackage"){
              singlePackage  = allInputData[i].checked;
            }else if(allInputData[i].type === 'checkbox' && allInputData[i].value === "purgeOnDelete"){
              purgeOnDelete  = allInputData[i].checked;
            }
        }
        let tempRunTest = [];
        console.log('this.runTest=',self.runTest);
        if(self.runTest && self.testLevel==='RunSpecifiedTests'){
                let runSpecificList = self.runTest.split(",");
                for(let i in runSpecificList){
                    tempRunTest.push(runSpecificList[i].trim());
                }
                runTests = tempRunTest;
        }else{
            if(self.testLevel==='RunSpecifiedTests'){
                alert("Please fill Run Test field other wise select other test level");
                return;
            }
           
        }
        /*
        console.log("allowMissingFiles",allowMissingFiles);
        console.log("autoUpdatePackage",autoUpdatePackage);
        console.log("checkOnly",checkOnly);
        console.log("ignoreWarnings",ignoreWarnings);
        console.log("performRetrieve",performRetrieve);
        console.log("rollbackOnError",rollbackOnError);
        console.log("singlePackage",singlePackage);
        console.log("runTests",runTests);
        console.log(" self.testLevel", self.testLevel);
        console.log('fileContents', fileContents);
        */
        deployZip({ 
          recId: self.recordId,
          zipData : fileContents, 
          allowMissingFiles : allowMissingFiles,
          autoUpdatePackage : autoUpdatePackage,
          checkOnly : checkOnly,
          ignoreWarnings : ignoreWarnings,
          performRetrieve : performRetrieve,
          rollbackOnError : rollbackOnError,
          runTests : runTests,
          purgeOnDelete : purgeOnDelete,
          testLevel : self.testLevel,
          singlePackage : singlePackage
        })
        .then(result => {
          console.log('result=',result);
          if(result){
            if(result.expireAccessTokenCheck){
                self.asyncRequest(result.dataList[0]);
             }else{
                self.showHideSpinner = false;
                self.saveAccessToken(result.dataList[0]);
             }
          }else{
            self.showHideSpinner = false;
            self.customShowToast("Error", "Your Session Expire Please Again Authorized", "error", "pester");
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

    asyncRequest(asyncId){
        let self = this;
        self.showHideSpinner = true;
        console.log('asyncRequest asyncId=',asyncId);
        console.log('this.recordId =',self.recordId);
        let timeInterval;
        let checkJobStatus = function(){
            checkAsyncRequestDeploy({ 
                recId : self.recordId, 
                asyncResultId : asyncId
            })
            .then(result => {
              console.log('result=',result);
              if(result.expireAccessTokenCheck){
                if(result.asynCheck){
                    clearInterval(timeInterval);
                    if(result.deploySuccess){
                        self.customShowToast("success", "Successfully Deploy", "success", "pester");
                        self.closeQuickAction();
                    }else{
                        self.customShowToast("Error", result.dataList[0], "error", "pester");
                    }
                    self.showHideSpinner = false;
                }
              }else{
                self.showHideSpinner = false;
                clearInterval(timeInterval);
                self.saveAccessToken(result.dataList[0]);
              }

            })
            .catch(error => {
              clearInterval(timeInterval);
              let errorMessage;
              if (error) {
                if (Array.isArray(error.body)) {
                  errorMessage = error.body.map(e => e.message).join(", ");
                } else if (typeof error.body.message === "string") {
                  errorMessage = error.body.message;
                }
              }
              if (errorMessage) {
                self.customShowToast("Error", errorMessage, "error", "pester");
              }
            });

        }
        timeInterval = setInterval(checkJobStatus, 5000);
    }


    handleChange(event){
        if(event && event.target){
            console.log('data=',event.target.value);
            this.testLevel = event.target.value;
            if(this.testLevel==='RunSpecifiedTests'){
                this.runSpecificDisable = false;
            }else{
                this.runSpecificDisable = true;
                this.runTest = undefined; 
            }
        }
    }

    handleRunTest(event){
        if(event && event.target){
            console.log('runTest=',event.target.value);
            this.runTest = event.target.value;
        }
    }

    saveAccessToken(newAccessToken) {
        let self = this;
        self.showHideSpinner = true;
		console.log('saveAccessToken=', newAccessToken);
		saveNewAccessToken({
				recId: self.recordId,
				accessToken: newAccessToken
			})
			.then(result => {
				console.log('saveAccessToken res=', result);
				if (result) {
                    self.showHideSpinner = false;
					self.customShowToast("Error", "Please Again Login Your Session Is Expire", "error", "pester");
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
import { LightningElement, track, api } from 'lwc';
import cloneMemberPlanAndCoverage from '@salesforce/apex/sl_memberPlanDetailController.cloneMemberPlanAndCoverage';
import getMemberPlanRecords from '@salesforce/apex/sl_memberPlanDetailController.getMemberPlanRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'


export default class Sl_memberPlanDetail extends LightningElement {
   @api recordId;
   @track memObjApiName = 'Member_Plan__c';
   @track memPlanRecId;
   @track coverageBenifitsRec;
   @track insertCoverageBenifits = [];
   @track memberPlanoptions;
   @track optionVal;
   @track hideShowBlock = {recordNotFound: true, isSpinner : false, isShowPicklist : false, isEditable : false};

      sectionAfieldsApi = [
            {fieldApiName : 'Name'},
            {fieldApiName : 'Contact__c'},
            {fieldApiName : 'Network_Plan__c'},
            {fieldApiName : 'Policy_Amount__c'},
            {fieldApiName : 'Policy_Number__c'}
      ];

      sectionBfieldsApi = [
            {fieldApiName : 'Name'},
            {fieldApiName : 'Contact__c'},
            {fieldApiName : 'Network_Plan__c'},
            {fieldApiName : 'Policy_Amount__c'},
            {fieldApiName : 'Policy_Number__c'}
      ];

      sectionCfieldsApi = [
            {fieldApiName : 'Name'},
            {fieldApiName : 'Contact__c'},
            {fieldApiName : 'Network_Plan__c'},
            {fieldApiName : 'Policy_Amount__c'},
            {fieldApiName : 'Policy_Number__c'}
      ];

      @track sectionWithFields = [
        {sectionName : 'Member Plan', isExpand : true, sectionId : '1', iconName : "custom:custom42", fieldsApiName : this.sectionAfieldsApi},
        {sectionName : 'Plan Characteristics', isExpand : true, sectionId : '2', iconName : "utility:chevrondown", fieldsApiName : this.sectionBfieldsApi},
        {sectionName : 'Diagnoses', isExpand : true, sectionId : '3', iconName : "utility:chevrondown", fieldsApiName : this.sectionCfieldsApi}];

      connectedCallback() {
            console.log('this.recordIda=',this.recordId);
            getMemberPlanRecords({ caseId: this.recordId })
                  .then(result => {
                  this.hideShowBlock.isSpinner = true;
                  console.log('getMemberPlanRecords result=',result);
                        if(result) {
                              this.memPlanRecId = result[0].Id;
                              console.log('this.memPlanRecId=',this.memPlanRecId);
                              if(result.length > 1) {
                                    let memberPlanoptions = [];
                                    for(let i in result) {
                                          memberPlanoptions.push({label : result[i].Name, value : result[i].Id});
                                    }
                                    this.memberPlanoptions = memberPlanoptions;
                                    this.optionVal = this.memPlanRecId;
                                    this.hideShowBlock.isShowPicklist = true;

                              } else {
                                    this.hideShowBlock.isShowPicklist = false;
                              } 
                              console.log('result[0].Coverage_benefits__r=',result[0].Coverage_benefits__r);
                              let coverage = result[0].Coverage_benefits__r;
                              Object.keys(coverage).map(
                                    function(object){
                                          coverage[object]["isEditable"]= false;
                              });
                              this.coverageBenifitsRec = coverage;
                              console.log('after coverage=',this.coverageBenifitsRec);                       
                        } else {
                            this.hideShowBlock.recordNotFound = false;
                        }
                        this.hideShowBlock.isSpinner = false;
                  })
                  .catch(error => {
                        this.hideShowBlock.isSpinner = false;
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

    
      sectionHanlder(event) {
            let sectionId =  event.target.dataset.sectionid;
            if(sectionId) {
                  let sectionField = this.sectionWithFields.filter(function (item) { return item.sectionId == sectionId})[0];
                  sectionField.isExpand = (sectionField.isExpand) ? false : true;
                  sectionField.iconName = (sectionField.isExpand) ? "utility:chevrondown" : "utility:chevronright" ;
            }
      }

      copyHandler() {
            console.log('copyHandler'); 
            this.hideShowBlock.isEditable = true;

      }

      editHandler(event) {
            console.log('editHandler'); 
            let recId =  event.target.dataset.id;
            let field =  event.target.dataset.field;
            let value = event.target.value;
            console.log('recId=',recId);
            console.log('field',field);
            console.log('value',value);
            let insertCoverageBenifits = this.insertCoverageBenifits;
            if(insertCoverageBenifits) {
                  let covObj = {};
                  let coverageBenefits = insertCoverageBenifits.filter(function (item) { return item.Id == recId})[0];
                  if(coverageBenefits) {
                        coverageBenefits[field] = value;
                  } else {
                        covObj["Id"] = recId;
                        covObj["MemberPlan"] = this.memPlanRecId;
                        covObj[field] = value;
                        insertCoverageBenifits.push(covObj);
                  }
            } else {
                  covObj["Id"] = recId;
                  covObj["MemberPlan"] = this.memPlanRecId;
                  covObj[field] = value;
                  insertCoverageBenifits.push(covObj);            
            }
            console.log("insertCoverageBenifits=",insertCoverageBenifits);
      }

      saveHandler(event) {
            console.log('saveHandler');
            let memberPlanFieldsStr = '';
            for(let i in this.sectionWithFields) {
                  for(let field in this.sectionWithFields[i].fieldsApiName) {
                        let fieldApiName = this.sectionWithFields[i].fieldsApiName[field].fieldApiName;
                        memberPlanFieldsStr = memberPlanFieldsStr + fieldApiName + ', ';
                  }
            }

            
            if (memberPlanFieldsStr && this.insertCoverageBenifits.length > 0) {
                 for(let j = 0; j < this.insertCoverageBenifits.length; j++) {
                   delete this.insertCoverageBenifits[j]['Id'];
                }
                console.log('memberPlanFieldsStr=',memberPlanFieldsStr);
                console.log('this.insertCoverageBenifits=',this.insertCoverageBenifits);
                this.hideShowBlock.isSpinner = true;
                  cloneMemberPlanAndCoverage({ memberPlanFieldsStr: memberPlanFieldsStr, memberPlanId : this.memPlanRecId, insertCoverageBenifits : this.insertCoverageBenifits })
                      .then(result => {
                        console.log('result=',result);
                        this.hideShowBlock.isSpinner = false;
                        this.customShowToast("Success", "Member Plan and Coverage benifits successfully Inserted", "success", "pester");
                        setInterval(function() {
                              window.location.reload();
                        }, 2000); 
                      })
                      .catch(error => {
                        this.hideShowBlock.isSpinner = false;
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
      }

      cancelHandler() {
            console.log('cancelHandler'); 
            this.hideShowBlock.isEditable = false;
      }

      handleChange(event) {
            console.log('handleChange');
            this.hideShowBlock.isSpinner = true;
            this.memPlanRecId = event.detail.value;
            this.hideShowBlock.isSpinner = false;
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
}
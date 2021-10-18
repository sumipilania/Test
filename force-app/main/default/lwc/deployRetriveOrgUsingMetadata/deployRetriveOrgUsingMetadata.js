import { LightningElement, api, track } from "lwc";
import fetchOrgData from "@salesforce/apex/DeployRetriveMetadataController.fetchRecord";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class DeployRetriveOrgUsingMetadata extends LightningElement {
  @api recordId;
  @track domainShowHide = false;
  @track orgObj = { 
    Custom_Url__c : '',
  Name : '',
  Org_Type__c : ''
};
  
 @track redirectUrl;

  connectedCallback() {
    fetchOrgData({ recId : this.recordId})
    .then(result => {
     
      console.log('this.recordId=',this.recordId);
        console.log('orgObjRecord=',result.orgObjRecord);
        console.log('redirectUrl=',result.redirectUrl);
        if(result.orgObjRecord){
            this.orgObj.Name = result.orgObjRecord.Name;
            this.orgObj.Custom_Url__c = result.orgObjRecord.Custom_Url__c;
            this.orgObj.Org_Type__c = result.orgObjRecord.Org_Type__c;
            if(result.orgObjRecord.Org_Type__c === 'Custom'){
              this.domainShowHide = true;
            }
            
        }
        if(result.redirectUrl){
          this.redirectUrl = result.redirectUrl;
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
        this.customShowToast("Error", errorMessage, "error", "pester");
      }
    });
  }

  get options() {
    return [
      {label: "Developer", value: "Developer" },
      {label: "Sandbox", value: "Sandbox" },
      {label: "Production",value: "Production"},
      {label: "Custom Domain",value: "Custom"}
    ];
  }

  handleName(event){
    if(event && event.detail){
      console.log('Name=',event.detail.value);
      this.orgObj.Name = event.detail.value;
    }
  }
  
  handlOrgType(event) {
    this.domainShowHide = false;
    if(event && event.detail){
    this.orgObj.Org_Type__c = event.detail.value;
    }
    console.log(' this.orgObj.Org_Type__c=', this.orgObj.Org_Type__c);
    if( this.orgObj.Org_Type__c==='Custom' ){
      this.domainShowHide = true; 
      this.orgObj.Custom_Url__c = '';
    }
  
  }

  handleUrl(event){
    if(event && event.detail){
      this.orgObj.Custom_Url__c = event.detail.value;
    }
  }

  handleAuthorize(){
   
    if(this.orgObj.Org_Type__c){
      if(this.orgObj.Org_Type__c === 'Developer'){
        this.orgObj.Custom_Url__c =  'https://login.salesforce.com';
      }
      else if(this.orgObj.Org_Type__c === 'Sandbox'){
        this.orgObj.Custom_Url__c =  'https://test.salesforce.com';
      }
      else if(this.orgObj.Org_Type__c === 'Production'){
        this.orgObj.Custom_Url__c =  'https://login.salesforce.com';
      }
    }
    let tempState = this.recordId + '%2C' + this.orgObj.Name + '%2C' + this.orgObj.Org_Type__c + '%2C' + this.orgObj.Custom_Url__c;
    let redirect = this.orgObj.Custom_Url__c + this.redirectUrl + '&state='+tempState;
     console.log('this.orgObj=',this.orgObj);
     console.log('tempState=',tempState);
     console.log('redirect=',redirect);  
     if(redirect){
      window.location.href = redirect;
     }
    
  }

  closeModal() {
    //this.orgObj.Name ='Sumit';
    //this.orgObj.Org_Type__c = 'Developer';
    //this.orgObj.Custom_Url__c = 'http';
   // window.location.href = 'https://login.salesforce.com/services/oauth2/authorize?client_id=3MVG9G9pzCUSkzZuOH7WKrfYuJ03Z6pxGPHCY0YTMhLIJbzvCvdhmmY0I4IYEk9Wbs4KhslctuUwu5wf6Y0Lz&prompt=login&redirect_uri=https://sumit-pilaniya-light9domain-dev-ed--c.visualforce.com/apex/deployRetriveMetadataRedirectPage&state='+this.orgObj+'&response_type=code';
    window.location.href = "https://sumit-pilaniya-light9domain-dev-ed.lightning.force.com/lightning/o/OrgDeatil__c/list?filterName=Recent";
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
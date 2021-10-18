import { LightningElement, track } from 'lwc';
import fetchCaseRecord from "@salesforce/apex/MergeCaseController.fetchRecord";
import mergeRecords from "@salesforce/apex/MergeCaseController.mergeRecords";
import { ShowToastEvent } from "lightning/platformShowToastEvent";


export default class MergeCaseComponent extends LightningElement {
@track ShowHideModal = true;
@track firstPage = true;
@track thirdPage = false;
@track secondPage = false;
@track allRecordList =[];
@track headerList = [];
@track mycheck = false;
@track mainList = [];
@track mergeRecordList = [];
@track deleteCaseObjList = [];
@track updateRecordId;
@track selectedRecordList=[];
@track updateCaseObj ={};

    connectedCallback() {
        fetchCaseRecord({ parentId: this.recordId })
        .then(result => {
          console.log('result=',result);
          console.log('recordList=',result.recordList);
          console.log('headerList=',result.headerList);
          this.headerList = result.headerList;
          let recList = result.recordList;
          this.mainList = result.recordList;
          let headerList =   result.headerList;
          let recordList = [];
          for(let recObj in recList){
            let valueList = [];
            for(let fieldApi in headerList){
              let tempFieldName = headerList[fieldApi].fieldApiName;
              valueList.push(recList[recObj][tempFieldName]);
            }            
            recordList.push({
              Id : result.recordList[recObj].Id,
              values : valueList,
              isSelected : false
            });
          }
          this.allRecordList = recordList;
         console.log('this.allRecordList==',this.allRecordList);         
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

    closeModal(){
      this.ShowHideModal = false;
    }
    firstNextHandle(){
      this.firstPage = false;
      this.secondPage = true;
      let selectedRecordList = [];
      let mergeVallist = [];
      this.mergeRecordList = [];
      console.log('next=');
      for(let recObj in  this.allRecordList){
        if(this.allRecordList[recObj].isSelected){
          for(let mainObj in this.mainList){
            if(this.mainList[mainObj].Id===this.allRecordList[recObj].Id){
              selectedRecordList.push(this.mainList[mainObj]);
              if(selectedRecordList.length===1){
                mergeVallist.push({
                  Id : this.allRecordList[recObj].Id,
                  val : 'Use a Master',
                  isChecked : true
                });
    
              }
              else{
                mergeVallist.push({
                  Id : this.allRecordList[recObj].Id,
                  val : 'Use a Master',
                  isChecked : false
                });
              }
            
            }
          }
       
          //let temp = (this.mainList.filter((x) => { return x.Id==this.allRecordList[recObj].Id; }));
        }

      }
      this.mergeRecordList.push({fieldApi:'Master Rocord',values:mergeVallist,isEditable:true});
      console.log('selectedRecordList=len',selectedRecordList.length);
      console.log(' before this.mergeRecordList=',this.mergeRecordList);
      console.log('selectedRecordList=',selectedRecordList);

    
      for(let fieldApi in this.headerList){
        mergeVallist = [];
        this.selectedRecordList = selectedRecordList;
        for(let recObj in selectedRecordList){
          let tempFieldName = this.headerList[fieldApi].fieldApiName;
          if(parseInt(recObj) === 0){
            mergeVallist.push({
              Id : selectedRecordList[recObj].Id,
              val : selectedRecordList[recObj][tempFieldName],
              isChecked : true
            });
          }
          else{
            mergeVallist.push({
              Id : selectedRecordList[recObj].Id,
              val : selectedRecordList[recObj][tempFieldName],
              isChecked : false
            });
          }
        }
        this.mergeRecordList.push({fieldApi:this.headerList[fieldApi].fieldApiName,values:mergeVallist,isEditable:this.headerList[fieldApi].isEditable});
       
      }
      console.log(' after this.mergeRecordList=',this.mergeRecordList);

   
    
     // let selectedRows = this.template.querySelectorAll('lightning-input');
     

/*
      for(let i = 0; i < selectedRows.length; i++) {
        if(selectedRows[i].checked && selectedRows[i].type === 'checkbox'){
          console.log('test=',selectedRows[i].dataset.id);
        }

        }*/
    }
    secondNextHandle(){
      console.log('enter=');
      this.updateMergeObjList = [];
      this.thirdPage = true;
      this.secondPage = false;   
      this.updateCaseObj = {};
      this.deleteCaseObjList = [];
      let selectedRows = this.template.querySelectorAll('lightning-input');
      for(let i = 0; i < selectedRows.length; i++) {
        if(selectedRows[i].checked && selectedRows[i].type === 'radio') {
          if(selectedRows[i].value === 'Master Rocord'){
            this.updateCaseObj['Id'] =  selectedRows[i].dataset.id;
            this.updateRecordId = selectedRows[i].dataset.id;
          }
          else{
            this.updateCaseObj[selectedRows[i].value] =  selectedRows[i].label;
          }
        }
    }
    console.log('this.selectedRecordList=',this.selectedRecordList);
    console.log('this.len=',this.selectedRecordList.length);
    console.log('updateMergeObj=',this.updateCaseObj);
 
    console.log('this.updateRecordId=',this.updateRecordId);
   for(let recObj in this.selectedRecordList){
    let deleteObj={};
    console.log('Id=',this.selectedRecordList[recObj].Id);
      if(this.selectedRecordList[recObj].Id != this.updateRecordId){
        console.log('afterId=',this.selectedRecordList[recObj].Id);
        deleteObj['Id'] = this.selectedRecordList[recObj].Id;
        this.deleteCaseObjList.push(deleteObj);
      }
   }
   console.log(' this.deleteCaseObjList=', this.deleteCaseObjList);

    }
    secondBackHandle(){
     
      this.firstPage = true;
      this.secondPage = false;
     
    }
    thirdBackHandle(){
      this.thirdPage = false;
      this.secondPage = true;
    }
    thirdMergeHandle(){

      mergeRecords({ updateCaseObj:  this.updateCaseObj, deleteCaseObjList : this.deleteCaseObjList})
      .then(result => {
        console.log('result=',result);
        this.customShowToast("Success", 'Your Case Successfully Merge', "success", "pester");
            
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
      this.ShowHideModal = false;
    }
    selectHandle(event){
      console.log('my selected=');
      let allRecordList = this.allRecordList;
      console.log('allRecordList=',allRecordList);
      let recId = event.target.value;
      console.log('recId=',recId);
      let tempList = [];
      for(let recObj in allRecordList){
        if(recId === allRecordList[recObj].Id){
            allRecordList[recObj].isSelected = (allRecordList[recObj].isSelected === true ? false : true); 
                 
        }
      }
      this.allRecordList = allRecordList;
    //  console.log('this.allRecordList==',this.allRecordList);
      console.log('allRecordList===',allRecordList);

    }
    radioHandle(event){
      console.log('value=',event.target.value);
      let fieldName = event.target.value
      console.log('dataset.id=',event.target.dataset.id);
      let recId = event.target.dataset.id;
      console.log('label=',event.target.label);
      console.log(' this.mergeRecordList=', this.mergeRecordList);
      for(let merge in this.mergeRecordList){
        if( this.mergeRecordList[merge].fieldApi ===fieldName){
          for(let valObj in this.mergeRecordList[merge].values){
            let tempRecId = this.mergeRecordList[merge].values[valObj].Id
            console.log('tempRecId=',tempRecId);
            if( this.mergeRecordList[merge].values[valObj].Id===recId){
              this.mergeRecordList[merge].values[valObj].isChecked = true;
            }else{
              this.mergeRecordList[merge].values[valObj].isChecked = false;

            }
          }
        }
      }
      
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
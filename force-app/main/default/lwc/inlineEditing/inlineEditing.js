import { LightningElement, track } from 'lwc';
import fetchObjectWrapper from "@salesforce/apex/InlineEditingController.fetchObjectWrapper";
import updateObjectRecord from "@salesforce/apex/InlineEditingController.updateObjectRecord";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import editPencilIconUrl from '@salesforce/resourceUrl/EditPencilIcon';
import lockIconUrl from '@salesforce/resourceUrl/lockIconUrl';
import SortDescUrl from '@salesforce/resourceUrl/SortDesc';
import SortAscUrl from '@salesforce/resourceUrl/SortAsc';



export default class InlineEditing extends LightningElement {

    allFieldWithoutSpace= 'AccountId,OwnerId,LastModifiedDate,LastName,RecordTypeId,MailingCity,Phone,Email,Title';
    @track objectName = 'Contact';
    @track headerList;
    @track allRecordList;
    @track showHideSpinner;
    @track editIconUrl = editPencilIconUrl;
    @track lockIconUrl =lockIconUrl;
    @track SortDescUrl =SortDescUrl;
    @track SortAscUrl =SortAscUrl;
    @track changeInputType = 'image';
   // @track showHideImage = true;
    @track showHideFooter = false;
    @track textBackgroundColor = '';
    @track updateJsonList = [];
    @track changeFieldValue = false;

    connectedCallback() {
        let self = this;
        self.showHideSpinner = true;
        console.log('test');
        fetchObjectWrapper({allFields : self.allFieldWithoutSpace,  objectName : self.objectName})
        .then(result => {
          console.log('result=',result);
          console.log('recordList=',result.recordList);
          console.log('headerList=',result.headerList);
          //console.log('dataList=',result.recordList[0].fields.AccountId.value);
          if(result){
            let headerList = result.headerList;
            let recList = result.recordList;
            let recordList = [];
            if(headerList && recList){
              let tempHeaderList = [];
              for(let headObj in headerList){
                tempHeaderList.push({
                  fieldApiName : headerList[headObj].fieldApiName,
                  fieldLabel : headerList[headObj].fieldLabel,
                  isEditable : headerList[headObj].isEditable,
                  fieldType : headerList[headObj].fieldType,
                  fieldRefernceName : headerList[headObj].fieldRefernceName,
                  isSortable : headerList[headObj].isSortable,
                  sortDirection : "asc",
                  isAsendingOrNot : true
                });
              }
              console.log('tempHeaderList=',tempHeaderList);
              self.headerList = tempHeaderList;

              for(let recObj in recList){
                let valueList = [];
                for(let fieldApi in headerList){
                  let tempFieldName = headerList[fieldApi].fieldApiName;
                  let refFieldValue;
                  let refObj;
                  if(headerList[fieldApi].fieldType){
                    refObj =headerList[fieldApi].fieldRefernceName;
                    //console.log('refObj=',refObj);
                    if(!(refObj==="RecordType")){
                      refFieldValue = (recList[recObj][refObj]) ? recList[recObj][refObj] : refFieldValue;
                      //console.log('refFieldValue=',refFieldValue);
                    }
                  
                    //console.log('name=',refFieldValue.Name);
                  }
                  valueList.push({
                    val : (recList[recObj][tempFieldName]) ? recList[recObj][tempFieldName] : "",
                    fieldName : tempFieldName,
                    isSelectedAndEditable : false,
                    isFieldEditable : headerList[fieldApi].isEditable,
                    fieldType : headerList[fieldApi].fieldType,
                    refFieldValueTemp : (headerList[fieldApi].fieldType && refFieldValue) ? refFieldValue.Name : refFieldValue
                  });
                }            
                recordList.push({
                  Id : result.recordList[recObj].Id,
                  values : valueList,
                  isSelected : false
                });
              }
              self.allRecordList = recordList;
              self.showHideSpinner = false;
              console.log('self.allRecordList==',self.allRecordList);         
            }
          }
         
        })
        .catch(error => {
          self.showHideSpinner = false;
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

    selectHeaderHandle(event){
      console.log('selectHeaderHandle');
      let recList  = this.allRecordList;
      console.log('recList=',recList);
      if(recList && event && event.target){
        for(let recObj in recList){
          console.log('recList[recObj].isSelected=',recList[recObj].isSelected);
          recList[recObj].isSelected = event.target.checked;
        }
      }
      console.log('next');
    }

    imgClick(event){
      this.showHideSpinner = true;
    //  console.log('imgClick');
      let fieldName = event.currentTarget.dataset.fieldname;
      let recId = event.currentTarget.dataset.id;
     //console.log('recId=',recId);
      //console.log('fieldName=',fieldName);
      //console.log('fieldValue=',fieldValue);
    //  this.showHideImage = false;
      let recList = this.allRecordList;
      //console.log('before this.allRecordList=',this.allRecordList);
      if(recId && fieldName && recList){
        for(let recObj in recList){
          if(recList[recObj].Id === recId){
            //console.log(' recList[recObj].Id=',recList[recObj].Id);
           let valData =  recList[recObj].values;
           //console.log(' valData=',valData);
           for(let valObj in valData){
              if(valData[valObj].fieldName === fieldName){
             //   console.log(' valData[valObj].fieldName=',valData[valObj].fieldName);
                valData[valObj].isSelectedAndEditable = true;
                //valData[valObj].val = fieldValue;
                break;
              }
           }
          }
        }
      }
      this.showHideSpinner = false;
    }
   
    onchangeText(){
      console.log('onchangeText');
      this.changeFieldValue = true;
    }
    onFocusOutHandler(event){
      this.showHideSpinner = true;
      this.textBackgroundColor = 'textClass';
      if(this.changeFieldValue){
        console.log('onFocusHandler');
        this.showHideFooter = true;
        let fieldValue = event.target.value;
        let fieldName = event.currentTarget.dataset.fieldname;
        let recId = event.currentTarget.dataset.id;
        console.log('fieldValue=',fieldValue);
        console.log('fieldName=',fieldName);
        console.log('recId=',recId);
        let recList = this.allRecordList;
        if(recId && fieldName && recList){
          for(let recObj in recList){
            if(recList[recObj].Id === recId){
              //console.log(' recList[recObj].Id=',recList[recObj].Id);
             let valData =  recList[recObj].values;
             //console.log(' valData=',valData);
             for(let valObj in valData){
                if(valData[valObj].fieldName === fieldName){
               //   console.log(' valData[valObj].fieldName=',valData[valObj].fieldName);
                  //valData[valObj].isSelectedAndEditable = false;
                  valData[valObj].val = fieldValue;
                  break;
                }
             }
            }
          }
        }
        let jsonList = this.updateJsonList;
        let jsonObj = {};
        let newObjInsert = true;
        if(jsonList.length > 0){
          for(let obj in jsonList){
            let singleJsonObj = jsonList[obj];
            console.log('singleJsonObj=',singleJsonObj);
            if(singleJsonObj.Id===recId){
              console.log('true==',recId);
              singleJsonObj[fieldName] = fieldValue;
              newObjInsert = false;
            }
          }
        }
        if(newObjInsert){
          jsonObj['Id']  = recId;
          jsonObj[fieldName] = fieldValue;
          jsonList.push(jsonObj);
        }
      }
      this.showHideSpinner = false;
    }

    cancelHandler(){
      this.showHideSpinner = true;
      this.showHideFooter = false;
      let recList = this.allRecordList;
      this.updateJsonList = [];
      if(recList){
        for(let recObj in recList){
             let valData =  recList[recObj].values;
             if(valData){
                for(let valObj in valData){
                  valData[valObj].isSelectedAndEditable = false;              
                }
             }
           }
       }
       this.showHideSpinner = false;
    }

    saveHandler(){
      let self = this;
      self.showHideSpinner = true;
      console.log('this.updateJsonList=',self.updateJsonList);
      updateObjectRecord({updateSObjectList : self.updateJsonList})
        .then(result => {
          console.log('result=',result);
          if(result){
            if(result==="Success"){
              self.showHideFooter = false;
              let recList = self.allRecordList;
              self.updateJsonList = [];
              if(recList){
                for(let recObj in recList){
                     let valData =  recList[recObj].values;
                   for(let valObj in valData){
                        valData[valObj].isSelectedAndEditable = false;              
                      }
                   }
               }
               self.customShowToast("Success", "Your Record Successfully Save", "success", "pester");
            }else{
              self.customShowToast("Error", result, "error", "pester");
            }
          }
          self.showHideSpinner = false;
        })
        .catch(error => {
          self.showHideSpinner = false;
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

    redirectRecordIdUrl(event){
      console.log('redirectRecordIdUrl');
      console.log('val=',event.currentTarget.dataset.id);
      window.open("/"+event.currentTarget.dataset.id);
    }

    sortHandle(event){
      console.log('sortHandle');
      console.log('fieldApi=',event.currentTarget.dataset.fieldname);
      console.log('direction=',event.currentTarget.dataset.sortdir);
      let sortField = event.currentTarget.dataset.fieldname;
      let dir = event.currentTarget.dataset.sortdir;
      let headerList = this.headerList;
      for(let obj in headerList){
         if(headerList[obj].fieldApiName === sortField){
            headerList[obj].isAsendingOrNot = (dir === "asc") ? true : false;
            headerList[obj].sortDirection = (dir === "asc") ? "desc" : "asc";
         }
      }
  
        this.allRecordList.sort(function (row1, row2) {
            let x = row1.values.filter( cell => {return cell.fieldName === sortField;})[0].val;
            let y = row2.values.filter( cell => {return cell.fieldName === sortField;})[0].val;
            x = x ? x.toLowerCase() : '';
            y = y ? y.toLowerCase() : '';
            if((x<y && dir === 'asc') || (x>y && dir === 'desc')){
                return -1;
            }
            return 0;
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
  
}
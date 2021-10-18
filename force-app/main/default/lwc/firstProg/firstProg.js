import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchList from "@salesforce/apex/Test1.fetchList";
import templateOne from './templateOne.html';
import templateTwo from './templateTwo.html';

export default class firstProg extends LightningElement {
    @track recordList;

    //First program ***************
    // connectedCallback() {
    //     let self = this;
    //     self.showHideSpinner = true;
    //     console.log('test');
    //     fetchList()
    //     .then(result => {
    //       console.log('result=',result);
    //       this.recordList = result;
    //       console.log('this.recordList=',this.recordList);
    //     })
    //     .catch(error => {
    //       self.showHideSpinner = false;
    //       let errorMessage;
    //       if (error) {
    //         if (Array.isArray(error.body)) {
    //           errorMessage = error.body.map(e => e.message).join(", ");
    //         } else if (typeof error.body.message === "string") {
    //           errorMessage = error.body.message;
    //         }
    //       }
    //       if (errorMessage) {
    //         this.customShowToast("Error", errorMessage, "error", "pester");
    //       }
    //     });
    // }
        
    //First program ***************

    //Second Program ******************
    // templateOne = true;

    // render() {
    //     console.log('test  =');
    //     return this.templateOne ? templateOne : templateTwo;
    // }

    // switchTemplate(){ 
    //     console.log(' before this.templateOne  =',this.templateOne);
    //     this.templateOne = this.templateOne === true ? false : true; 
    //     console.log('after this.templateOne  =',this.templateOne);
    // }
    //Second Program ******************

    //Third Program *****************
    handleSuccess(event) {
        console.log('onsuccess event recordEditForm',event.detail.id)
    }
    handleSubmit(event) {
        event.preventDefault();
        console.log('onsubmit event recordEditForm',event.detail.fields);
        console.log('onsubmit event recordEditForm stirng',JSON.stringify(event.detail.fields));
    }
    //Third Program *****************

}
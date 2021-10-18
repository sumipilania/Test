/* eslint-disable eqeqeq */
/* eslint-disable radix */
/* eslint-disable @lwc/lwc/no-document-query */
/* eslint-disable vars-on-top */
/* eslint-disable guard-for-in */
import { LightningElement, track } from 'lwc';
import fetchAccount from '@salesforce/apex/PaginationLWCOffset.fetchAccountList';
export default class PaginationOffset extends LightningElement {
@track sObjName = 'Account';
@track fieldName = 'Name,Id,Phone';
@track limit = '5';
@track offset = '0';
@track accountsList = [];
@track error;
@track totalRec;
@track queryTemp = '';
@track fieldList = this.fieldName.split(",");
@track pageSize = 1;
@track recPageSize;
@track firstFlag = true;
@track lastFlag = false;
@track spinner = false;

connectedCallback() {
    this.queryTemp = 'SELECT '+this.fieldName+' FROM '+this.sObjName+' LIMIT '+this.limit+' OFFSET '+this.offset;
    this.processData(this.queryTemp);
}

processData(queryTemp){
    this.spinner = true;
            window.console.log('Enter=',queryTemp);
            fetchAccount({ query: queryTemp,selObjName : this.sObjName})
                .then(result => {
                    window.console.log('result=',result);
                    window.console.log('result resp=',result.recList);
                    this.totalRec = result.totalRec;
                    this.recPageSize = Math.ceil(this.totalRec/this.limit);
                var temp = [];
                for(var i in result.recList) {                   
                    var temp1 = [];
                    for(var j in this.fieldList){
                         var fil = this.fieldList[j];
                        temp1.push(result.recList[i][fil]);                                               
                    }                    
                    temp.push({'Id':result.recList[i].Id,'values':temp1});                     
                }   
                window.console.log('temp=',temp);
                this.accountsList = temp;
                    this.error = undefined;
                    this.spinner = false;
                })
                .catch(error => {
                this.error = error;
                this.accountsList = undefined;
                this.spinner = false;
                });
            }
            pageSelectHandler(event) {
                this.firstFlag = true;
                this.lastFlag = false;
                window.console.log(event.target.value);
                this.limit = event.target.value;
                this.offset = '0';
                this.pageSize = 1;
                this.queryTemp = 'SELECT '+this.fieldName+' FROM '+this.sObjName+' LIMIT '+this.limit+' OFFSET '+this.offset;
                window.console.log('select==',this.queryTemp);
                this.processData(this.queryTemp);

            }
            handleFirst(){
                this.firstFlag = true;
                this.lastFlag = false;
                this.pageSize = 1;
                this.offset = '0';
                this.queryTemp = 'SELECT '+this.fieldName+' FROM '+this.sObjName+' LIMIT '+this.limit+' OFFSET '+this.offset;
                window.console.log('select==',this.queryTemp);
                this.processData(this.queryTemp);
            }
            handleLast(){
                this.firstFlag = false;
                this.lastFlag = true;
                this.pageSize = parseInt(this.recPageSize);
                this.offset = this.totalRec - this.limit;
                window.console.log('offset==',this.offset);
                this.queryTemp = 'SELECT '+this.fieldName+' FROM '+this.sObjName+' LIMIT '+this.limit+' OFFSET '+this.offset;
                this.processData(this.queryTemp);

            }
            handleNext(){
                this.firstFlag = false;
                this.pageSize = parseInt(this.pageSize) + 1;
                if(this.pageSize >= this.recPageSize){
                    this.offset =  parseInt(this.offset) + parseInt(this.limit);
                    this.queryTemp = 'SELECT '+this.fieldName+' FROM '+this.sObjName+' LIMIT '+this.limit+' OFFSET '+this.offset;
                    this.processData(this.queryTemp);
                    this.lastFlag = true;
                }else{
                        this.offset =  parseInt(this.offset) + parseInt(this.limit);
                        this.queryTemp = 'SELECT '+this.fieldName+' FROM '+this.sObjName+' LIMIT '+this.limit+' OFFSET '+this.offset;
                        this.processData(this.queryTemp);
                }
            }
            handlePrev(){
                this.lastFlag = false;
                this.pageSize = parseInt(this.pageSize) - 1;
                if(this.pageSize <= 1){
                    this.offset =  parseInt(this.offset) - parseInt(this.limit);
                    this.queryTemp = 'SELECT '+this.fieldName+' FROM '+this.sObjName+' LIMIT '+this.limit+' OFFSET '+this.offset;
                    this.processData(this.queryTemp);
                    this.firstFlag = true;
                }else{
                        this.offset =  parseInt(this.offset) - parseInt(this.limit);
                        this.queryTemp = 'SELECT '+this.fieldName+' FROM '+this.sObjName+' LIMIT '+this.limit+' OFFSET '+this.offset;
                        this.processData(this.queryTemp);
                }
            }

}
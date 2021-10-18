import { LightningElement, track, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import punchhResources from '@salesforce/resourceUrl/punchhResources'
import getSfRecordCount from '@salesforce/apex/PunchCalloutController.getSfRecordCount';
import createSchedule from '@salesforce/apex/PunchCalloutController.createSchedule';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import validateOrSaveConnection from "@salesforce/apex/PunchCalloutController.validateOrSaveConnection";

export default class ScheduleModal extends LightningElement {

    @track tabHideActive = {
        fieldMappingActiveInactive: 'slds-is-active slds-tabs_default__item',
        fieldMappingHideShow: 'slds-tabs_default__content slds-show',
        scheduleActiveInactive: 'slds-tabs_default__item',
        scheduleShowHide: 'slds-tabs_default__content slds-hide',
        footerBtnFlag: false
    };
    
    @track fieldMappingMetadata;
    @track punchFields;
    @track sfFields;
    @track allFieldsList;
    @track showHideObj = { showFields: false, testMapBtn: true, nextBtn: true, sfRecordCount: false };
    @track currentDateTime;
    @track sforceRecountCount;
    @track startTime;
    @api scheduleDetails;
    @api localScheduleDetails;
    @api fieldMappingMetadataFromP;
    @api externalConfig;
    @track config;
    spinner = false;

    @track headerList = [
        {
            label: 'Punchh Object',
            name: 'punchhObject'
        },
        {
            label: 'Salesforce Object',
            name: 'salesforceObject'
        },
        {
            label: 'Filter Data',
            name: 'filterData'
        }
    ];

    get booleanOption() {
        return [
            { label: 'True', value: 'true' },
            { label: 'False', value: 'false' },
        ];
    }

    get frequencyOption() {
        return [
            { label: 'Daily', value: 'daily' },
            { label: 'Monthly', value: 'monthly' }
        ];
    }

    get isReadOnly() {
        return (this.scheduleDetails && !this.scheduleDetails.isEditable) ? true : false;
    }

    setoperatorOption(sfFieldType) {
        try {
            if (sfFieldType.isBooleanField) {
                sfFieldType.operatorOptions = [
                    { label: 'Equal', value: '=' },
                    { label: 'Not Equal', value: '!=' }
                ];
            } else if (sfFieldType.isDataTimeField || sfFieldType.isNumberField || sfFieldType.isDataField || sfFieldType.isReferenceField) {
                sfFieldType.operatorOptions = [
                    { label: 'Equal', value: '=' },
                    { label: 'Not Equal', value: '!=' },
                    { label: 'Greater than', value: '>' },
                    { label: 'Greater than or equal', value: '>=' },
                    { label: 'Less than', value: '<' },
                    { label: 'Less than or equal', value: '<=' }
                ];

            } else if(sfFieldType.isStringField && !sfFieldType.isReferenceField) {
                sfFieldType.operatorOptions = [
                    { label: 'Equal', value: '=' },
                    { label: 'Not Equal', value: '!=' },
                    { label: 'Contains', value: '%%' }
                ];
            }
        } catch(e) { }
    }

   

    connectedCallback() {
        this.formatDate(new Date());
        Promise.all([
            loadStyle(this, punchhResources + '/css/punchCss.css')
        ])
            .then(() => {
                if (!this.fieldMappingMetadata && this.fieldMappingMetadataFromP) {
                    this.fieldMappingMetadata = JSON.parse(JSON.stringify(this.fieldMappingMetadataFromP));
                    this.prepareHeader();
                } else {
                    this.errorOccured();
                }

                if (!this.localScheduleDetails && this.scheduleDetails) {
                    this.localScheduleDetails = JSON.parse(JSON.stringify(this.scheduleDetails));
                    this.localScheduleDetails.allDetails.active = this.localScheduleDetails.allDetails.active == "Inactive" ? false : true;
                }

                if (!this.config) {
                    this.config = JSON.parse(JSON.stringify(this.externalConfig));
                }
                this.spinner = true;
            }).then(() => {
                if (this.scheduleDetails && this.scheduleDetails.allDetails) {
                    this.allFieldsList = [];
                    let userType = this.scheduleDetails.allDetails.userType;
                    let objectname = this.scheduleDetails.allDetails.objectName;
                    if (this.fieldMappingMetadata) {
                        this.prepareData('punchh', userType, 'salesforce', objectname, this.scheduleDetails);
                    }
                    if (!this.scheduleDetails.isEditable) {
                        this.showHideObj.testMapBtn = true;
                    }
                }
            })
            .catch(error => {
                this.spinner = true;
                this.showErrorMessage(error);
            });
    }

    prepareHeader() {
        try {
            if (this.fieldMappingMetadata) {
                if (this.fieldMappingMetadata.data) {
                    for (let i = 0; i < this.fieldMappingMetadata.data.length; i++) {
                        this.fieldMappingMetadata.data[i].value = this.fieldMappingMetadata.data[i].name;
                        if (this.fieldMappingMetadata.data[i].attributes) {
                            for (let j = 0; j < this.fieldMappingMetadata.data[i].attributes.length; j++) {
                                this.fieldMappingMetadata.data[i].attributes[j].value = this.fieldMappingMetadata.data[i].attributes[j].name;
                            }
                        }
                    }
                }
                if (this.fieldMappingMetadata.sfData) {
                    for (let i = 0; i < this.fieldMappingMetadata.sfData.length; i++) {
                        this.fieldMappingMetadata.sfData[i].value = this.fieldMappingMetadata.sfData[i].name;
                        if (this.fieldMappingMetadata.sfData[i].attributes) {
                            for (let j = 0; j < this.fieldMappingMetadata.sfData[i].attributes.length; j++) {
                                this.fieldMappingMetadata.sfData[i].attributes[j].value = this.fieldMappingMetadata.sfData[i].attributes[j].name;
                            }
                        }
                    }
                }
            }
        }
        catch(e) { }
    }

    operatorChangeHanlder(event) {
        try {
            if (event && event.target) {
                this.allFieldsList[event.target.dataset.in].filterSymbol = event.target.value;
            }
        }
        catch(e) { }

    }

    fieldTabHandler() {
        let tabHideActive = this.tabHideActive;
        tabHideActive.fieldMappingActiveInactive = 'slds-is-active slds-tabs_default__item';
        tabHideActive.fieldMappingHideShow = 'slds-tabs_default__content slds-show';
        tabHideActive.scheduleActiveInactive = 'slds-tabs_default__item';
        tabHideActive.scheduleShowHide = 'slds-tabs_default__content slds-hide';
        tabHideActive.footerBtnFlag = false;
    }

    scheduleTabHandler() {
        let tabHideActive = this.tabHideActive;
        tabHideActive.fieldMappingActiveInactive = 'slds-tabs_default__item';
        tabHideActive.fieldMappingHideShow = 'slds-tabs_default__content slds-hide';
        tabHideActive.scheduleActiveInactive = 'slds-is-active slds-tabs_default__item';
        tabHideActive.scheduleShowHide = 'slds-tabs_default__content slds-show';
        tabHideActive.footerBtnFlag = true;
    }

    cancelHandler() {
        try {
            this.spinner = false;
            const evt = new CustomEvent('response', { detail: 'landingCompRefresh' });
            this.dispatchEvent(evt);
        } catch(e) {}
    }

    backmappingHandler() {
        this.fieldTabHandler();
    }

    saveChangesHandler() {
        try {
            this.spinner = false;
            let requestBodyJson = this.getRequestBodyJson();
            if (requestBodyJson) {
                    createSchedule({ requestJson: JSON.stringify(requestBodyJson) })
                    .then(result => {
                        if (result) {
                            if (result.statusCode == 200) {
                                let data = JSON.parse(result.data);
                                if (data.status) {
                                    this.customShowToast("Success", result.message, "success", "pester");
                                    const evt = new CustomEvent('response', { detail: 'landingCompRefresh' });
                                    this.dispatchEvent(evt);
                                } else {
                                    this.customShowToast("Error", data.error, "error", "pester");
                                }
                            } else if (result.statusCode == 401) {
                                this.saveAndTestHandler('saveChangesHandler');
                            } else {
                                this.customShowToast("Error", result.message, "error", "pester");
                                this.errorOccured();
                            }
                        }
                        this.spinner = true;
                    })
                    .catch(error => {
                        this.spinner = true;
                        this.showErrorMessage(error);
                        this.errorOccured();
                    });
            } else {
                this.spinner = true;
                this.customShowToast("Error", 'Please fill out all the required values before proceeding', "error", "pester");
            }
        }
        catch(e) { }
    }

    nextHandler() {
        this.scheduleTabHandler();
    }

    selectObject(event) {
        try {
            this.showHideObj.showFields = false;
            if (event.target.dataset.obj == 'punchh') {
                this.prepareData('punchh', event.detail.value);
            } else if (event.target.dataset.obj == 'salesforce') {
                this.prepareData(null, null, 'salesforce', event.detail.value);
            }
        } catch(e) { }
    }

    setPunchFieldInputValue(event) {
        try {
            let index = event.target.dataset.pinputfield;
            this.allFieldsList[index].isInputFieldValue = event.detail.value;
        } catch(e) {
        }
    }

    prepareData(objectP, userType, objectS, objectname, scheduleDetails) {
        try {
            if (objectP == 'punchh') {
                let pf = {};
                pf.allFields = this.fieldMappingMetadata.data.filter(function (item) { return item.name == userType })[0].attributes;
                this.punchFields = pf;
                this.fieldMappingMetadata.userType = userType;
            }

            if (objectS == 'salesforce') {
                let sf = this.fieldMappingMetadata.sfData.filter(function (item) { return item.name == objectname });
                this.sfFields = sf[0].attributes;
                this.fieldMappingMetadata.objectName = objectname;
            }

            if (!this.showHideObj.showFields && this.sfFields && this.punchFields) {
                this.showHideObj.showFields = true;
                this.showHideObj.testMapBtn = false;
                this.showHideObj.nextBtn = false;

                this.punchFields.requriedList = this.punchFields.allFields.filter(function (item) { return item.required == true });
                this.punchFields.nonRequriedList = this.punchFields.allFields.filter(function (item) { return item.required == false });
                this.punchFields.nonRequriedList.push({
                    name: "inputTest",
                    value: 'inputTest',
                    label: "Input Test",
                    type: "string",
                    required: false,
                    readonly: false,
                    inputType: "text"
                });
                let allFieldsList = [];

                if (this.punchFields && this.punchFields.requriedList && this.punchFields.nonRequriedList) {
                    if (!scheduleDetails) {
                        for (let fieldObj in this.punchFields.requriedList) {
                            let field = this.punchFields.requriedList[fieldObj];
                            allFieldsList.push(
                                {
                                    required: field.required,
                                    isChecked: false,
                                    punchhAttr: field.name,
                                    salesforceAttr: '',
                                    punchhlabel: '',
                                    salesforcelabel: '',
                                    haveSelectedData: false,
                                    isInputField: field.inputType == 'text' ? true : false,
                                    filterSymbol: '',
                                    filterInputData: null,
                                    disableCb: true
                                }
                            );
                        }
                    } else {
                        let filterData = this.getFilterData(objectname, JSON.parse(JSON.stringify(scheduleDetails.allDetails)).batchQuery);
                        let inputTypeFields = this.punchFields.requriedList.filter(function (item) { return item.inputType == 'text' });
                        if (inputTypeFields && inputTypeFields.length > 0) {
                            for (let index = 0; index < inputTypeFields.length; index++) {
                                let abName = inputTypeFields[index].name == 'store_number' ? 'storeNumber' : inputTypeFields[index].name;
                                if (scheduleDetails.allDetails[abName]) {
                                    allFieldsList.push({
                                        required: inputTypeFields[index].required,
                                        isChecked: false,
                                        punchhAttr: inputTypeFields[index].name,
                                        salesforceAttr: '',
                                        punchhlabel: inputTypeFields[index].label,
                                        salesforcelabel: '',
                                        haveSelectedData: false,
                                        isInputField: true,
                                        isInputFieldValue: scheduleDetails.allDetails[abName],
                                        filterSymbol: '',
                                        filterInputData: '',
                                        disableCb: false
                                    });
                                }
                            }
                        }
                        let fieldOccurance = {};
                        for (let index = 0; index < scheduleDetails.allDetails.fieldMapping.length; index++) {
                            let fieldMapping = scheduleDetails.allDetails.fieldMapping[index];
                            let field = this.punchFields.allFields.filter(function (item) { return item.name == fieldMapping.punchhAttr })[0];
                            let sfField = this.sfFields.filter(function (item) { return item.name == fieldMapping.salesforceAttr })[0];

                            if (field && sfField) {
                                let isCheckData;
                                if (filterData.length > 0) {
                                    let ab = fieldOccurance[sfField.name] + 1;
                                    fieldOccurance[sfField.name] = !ab ? 0 : ab;
                                    isCheckData = filterData.filter(function (item) { return item.fieldName == sfField.name })[fieldOccurance[sfField.name]];
                                }
                                let row = {
                                    required: field.required,
                                    isChecked: isCheckData ? true : false,
                                    punchhAttr: field.name,
                                    salesforceAttr: sfField.name,
                                    punchhlabel: field.label,
                                    salesforcelabel: sfField.label,
                                    haveSelectedData: true,
                                    isInputField: false,
                                    filterSymbol: isCheckData ? isCheckData.operator : '',
                                    filterInputData: isCheckData ? isCheckData.value : '',
                                    disableCb: false
                                }
                                this.getSelectedFieldType(row, sfField.type);
                                allFieldsList.push(row);
                            }
                        }
                    }
                }
                this.allFieldsList = allFieldsList;
            }
        } catch(e) { }
    }

    testMappingHandler() {
        try {
            this.spinner = false;
            this.showHideObj.sfRecordCount = false;
            let apexQuery = this.getBatchQuery(false);
            if (apexQuery) {
                getSfRecordCount({ query: apexQuery })
                    .then(result => {
                        if (result && parseInt(result) > 0) {
                            this.showHideObj.sfRecordCount = true;
                            this.sforceRecountCount = result;
                        } else {
                            this.customShowToast("Error", "No Record Found", "error", "pester");
                        }
                        this.spinner = true;

                    })
                    .catch(error => {
                        this.spinner = true;
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
            } else {
                this.spinner = true;
            }
        }
        catch(e) { }
    }

    newMappingHandler() {
        let allFieldsList = this.allFieldsList;
        if (allFieldsList.length < this.punchFields.allFields.length) {
            allFieldsList.push({
                required: false,
                isChecked: false,
                punchhAttr: '',
                salesforceAttr: '',
                haveSelectedData: false,
                disableCb: true,
                punchhlabel: '',
                filterSymbol: '',
                isInputField: false,
                filterInputData: null,
                salesforcelabel: ''
            });
        }
    }

    checkboxHandler(event) {
        try {
            if (event && event.target) {
                let index = parseInt(event.target.value);
                this.allFieldsList[index].isChecked = event.target.checked;
                this.allFieldsList[index].filterInputData = '';
            }
        } catch(e) {}
    }

    formatDate(date) {
        try {
            let hours = date.getHours();
            let minutes = date.getMinutes();
            let ampm = hours >= 12 ? 'PM' : 'AM';
            hours = hours % 12;
            hours = hours ? hours : 12; // the hour '0' should be '12'
            minutes = minutes < 10 ? '0' + minutes : minutes;
            let strTime = hours + ':' + minutes + ' ' + ampm;
            let month = date.getMonth() + parseInt(1);
            let currentDate = date.getFullYear() + "-" + month + "-" + date.getDate();
            let currentTime = strTime;
            let scheduleDefaultName = 'Unnamed ' + month + "/" + date.getDate() + "/" + date.getFullYear() + ", " + currentTime;
            this.currentDateTime = { currentDate: currentDate, currentTime: currentTime, scheduleDefaultName: scheduleDefaultName };
        } catch(e) {}
    }

    selectedPickListValues(event) {
        try {
            let selectOption = event.target.dataset;
            let index;
            if (selectOption.so == 'sf') {
                index = selectOption.sf;
                this.allFieldsList[index].salesforceAttr = event.target.value;
                this.getSelectedFieldType(this.allFieldsList[index], this.sfFields.filter(function (item) { return item.name == event.target.value })[0].type);
            } else if (selectOption.so == 'pf') {
                index = selectOption.pf;
                this.allFieldsList[index].punchhAttr = event.target.value;
                let inputTypeFields = this.punchFields.nonRequriedList.filter(function (item) { return item.name == event.target.value });
                if (inputTypeFields && inputTypeFields.length > 0 && inputTypeFields[0].inputType == 'text') {
                    this.allFieldsList[index].isInputField = true;
                } else {
                    this.allFieldsList[index].isInputField = false;
                }
            }
            if (this.allFieldsList[index].punchhAttr && this.allFieldsList[index].salesforceAttr) {
                this.allFieldsList[index].disableCb = false;
                this.allFieldsList[index].haveSelectedData = true;
            } else {
                this.allFieldsList[index].disableCb = true;
                this.allFieldsList[index].haveSelectedData = false;
            }
        } catch(e) { }
    }

    getSelectedFieldType(row, sfFieldType) {
        try {
            row.isBooleanField = false;
            row.isDataTimeField = false;
            row.isDataField = false;
            row.isNumberField = false;
            row.isStringField = false;
            if (sfFieldType == 'BOOLEAN') {
                row.isBooleanField = true;
            } else if (sfFieldType == "DATETIME") {
                row.isDataTimeField = true;
            } else if (sfFieldType == "DATE") {
                row.isDataField = true;
            } else if (sfFieldType == "DOUBLE" || sfFieldType == "INTEGER" || sfFieldType == "DECIMAL") {
                row.isNumberField = true;
            } else {
                row.isStringField = true;
                if(sfFieldType == "REFERENCE" || sfFieldType == "ID") {
                    row.isReferenceField = true;
                }
            }
            this.setoperatorOption(row);
        } catch(e) { }

    }

    getBatchQuery(batchQueryFlag) {
        let selectedSfFieldLList = this.allFieldsList.filter(function (item) { return item.salesforceAttr != '' });
        let query = 'SELECT ';
        let condition = ' WHERE';
        let objectName = this.fieldMappingMetadata.objectName;

        let conditionFlag = false;
        if (selectedSfFieldLList) {
            for (let fieldObj in selectedSfFieldLList) {
                if (selectedSfFieldLList[fieldObj]) {
                    let sfField = selectedSfFieldLList[fieldObj];
                    query = query + objectName + '.' + sfField.salesforceAttr + ', ';

                    if (sfField.filterSymbol != '' && sfField.filterSymbol != null && sfField.isChecked) {
                        let operatorData;
                        let operator = sfField.filterSymbol;
                        if (operator == '%%') {
                            let data = "'%" + sfField.filterInputData + "%'";
                            operatorData = 'like' + ' ' + data;
                        } else {
                            operatorData = operator + ' ' + (sfField.isBooleanField ? (sfField.filterInputData == 'true' ? true : false) : (sfField.isStringField ? "'" + sfField.filterInputData + "'" : sfField.filterInputData));
                        }
                        condition += ' ' + (batchQueryFlag ? objectName + '.' : '') + sfField.salesforceAttr + ' ' + operatorData + ' AND';
                        if (!conditionFlag) {
                            conditionFlag = true;
                        }
                    }
                } else {
                    query = query + objectName + '.' + sfField.salesforceAttr + ', ';
                }
            }
        }
        query = query.substring(0, query.length - 2);
        query = query + ' FROM ' + objectName;
        condition = condition.substring(0, condition.length - 4);
        let mappingQuery = 'SELECT COUNT() FROM ' + objectName;
        let mainQuery;
        if (batchQueryFlag) {
            if (conditionFlag) {
                mainQuery = query + condition;
            } else {
                mainQuery = query; //+ " WHERE Contact.Id != ''"
            }
        } else {
            if (conditionFlag) {
                mainQuery = mappingQuery + condition;
            } else {
                mainQuery = mappingQuery;
            }
        }
        return mainQuery;
    }

    getFilterData(objectName, query) {
        let fieldJsonList = [];
        try {
            let objNameWithDot = objectName + '.';
            let regex = new RegExp(objNameWithDot, 'g');
            let afterWhereStr = query.split('WHERE')[1];
            let removeObjNameList = afterWhereStr.replace(regex, ' ').trim();
            let fieldList = removeObjNameList.split(',');
            let seAllField = fieldList[0].split("AND");

            for (let i in seAllField) {
                let seprateAllField = seAllField[i].trim().split(" ");
                var value = seprateAllField[2].replace(/'/g, ' ').trim();
                if (value.charAt(0) && value.charAt(value.length - 1)) {
                    value = value.replace(/%/g, '').trim();
                }
                let fieldObj = { fieldName: seprateAllField[0], operator: (seprateAllField[1] == 'like' ? '%%' : seprateAllField[1]), value: value };
                fieldJsonList.push(fieldObj);
            }
        } catch(e) {

        }
        return fieldJsonList;
    }

    operatorValueChangeHanlder(event) {
        try {
            if (event && event.target) {
                let index = event.target;
                if (index.dataset.in) {
                    this.allFieldsList[index.dataset.in].filterInputData = index.value;
                }
            }
        }
        catch(e) { }
    }

    timeChangeHandler(event) {
        try {
            let timeSplit = event.target.value.split(':'),
                hours,
                minutes,
                meridian;
            hours = timeSplit[0];
            minutes = timeSplit[1];
            if (hours > 12) {
                meridian = 'PM';
                hours -= 12;
                hours = '0' + hours;
            } else if (hours < 12) {
                meridian = 'AM';
                if (hours == 0) {
                    hours = 12;
                }
            } else {
                meridian = 'PM';
            }
            this.startTime = hours + ':' + minutes + ' ' + meridian;
        } catch(e) { }
    }

    updateName(event) {
        try {
            if (this.scheduleDetails && this.scheduleDetails.allDetails && this.scheduleDetails.allDetails.name && event.target.value) {
                this.localScheduleDetails.allDetails.name = event.target.value;
            } else {
                this.currentDateTime.scheduleDefaultName = event.target.value;
            }
        } catch(e) {}
    }

    getRequestBodyJson() {
        try {
            let fieldMappingList = [];
            let requestJsonBody = {};
            let allFieldsList = this.allFieldsList;
            if (allFieldsList) {

                let batchQuery = this.getBatchQuery(true);
                let startDate = this.template.querySelector('[data-startdate="startdate"]').value;
                let frequency = this.template.querySelector('[data-freq="frqvalue"]').value;
                let active = this.template.querySelector('[data-active="isActive"]').checked;
                let userType = this.fieldMappingMetadata.userType;
                let objectName = this.fieldMappingMetadata.objectName;
                let name = this.template.querySelector('[data-title="name"]').value;
                let timeZone = this.template.querySelector('[data-timezone="time"]').value;
                if (batchQuery && startDate && frequency && userType && name && timeZone) {
                    requestJsonBody = {
                        name: name,
                        objectName: objectName,
                        batchQuery: batchQuery,
                        userType: userType,
                        frequency: frequency,
                        startDate: startDate,
                        startTime: this.startTime,
                        active: active,
                        timezone: timeZone,
                        fieldMapping: fieldMappingList
                    }
                } else {
                    this.customShowToast("Error", "Please fill out all the required values before proceeding", "error", "pester");
                    this.spinner = true;
                    return null;
                }

                for (let fieldObj in allFieldsList) {
                    if ((allFieldsList[fieldObj].required && !allFieldsList[fieldObj].haveSelectedData && !allFieldsList[fieldObj].isInputField)
                        || (allFieldsList[fieldObj].isInputField && !allFieldsList[fieldObj].isInputFieldValue)) {
                        this.customShowToast("Error", "Complete the field mapping section before proceeding.", "error", "pester");
                        this.spinner = true;
                        return null;
                    }
                    if (allFieldsList[fieldObj].haveSelectedData) {
                        let fieldMapping = { punchhAttr: allFieldsList[fieldObj].punchhAttr, salesforceAttr: allFieldsList[fieldObj].salesforceAttr };
                        fieldMappingList.push(fieldMapping);
                    }

                    if (allFieldsList[fieldObj].isInputField) {
                        let abName = (allFieldsList[fieldObj].punchhAttr == 'store_number') ? 'storeNumber' : allFieldsList[fieldObj].punchhAttr;
                        requestJsonBody[abName] = allFieldsList[fieldObj].isInputFieldValue;
                    }
                }

                if (this.scheduleDetails && this.scheduleDetails.allDetails && this.scheduleDetails.isEditable) {
                    requestJsonBody.id = this.scheduleDetails.allDetails.id;
                    if (!requestJsonBody.startTime) {
                        requestJsonBody.startTime = this.scheduleDetails.allDetails.startTime;
                    }
                    requestJsonBody.active =  this.localScheduleDetails.allDetails.active;
                }
            }
            return requestJsonBody;
        }
        catch(e) { }
    }

    updateEnabled(event) {
        try {
            if (this.localScheduleDetails && this.localScheduleDetails.allDetails && this.localScheduleDetails.allDetails.name && event.target.value) {
                this.localScheduleDetails.allDetails.active = event.target.checked;
            }
        } catch(e) {}
    }

    deleteRowHandler(event) {
        try {
            if (event && event.target) {
                let index = event.target.dataset.in;
                if (index) {
                    this.allFieldsList.splice(index, 1);
                }
            }
        }
        catch(e) { }
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

    saveAndTestHandler(excecutionMethod, event) {
        this.config.action = 'SAVE';
        this.config.body = this.createBody(this.config.configData, this.config.action);
        validateOrSaveConnection({ inputJson: JSON.stringify(this.config) })
            .then(result => {
                if (result && result.statusCode == 200) {
                    if (result.status) {
                        if (excecutionMethod == 'saveChangesHandler') {
                            this.saveChangesHandler();
                        }
                    } else {
                        this.customShowToast("Error", result.error, "error", "pester");
                    }
                } else {
                    if (result.message) {
                        this.customShowToast("Error", result.message, "error", "pester");
                    }
                    if (!result.message) {
                        this.errorOccured();
                    }
                }
            })
            .catch(error => {
                this.showErrorMessage(error);
                this.errorOccured();
            });
    }

    createBody(configData, action) {
        try {
            if(configData && action) {
                let body = {
                    clientId: configData.clientId,
                    clientSecret: configData.clientSecret,
                    punchhUrl: configData.punchhUrl,
                    adminKey: configData.adminKey,
                    sfOrgId: "putOrgId",
                    action: action
                };
                return JSON.stringify(body);
            }
        } catch(e) {}
    }

    errorOccured() {
        try {
            const evt = new CustomEvent('response', { detail: 'landingCompError' });
            this.dispatchEvent(evt);
        } catch(e) {}
    }

    showErrorMessage(error) {
        let errorMessage;
        if (error) {
            if (error.body && Array.isArray(error.body)) {
                if(error.body) {
                    errorMessage = error.body.map(e => e.message).join(", ");
                }
            } else if (error && error.body && error.body.message && typeof error.body.message === "string") {
                errorMessage = error.body.message;
            }
        }
        if (errorMessage) {
            this.customShowToast("Error", errorMessage, "error", "pester");
        }
    }

    get timeZoneOption() {
        return [
            {
                value: "Europe/London",
                label: "(GMT+00:00) Edinburgh ( GMT )"
            },
            {
                value: "Europe/Lisbon",
                label: "(GMT+00:00) Lisbon ( WET )"
            },
            {
                value: "Europe/London",
                label: "(GMT+00:00) London ( GMT )"
            },
            {
                value: "Africa/Monrovia",
                label: "(GMT+00:00) Monrovia ( GMT )"
            },
            {
                value: "Etc/UTC",
                label: "(GMT+00:00) UTC ( UTC )"
            },
            {
                value: "Europe/Amsterdam",
                label: "(GMT+01:00) Amsterdam ( CET )"
            },
            {
                value: "Europe/Belgrade",
                label: "(GMT+01:00) Belgrade ( CET )"
            },
            {
                value: "Europe/Berlin",
                label: "(GMT+01:00) Berlin ( CET )"
            },
            {
                value: "Europe/Berlin",
                label: "(GMT+01:00) Bern ( CET )"
            },
            {
                value: "Europe/Bratislava",
                label: "(GMT+01:00) Bratislava ( CET )"
            },
            {
                value: "Europe/Brussels",
                label: "(GMT+01:00) Brussels ( CET )"
            },
            {
                value: "Europe/Budapest",
                label: "(GMT+01:00) Budapest ( CET )"
            },
            {
                value: "Africa/Casablanca",
                label: "(GMT+01:00) Casablanca ( +01 )"
            },
            {
                value: "Europe/Copenhagen",
                label: "(GMT+01:00) Copenhagen ( CET )"
            },
            {
                value: "Europe/Dublin",
                label: "(GMT+01:00) Dublin ( GMT )"
            },
            {
                value: "Europe/Ljubljana",
                label: "(GMT+01:00) Ljubljana ( CET )"
            },
            {
                value: "Europe/Madrid",
                label: "(GMT+01:00) Madrid ( CET )"
            },
            {
                value: "Europe/Paris",
                label: "(GMT+01:00) Paris ( CET )"
            },
            {
                value: "Europe/Prague",
                label: "(GMT+01:00) Prague ( CET )"
            },
            {
                value: "Europe/Rome",
                label: "(GMT+01:00) Rome ( CET )"
            },
            {
                value: "Europe/Sarajevo",
                label: "(GMT+01:00) Sarajevo ( CET )"
            },
            {
                value: "Europe/Skopje",
                label: "(GMT+01:00) Skopje ( CET )"
            },
            {
                value: "Europe/Stockholm",
                label: "(GMT+01:00) Stockholm ( CET )"
            },
            {
                value: "Europe/Vienna",
                label: "(GMT+01:00) Vienna ( CET )"
            },
            {
                value: "Europe/Warsaw",
                label: "(GMT+01:00) Warsaw ( CET )"
            },
            {
                value: "Africa/Algiers",
                label: "(GMT+01:00) West Central Africa ( CET )"
            },
            {
                value: "Europe/Zagreb",
                label: "(GMT+01:00) Zagreb ( CET )"
            },
            {
                value: "Europe/Athens",
                label: "(GMT+02:00) Athens ( EET )"
            },
            {
                value: "Europe/Bucharest",
                label: "(GMT+02:00) Bucharest ( EET )"
            },
            {
                value: "Africa/Cairo",
                label: "(GMT+02:00) Cairo ( EET )"
            },
            {
                value: "Africa/Harare",
                label: "(GMT+02:00) Harare ( CAT )"
            },
            {
                value: "Europe/Helsinki",
                label: "(GMT+02:00) Helsinki ( EET )"
            },
            {
                value: "Asia/Jerusalem",
                label: "(GMT+02:00) Jerusalem ( IST )"
            },
            {
                value: "Europe/Kaliningrad",
                label: "(GMT+02:00) Kaliningrad ( EET )"
            },
            {
                value: "Europe/Kiev",
                label: "(GMT+02:00) Kyiv ( EET )"
            },
            {
                value: "Africa/Johannesburg",
                label: "(GMT+02:00) Pretoria ( SAST )"
            },
            {
                value: "Europe/Riga",
                label: "(GMT+02:00) Riga ( EET )"
            },
            {
                value: "Europe/Sofia",
                label: "(GMT+02:00) Sofia ( EET )"
            },
            {
                value: "Europe/Tallinn",
                label: "(GMT+02:00) Tallinn ( EET )"
            },
            {
                value: "Europe/Vilnius",
                label: "(GMT+02:00) Vilnius ( EET )"
            },
            {
                value: "Asia/Baghdad",
                label: "(GMT+03:00) Baghdad ( +03 )"
            },
            {
                value: "Europe/Istanbul",
                label: "(GMT+03:00) Istanbul ( +03 )"
            },
            {
                value: "Asia/Kuwait",
                label: "(GMT+03:00) Kuwait ( +03 )"
            },
            {
                value: "Europe/Minsk",
                label: "(GMT+03:00) Minsk ( +03 )"
            },
            {
                value: "Europe/Moscow",
                label: "(GMT+03:00) Moscow ( MSK )"
            },
            {
                value: "Africa/Nairobi",
                label: "(GMT+03:00) Nairobi ( EAT )"
            },
            {
                value: "Asia/Riyadh",
                label: "(GMT+03:00) Riyadh ( +03 )"
            },
            {
                value: "Europe/Moscow",
                label: "(GMT+03:00) St. Petersburg ( MSK )"
            },
            {
                value: "Asia/Tehran",
                label: "(GMT+03:30) Tehran ( +0330 )"
            },
            {
                value: "Asia/Muscat",
                label: "(GMT+04:00) Abu Dhabi ( +04 )"
            },
            {
                value: "Asia/Baku",
                label: "(GMT+04:00) Baku ( +04 )"
            },
            {
                value: "Asia/Muscat",
                label: "(GMT+04:00) Muscat ( +04 )"
            },
            {
                value: "Europe/Samara",
                label: "(GMT+04:00) Samara ( +04 )"
            },
            {
                value: "Asia/Tbilisi",
                label: "(GMT+04:00) Tbilisi ( +04 )"
            },
            {
                value: "Europe/Volgograd",
                label: "(GMT+04:00) Volgograd ( +04 )"
            },
            {
                value: "Asia/Yerevan",
                label: "(GMT+04:00) Yerevan ( +04 )"
            },
            {
                value: "Asia/Kabul",
                label: "(GMT+04:30) Kabul ( +0430 )"
            },
            {
                value: "Asia/Yekaterinburg",
                label: "(GMT+05:00) Ekaterinburg ( +05 )"
            },
            {
                value: "Asia/Karachi",
                label: "(GMT+05:00) Islamabad ( PKT )"
            },
            {
                value: "Asia/Karachi",
                label: "(GMT+05:00) Karachi ( PKT )"
            },
            {
                value: "Asia/Tashkent",
                label: "(GMT+05:00) Tashkent ( +05 )"
            },
            {
                value: "Asia/Kolkata",
                label: "(GMT+05:30) Chennai ( IST )"
            },
            {
                value: "Asia/Kolkata",
                label: "(GMT+05:30) Kolkata ( IST )"
            },
            {
                value: "Asia/Kolkata",
                label: "(GMT+05:30) Mumbai ( IST )"
            },
            {
                value: "Asia/Kolkata",
                label: "(GMT+05:30) New Delhi ( IST )"
            },
            {
                value: "Asia/Colombo",
                label: "(GMT+05:30) Sri Jayawardenepura ( +0530 )"
            },
            {
                value: "Asia/Kathmandu",
                label: "(GMT+05:45) Kathmandu ( +0545 )"
            },
            {
                value: "Asia/Almaty",
                label: "(GMT+06:00) Almaty ( +06 )"
            },
            {
                value: "Asia/Dhaka",
                label: "(GMT+06:00) Astana ( +06 )"
            },
            {
                value: "Asia/Dhaka",
                label: "(GMT+06:00) Dhaka ( +06 )"
            },
            {
                value: "Asia/Urumqi",
                label: "(GMT+06:00) Urumqi ( +06 )"
            },
            {
                value: "Asia/Rangoon",
                label: "(GMT+06:30) Rangoon ( +0630 )"
            },
            {
                value: "Asia/Bangkok",
                label: "(GMT+07:00) Bangkok ( +07 )"
            },
            {
                value: "Asia/Bangkok",
                label: "(GMT+07:00) Hanoi ( +07 )"
            },
            {
                value: "Asia/Jakarta",
                label: "(GMT+07:00) Jakarta ( WIB )"
            },
            {
                value: "Asia/Krasnoyarsk",
                label: "(GMT+07:00) Krasnoyarsk ( +07 )"
            },
            {
                value: "Asia/Novosibirsk",
                label: "(GMT+07:00) Novosibirsk ( +07 )"
            },
            {
                value: "Asia/Shanghai",
                label: "(GMT+08:00) Beijing ( CST )"
            },
            {
                value: "Asia/Chongqing",
                label: "(GMT+08:00) Chongqing ( CST )"
            },
            {
                value: "Asia/Hong_Kong",
                label: "(GMT+08:00) Hong Kong ( HKT )"
            },
            {
                value: "Asia/Irkutsk",
                label: "(GMT+08:00) Irkutsk ( +08 )"
            },
            {
                value: "Asia/Kuala_Lumpur",
                label: "(GMT+08:00) Kuala Lumpur ( +08 )"
            },
            {
                value: "Australia/Perth",
                label: "(GMT+08:00) Perth ( AWST )"
            },
            {
                value: "Asia/Singapore",
                label: "(GMT+08:00) Singapore ( +08 )"
            },
            {
                value: "Asia/Taipei",
                label: "(GMT+08:00) Taipei ( CST )"
            },
            {
                value: "Asia/Ulaanbaatar",
                label: "(GMT+08:00) Ulaanbaatar ( +08 )"
            },
            {
                value: "Asia/Tokyo",
                label: "(GMT+09:00) Osaka ( JST )"
            },
            {
                value: "Asia/Tokyo",
                label: "(GMT+09:00) Sapporo ( JST )"
            },
            {
                value: "Asia/Seoul",
                label: "(GMT+09:00) Seoul ( KST )"
            },
            {
                value: "Asia/Tokyo",
                label: "(GMT+09:00) Tokyo ( JST )"
            },
            {
                value: "Asia/Yakutsk",
                label: "(GMT+09:00) Yakutsk ( +09 )"
            },
            {
                value: "Australia/Adelaide",
                label: "(GMT+09:30) Adelaide ( ACDT )"
            },
            {
                value: "Australia/Darwin",
                label: "(GMT+09:30) Darwin ( ACST )"
            },
            {
                value: "Australia/Brisbane",
                label: "(GMT+10:00) Brisbane ( AEST )"
            },
            {
                value: "Australia/Melbourne",
                label: "(GMT+10:00) Canberra ( AEDT )"
            },
            {
                value: "Pacific/Guam",
                label: "(GMT+10:00) Guam ( ChST )"
            },
            {
                value: "Australia/Hobart",
                label: "(GMT+10:00) Hobart ( AEDT )"
            },
            {
                value: "Australia/Melbourne",
                label: "(GMT+10:00) Melbourne ( AEDT )"
            },
            {
                value: "Pacific/Port_Moresby",
                label: "(GMT+10:00) Port Moresby ( +10 )"
            },
            {
                value: "Australia/Sydney",
                label: "(GMT+10:00) Sydney ( AEDT )"
            },
            {
                value: "Asia/Vladivostok",
                label: "(GMT+10:00) Vladivostok ( +10 )"
            },
            {
                value: "Asia/Magadan",
                label: "(GMT+11:00) Magadan ( +11 )"
            },
            {
                value: "Pacific/Noumea",
                label: "(GMT+11:00) New Caledonia ( +11 )"
            },
            {
                value: "Pacific/Guadalcanal",
                label: "(GMT+11:00) Solomon Is. ( +11 )"
            },
            {
                value: "Asia/Srednekolymsk",
                label: "(GMT+11:00) Srednekolymsk ( +11 )"
            },
            {
                value: "Pacific/Auckland",
                label: "(GMT+12:00) Auckland ( NZDT )"
            },
            {
                value: "Pacific/Fiji",
                label: "(GMT+12:00) Fiji ( +12 )"
            },
            {
                value: "Asia/Kamchatka",
                label: "(GMT+12:00) Kamchatka ( +12 )"
            },
            {
                value: "Pacific/Majuro",
                label: "(GMT+12:00) Marshall Is. ( +12 )"
            },
            {
                value: "Pacific/Auckland",
                label: "(GMT+12:00) Wellington ( NZDT )"
            },
            {
                value: "Pacific/Chatham",
                label: "(GMT+12:45) Chatham Is. ( +1345 )"
            },
            {
                value: "Pacific/Tongatapu",
                label: "(GMT+13:00) Nuku'alofa ( +13 )"
            },
            {
                value: "Pacific/Apia",
                label: "(GMT+13:00) Samoa ( +14 )"
            },
            {
                value: "Pacific/Fakaofo",
                label: "(GMT+13:00) Tokelau Is. ( +13 )"
            },
            {
                value: "Atlantic/Azores",
                label: "(GMT-01:00) Azores ( -01 )"
            },
            {
                value: "Atlantic/Cape_Verde",
                label: "(GMT-01:00) Cape Verde Is. ( -01 )"
            },
            {
                value: "Atlantic/South_Georgia",
                label: "(GMT-02:00) Mid-Atlantic ( -02 )"
            },
            {
                value: "America/Sao_Paulo",
                label: "(GMT-03:00) Brasilia ( -03 )"
            },
            {
                value: "America/Argentina/Buenos_Aires",
                label: "(GMT-03:00) Buenos Aires ( -03 )"
            },
            {
                value: "America/Godthab",
                label: "(GMT-03:00) Greenland ( -03 )"
            },
            {
                value: "America/Montevideo",
                label: "(GMT-03:00) Montevideo ( -03 )"
            },
            {
                value: "America/St_Johns",
                label: "(GMT-03:30) Newfoundland ( NST )"
            },
            {
                value: "America/Halifax",
                label: "(GMT-04:00) Atlantic Time (Canada) ( AST )"
            },
            {
                value: "America/Caracas",
                label: "(GMT-04:00) Caracas ( -04 )"
            },
            {
                value: "America/Guyana",
                label: "(GMT-04:00) Georgetown ( -04 )"
            },
            {
                value: "America/La_Paz",
                label: "(GMT-04:00) La Paz ( -04 )"
            },
            {
                value: "America/Santiago",
                label: "(GMT-04:00) Santiago ( -03 )"
            },
            {
                value: "America/Bogota",
                label: "(GMT-05:00) Bogota ( -05 )"
            },
            {
                value: "America/New_York",
                label: "(GMT-05:00) Eastern Time (US &amp; Canada) ( EST )"
            },
            {
                value: "America/Indiana/Indianapolis",
                label: "(GMT-05:00) Indiana (East) ( EST )"
            },
            {
                value: "America/Lima",
                label: "(GMT-05:00) Lima ( -05 )"
            },
            {
                value: "America/Lima",
                label: "(GMT-05:00) Quito ( -05 )"
            },
            {
                value: "America/Guatemala",
                label: "(GMT-06:00) Central America ( CST )"
            },
            {
                value: "America/Chicago",
                label: "(GMT-06:00) Central Time (US &amp; Canada) ( CST )"
            },
            {
                value: "America/Mexico_City",
                label: "(GMT-06:00) Guadalajara ( CST )"
            },
            {
                value: "America/Mexico_City",
                label: "(GMT-06:00) Mexico City ( CST )"
            },
            {
                value: "America/Monterrey",
                label: "(GMT-06:00) Monterrey ( CST )"
            },
            {
                value: "America/Regina",
                label: "(GMT-06:00) Saskatchewan ( CST )"
            },
            {
                value: "America/Phoenix",
                label: "(GMT-07:00) Arizona ( MST )"
            },
            {
                value: "America/Chihuahua",
                label: "(GMT-07:00) Chihuahua ( MST )"
            },
            {
                value: "America/Mazatlan",
                label: "(GMT-07:00) Mazatlan ( MST )"
            },
            {
                value: "America/Denver",
                label: "(GMT-07:00) Mountain Time (US &amp; Canada) ( MST )"
            },
            {
                value: "America/Los_Angeles",
                label: "(GMT-08:00) Pacific Time (US &amp; Canada) ( PST )"
            },
            {
                value: "America/Tijuana",
                label: "(GMT-08:00) Tijuana ( PST )"
            },
            {
                value: "America/Juneau",
                label: "(GMT-09:00) Alaska ( AKST )"
            },
            {
                value: "Pacific/Honolulu",
                label: "(GMT-10:00) Hawaii ( HST )"
            },
            {
                value: "Pacific/Midway",
                label: "(GMT-11:00) International Date Line West ( SST )"
            },
            {
                value: "Pacific/Midway",
                label: "(GMT-11:00) Midway Island ( SST )"
            }
        ];
    }

}
import { LightningElement, api, track } from 'lwc';
import punchhResources from '@salesforce/resourceUrl/punchhResources'
import { loadStyle } from 'lightning/platformResourceLoader';
import getConfiguration from '@salesforce/apex/PunchCalloutController.getConfiguration';
import getScheduleList from '@salesforce/apex/PunchCalloutController.getScheduleList';
import deleteSchedule from '@salesforce/apex/PunchCalloutController.deleteSchedule';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import validateOrSaveConnection from "@salesforce/apex/PunchCalloutController.validateOrSaveConnection";
import getPunchAndSfObjects from '@salesforce/apex/PunchCalloutController.getPunchAndSfObjects';

export default class LandingComp extends LightningElement {
    @api showHideComp = { landingComp: false, showEmptyState: false, configurationComp: false, scheduleComp: false, scheduleHistory: false, errorPage: false };
    @api error;
    @api config = this.fillConfig();
    @track recordList = [];
    @track pageNumber = 1;
    @track pageSize = 5;
    @track sortUp = punchhResources + '/icons/sortUp.svg';
    @track sortDown = punchhResources + '/icons/sortDown.svg';
    @track showEmptyState = false;
    @track spinner = false;
    @track showDeletePopup = false;
    @api scheduleDetails;
    @track recordSetCount = 1;
    @track fields = [
        { label: "NAME", value: "name", isAsc: true },
        { label: "PUNCHH TYPE", value: "userType", isAsc: false },
        { label: "FREQUENCY", value: "frequency", isAsc: false },
        { label: "STATUS", value: "active", isAsc: false }
    ];
    @track recordsToDisplay = [];
    @track sortField = 'name';
    @track sortDirection = 'asc';
    @track selectedRecordIdOrName;
    @track selectedRecord;
    @api fieldMappingMetadataP;
    @track emptyImg = punchhResources + '/icons/emptyImg.svg';
    @track errorImg = punchhResources + '/icons/errorImg.svg';

    get sizeOptions() {
        return [
            { label: 5, value: 5 },
            { label: 10, value: 10 },
            { label: 15, value: 15 }
        ];
    }

    get isAsc() {
        return this.sortDirection == 'asc';
    }

    get notHasPrevious() {
        let recordSetCount = parseInt(this.recordSetCount);
        if (recordSetCount && recordSetCount > 0) {
            return recordSetCount == 1;
        } else {
            return true;
        }
    }

    get navigationButtons() {
        let count = (parseInt(this.recordSetCount) - 1) * 7;
        let totalRecords = this.recordList ? this.recordList.length : 0;
        let pageSize = parseInt(this.pageSize);
        let totalPages = Math.ceil(totalRecords / pageSize);
        let buttons = [];
        for (let i = 1; i <= 7; i++) {
            let btn = {};
            btn.pageNumber = (count + i);
            btn.disabled = (count + i) > totalPages;
            btn.isSelected = (count + i) == parseInt(this.pageNumber);
            buttons.push(btn);
        }
        return buttons;
    }

    
    get currentPageFirstRecordSeq() {
        if(this.recordList && this.recordList.length > 0){
            return (parseInt(this.pageNumber) - 1) * parseInt(this.pageSize) + 1;
        } else {
            return 0;
        }
    }

    get currentPageLastRecordSeq() {
        if(this.recordList && this.recordList.length > 0){
            let totalRecords = this.recordList ? this.recordList.length : 0;
            let pageSize = parseInt(this.pageSize);
            let totalPages = Math.ceil(totalRecords / pageSize);
            if(parseInt(this.pageNumber) == totalPages){
                return totalRecords;
            } else {
                return (parseInt(this.pageNumber) * parseInt(this.pageSize));
            }
        } else {
            return 0;
        }
    }

    get hasNoRecords() {
        return this.recordList.length == 0;
    }

    get notHasNext() {
        let recordSetCount = parseInt(this.recordSetCount);
        let totalRecords = this.recordList ? this.recordList.length : 0;
        let pageSize = parseInt(this.pageSize);
        if (recordSetCount && recordSetCount > 0 && totalRecords > 0 && pageSize && pageSize > 0) {
            let totalPages = Math.ceil(totalRecords / pageSize);
            let totalRecordSets = Math.ceil(totalPages / 7);
            return recordSetCount == totalRecordSets;
        } else {
            return true;
        }
    }

    constructor() {
        super();
        Promise.all([
            loadStyle(this, punchhResources + '/css/punchCss.css')
        ])
            .then(() => {
                getConfiguration()
                    .then(result => {
                        if (result && JSON.parse(result).status) {
                            this.config = JSON.parse(result);
                            this.fetchScheduleList();
                        } else {
                            this.showComp('landingComp', 'showEmptyState');
                            this.spinner = true;
                        }
                    })
                    .catch(error => {
                        this.spinner = true;
                        this.showComp('landingComp', 'errorPage');
                    });
            }).then(() => {
                if (this.config && this.config.configData && this.config.configData.recId != null) {
                    this.getPunchAndSFObject();
                }
            }).catch(error => {
                this.spinner = true;
                this.error = error;
                this.showComp('landingComp', 'errorPage');
            });
    }


    fetchScheduleList() {
        try {
            getScheduleList()
                .then(result => {
                    this.spinner = false;
                    if (result) {
                        if (result.statusCode == 200 && result.status) {
                            if (result.data) {
                                let recordList = result.data;
                                for (let rec in recordList) {
                                    recordList[rec].active = (recordList[rec].active) ? "Active" : "Inactive";
                                }
                                this.recordList = recordList;
                                this.pageNumber = 1;
                                this.recordSetCount = 1;
                                this.pageSize = 5;
                                this.prepareDataWrapper(this.recordList.slice(0, 5));
                            } else {
                                this.showComp('landingComp', 'showEmptyState');
                            }
                        } else {
                            if (result.statusCode == 401) {
                                this.saveAndTestHandler('fetchScheduleList');
                            } else {
                                if (!result.statusCode && result.message) {
                                    this.customShowToast("Error", result.message, "error", "pester");
                                } else {
                                    this.showComp('landingComp', 'errorPage');
                                }
                            }
                        }
                    }
                    this.spinner = true;
                }).then(() => {
                    if (this.config && this.config.configData && this.config.configData.recId != null) {
                        this.getPunchAndSFObject();
                    }
                }).catch(error => {
                    this.spinner = true;
                    this.showComp('landingComp', 'errorPage');
                    this.showErrorMessage(error);
                });
        } catch (e) {
            this.spinner = true;
        }
    }

    getPunchAndSFObject() {
        try {
            if (!this.fieldMappingMetadataP) {
                this.spinner = false;
                getPunchAndSfObjects()
                    .then(result => {
                        if (result && result.statusCode == 200 && result.status) {
                            this.fieldMappingMetadataP = result;
                        } else if (result.statusCode == 401) {
                            this.saveAndTestHandler('getPunchAndSFObject');
                        } else {
                            if (result.message) {
                                this.customShowToast("Error", result.message, "error", "pester");
                            }
                            if (!result.statusCode) {
                                this.showComp('landingComp', 'errorPage');
                            }
                        }
                        this.spinner = true;
                    })
                    .catch(error => {
                        this.spinner = true;
                        this.showComp('landingComp', 'errorPage');
                        this.showErrorMessage(error);
                    });
            }
        } catch(e) {}
    }

    fillConfig() {
        return {
            status: null,
            action: null,
            body: null,
            sfOrgId: null,
            data: null,
            configData: {
            recId: null, clientId: null, clientSecret: null, punchhUrl: null, adminKey: null,
            accessToken: null, apiEndpoint: null, action: null
            }
        };
    }

    newMappingHandler() {
        try {
            if (this.config && this.config.configData.recId == null) {
                this.showComp('configurationComp');
            } else {
                this.scheduleDetails = null;
                this.showComp('scheduleComp');
            }
        } catch(e) {} 
    }

    handleActions(event) {
        try {
            if (event && event.detail && event.detail.value) {
                switch (event.detail.value) {
                    case 'view': this.openScheduleModal(event); break;
                    case 'edit': this.openScheduleModal(event); break;
                    case 'delete': this.openDeleteModal(event); break;
                }
            }
        } catch(e) {}
    }

    openDeleteModal(event) {
        try {
            this.showDeletePopup = true;
            if (event && event.target && event.target.dataset && event.target.dataset.id && event.target.dataset.name) {
                let selectedRecordIdOrName = {
                    id: event.target.dataset.id,
                    name: event.target.dataset.name
                }
                this.selectedRecordIdOrName = selectedRecordIdOrName;
            }
        } catch(e) {}
    }

    openScheduleModal(event) {
        try {
            if (event && event.target && event.target.dataset && event.target.dataset.id) {
                this.scheduleDetails = {};
                this.scheduleDetails.isEditable = event.detail.value == 'edit' ? true : false;
                this.scheduleDetails.allDetails = this.recordList.filter(function (item) { return item.id == event.target.dataset.id })[0];
                this.showComp('scheduleComp');
            }
        } catch (e) {}
    }

    closeDeleteModal() {
        this.showDeletePopup = false;
    }

    deleteSchedule(event) {
        try {
            this.closeDeleteModal();
            this.spinner = false;
            let recordId = this.selectedRecordIdOrName.id;
            let scheduleName = this.selectedRecordIdOrName.name;
            if (recordId && scheduleName) {
                deleteSchedule({ scheduleId: recordId, scheduleName: scheduleName })
                    .then(result => {
                        if (result) {
                            if (result.statusCode == 200) {
                                this.recordList = this.recordList.filter(record => { return record.id != recordId });
                                this.navigate({target : { dataset : { pagenumber : parseInt(this.pageNumber) }}});
                                this.customShowToast("Success", result.message, "success", "pester");
                                this.selectedRecordIdOrName = null;
                            } else if (result.statusCode == 401) {
                                this.saveAndTestHandler('deleteSchedule', event);
                            } else if (result.statusCode && result.message) {
                                this.customShowToast("Error", result.message, "error", "pester");
                            } else {
                                this.showComp('landingComp', 'errorPage');
                                this.customShowToast("Success", result.message, "success", "pester");
                            }
                        } else {
                            this.showComp('landingComp', 'errorPage');
                            this.customShowToast("Error", 'Error in deleting schedule', "error", "pester");
                        }
                        this.spinner = true;
                    })
                    .catch(error => {
                        this.spinner = true;
                        this.showComp('landingComp', 'errorPage');
                        this.showErrorMessage(error);
                    });
            }
        } catch(e) {}  
    }

    settingHandler() {
        this.showComp('configurationComp');
    }

    showHideHandler(event) {
        try {
            if(event && event.detail) {
                const res = event.detail;
                if (res == 'landingCompRefresh') {
                    this.fetchScheduleList();
                } else if (res == 'landingCompError') {
                    this.showComp('landingComp', 'errorPage');
                } else {
                    this.showComp(res);
                }
            }
        } catch(e) {}       
    }

    updateConfig(event) {
        try {
            if(event && event.detail) {
                this.config = event.detail;
                this.showComp('landingComp');
                this.fetchScheduleList();
            }
        } catch(e) {}
    }

    prepareDataWrapper(records) {
        try {
            let dataWrapperList = [];
            let fields = this.fields;
            if (records && records.length > 0 && fields && fields.length > 0) {
                records.forEach(record => {
                    if (record) {
                        let row = {};
                        row.recordId = record.id;
                        row.name = record.name;
                        row.cells = [];
                        fields.forEach(field => {
                            if (field && field.value) {
                                var cell = {};
                                cell.label = field.value;
                                cell.value = record[field.value] ? record[field.value] : '';
                                cell.isClickable = (field.value == 'name') ? true : false;
                                row.cells.push(cell);
                            }
                        });
                        dataWrapperList.push(row);
                    }
                });
            }
            if (dataWrapperList && dataWrapperList.length > 0) {
                this.recordsToDisplay = dataWrapperList;
            }
            this.showComp('landingComp');
        } catch (e) {}
    }

    sortHanlder(event) {
        try {
            let fieldName = event.target.dataset.field;
            if (fieldName) {
                this.sortDirection = (this.sortField == fieldName) ? (this.sortDirection == 'asc' ? 'desc' : 'asc') : 'asc';
                this.sortField = fieldName;
                this.fields.forEach(field => {
                    if (field && field.value) {
                        if (field.value == fieldName && field.isAsc) {
                            field.isAsc = false;
                        } else if (field.value == fieldName) {
                            field.isAsc = true;
                        } else {
                            field.isAsc = false;
                        }
                    }
                });
            }
            this.recordList = this.recordList.sort(this.compareValues(fieldName, this.sortDirection));
            this.navigate({target : { dataset : { pagenumber : parseInt(this.pageNumber) }}});
        } catch (e) {}
    }

    compareValues(key, order = 'asc') {
        try {
            return function innerSort(a, b) {
                if (!a.hasOwnProperty(key) || !b.hasOwnProperty(key)) {
                    return 0;
                }
                const varA = (typeof a[key] === 'string')
                    ? a[key].toUpperCase() : a[key];
                const varB = (typeof b[key] === 'string')
                    ? b[key].toUpperCase() : b[key];
                let comparison = 0;
                if (varA > varB) {
                    comparison = 1;
                } else if (varA < varB) {
                    comparison = -1;
                }
                return (
                    (order === 'desc') ? (comparison * -1) : comparison
                );
            };
        } catch(e) {}
        
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

    showComp(compName, secComp) {
        try {
            this.showHideComp = { landingComp: false, showEmptyState: false, configurationComp: false, scheduleComp: false, scheduleHistory: false, errorPage: false };
            if (secComp) {
                this.showHideComp[secComp] = true;
            }
            this.showHideComp[compName] = true;
        } catch(e) {}
    }

    openHistory(event) {
        try {
            if (event && event.target && event.target.dataset && event.target.dataset.id && this.recordList) {
                let filteredRecords = this.recordList.filter(rcd => { return rcd.id == event.target.dataset.id; });
                if (filteredRecords && filteredRecords.length > 0) {
                    this.selectedRecord = filteredRecords[0];
                    this.showComp('scheduleHistory');
                }
            }
        } catch(e) {}
    }

    handleChangePageSet(event) {
        try {
            if (event && event.target && event.target.dataset && event.target.dataset.direction) {
                let dir = event.target.dataset.direction;
                if (dir == 'previous') {
                    this.recordSetCount = parseInt(this.recordSetCount) - 1;
                } else if (dir == 'next') {
                    this.recordSetCount = parseInt(this.recordSetCount) + 1;
                }
                this.pageNumber = (parseInt(this.recordSetCount) - 1) * 7 + 1;
                this.loadPage();
            }
        } catch(e) {}
    }

    

    navigate(event) {
        try {
            if (event && event.target && event.target.dataset && event.target.dataset.pagenumber) {
                this.pageNumber = parseInt(event.target.dataset.pagenumber);
                this.loadPage();
            }
        } catch(e) {}
    }

    loadPage() {
        try {
            let pageSize = parseInt(this.pageSize);
            let pageNumber = parseInt(this.pageNumber);
            let allRecords = this.recordList;
            if (allRecords && allRecords.length > 0 && pageSize && pageSize > 0 && pageNumber && pageNumber > 0) {
                let firstPosition = (pageNumber - 1) * pageSize;
                let lastPosition = pageNumber * pageSize;
                let currentSetRecords = allRecords.slice(firstPosition, lastPosition);
                if(currentSetRecords && currentSetRecords.length > 0){
                    this.prepareDataWrapper(currentSetRecords);
                } else if(pageNumber - 1 > 0){
                    this.pageNumber = pageNumber - 1;
                    this.loadPage();
                    let count = parseInt(this.recordSetCount);
                    if(this.pageNumber < (7*(count-1) + 1)){
                        this.recordSetCount = count > 1 ? count - 1 : 1;
                    }
                } else {
                    this.recordsToDisplay = [];
                    this.showComp('landingComp', 'showEmptyState');
                }
            } else {
                this.recordsToDisplay = [];
                this.showComp('landingComp', 'showEmptyState');
            }
        } catch(e) {}
    }

    handleSizeChange(event) {
        try {
            if (event && event.detail && event.detail.value) {
                this.pageSize = parseInt(event.detail.value);
                this.pageNumber = 1;
                this.recordSetCount = 1;
                this.loadPage();
            }
        } catch(e) {} 
    }

    saveAndTestHandler(excecutionMethod, event) {
        try {
            this.config.action = 'SAVE';
            this.config.body = this.createBody(this.config.configData, this.config.action);
            validateOrSaveConnection({ inputJson: JSON.stringify(this.config) })
                .then(result => {
                    if (result && result.statusCode == 200) {
                        if (result.status) {
                            if (excecutionMethod == 'fetchScheduleList') {
                                this.fetchScheduleList();
                                this.getPunchAndSFObject();
                            } else if (excecutionMethod == 'deleteSchedule') {
                                this.deleteSchedule(event);
                            } else if (excecutionMethod == 'getPunchAndSFObject') {
                                this.getPunchAndSFObject();
                            }
                        } else {
                            this.customShowToast("Error", result.error, "error", "pester");
                        }
                    } else {
                        if (!result.statusCode) {
                            this.showComp('landingComp', 'errorPage');
                        }
                        if (result.message) {
                            this.customShowToast("Error", result.message, "error", "pester");
                        }
                    }
                }).catch(error => {
                    this.showErrorMessage(error);
                    this.showComp('landingComp', 'errorPage');
                });
        } catch(e) {}
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

    showErrorMessage(error) {
        try {
            let errorMessage;
            if (error) {
                if (error.body && Array.isArray(error.body)) {
                    errorMessage = error.body.map(e => e.message).join(", ");
                } else if (error && error.body && error.body.message && typeof error.body.message === "string") {
                    errorMessage = error.body.message;
                }
            }
            if (errorMessage) {
                this.customShowToast("Error", errorMessage, "error", "pester");
            }
        } catch(e) {}
    }
}
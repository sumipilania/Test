import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import punchhResources from '@salesforce/resourceUrl/punchhResources'
import getScheduleHistory from '@salesforce/apex/PunchCalloutController.getScheduleHistory';
import validateOrSaveConnection from "@salesforce/apex/PunchCalloutController.validateOrSaveConnection";

export default class ScheduleHistory extends LightningElement {

    @api scheduleRecord;
    @api configData;
    @api config;
    @track historyRecords = [];
    @track fields = [
        { label: "START TIME", value: "startedAt", isAsc: true, hasStatus: false },
        { label: "STATUS", value: "processState", isAsc: false, hasStatus: true },
        { label: "OPERATION TYPE", value: "operation", isAsc: false, hasStatus: false },
        { label: "RECORDS SYNCED", value: "recordsSynced", isAsc: false, hasStatus: true }
    ];
    @track sortDirection = 'asc';
    @track recordsToDisplay = [];
    @track sortUp = punchhResources + '/icons/sortUp.svg';
    @track sortDown = punchhResources + '/icons/sortDown.svg';
    @track showSpinner = false;
    @track currentPage = 1;
    @track pageSize = 5;
    @track recordSetCount = 1;
    @track sortField = 'startedAt';

    get currentPageFirstRecordSeq() {
        if(this.historyRecords && this.historyRecords.length > 0){
            return (parseInt(this.currentPage) - 1) * parseInt(this.pageSize) + 1;
        } else {
            return 0;
        }
        
    }

    get currentPageLastRecordSeq() {
        if(this.historyRecords && this.historyRecords.length > 0){
            let totalRecords = this.historyRecords ? this.historyRecords.length : 0;
            let pageSize = parseInt(this.pageSize);
            let totalPages = Math.ceil(totalRecords / pageSize);
            if(parseInt(this.currentPage) == totalPages){
                return totalRecords;
            } else {
                return (parseInt(this.currentPage) * parseInt(this.pageSize));
            }
        } else {
            return 0;
        }
    }

    get hasNoRecords() {
        return this.historyRecords.length == 0;
    }

    get sizeOptions() {
        return [
            { label: 5, value: 5 },
            { label: 10, value: 10 },
            { label: 15, value: 15 }
        ];
    }

    get notHasPrevious() {
        let recordSetCount = parseInt(this.recordSetCount);
        if (recordSetCount && recordSetCount > 0) {
            return recordSetCount == 1;
        } else {
            return true;
        }
    }

    get notHasNext() {
        let recordSetCount = parseInt(this.recordSetCount);
        let totalRecords = this.historyRecords ? this.historyRecords.length : 0;
        let pageSize = parseInt(this.pageSize);
        if (recordSetCount && recordSetCount > 0 && totalRecords > 0 && pageSize && pageSize > 0) {
            let totalPages = Math.ceil(totalRecords / pageSize);
            let totalRecordSets = Math.ceil(totalPages / 7);
            return recordSetCount == totalRecordSets;
        } else {
            return true;
        }
    }

    get navigationButtons() {
        let count = (parseInt(this.recordSetCount) - 1) * 7;
        let totalRecords = this.historyRecords ? this.historyRecords.length : 0;
        let pageSize = parseInt(this.pageSize);
        let totalPages = Math.ceil(totalRecords / pageSize);
        let buttons = [];
        for (let i = 1; i <= 7; i++) {
            let btn = {};
            btn.pageNumber = (count + i);
            btn.disabled = (count + i) > totalPages;
            btn.isSelected = (count + i) == parseInt(this.currentPage);
            buttons.push(btn);
        }
        return buttons;
    }

    connectedCallback() {
        Promise.all([
            this.config = JSON.parse(JSON.stringify(this.configData))
        ]).then(() => {
            this.getScheduleHistoryData();
        }).catch(error => {
            this.spinner = true;
            this.error = error;
        });

    }

    getScheduleHistoryData() {
        try {
            if (this.scheduleRecord && this.scheduleRecord.id) {
                this.showSpinner = true;
                getScheduleHistory({ "scheduleId": this.scheduleRecord.id })
                    .then(result => {
                        if (result) {
                            if (result.statusCode == 200) {
                                let responseBody = JSON.parse(result.data);
                                this.historyRecords = responseBody.data;
                                if (this.historyRecords && this.historyRecords.length > 0) {
                                    this.loadPage();
                                }
                            } else if (result.statusCode == 401) {
                                this.saveAndTestHandler();
                            } else {
                                this.customShowToast("Error", result.message, "error", "pester");
                                if (!result.statusCode) {
                                    this.errorOccured();
                                }
                            }
                        } else {
                            this.customShowToast("Error", 'Error in fetching schedule history', "error", "pester");
                            this.errorOccured();
                        }
                        this.showSpinner = false;
                    })
                    .catch(error => {
                        this.showSpinner = false;
                        this.customShowToast("Error", result.message, "error", "pester");
                        this.errorOccured();
                    })
            }
        } catch (e) {}
    }

    errorOccured() {
        try{
            const evt = new CustomEvent('response', { detail: 'landingCompError' });
            this.dispatchEvent(evt);
        } catch(e) {}
    }

    back() {
        try{
            const evt = new CustomEvent('response', { detail: 'landingComp' });
            this.dispatchEvent(evt);
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
                this.currentPage = (parseInt(this.recordSetCount) - 1) * 7 + 1;
                this.loadPage();
            }
        } catch(e) {}
        
    }

    handleSizeChange(event) {
        try {
            if (event && event.detail && event.detail.value) {
                this.pageSize = parseInt(event.detail.value);
                this.currentPage = 1;
                this.recordSetCount = 1;
                this.loadPage();
            }
        } catch(e) {}
       
    }

    navigate(event) {
        try {
            if (event && event.target && event.target.dataset && event.target.dataset.pagenumber) {
                this.currentPage = parseInt(event.target.dataset.pagenumber);
                this.loadPage();
            }
        } catch(e) {}
    }

    loadPage() {
        try {
            let pageSize = parseInt(this.pageSize);
            let currentPage = parseInt(this.currentPage);
            let allRecords = this.historyRecords;
            if (allRecords && allRecords.length > 0 && pageSize && pageSize > 0 && currentPage && currentPage > 0) {
                let firstPosition = (currentPage - 1) * pageSize;
                let lastPosition = currentPage * pageSize;
                this.prepareDataWrapper(allRecords.slice(firstPosition, lastPosition));
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
                        row.jobId = record.jobId;
                        row.cells = [];
                        fields.forEach(field => {
                            if (field && field.value) {
                                var cell = {};
                                cell.label = field.value;
                                if (cell.label == 'recordsSynced') {
                                    let proccessRecord = parseInt(record.retrySuccess) + parseInt(record.processedRecords);
                                    cell.value = proccessRecord + ' of ' + record.batchProcessed;
                                } else if(cell.label == 'startedAt') {
                                    let dateTimeformat = record[field.value].toLocaleString('en-US', { timeZone: this.scheduleRecord.timezone })
                                    cell.value = this.formatDate(new Date(dateTimeformat));
                                } else {
                                    cell.value = record[field.value] ? record[field.value] : '';
                                }
                                if (field.hasStatus) {
                                    cell.hasStatus = true;
                                }
                                if (field.value == 'processState' && cell.value == 'inprogress') {
                                    cell.value = 'In Progress';
                                    row.inProgress = true;
                                } else if (field.value == 'processState' && cell.value == 'failed') {
                                    row.failed = true;
                                } else if (field.value == 'processState' && cell.value == 'open') {
                                   row.cells[0].value = (row.cells[0].label == 'startedAt') ? 'N/A' : '';
                                   row.done = true;
                                } else if (field.value == 'processState') {
                                    row.done = true;
                                }
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
        } catch (e) {
        }
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
            this.historyRecords = this.historyRecords.sort(this.compareValues(fieldName, this.sortDirection));
            this.loadPage();
        } catch (e) {
        }
    }

    compareValues(key, order = 'asc') {
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

    saveAndTestHandler() {
        this.config.action = 'SAVE';
        this.config.body = this.createBody(this.config.configData, this.config.action);
        validateOrSaveConnection({ inputJson: JSON.stringify(this.config) })
            .then(result => {
                if (result && result.statusCode == 200) {
                    if (result.status) {
                        this.getScheduleHistoryData();
                    } else {
                        this.customShowToast("Error", result.error, "error", "pester");
                    }
                } else {
                    this.customShowToast("Error", result.message, "error", "pester");
                    if (!result.statusCode) {
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

    showErrorMessage(error) {
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
            let currentTime = strTime;
            let startedAt = month + "/" + date.getDate() + "/" + date.getFullYear() + ", " + currentTime;
            return startedAt;
        } catch(e) {}
    }
}
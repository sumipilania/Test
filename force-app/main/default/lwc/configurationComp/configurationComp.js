import { LightningElement, track, api } from 'lwc';
import validateOrSaveConnection from "@salesforce/apex/PunchCalloutController.validateOrSaveConnection";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class ConfigurationComp extends LightningElement {

  @track showHideSaveBtn = true;
  @api localConfig;
  @api config;
  @track spinner = false;
  @track successFlag = false;

  connectedCallback() {
    if (this.localConfig == null || this.localConfig == undefined) {
      this.localConfig = JSON.parse(JSON.stringify(this.config));
      this.spinner = true;
    }
    if (this.localConfig && this.localConfig.configData && this.localConfig.configData.recId) {
      this.cancelOrCloseFlag = false;
    } else {
      this.cancelOrCloseFlag = true;
    }
  }

  saveAndTestHandler(event) {
    this.spinner = false;
    this.successFlag = false;
    this.localConfig.action = event.target.dataset.btn;
    for (let i of this.template.querySelectorAll('input')) {
      this.localConfig.configData[i.name] = i.value;
      if(!this.localConfig.configData[i.name]) {
        this.customShowToast("Error", 'Please fill out all inputs', "error", "pester");
        this.spinner = true;
        return null;
      }
    }
    this.localConfig.body = this.createBody(this.localConfig.configData, this.localConfig.action);
    validateOrSaveConnection({ inputJson: JSON.stringify(this.localConfig) })
      .then(result => {
        if (result && result.statusCode == 200) {
          if (result.status) {
            this.showHideSaveBtn = this.localConfig.action == 'Test' ? false : this.showHideSaveBtn;
            if (this.localConfig.action != 'Test') {
              const evt = new CustomEvent('updateconfig', { detail: result });
              this.dispatchEvent(evt);
              this.customShowToast("Success", result.message, "success", "pester");
            } else {
              this.successFlag = true;
            }
          } else {
            this.showHideSaveBtn = this.localConfig.action == 'Test' ? true : this.showHideSaveBtn;
            this.customShowToast("Error", result.error, "error", "pester");
          }
        } else {
          this.showHideSaveBtn = this.localConfig.action == 'Test' ? true : this.showHideSaveBtn;
          this.customShowToast("Error", result.message, "error", "pester");
          if (!result.statusCode) {
            this.errorOccured();
          }
        }
        this.spinner = true;
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
        this.spinner = true;
      });
  }

  cancelHandler() {
    try {
      this.spinner = false;
      const evt = new CustomEvent('response', { detail: 'landingCompRefresh' });
      this.dispatchEvent(evt);
    } catch(e) {}
  }

  createBody(configData, action) {
    try {
      if (configData && action) {
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
    } catch (e) {}
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

  errorOccured() {
    try {
      const evt = new CustomEvent('response', { detail: 'landingCompError' });
      this.dispatchEvent(evt);
    } catch(e) {}
  }
}
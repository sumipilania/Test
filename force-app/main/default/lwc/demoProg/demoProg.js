import { LightningElement, api } from "lwc";
import {
  FlowAttributeChangeEvent,
  FlowNavigationNextEvent
} from "lightning/flowSupport";

export default class DemoProg extends LightningElement {
  @api recordId; // provided by the contact record page
  @api selectedAccs ;
  @api selectedAccsString;
  connectedCallback() {
    const attributeChangeEvent = new FlowAttributeChangeEvent(
      "selectedAccs",
      "My Account LWc"
    );
    this.dispatchEvent(attributeChangeEvent);
   
  }
  handleNext(event) {
    const nextNavigationEvent = new FlowNavigationNextEvent();
    this.dispatchEvent(nextNavigationEvent);
    console.log('selectedAccs=',this.selectedAccs);
    console.log('selectedAccsString=',this.selectedAccsString);
  }
}
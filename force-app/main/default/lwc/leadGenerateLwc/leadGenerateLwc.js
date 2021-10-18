import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LeadGenerateLwc extends LightningElement {
    @track displayMessage = '';
    @track radioOption = [
        {'label': 'Standred', 'value': 'Standred'},
        {'label': 'Custom', 'value': 'Custom'},
    ];
    @track nextScreenShowHide = false;
    
    nextHandler() {
      this.nextScreenShowHide = true;
    }
    cancel() {
      this.dispatchEvent(new CustomEvent('close'));
    }
    handleRadioChange(event){
        console.log('handleRadioChange');
        console.log('val==',event.target.value);
    }
}
import { LightningElement, api } from 'lwc';

export default class CustomLookup extends LightningElement {

    @api objectName = 'Contact'; //Contact is the default value
    @api targetFieldApiName = 'AccountId'; //AccountId is the default value
    @api fieldLabel = 'Your field label here';
    @api disabled = false;
    @api value;
    @api required = false;

    handleChange(event) {
       console.log('event.detail.value=',event.detail.value);
       console.log('value=',this.value);
       console.log('data=',this.value);
       
    }

}
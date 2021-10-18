import { LightningElement } from 'lwc';
import {loadScript} from 'lightning/platformResourceLoader';
import lightpick from '@salesforce/resourceUrl/lightpick';
import moment from '@salesforce/resourceUrl/moment';
export default class LightPickThirdPartyCalendre extends LightningElement {

    
	demo() {
        console.log('renderedCallback=');

			Promise.all([
				loadScript(this, lightpick),
				loadScript(this, moment)
			]).then(() => {
				console.log('Files loaded.');
			}).catch(error => {
				let errorMessage;
				if (error) {
					if (Array.isArray(error.body)) {
						errorMessage = error.body.map(e => e.message).join(", ");
					} else if (typeof error.body.message === "string") {
						errorMessage = error.body.message;
					}
				}
				if (errorMessage) {
                    console.log('errorMessage=',errorMessage);
				//	this.customShowToast("Error", errorMessage, "error", "pester");
				}
			});
    }
    
    connectedCallback() {
        this.demo();
        console.log('connectedCallback=');
        var picker = new Lightpick({
            field: document.getElementById('demo-2'),
            singleDate: false,
            onSelect: function(start, end){
                var str = '';
                str += start ? start.format('Do MMMM YYYY') + ' to ' : '';
                str += end ? end.format('Do MMMM YYYY') : '...';
                document.getElementById('result-2').innerHTML = str;
            }
        });
        console.log('picker=',picker);
    }
}
import { LightningElement, track, api } from 'lwc';
import {
    FlowNavigationNextEvent
  } from "lightning/flowSupport";

export default class CustomForm extends LightningElement {

    @api height = '500px';
    @api width = '100%';
    @track _uuid;

    get url() {
        return '/apex/FormVf?formid='+this.uuid;
    }

    @api 
    get uuid() {
        return this._uuid;
    }

    set uuid(value) {
        this._uuid = value;
    }

    @track messageFromVF;
    @api availableActions = [];

    connectedCallback() {
        window.addEventListener("message", (message) => {
            console.log("some message received",JSON.stringify(message, null, 2));

            //handle the message
            if (message.data.name === "completeEvent") {
                this.messageFromVF = message.data.payload;
            }
            console.log("some message received",this.messageFromVF);
            this.gotoNextScreen();
        });
    }

    
    gotoNextScreen() {
        if (this.availableActions.find((action) => action === "NEXT")) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }
}
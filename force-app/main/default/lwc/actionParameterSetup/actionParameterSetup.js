import { LightningElement, api, track, wire } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import VFID_FIELD from "@salesforce/schema/Action_Parameter__c.VisualForce_Page_Id__c";
import SITEID_FIELD from "@salesforce/schema/Action_Parameter__c.Site__c";

const fields = [VFID_FIELD, SITEID_FIELD];

import updateActionParameterSite from '@salesforce/apex/ActionParameterSetupController.updateActionParameterSite';
import updateActionParameterPage from '@salesforce/apex/ActionParameterSetupController.updateActionParameterPage';

export default class ActionParameterSetup extends LightningElement {
    //Variable declaration.
    @api recordId;
    error;
    siteInfo;
    pageInfo;


    //life-cycle hooks

    //handlers
    @wire(getRecord, { recordId: "$recordId", fields })
    action_parameter;

    get vfpageId() {
        return getFieldValue(this.action_parameter.data, VFID_FIELD);
    }

    get siteId() {
        return getFieldValue(this.action_parameter.data, SITEID_FIELD);
    }

    handleSaveClick(event) {
        
        if (this.siteId != this.siteInfo.Id) {
            updateActionParameterSite({ recordId : this.recordId , objectWrapper : JSON.stringify(this.siteInfo) })
            .then((result) => {
                this.showToast('Success', 'Successfully updated!', 'success');
                this.dispatchEvent(new RefreshEvent());
            })
            .catch((error) => {
                this.error = error;
                this.showToast('Error', error, 'error');
            });
    
        }
        else if (this.vfpageId != this.pageInfo.Id) {
            updateActionParameterPage({ recordId : this.recordId , objectWrapper : JSON.stringify(this.pageInfo) })
            .then((result) => {
                this.showToast('Success', 'Successfully updated!', 'success');
                this.dispatchEvent(new RefreshEvent());
            })
            .catch((error) => {
                this.error = error;
                this.showToast('Error', error, 'error');
            });
    
        }
    }

    handleHealthCheck(event) {
        
    }

    handleSelect(event) {
        let message = event.detail;
        
        if (message.fieldtype == "vfpage") {
            console.log('message ', JSON.stringify(message.selectedRecord.record, null, 2));
            this.pageInfo = message.selectedRecord.record;
        }
        else if (message.fieldtype == "site") {
            console.log('message ', JSON.stringify(message.selectedRecord.record, null, 2));
            this.siteInfo = message.selectedRecord.record;
        }
    }

    showToast(titletext, messagetext, variantname) {
        const event = new ShowToastEvent({
            title: titletext,
            message: messagetext,
            variant: variantname,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

}
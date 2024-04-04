import { LightningElement,api,wire, track} from 'lwc';
// import apex method from salesforce module 
import getSearchResult from '@salesforce/apex/LookupController.getSearchResult';
import fetchDefaultRecord from '@salesforce/apex/LookupController.fetchDefaultRecord';
const DELAY = 1000; // dealy apex callout timing in miliseconds  

export default class CustomLookupLwc extends LightningElement {
    // public properties with initial default values 
    @api label = '';
    @api placeholder = 'search...'; 
    @api iconName = 'standard:insights';
    @api sObjectApiName = '';
    // @api defaultRecordId = '';
    @api isObjectLookup = false;
    @api fieldType = "";

    @api
    get defaultRecordId() {
        return this._defaultRecordId;
    }
    set defaultRecordId(value) {
        this._defaultRecordId = value;
        this.getDefaultRecord();
    }

    //sObject api name for merge fields
    sObjectOne = '';
    sObjectTwo = '';
    sObjectThree = '';
    sObjectFour = '';
    
    // private properties 
    @track lstResult = []; // to store list of returned records   
    hasRecords = true; 
    searchKey=''; // to store input field value    
    isSearchLoading = false; // to control loading spinner  
    delayTimeout;
    @track selectedRecord = {}; 
    @track fieldApiName = '';

    get readOnlyField() {
        return !this.selectedRecord.expand;
    }
    
    // to store selected lookup record in object formate 
   // initial function to populate default selected lookup record if defaultRecordId provided  
    connectedCallback(){
        //  if(this._defaultRecordId != ''){
        //     this.getDefaultRecord();
        //  }
    }

    getDefaultRecord() {
        fetchDefaultRecord({ recordId: this._defaultRecordId , 'sObjectApiName' : this.sObjectApiName })
        .then((result) => {
            if(result != null){
                console.log('default ', this.sObjectApiName, JSON.stringify(result, null, 2))
                this.selectedRecord = result;
                this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
            }
        })
        .catch((error) => {
            this.error = error;
            this.selectedRecord = {};
        });
    }
    // wire function property to fetch search record based on user input
    @wire(getSearchResult, 
        { 
            sObjectApiName : '$sObjectApiName' ,
            searchKey: '$searchKey' 
        })
     searchResult(value) {
        const { data, error } = value; // destructure the provisioned value
        this.isSearchLoading = false;
        if (data) {
            // console.log('results data before',data.length,JSON.stringify(data, null, 2));
            this.hasRecords = data.length == 0 ? false : true; 
            try {
                // data.forEach((element) => {
                //     console.log('element ', element, this.uuidv4());
                //     try { 
                //         let randomid = this.uuidv4();
                //         element.uuid = randomid;
                //         console.log('element after ', element);
                //     } catch (e) {
                //         console.error('wire error 12',JSON.stringify(e, null, 2));
                //     }
                // });
                // console.log('elements ', JSON.stringify(data, null, 2));
                this.lstResult = JSON.parse(JSON.stringify(data)); 
                // console.log('results data',JSON.stringify(this.lstResult, null, 2));
            } catch (e) {
                console.log('wire error ',JSON.stringify(e, null, 2));
            }
            
         }
        else if (error) {
            console.log('(error---> ' + JSON.stringify(error));
         }
    };

    uuidv4() {
        return "10000000-1000-4000-8000-100000000000".replace(/[018]/g, c =>
          (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
        );
    }
       
    // update searchKey property on input field change  
    handleKeyChange(event) {
        // Debouncing this method: Do not update the reactive property as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        // if(!this.isObjectLookup) {
        //     this.toggleResult(event);
        // }
        this.isSearchLoading = true;
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.searchKey = searchKey;
        }, DELAY);
    }

    handleKeyChangeInField(event) {
        this.isSearchLoading = true;
        this.toggleResult(event);
        window.clearTimeout(this.delayTimeout);
        const fullSearchKey = event.target.value;
        // let searchKey = fullSearchKey.split(".").pop();
        // console.log('key changed ', event.target.value, ' search key ',fullSearchKey);
        // console.log('selected record ', this.selectedRecord);
        // this.fieldApiName = fullSearchKey;
        // this.searchKey = fullSearchKey;

        this.delayTimeout = setTimeout(() => {
            this.searchKey = fullSearchKey;
        }, DELAY);
    }

    // method to toggle lookup result section on UI 
    toggleResult(event){
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer.classList;
        const whichEvent = event.target.getAttribute('data-source');
        console.log('whichEvent ', whichEvent );
        switch(whichEvent) {
            case 'searchInputField':
                clsList.add('slds-is-open');
                break;
            case 'lookupContainer':
                clsList.remove('slds-is-open');    
                break;                    
           }
    }

   // method to clear selected lookup record  
   handleRemove(){
        this.searchKey = '';    
        this.selectedRecord = {};
        this.lookupUpdatehandler(undefined); // update value on parent component as well from helper function 
        
        // remove selected pill and display input field again 
        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        searchBoxWrapper.classList.remove('slds-hide');
        searchBoxWrapper.classList.add('slds-show');
        const pillDiv = this.template.querySelector('.pillDiv');
        pillDiv.classList.remove('slds-show');
        pillDiv.classList.add('slds-hide');
    }

    // method to update selected record from search result 
    handelSelectedRecord(event){   
        var objId = event.target.getAttribute('data-recid'); // get selected record Id 
        this.selectedRecord = this.lstResult.find(data => data.uuid === objId); // find selected record from list 
        this.fieldApiName = this.selectedRecord.optionName;
        if(!this.isObjectLookup) {
            this.searchKey = this.selectedRecord.optionName;
            const inputField = this.template.querySelector('.lookup-field-main');
            if(inputField && this.searchKey && this.searchKey.endsWith(".")) {
                inputField.focus();
                return;
            }
                
        }

        //set primary sObject and send it to parent component
        

        // console.log('pushed ', JSON.stringify({...this.selectedRecord}, null, 2));
        this.lookupUpdatehandler({...this.selectedRecord});
        
        // if(this.isObjectLookup)
            this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
        // else 
        //     this.handleLookUpOpen();
    }

    renderedCallback() {
        this.handleInputFieldFocus();
    }

    handleInputFieldFocus() {
        const inputField = this.template.querySelector('.combobox-id-field');
        if(inputField)
            inputField.focus();
        console.log('on focus', inputField);
    }

    /*COMMON HELPER METHOD STARTED*/
    handelSelectRecordHelper(){
        console.log('handelSelectRecordHelper init');
        this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        searchBoxWrapper.classList.remove('slds-show');
        searchBoxWrapper.classList.add('slds-hide');
        const pillDiv = this.template.querySelector('.pillDiv');
        pillDiv.classList.remove('slds-hide');
        pillDiv.classList.add('slds-show');     

        
    }

    handleLookUpOpen() {
        this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
        
    }
    
    // send selected lookup record to parent component using custom event
    lookupUpdatehandler(value){    
            const oEvent = new CustomEvent('lookupupdate',
            {
                'detail': { selectedRecord: value, fieldtype : this.fieldType }
            }
            );
            this.dispatchEvent(oEvent);
    }
}
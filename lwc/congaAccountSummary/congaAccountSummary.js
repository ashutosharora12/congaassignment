import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CONTACTS_DATA from '@salesforce/apex/CONGA_ContactsData_Controller.getContactsForAccount'
export default class CongaAccountSummary extends LightningElement {
    //@api recordId; //when placed on Account Record Page - this would hold the Account record Id
    @api set recordId(value){
        this.sAccountId = value;
    }
    get recordId(){
        return this.sAccountId;
    }
    sAccountId;
    bShowCustomerSuccessContacts = false;
    bShowAppDeveloperContacts = false;
    //Contact title to be fetched.
    lstContactTitles = ['Customer Success', 'Application Developer'];
    //Child relationship name
    sChildToQuery = 'Contacts';
    //list of columns to display in lightning-datatable
    columns = [
        {label : 'Last Name', fieldName : 'LastName'},
        {label : 'Title', fieldName : 'Title'}
    ];
    
    //fetches contacts under account that have title in lstContactTitles
    @wire(CONTACTS_DATA, {sAccountId : '$sAccountId' , lstTitles : '$lstContactTitles'})
    contactsData(result){
        if(result.data){
            this.lstContactsData = result.data;
            //check if Contacts with Custom Success and Application Developer title exist for the Account
            this.bShowCustomerSuccessContacts = (this.lstContactsData.filter(obj => obj.Title === 'Customer Success')).length > 0;
            this.bShowAppDeveloperContacts = (this.lstContactsData.filter(obj => obj.Title === 'Application Developer')).length > 0
        }else {
            this.showToastMessage('Error Occurred, please report this to your Admin.', 'Error', 'error');
        }
    }
    //get Contacts with Customer Success title
    get CustomerSuccessContacts(){
        return this.lstContactsData.filter(obj => obj.Title === 'Customer Success');
    }
    //get Contacts with Application Developer title
    get appDeveloperContacts(){
        return this.lstContactsData.filter(obj => obj.Title === 'Application Developer');
    }
    
    //generic method to show toast message
    showToastMessage(sMessage, sTitle, sVariant){
        const toastEvent = new ShowToastEvent({
                            title : sTitle,
                            message : sMessage,
                            variant : sVariant 
                            });
        this.dispatchEvent(toastEvent);
    }
}
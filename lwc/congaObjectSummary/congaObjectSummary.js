import { LightningElement , api, wire} from 'lwc';
import OBJECT_SUMMARY from '@salesforce/apex/Conga_ObjectSummary_Controller.getObjectSummaryData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class CongaObjectSummary extends LightningElement {
    lstSummaryData = [];
    @api recordId; //record Id for which summary data is to be displayed
    @api sChildToQuery; //Child relationship name passed from parent component - to query count of child records
    //called on load - fetches list of summary data - Field label & its value 
    connectedCallback(){
        console.log('recordId : ' ,this.recordId);
        console.log('sChildToQuery : ' ,this.sChildToQuery);
    }
    @wire(OBJECT_SUMMARY, {sRecordId : '$recordId', sChildToQuery : '$sChildToQuery'})
    accountFields(result){
        if(result.data){
            console.log('result.data &&&&&: ' ,result.data);
            this.lstSummaryData = result.data;
            console.log('this.lstSummaryData : ' ,this.lstSummaryData);
        }else {
            this.showToastMessage('Error Occurred, please report this to your Admin.', 'Error!!!', 'error');
        }
    }

    //generic method to show toast messages - make a separate reusable component for this**
    showToastMessage(sMessage, sTitle, sVariant){
        const toastEvent = new ShowToastEvent({
                            title : sTitle,
                            message : sMessage,
                            variant : sVariant 
                            });
        this.dispatchEvent(toastEvent);
    }
}
/**
 * RaiseLeadsTable Component
 * @description This component manages the leads table for the raise process. It handles displaying leads data, updating lead records, and fetching necessary picklist values from the server.
 * 
 * @example
 * <c-raise-leads-table record-id={recordId}></c-raise-leads-table>
 */

import { LightningElement ,api, track} from 'lwc';
import apex_getRecords from '@salesforce/apex/LeadControllerNew.getRecords';
import apex_updateLead from '@salesforce/apex/LeadControllerNew.updateLead';

export default class RaiseLeadsTable extends LightningElement {
    @api recordId; // The record ID of the raise.

    apexGetRecords = apex_getRecords; // Reference to the Apex method for getting records.
    apexUpdateRecord = apex_updateLead; // Reference to the Apex method for updating a lead record.

    objectName = 'Lead'; // Name of the object for the records.

    pageSize = 10; // Number of records to display per page.

    // An array of fields to fetch picklist values.
    picklistFields =  [
        {formField: 'callBackReq', variableName:'callBackOptions', fieldName : 'Call_back_required__c'},
        {formField: 'founderStatus', variableName:'founderStatusOptions', fieldName : 'Founder_status__c'},
    ]

    @track columns = [
        { label: 'Date created', fieldName: 'CreatedDate', type: 'date', sortable: true, width: 5 },
        { label: 'Status', fieldName: 'Status', type: 'text', sortable: true , width: 5},
        { label: 'Investment amount', fieldName: 'Investment_Amount__c', type: 'text', sortable: true , width: 5},
        { label: 'Web source', fieldName: 'Web_Source__c', type: 'text', sortable: true , width: 5},
        { label: 'Lead source', fieldName: 'LeadSource', type: 'text', sortable: true , width: 5},
        { label: 'First name', fieldName: 'FirstName', type: 'text', sortable: true , width: 10},
        { label: 'Last name', fieldName: 'LastName', type: 'text', sortable: true, width: 5 },
        { label: 'Email', fieldName: 'Email', type: 'text', sortable: true , width: 10},
        { label: 'Mobile phone', fieldName: 'MobilePhone', type: 'text', sortable: true , width: 5},
        { 
            label: 'Comments', 
            fieldName: 'Comments__c', 
            type: 'input', 
            attributes:{
                inputType: 'text',
                name: 'comments',
            },
            sortable: true , 
            width: 30
        },
        { 
            label: 'Call back required', 
            fieldName: 'Call_back_required__c', 
            type: 'input', 
            attributes:{
                name: 'callBackReq',
                inputType: 'dropdown',
                selectOptions : 'callBackOptions',
            },
            sortable: true,
            width: 5
        },
        { 
            label: 'Founder status', 
            fieldName: 'Founder_status__c', 
            type: 'input', 
            attributes:{
                name: 'founderStatus',
                inputType: 'dropdown',
                selectOptions : 'founderStatusOptions',
            },
            sortable: true ,
            width: 15
        },
    ];

}
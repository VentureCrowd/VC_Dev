/**
 * RaiseOpportunitiesTable Component
 * @description This component manages the opportunities table for the raise process. It handles displaying opportunity data, updating opportunity records, and fetching necessary picklist values from the server.
 * 
 * @example
 * <c-raise-opportunities-table record-id={recordId}></c-raise-opportunities-table>
 */

import { LightningElement, api, track } from 'lwc';
import apex_getRecords from '@salesforce/apex/OpportunitiesController.getRecords';
import apex_updateRecord from '@salesforce/apex/LeadControllerNew.updateLead';
export default class RaiseOpportunitiesTable extends LightningElement {
    @api recordId; // The record ID of the raise.

    apexOpportunityMethod = apex_getRecords; // Reference to the Apex method for getting opportunity records.
    apexUpdateRecord = apex_updateRecord; // Reference to the Apex method for updating an opportunity record.

    objectName = 'Opportunity'; // Name of the object for the records.

    pageSize = 10; // Number of records to display per page.

    // An array of fields to fetch picklist values.
    picklistFields =  [
        {formField: 'callBackReq', variableName:'callBackOptions', fieldName : 'Call_back_required__c'},
        {formField: 'founderStatus', variableName:'founderStatusOptions', fieldName : 'Founder_status__c'},
    ]

    @track columns = [
        { label: 'Stage', fieldName: 'StageName', type: 'text', sortable: true , width: 10},
        { label: 'Opportunity Name', fieldName: 'Name', type: 'text', sortable: true , width: 15},
        { label: 'Amount', fieldName: 'Amount', type: 'text', sortable: true , width: 5},
        { label: 'Date created', fieldName: 'CreatedDate', type: 'date', sortable: true, width: 10 },
        { label: 'Email', fieldName: 'Person_Account_Email__c', type: 'text', sortable: true , width: 10},
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
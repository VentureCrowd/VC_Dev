import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createAccount from '@salesforce/apex/createAccountEntity.createAccount';
export default class CreateAccountEntity extends LightningElement {
    popup = false;
    showACN = true;
    showHeldInTrust = false;
    showTrustname_1 = false;
    showspinner = false;
    @track showCaseOptions = false;
    hinhelptxt = 'A HIN is a unique number that is issued to you by ASX when you become a client of a broker. You can find your HIN on a CHESS statement, by speaking to your broker or logging into your online trading account. A HIN starts with the letter X, followed by ten numbers, e.g. X0001234567. Some trading platforms hide the letter "X" and preceding zeros. Please include the "X" and the zeros when entering a HIN to your VentureCrowd portal.';
    createEntity(){
        this.showspinner = true;
        let inputelements = this.template.querySelectorAll('lightning-input');
        let allelements = Array.from(inputelements);
        let isformvalid = true;
        allelements.forEach(ele =>{
            ele.value = ele.value ? ele.value.trim() : ele.value;
            ele.reportValidity();
            isformvalid = isformvalid & ele.checkValidity();
        })
        let inputareaelements  = this.template.querySelector('c-loqate-address');
        isformvalid = isformvalid && inputareaelements.checkValidity();
        let datamap = {};
        if(isformvalid){
            allelements.forEach(ele =>{
                if(ele.type == 'number'){
                    datamap[ele.dataset.id] = parseInt(ele.value);
                }else if(ele.type == 'checkbox'){
                    datamap[ele.dataset.id] = ele.checked;
                }else{
                    datamap[ele.dataset.id] = ele.value;
                }
            })
            if(this.showHeldInTrust)
            datamap['Held_in_trust__c'] = true;
            let address = this.template.querySelector('c-loqate-address');
            datamap['BillingStreet'] = address.street ;
            datamap['BillingCity'] = address.city ;
            datamap['BillingState'] = address.state ;
            datamap['BillingPostalCode'] = address.postcode ;
            datamap['BillingCountry'] = address.country ;            
            createAccount({datamap})
            .then(r =>{
                if(r == 'Sucess'){  
                this.popup = false;
                this.showtoast('Your new entity application has been received. Before you can invest with this new entity, our team will reach out to you shortly to verify the information submitted. Won?t be a moment!','success');
                this.showspinner = false;
                }else{
                    r = r.includes('A HIN starts with a letter and followed by ten n') ? 'A HIN starts with a letter and followed by ten numbers, e.g. X0001234567' : r;
                    this.showtoast(r,'error');
                    this.showspinner = false;
                }                
            })
            .catch(e => {
                console.log(e);
                this.showtoast('We hit a snag. We are unable to process the application. Please call 1300 039 655 or email us at investor@venturecrowd.com.au for assistance. Thank you for your patience.','error');
                this.showspinner = false;
            })
        }else{
            this.showspinner = false;
            this.showtoast('Please fill in all the details','error');
        }
    }
    showpopup(){
        this.popup = true;
    }
    closeppup(){
        this.popup = false;
    }
    showtoast(m,k){
        this.dispatchEvent(
            new ShowToastEvent({
                title: m,
                variant: k
            })
        );
    }
    handleChange(event){
        this.showACN = false;
        this.showHeldInTrust = false;
        if(event.target.value == 'Company'){
            this.showACN = true;
        }else if(event.target.value == 'Trust'){
            this.showHeldInTrust = true;
            console.log('this.showHeldInTrust = true; :');
        }
    }
    get options() {
        return [
            { label: 'Company', value: 'Company' },
            { label: 'SMSF', value: 'SMSF' },
            { label: 'Sole Trader', value: 'Sole Trader' },
            { label: 'Trust', value: 'Trust' },
        ];
    }
    checkboxchange(event){
    }

    handleShowCaseOption() {
        if (this.showCaseOptions) {
            this.showCaseOptions = false;
        } else {
            this.showCaseOptions = true;
        }
    }

    handleShowCaseOptionFalse() {
        this.showCaseOptions = false;
    }

    handleOnClickCaseOption(event) {
        this.caseOption = event.target.dataset.value;   
        console.log('caseOption :', this.caseOption);
        this.showCaseOptions = false;
        this.completeVisibility = false;
        this.showACN = false;
        this.showHeldInTrust = false;
        if(event.target.dataset.value == 'Company'){
            this.showACN = true;
        }else if(event.target.dataset.value == 'Trust'){
            this.showHeldInTrust = true;
            console.log('handleOnClickCaseOption this.showHeldInTrust = true; :');
        }

    }

}
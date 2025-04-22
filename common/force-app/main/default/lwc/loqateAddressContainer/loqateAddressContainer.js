import { LightningElement,api } from 'lwc';
import loqateFinder from '@salesforce/apex/LoqateHelper.loqateFinder';
import loqateRetriever from '@salesforce/apex/LoqateHelper.loqateRetriever';
export default class LoqateAddressContainer extends LightningElement {
    @api label='Mailing Address';
    cntryVal = 'au';
    chosenCountry = 'Australia';

    //
    showCaseOptions = false;
    //
    
    handlecntrychange(event){
        this.cntryVal = event.detail.value;
    }

    options =[
        { label: 'Australia', value: 'Australia' },
        { label: 'New Zealand', value: 'New Zealand' },
    ];

    handinputchange(event){
        debugger;
        this.loqatefind(this.cntryVal,event.detail)
    }
    optionsel(event){
        debugger;
        
        this.loqateret(event.detail);
    }
    loqatefind(country, searchtext){
        loqateFinder({country,adress : searchtext})
        .then(res =>{
            this.template.querySelector('c-search-combobox').options = res;
        })
        .catch(e => console.log(e));
    }
    loqateret(addId){
        loqateRetriever({id : addId})
        .then(res => {
            this.dispatchEvent(new CustomEvent('doupdate', { detail: res }));
            // this.street =  res.subdwelling+' '+res.streetNumber+' '+res.street;
            // this.template.querySelector('[data-id="street"]').value = this.street;
            // this.city = res.locality;;
            // this.template.querySelector('[data-id="city"]').value = this.city;
            // this.state = res.state;
            // this.template.querySelector('[data-id="state"]').value = this.state;
            // this.postcode = res.postcode;
            // this.template.querySelector('[data-id="zip"]').value = this.postcode;
            // this.country = res.country;
            // this.template.querySelector('[data-id="country"]').value = this.country;
        })
        .catch(e => console.log(e));
    }

    showOptions() {
        if (this.showCaseOptions) {
            this.showCaseOptions = false;
        } else {
            this.showCaseOptions = true;
        }
    }

    hideOptions() {
        this.showCaseOptions = false;
    }

    handleCountryChange(event) {
        this.chosenCountry = event.target.dataset.value;
        console.log('chosenCountry :', this.chosenCountry);
        if(this.chosenCountry == 'Australia'){
            this.cntryVal = 'au';   
            console.log('this.cntryVal :', this.cntryVal);
        }else{
            this.cntryVal = 'nz';
            console.log('this.cntryVal :', this.cntryVal);
        }
        this.showCaseOptions = false;
    }

    get options() {
        return [
            { label: 'Australia', value: 'au' },
            { label: 'New Zealand', value: 'nz' },
        ];
    }
}
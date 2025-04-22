import { LightningElement, track } from 'lwc';
import communityLogin from '@salesforce/apex/ReCaptchaAuraController.communityLogin';
import getEOICompany from '@salesforce/apex/ReCaptchaAuraController.getEOICompanyId';

export default class SelfRegister_Thankyouv2 extends LightningElement {
    @track eoiRecord;
    abn;

    connectedCallback() {
        this.initializeComponent();
    }

    //? Get the Id of the Company Recently Created
    async initializeComponent() {
        let url = new URL(window.location.href);
        this.abn = url.searchParams.get("abn"); // Assign ABN to the class variable
        if (this.abn) {
            try {
                const result = await getEOICompany({ acn: this.abn });
                this.eoiRecord = result;
            } catch (error) {
                console.error('Error fetching EOI Company:', error);
            }
        }
        this.redirectUser();

    }

    //? Get the values from newRegistration and then assign them to the corresponding properties
    redirectUser() {
        let url = new URL(window.location.href);
        let email = atob(decodeURIComponent(url.searchParams.get("eml")));
        let pwd = atob(decodeURIComponent(url.searchParams.get("pd")));
        let investentity = url.searchParams.get("investentity");
        let selectedValue = url.searchParams.get("selectedValue");
        let landingurl;
        //* If it's founder and it's record EOI go to the edit page
        if (selectedValue == 'Founder' && this.eoiRecord) {
            landingurl = `/s/portal/my-companies/edit-eoi?edit=${this.eoiRecord}`;
        //* If the checkbox of entity is checked go to my entities
        } else if (investentity == 'true') {
            landingurl = '/s/portal/my-entities';
        } else {
            landingurl = '/s/portal/portfolio';
        }

        //* ReCaptchaAuraController method
        communityLogin({ email, pwd, landingurl })
        .then(res => {
            window.location.href = res;
        })
        .catch(e => console.error(e));
    }
}
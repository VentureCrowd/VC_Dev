import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import updateAccountVerificationDetails from "@salesforce/apex/VerificationController.updateAccountVerificationDetails";
import getverificationresult from "@salesforce/apex/VerificationController.getverificationresult";

const columns = [
{ label: 'Verification Result', fieldName: 'verificationResult' },
{ label: 'Verifiction Id', fieldName: 'verificationId' },
{ label: 'Verification Token', fieldName: 'verificationToken' },
{ label: 'Given Name', fieldName: 'givenName' },
{ label: 'Middle Name', fieldName: 'middleNames' },
{ label: 'Sur Name', fieldName: 'surname' },
{ label: 'Email', fieldName: 'email' },
{ label: 'Date of Birth', fieldName: 'dob' },
{ label: 'Street Number', fieldName: 'streetNumber' },
{ label: 'Street Name', fieldName: 'streetName' },
{ label: 'Sub Urb', fieldName: 'suburb' },
{ label: 'Postal Code', fieldName: 'postcode' },
{ label: 'Country', fieldName: 'country' },
];
export default class VenturecrowdVerificationStatus extends NavigationMixin(
  LightningElement
) {
  @api verificationToken;
  @api verificationResult;

  baseUrl = "https://simpleui-au.vixverify.com/df/verificationResult";
  accountId = "venturecrowd";
  webServicePassword = "KXE-Ycz-3M9-VCN";
  data = [];
  showError = false;
  @track showSpinner = true;

  @track isVerificationSuccesful = false;
  @track isInProgress = false;
  @track isError = false;
  @track isPending = false;
  @track isLockedOut = false;
  @track isNull = false;
  

  async connectedCallback() {
    if (this.verificationToken) {
      getverificationresult({accountId:this.accountId,webServicePassword:this.webServicePassword,verificationToken:this.verificationToken})
      .then(res => {
        switch (res) {
            case 'VERIFIED','VERIFIED_ADMINS','VERIFIED_WITH_CHANGES':
                this.isVerificationSuccesful = true;
            break;
            case 'IN_PROGRESS':
                this.isInProgress = true;
            break;
            case 'ERROR':
                this.isError = true;
            break;
            case 'PENDING':
                this.isPending = true;
            break;
            case 'LOCKED_OUT':
                this.isLockedOut = true;
            break;
            default:
                this.isNull = true;
            break;
        }
      })
      .catch(e => console.log(e));
    }
  }

  updateCurrentAccount() {
    updateAccountVerificationDetails({
      dataToBeUpdated: JSON.stringify(this.data)
    })
      .then((result) => {
        if (result === "Success") {
          console.log('vefificarion'+this.verificationResult);
          //this.handleNavigation();
        } else {
          this.showError = true;
        }
      })
      .catch((error) => {
        console.error(JSON.stringify(error));
        this.showError = true;
      });
  }

  handleNavigation() {
    let windoworigin = window.location.origin;

    this.dispatchEvent(new CustomEvent(
        'navpage', 
        {
            detail :`${windoworigin}/s/portal/portfolio`,
            bubbles: true,
            composed: true,
        }
    ));
  }

  fetchDataHelper() {
    let xmlhttp = new XMLHttpRequest();
    xmlhttp.open('POST', 'https://au.vixverify.com/Registrations-Registrations/DynamicFormsServiceV3', true);
    let sr = '<?xml version="1.0" encoding="utf-8"?> <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dyn="http://dynamicform.services.registrations.edentiti.com/"><soapenv:Header/><soapenv:Header/>';
      sr = sr + `<soapenv:Body><dyn:getVerificationResult><accountId>${this.accountId}</accountId><password>${this.webServicePassword}</password><verificationToken>${this.verificationToken}</verificationToken></dyn:getVerificationResult></soapenv:Body></soapenv:Envelope>` ;
    xmlhttp.onreadystatechange = () => {
      console.log(xmlhttp.readyState ,xmlhttp.status,xmlhttp.responseText);
      // if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
        
      // }
    }
    xmlhttp.setRequestHeader('Content-Type', 'text/xml');
    debugger;
    console.log(sr);
    xmlhttp.send(sr);
    return null;
  }

  handlePageReload() {
    let windoworigin = window.location.origin;
    this.dispatchEvent(new CustomEvent(
        'navpage', 
        {   
            detail :`${windoworigin}/s/venture-verification`,
            bubbles: true,
            composed: true,
        }
    )); 
  }
}
import { LightningElement,track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import checkVerificationNeeded from "@salesforce/apex/VerificationController.checkVerificationNeeded";

export default class VerifyNowContainer extends NavigationMixin(LightningElement) {

  @track buttonLabel = '';
  @track displayComponent = false;
  @track displayButton = false;
  @track displayText = '';
  @track displayHelpline = false;

  statusLockedOut = 'LOCKED_OUT';
  statusNull = 'null';
  statusError = 'ERROR';
  statusInProgress = 'IN_PROGRESS';
  statusPending = 'PENDING';
  connectedCallback() {
    this.initiateVerification();
  }
  async initiateVerification() {

    try {
      const retrievedAccount = await checkVerificationNeeded();
  
      if (( !retrievedAccount?.GreenId_Status__c
            || retrievedAccount?.GreenId_Status__c == this.statusNull
            || retrievedAccount?.GreenId_Status__c == this.statusError )
          && !retrievedAccount?.ID_Checked__pc) {
          this.displayButton = true;
          this.displayText = 'Verify your identity';
          this.buttonLabel = 'Verify Now';
          this.displayComponent = true;
      }
      else if (retrievedAccount?.GreenId_Status__c == this.statusInProgress 
          && !retrievedAccount?.ID_Checked__pc) {
          this.displayButton = true;
          this.buttonLabel = 'Complete Now';
          this.displayComponent = true;
          this.displayText = 'Your ID Verification is In Progress';
      }else if (retrievedAccount?.GreenId_Status__c == this.statusLockedOut 
          && !retrievedAccount?.ID_Checked__pc) {
          this.displayButton = false;
          this.displayHelpline = true;
          this.buttonLabel = 'Complete Now';
          this.displayComponent = true;
          this.displayText = 'Before you invest, we need to verify your identity. To do this, please call';
      }else if (retrievedAccount?.GreenId_Status__c == this.statusPending 
          && !retrievedAccount?.ID_Checked__pc) {
          this.displayButton = false;
          this.displayComponent = true;
          this.displayText = 'Your ID verification has been submitted and is pending';
      }
      
    } catch (error) {
      console.log("===error===>", error.message);
    }
  }

  handleNavigation() {
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: "/venture-verification"
      }
    });
  }
}
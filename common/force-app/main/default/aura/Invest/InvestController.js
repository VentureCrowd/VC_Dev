({
  doInit: function (component, event, helper) {
    helper.doInit(component, event);
  },
  handleClick: function (cmp, event, helper) {
    helper.handleClick(cmp, event);
  },
  openGCSF: function (cmp, event, helper) {
    helper.openGCSF(cmp, event);
  },
  generatePDF: function (cmp, event, helper) {
    helper.generatePDF(cmp, event);
  },
  closeGCSF: function (cmp, event, helper) {
    helper.closeGCSF(cmp, event);
  },
  openInvestmentContract: function (cmp, event, helper) {
    helper.openInvestmentContract(cmp, event);
  },
  closeInvestmentContract: function (cmp, event, helper) {
    helper.closeInvestmentContract(cmp, event);
  },
  handleClickHome: function (cmp, event, helper) {
    helper.handleClickHome(cmp, event);
  },
  handleAmountChange: function (cmp, event, helper) {
    helper.handleAmountChange(cmp, event);
  },
  handleQuantityChange: function (cmp, event, helper) {
    helper.handleQuantityChange(cmp, event);
  },
  handleValue: function (cmp, event, helper) {
    helper.handleValue(cmp, event);
  },
  handleQuantity: function (cmp, event, helper) {
    helper.handleQuantity(cmp, event);
  },
  handleRadioClick: function (cmp, event, helper) {
    helper.handleRadioClick(cmp, event);
  },
  handleRadioChange: function (cmp, event, helper) {
    if (
      event.currentTarget.dataset.val &&
      cmp.get(`v.${event.currentTarget.dataset.val}`)
    ) {
      cmp.set(`v.${event.currentTarget.dataset.val}`, false);
    }
  },
  handleInvesterChange: function (cmp, event, helper) {
    cmp.set("v.isDownloadPDF", false);
    cmp.set("v.showInestAserror",false);
    let investingas;
    cmp.get("v.accountOptions").forEach(e=>{
      if(e.label == event.target.value )
      investingas = e.value;
    });
    cmp.set("v.investingAs", investingas);

    var relatedAccountList = cmp.get("v.relatedAccountList");
    var account = cmp.get("v.account");
    var index = relatedAccountList.findIndex(
        (item) => item.Account.Name === cmp.get("v.investingAs")
      ),
      investerName =
        index >= 0 ? relatedAccountList[index].Account.Name : account.Name;
    if (investerName) {
      cmp.set("v.investingAsName", investerName);
    }

    var address = "";
    for (var i = 0; i < relatedAccountList.length; i++) {
      if (relatedAccountList[i].Account.Name === investerName) {
        if (relatedAccountList[i].Account.IsPersonAccount === true) {
          if (relatedAccountList[i].Account.PersonMailingStreet !== undefined) {
            address = relatedAccountList[i].Account.PersonMailingStreet + " ";
          }
          if (relatedAccountList[i].Account.PersonMailingCity !== undefined) {
            address =
              address + relatedAccountList[i].Account.PersonMailingCity + " ";
          }
          if (relatedAccountList[i].Account.PersonMailingState !== undefined) {
            address =
              address + relatedAccountList[i].Account.PersonMailingState + " ";
          }
          if (
            relatedAccountList[i].Account.PersonMailingPostalCode !== undefined
          ) {
            address =
              address +
              relatedAccountList[i].Account.PersonMailingPostalCode +
              " ";
          }
          if (
            relatedAccountList[i].Account.PersonMailingCountry !== undefined
          ) {
            address =
              address +
              relatedAccountList[i].Account.PersonMailingCountry +
              " ";
          }
        } else {
          if (relatedAccountList[i].Account.BillingStreet !== undefined) {
            address = relatedAccountList[i].Account.BillingStreet + " ";
          }
          if (relatedAccountList[i].Account.BillingCity !== undefined) {
            address = address + relatedAccountList[i].Account.BillingCity + " ";
          }
          if (relatedAccountList[i].Account.BillingState !== undefined) {
            address =
              address + relatedAccountList[i].Account.BillingState + " ";
          }
          if (relatedAccountList[i].Account.BillingPostalCode !== undefined) {
            address =
              address + relatedAccountList[i].Account.BillingPostalCode + " ";
          }
          if (relatedAccountList[i].Account.BillingCountry !== undefined) {
            address =
              address + relatedAccountList[i].Account.BillingCountry + " ";
          }
        }
      }
    }

    if (address) {
      cmp.set("v.oppAddress", address);
    } else if (account.Id === cmp.get("v.investingAs")) {
      cmp.set("v.oppAddress", cmp.get("v.tempOppAddress"));
    } else {
      cmp.set("v.oppAddress", "");
    }
  },

  handleListClick: function (cmp, event, helper) {
    let clickEl = event.currentTarget.dataset.value;
    let selectEl = document.getElementById("investment-select");

    // Set the value of the dropdown to the current custom select item.
    selectEl.value = clickEl;

    // Dispatch a new event to trigger the onchange event.
    selectEl.dispatchEvent(new Event("change"));

    // Update the title.
    document.querySelector(".invest-as--custom-dropdown .title").innerText =
      clickEl;

    // Close the dropdown box.
    document
      .querySelector(".invest-as--custom-dropdown .expanded-list")
      .classList.remove("open");
    document
      .querySelector(".invest-as--custom-dropdown .current-selection")
      .classList.remove("open");

    // Trigger the event handler for the original select item. Apparently Salesforce doesn't allow this?
    //this.handleInvesterChange();
    helper.updatecontributionFee(cmp,event,helper,event.currentTarget.dataset.keyvalue);
    // But this shitty method works?
    //$A.enqueueAction(cmp.get('c.handleInvesterChange'));
  },

  openSelectionMenu: function (cmp, event, helper) {
    document
      .querySelector(".invest-as--custom-dropdown .expanded-list")
      .classList.toggle("open");
    document
      .querySelector(".invest-as--custom-dropdown .current-selection")
      .classList.toggle("open");
  },
  handleDonationChange: function (cmp, event, helper) {
   var options = cmp.find("donAmt");
   var result = 0 ;
   for (var i=0; i<options.length; i++) {
      if (options[i].get("v.checked")) {
          result += parseFloat(options[i].get("v.value"));
      }
  }
      cmp.set("v.DonationValueAmount",result);
      var manualAmt = cmp.find("manualAmt").get("v.value");
      if(manualAmt.length!=0){
        result += parseFloat(manualAmt);
      }
    if(manualAmt.length!=0 && result<50){
      cmp.set("v.minDonAmt",true);
    }
    else{
      cmp.set("v.minDonAmt",false);
      cmp.set("v.DonationValueAmount",result);
      let totalAmount =
      parseFloat(cmp.get("v.InvestmentValueAmount")) +
      parseFloat(cmp.get("v.contributionFeeAmount"))+
      parseFloat(cmp.get("v.DonationValueAmount"));
      cmp.set("v.totalAmount", totalAmount);
    }
  },
  openModal:function (cmp, event) {
    cmp.set("v.isModalOpen", true);
  },
  openentitymodal:function (cmp, event) {
    cmp.set("v.isopenentitymodal", true);
  }
});
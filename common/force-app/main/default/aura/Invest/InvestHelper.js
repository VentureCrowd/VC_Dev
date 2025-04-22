/** 
 * Add this code to trigger the gta event of the invest now page
 * document.addEventListener('lwc_investconversiongtaevent', (e) => {
    // Trigger Google Analytics Event
    window.gtag('event', 'InvestmentConversion', {
        event_category: 'Investment Conversion',
        // Track the full URL for attribution
        event_label: e.detail.url,  
        ...e.detail.urlParameters,
        product_name: e.detail.productName,
    });
});
 * 
**/
({
  doInit: function (cmp, event) {
    if (window.screen.width < 490 || $A.get("$Browser.isPhone")) {
      cmp.set("v.isMobile", true);
    }
    cmp.set("v.showSpinner", true);
    var searchParams = new URLSearchParams(window.location.search.substr(1));

    var idInfo = searchParams.get("Id");
    var amount = parseFloat(searchParams.get("amount"));
    if (idInfo) {
      if(idInfo == '01t5i00000017tGAAQ')
      cmp.set("v.trustfund", "Partnership Deed");
      var actionFromRecordPage = cmp.get("c.getInvestmentInfo");
      actionFromRecordPage.setParams({
        recordId: idInfo
      });
      actionFromRecordPage.setCallback(this, function (a) {
        var state = a.getState();
        if (state == "SUCCESS") {
          try{
          var objectInf = JSON.parse(a.getReturnValue());
          var unitPrice = 1.0;
          cmp.set("v.idInfo", idInfo);
          cmp.set("v.uInfo", objectInf.prodinfo[0]);
          if(objectInf.prodinfo[0].Fully_Funded__c)
          window.location.href = "/s/invest";
          cmp.set("v.notwholesaledirect", !objectInf.prodinfo[0].Wholesale_Direct__c);
          cmp.set("v.relatedAccountList", objectInf.relatedAccountList);
          cmp.set("v.retailMISProd", objectInf.prodinfo[0].Type__c == 'Retail MIS');
          cmp.set("v.gsl", objectInf.prodinfo[0].AFSL_Licence__c == 'GSL');
          cmp.set("v.retailIPO", objectInf.prodinfo[0].Type__c == 'Retail IPO');
          cmp.set("v.csfNominee", objectInf.prodinfo[0].Type__c == 'CSF Nominee');
          if(cmp.get("v.retailMISProd")){
            cmp.set("v.buyingLabel","Interests you are buying");
            cmp.set("v.misRedirectData",objectInf.prodinfo[0]);
          }
          cmp.set("v.account", objectInf.account[0]);
          cmp.set("v.accMembershipmap", objectInf.accMembershipmap);
          cmp.set("v.productcode", objectInf.prodinfo[0].ProductCode);
          if (objectInf.OppDetail[0] && objectInf.OppDetail[0] !== undefined) {
            cmp.set("v.OppDetail", objectInf.OppDetail[0]);
          }
          let accountOptions = [];
          if (objectInf.account[0] && objectInf.account[0] !== undefined) {
            let option = {};
            option.label = objectInf.account[0].Name;
            option.value = objectInf.account[0].Id;
            accountOptions.push(option);
          }
          if (
            objectInf.relatedAccountList[0] &&
            objectInf.relatedAccountList[0] !== undefined
          ) {
            for (var i = 0; i < objectInf.relatedAccountList.length; i++) {
              let option = {};
              option.label = objectInf.relatedAccountList[i].Account.Name;
              option.value = objectInf.relatedAccountList[i].AccountId;
              option.disabled =  objectInf.relatedAccountList[i].Account.Account_Created_via_Portal__c && !objectInf.relatedAccountList[i].Account.Active__c ? 'disabled':'dummy';
              accountOptions.push(option);
            }
          }

          cmp.set("v.accountOptions", accountOptions);
          if(accountOptions.length == 1){
            cmp.set("v.investingTitle", objectInf.uinfo[0].Name);
            cmp.set("v.investingAsName", objectInf.account[0].Name);
            cmp.set("v.investingAs", objectInf.account[0].Id);
          }
          if (
            objectInf.uinfo[0].Contact !== undefined &&
            objectInf.uinfo[0].Contact.Name !== undefined
          ) {
            cmp.set("v.accountName", objectInf.uinfo[0].Contact.Name);
          }
          var address = "";
          if (
            objectInf.uinfo[0].Contact !== undefined &&
            objectInf.uinfo[0].Contact.MailingStreet !== undefined
          ) {
            address = objectInf.uinfo[0].Contact.MailingStreet + " ";
          }
          if (
            objectInf.uinfo[0].Contact !== undefined &&
            objectInf.uinfo[0].Contact.MailingCity !== undefined
          ) {
            address = address + objectInf.uinfo[0].Contact.MailingCity + " ";
          }
          if (
            objectInf.uinfo[0].Contact !== undefined &&
            objectInf.uinfo[0].Contact.MailingState !== undefined
          ) {
            address =
              address + objectInf.uinfo[0].Contact.MailingState + " ";
          }
          if (
            objectInf.uinfo[0].Contact !== undefined &&
            objectInf.uinfo[0].Contact.MailingPostalCode !== undefined
          ) {
            address =
              address + objectInf.uinfo[0].Contact.MailingPostalCode + " ";
          }
          if (
            objectInf.uinfo[0].Contact !== undefined &&
            objectInf.uinfo[0].Contact.MailingCountry !== undefined
          ) {
            address = address + objectInf.uinfo[0].Contact.MailingCountry + " ";
          }
          cmp.set("v.tempOppAddress", address);
          cmp.set("v.oppAddress", address);
          //console.log('OppDetail=='+OppDetail);
          cmp.set("v.amountCall", searchParams.get("amount"));
          cmp.set("v.amount", amount);

          if (
            objectInf.prodinfo[0] &&
            objectInf.prodinfo[0].Minimum_Investment__c !== undefined &&
            objectInf.prodinfo[0].Minimum_Investment__c !== "" &&
            objectInf.prodinfo[0].Minimum_Investment__c !== null
          ) {
            cmp.set(
              "v.minInvestment",
              objectInf.prodinfo[0].Minimum_Investment__c
            );
          }
          if (
            objectInf.prodinfo[0] &&
            objectInf.prodinfo[0].Maximum_Investment__c !== undefined &&
            objectInf.prodinfo[0].Maximum_Investment__c !== "" &&
            objectInf.prodinfo[0].Maximum_Investment__c !== null
          ) {
            cmp.set(
              "v.maxInvestment",
              objectInf.prodinfo[0].Maximum_Investment__c
            );
          }
          if (
            objectInf.prodinfo[0] &&
            objectInf.prodinfo[0].Investor_Contribution_Fee__c !== undefined &&
            objectInf.prodinfo[0].Investor_Contribution_Fee__c !== "" &&
            objectInf.prodinfo[0].Investor_Contribution_Fee__c !== null
          ) {
            cmp.set("v.contributionfeepercentage",objectInf.prodinfo[0].Investor_Contribution_Fee__c);
            if(cmp.get("v.accMembershipmap")[objectInf.account[0].Id]){
              cmp.set("v.contributionFee", objectInf.prodinfo[0].Investor_Contribution_Fee__c);
              cmp.set("v.contributionFeeAmount",(amount * objectInf.prodinfo[0].Investor_Contribution_Fee__c) /100);
            }else{
              cmp.set("v.contributionFee", 0);
              cmp.set("v.contributionFeeAmount",0);
            }
          }

          if (
            objectInf.prodinfo[0] &&
            objectInf.prodinfo[0].Family !== undefined &&
            objectInf.prodinfo[0].Family !== "" &&
            objectInf.prodinfo[0].Family !== null
          ) {
            cmp.set("v.family", objectInf.prodinfo[0].Family);
            if (objectInf.prodinfo[0].Family === "Wholesale") {
              cmp.set("v.isRetail", false);
              cmp.set("v.isWholeSale", true);
            }
          }
          //cmp.set('v.amount',amount.toLocaleString('en-US', { style: 'currency', currency: 'USD',minimumFractionDigits: 0 }).substring(1));
          if (
            objectInf.priceBookInfo[0] &&
            objectInf.priceBookInfo[0].UnitPrice !== undefined &&
            objectInf.priceBookInfo[0].UnitPrice !== "" &&
            objectInf.priceBookInfo[0].UnitPrice !== null
          ) {
            cmp.set("v.unitPrice", objectInf.priceBookInfo[0].UnitPrice);
          } else {
            cmp.set("v.unitPrice", 1.0);
          }
          cmp.set("v.quantity", Math.floor(amount / cmp.get("v.unitPrice")));
          cmp.set("v.InvestmentValueAmount",  cmp.get("v.quantity") * cmp.get("v.unitPrice"));
          cmp.set(
            "v.totalAmount",
            cmp.get("v.InvestmentValueAmount") +
              cmp.get("v.contributionFeeAmount") +
              cmp.get("v.DonationValueAmount")
          );
          /*cmp.set(
            "v.totalAmount",
            cmp.get("v.quantity") * cmp.get("v.unitPrice")
          );*/
          cmp.set("v.userInfoData", objectInf.uinfo[0]);
          cmp.set("v.oppAmount", "$ " + cmp.get("v.totalAmount"));
          cmp.set("v.showSpinner", false);
          cmp.set("v.isInvestHome", true);
          }catch(e){
            console.log(e);
          }
          //cmp.set("v.totalInvestments",a.getReturnValue().toLocaleString('en-US', { style: 'currency', currency: 'USD',minimumFractionDigits: 0 }));
        } else if (state == "ERROR") {
          cmp.set("v.showSpinner", false);
          //cmp.set("v.dataExists",false);
        }
      });
      $A.enqueueAction(actionFromRecordPage);
    } else {
      console.log("Id Not available. Bad URL!!");
      cmp.set("v.isBadURL", true);
      cmp.set("v.formAccept", false);
    }
  },
  handleClick: function (cmp, event) {
    cmp.set("v.showSpinner", true);
    cmp.set("v.showInestAserror",false);
    let canProceedNext = true;
    let investAsFilled= true;
    if(document.getElementById("radio-43") &&!document.getElementById("radio-43").checked){
      cmp.set("v.radio43", true);
      canProceedNext = false;
    }else{
      cmp.set("v.radio43", false);
    }
    if(document.getElementById("radio-44") &&!document.getElementById("radio-44").checked){
      cmp.set("v.radio44", true);
      canProceedNext = false;
    }else{
      cmp.set("v.radio44", false);
    }
    if(document.getElementById("radio-45") &&!document.getElementById("radio-45").checked){
      cmp.set("v.radio45", true);
      canProceedNext = false;
    }else{
      cmp.set("v.radio45", false);
    }
    if(document.getElementById("radio-42") && !document.getElementById("radio-42").checked){
      cmp.set("v.radio42", true);
      canProceedNext = false;
    }else{
      cmp.set("v.radio42", false);
    }
    if(document.getElementById("radio-41") && !document.getElementById("radio-41").checked){
      cmp.set("v.radio41", true);
      canProceedNext = false;
    }else{
      cmp.set("v.radio41", false);
    }
    if(cmp.get("v.isLessThanMinInvestment") === true) {
      canProceedNext = false;
    }
    if(cmp.get("v.isGreaterThanMaxInvestment") === true) {
      canProceedNext = false;
    }
    if(cmp.get("v.minDonAmt")){
      canProceedNext = false;
    }
    if(!cmp.get("v.investingAs")){
      investAsFilled = false;
      cmp.set("v.showInestAserror",true);      
    }
    if(!canProceedNext || !investAsFilled) {
      cmp.set("v.showSpinner", false);
      if(!canProceedNext){
        cmp.set("v.radioFail", true);
      }
      return;
    }
    let url = new URL(window.location.href);
    let utmmap = {};
    utmmap['utm_source__c'] = url.searchParams.get("utm_source");
    utmmap['utm_medium__c'] = url.searchParams.get("utm_medium");
    utmmap['utm_campaign__c'] = url.searchParams.get("utm_campaign");
    utmmap['utm_content__c'] = url.searchParams.get("utm_content");
    utmmap['utm_term__c'] = url.searchParams.get("utm_term");
    if(cmp.get("v.retailIPO")){
      utmmap['Read_and_Agree_Financial_Services_Guide__c'] = true;
      utmmap['Read_and_Agree_General_Risk_Warning__c'] = true;
      utmmap['Read_and_Agree_General_Warning_Statement__c'] = true;
      utmmap['Read_and_Agree_Investment_Contract__c'] = true;
      utmmap['Read_and_Agree_Prospectus_Document__c'] = true;
      utmmap['Read_and_Agree_TargetMarketDetermination__c'] = true;
    }
    if(cmp.get("v.csfNominee")){
      utmmap['Read_and_Agree_Financial_Services_Guide__c'] = true;
      utmmap['Read_and_Agree_General_Risk_Warning__c'] = true;
      utmmap['Read_and_Agree_General_Warning_Statement__c'] = true;
      utmmap['Read_and_Agree_Investment_Contract__c'] = true;
      utmmap['Read_and_Agree_Crowd_Sourced_Funding__c'] = true;
      utmmap['Read_and_Agree_CSF_Risk_Warning__c'] = true;
    }

    this.handleGTAGEvent(cmp, utmmap);

    var actionForOppCreation = cmp.get("c.createOpportunity");
    actionForOppCreation.setParams({
      recordId: cmp.get("v.idInfo"),
      amount: cmp.get("v.amountCall"),
      quantity: cmp.get("v.quantity"),
      totalAmount: cmp.get("v.totalAmount"),
      donationamount: cmp.get("v.DonationValueAmount"),
      reqtoInvest: cmp.get("v.showInvestmentEntryText"),
      investingAs: cmp.get("v.investingAs"),
      contributionfee : cmp.get("v.contributionFeeAmount"),
      utmmap
    });
    actionForOppCreation.setCallback(this, function (a) {
      var state = a.getState();
      if (state == "SUCCESS") {
        if(a.getReturnValue() == 'failure'){
          cmp.set("v.isInvestHome", false);
          cmp.set("v.isOppCreationFailure", true);
        }else{
          cmp.set("v.isInvestHome", false);
          window.displayurl = cmp.get("v.uInfo.DisplayUrl");
          window.prodName = cmp.get("v.uInfo.Name");
          let urlEvent = $A.get("e.force:navigateToURL");
          urlEvent.setParams({
            url: "/s/typ-investment?Id="+cmp.get("v.uInfo.Id")
          });
          urlEvent.fire();
          // cmp.set("v.isInvestConfirmed", true);
        }
      } else if (state == "ERROR") {
        cmp.set("v.isInvestHome", false);
        cmp.set("v.isOppCreationFailure", true);
        console.log(a.getError()[0].message);
      }
      cmp.set("v.showSpinner", false);
    });
    $A.enqueueAction(actionForOppCreation);
  },
  /**
   * Cesar 4/4/25 - Added to fire an event to send the GTA
   * @param {*} data UTM Data
   */
  handleGTAGEvent: function(cmp, data) {
    var currentURL = window.location.href;
    var productName = cmp.get("v.uInfo") && cmp.get("v.uInfo").Name;
    var detail = {
        url: currentURL,
        urlParameters: data,
        productName: productName
    };
    // Create the custom event with bubbling and composed set to true
    var customEvent = new CustomEvent('lwc_investconversiongtaevent', {
        detail: detail,
        bubbles: true,
        composed: true
    });
    // Dispatch the event from the component's root element
    cmp.getElement().dispatchEvent(customEvent);
  },

  openGCSF: function (cmp, event) {
    cmp.set("v.isGeneralCSFModal", true);
  },
  openInvestmentContract: function (cmp, event) {
    cmp.set("v.isInvestmentContractModal", true);
  },
  closeInvestmentContract: function (cmp, event) {
    cmp.set("v.isInvestmentContractModal", false);
  },

  handleQuantity: function (cmp, event) {
    cmp.set("v.showValue", false);
  },

  handleValue: function (cmp, event) {
    cmp.set("v.showValue", true);
 },
  closeGCSF: function (cmp, event) {
    cmp.set("v.isGeneralCSFModal", false);
    cmp.set("v.isDownloadPDF", false);
    cmp.set("v.isModalOpen",false);
    cmp.set("v.isopenentitymodal",false);
  },
  handleClickHome: function (cmp, event) {
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      url: "/s/portal/portfolio"
    });
    urlEvent.fire();
  },
  generatePDF: function (cmp, event) {
    cmp.set("v.isDownloadPDF", false);
    cmp.set("v.isDownloadPDF", true);
  },
  handleRadioClick: function (cmp, event) {
    //var opts = document.querySelector('input[name="investmentRadio"]:checked').value;
    if (event.target.value === "checked") {
      cmp.set("v.showInvestmentEntryText", true);
    }
  },

  handleAmountChange: function (cmp, event) {
    cmp.set("v.isDownloadPDF", false);
    cmp.set("v.ourCowSpecialErr",false);
    const amount = event.getSource().get("v.value"),
    unitPrice = cmp.get("v.unitPrice"),
    minInvestment = cmp.get("v.minInvestment")
    let maxInvestment = cmp.get("v.maxInvestment");
    let quantity = Math.floor(amount / unitPrice);
    cmp.set("v.contributionFeeAmount",(amount * cmp.get("v.contributionFee")) / 100);
    cmp.set("v.InvestmentValueAmount", quantity * unitPrice);
    // let totalAmount = quantity * unitPrice,
    let totalAmount =
      parseFloat(cmp.get("v.InvestmentValueAmount")) +
      parseFloat(cmp.get("v.contributionFeeAmount"))+
      parseFloat(cmp.get("v.DonationValueAmount"));
    let oppAmount = `$ ${totalAmount}`;
    //Assign Values to the component
    cmp.set("v.isLessThanMinInvestment", false);
    cmp.set("v.isGreaterThanMaxInvestment", false);
    cmp.set("v.quantity", quantity);
    //cmp.set("v.totalAmount", totalAmount);
    cmp.set("v.oppAmount", oppAmount);
    cmp.set("v.totalAmount", totalAmount);
    //Validate Minimum Amount and show warning
    if (minInvestment && (!amount || amount < minInvestment)) {
      cmp.set("v.isLessThanMinInvestment", true);
      return;
    }
    if(cmp.get("v.productcode") == 'OURCOW' && (cmp.get("v.account").Wholesale__pc == false && cmp.get("v.account").EIC_Startup__pc == false)){
      maxInvestment = 10000;
      cmp.set("v.ourCowSpecialErr", true);
    }
    //Validate Maximum Amount and show warning
    if (maxInvestment && (!amount || amount > maxInvestment)) {
      cmp.set("v.isGreaterThanMaxInvestment", true);
      return;
    }
  },

  handleQuantityChange: function (cmp, event) {
    const quantity = event.getSource().get("v.value"),
    unitPrice = cmp.get("v.unitPrice"),
    minInvestment = cmp.get("v.minInvestment")
    let maxInvestment = cmp.get("v.maxInvestment");
    cmp.set("v.ourCowSpecialErr", false);
    let amount = Math.floor(quantity * unitPrice);
    cmp.set("v.contributionFeeAmount",(amount * cmp.get("v.contributionFee")) / 100);
    cmp.set("v.InvestmentValueAmount", quantity * unitPrice);
    // let totalAmount = quantity * unitPrice,
    let totalAmount = parseFloat(cmp.get("v.InvestmentValueAmount")) + parseFloat(cmp.get("v.contributionFeeAmount"))+ parseFloat(cmp.get("v.DonationValueAmount"));
    let oppAmount = `$ ${totalAmount}`;
    if(cmp.get("v.productcode") == 'OURCOW' && (cmp.get("v.account").Wholesale__pc == false || cmp.get("v.account").EIC_Startup__pc == false)){
      maxInvestment = 10000;
      cmp.set("v.ourCowSpecialErr", true);
    }
    //Assign Values to the component
    cmp.set("v.isLessThanMinInvestment", false);
    cmp.set("v.isGreaterThanMaxInvestment", false);
    cmp.set("v.quantity", quantity);
    //cmp.set("v.totalAmount", totalAmount);
    cmp.set("v.oppAmount", oppAmount);
    cmp.set("v.totalAmount", totalAmount);
    //Validate Minimum Amount and show warning
    if (minInvestment && (!amount || amount < minInvestment)) {
      cmp.set("v.isLessThanMinInvestment", true);
      return;
    }
    //Validate Maximum Amount and show warning
    if (maxInvestment && (!amount || amount > maxInvestment)) {
      cmp.set("v.isGreaterThanMaxInvestment", true);
      return;
    }
  },
  updatecontributionFee: function (cmp, event,helper,recId) {
    if(cmp.get("v.accMembershipmap")[recId]){
      cmp.set("v.contributionFee", cmp.get("v.contributionfeepercentage"));
      cmp.set("v.contributionFeeAmount",(cmp.get("v.InvestmentValueAmount") * cmp.get("v.contributionfeepercentage")) /100);
      cmp.set("v.totalAmount", cmp.get("v.InvestmentValueAmount") +cmp.get("v.contributionFeeAmount") +cmp.get("v.DonationValueAmount"));
    }else{
      cmp.set("v.contributionFee", 0);
      cmp.set("v.contributionFeeAmount",0);
      cmp.set("v.totalAmount", cmp.get("v.InvestmentValueAmount") +cmp.get("v.contributionFeeAmount") +cmp.get("v.DonationValueAmount"));
    }
  }
});
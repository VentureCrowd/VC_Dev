import { LightningElement } from 'lwc';
import availableProdOptns from "@salesforce/apex/interestDividendDisbursementCntrl.availableProdOptns";
import getProdsetails from "@salesforce/apex/interestDividendDisbursementCntrl.getProdsetails";
import createFunddisuirsment from "@salesforce/apex/interestDividendDisbursementCntrl.createFunddisuirsment";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class InterestDividendDisbursement extends LightningElement {
    value;
    prodOptns;
    selectedProd;
    opplist = [];
    tablerows = [];
    selectedenddate;
    totalinterset = 0;
    productPricesMap;
    roiMap;
    columns = [
        { label: 'Opp Name', fieldName: 'Name',cellAttributes: {alignment: 'center'} },
        { label: 'Start Date', fieldName: 'startdate' ,cellAttributes: {alignment: 'center'}},
        { label: 'End Date', fieldName: 'enddate',cellAttributes: {alignment: 'center'} },
        {label: 'Invstment Value',fieldName: 'totalworth', type:'currency',typeAttributes: {maximumFractionDigits: '4' },cellAttributes: {alignment: 'center'}},
        {label: 'Returns Percentage',fieldName: 'returnspercentage', type:'percent',typeAttributes: {maximumFractionDigits: '2' },cellAttributes: {alignment: 'center'}},
        {label: 'Number of days',fieldName: 'dayscnt', type:'number',typeAttributes: {maximumFractionDigits: '2' },cellAttributes: {alignment: 'center'}},
        {label: 'Total Interest',fieldName: 'totalint', type:'currency',typeAttributes: {maximumFractionDigits: '4' },cellAttributes: {alignment: 'center'}},
        { label: '',type: 'button', initialWidth: 50,
            typeAttributes: { label: '', title: 'Click to Remove',disabled: false, variant: 'base', iconName: {fieldName : 'icnname'}} ,cellAttributes: {alignment: 'center'}
        }
    ];
    connectedCallback(){
        availableProdOptns()
        .then(r =>{
            this.prodOptns = r;
        })
        .catch(e => console.log(e));
    }
    handleChange(event){
        let prodID = event.target.value;
        getProdsetails({prodID})
        .then(r =>{
            this.selectedProd = r.prod;
            this.productPricesMap = new Map();
            this.roiMap = new Map();
            let today = new Date();
            let todaysdate = today.getFullYear()+'-'+(((today.getMonth()+1) < 10 ? '0'+(today.getMonth()+1) : (today.getMonth()+1)))+'-'+(today.getDate() < 10 ? '0'+today.getDate() : today.getDate());
            if(this.selectedProd.Pricebook_Entry_Logs__r){
                this.selectedProd.Pricebook_Entry_Logs__r.forEach(e=>{
                    let startDate = e.Start_Date__c.split('T')[0];
                    let endDate = e.End_Date__c ? e.End_Date__c.split('T')[0] : todaysdate ; 
                    let unitprice = e.List_Price__c;
                    this.productPricesMap.set(startDate+'@@@'+endDate,{startDate,endDate,unitprice});
                })
            }else{
                let startDate = this.selectedProd.CreatedDate;
                let endDate = todaysdate ; 
                let unitprice = this.selectedProd.PricebookEntries[0].UnitPrice;
                this.productPricesMap.set(startDate+'@@@'+endDate,{startDate,endDate,unitprice});
            }
            this.selectedProd.ROI_Log__r.forEach(e=>{
                let startDate = e.Start_Date__c.split('T')[0];
                let endDate = e.End_Date__c ? e.End_Date__c.split('T')[0] : todaysdate ; 
                let fixedreturns = e.Returns_Percentage__c;
                this.roiMap.set(startDate+'@@@'+endDate,{startDate,endDate,fixedreturns});
            })
            this.opplst = r.opplst;
            this.calculatetablerows();
        })
        .catch(e => console.log(e));
    }
    handledatechange(event){
        this.selectedenddate = event.target.value;
        if(new Date(this.selectedenddate) <= new Date())
            this.calculatetablerows();
        else
            this.showNotification('Please selct Date today or less than today','','error');
    }
    calculatetablerows(){
        if(this.opplst && this.selectedenddate){
            try{
            this.tablerows = [];
            this.totalinterset = 0;
            this.opplst.forEach(ele => {
                let startdate = ele.Interest_Dividend_Transaction_Log__r ? ele.Interest_Dividend_Transaction_Log__r[0].End_Date__c : ele.Unit_Cert_Issued__c;
                let enddate = this.selectedenddate;
                let dayscnt = 0; 
                let totalint = 0;
                let numberofshares= ele.OpportunityLineItems[0].Quantity;
                let saleprice = ele.OpportunityLineItems[0].UnitPrice;
                let _children = [];
                let childrencount = 0 ;
                Array.from(this.roiMap.values()).forEach(e=>{
                    let tempstartdate =  new Date(e.startDate);
                    let tempenddate =  new Date(e.endDate);
                    let strdate =  new Date(startdate);
                    let endate =  new Date(enddate);
                    let temptotalworth= 0;
                    let childstartdate_LP;
                    let childendadate_LP;
                    let unitprice = e.unitprice;
                    let tempdayscount = 0;
                    let tempint= 0;
                    if( !(strdate >tempenddate) && !(endate < tempstartdate)){
                        if(strdate >= tempstartdate && tempenddate <= endate){
                            tempdayscount = (tempenddate - strdate)/(1000 * 60 * 60 * 24);
                            childstartdate_LP = startdate;
                            childendadate_LP = e.endDate;
                        }else if(tempstartdate >= strdate && tempenddate <= endate){
                            tempdayscount = (tempenddate - tempstartdate)/(1000 * 60 * 60 * 24);
                            childstartdate_LP = e.startDate;
                            childendadate_LP = e.endDate;
                        }else if(strdate <= tempstartdate && endate <= tempenddate){
                            tempdayscount = (endate - tempstartdate)/(1000 * 60 * 60 * 24);
                            childstartdate_LP = e.startDate;
                            childendadate_LP = enddate;
                        }else if(strdate >= tempstartdate && endate <= tempenddate){
                            tempdayscount = (endate - strdate)/(1000 * 60 * 60 * 24);
                            childstartdate_LP = startdate;
                            childendadate_LP = enddate;
                        } 
                        temptotalworth = numberofshares*saleprice;  
                        let startyear = new Date(childstartdate_LP).getFullYear();
                        let endyear = new Date(childendadate_LP).getFullYear();
                        console.log(startyear,endyear);
                        if(startyear == endyear){
                            let daysinayear = startyear % 4 == 0 ?366 :365;
                            tempint = temptotalworth*e.fixedreturns/100/daysinayear*tempdayscount;
                        }else{
                            let currentyear = startyear;
                            for(let i=0 ; i<= endyear-startyear;i++ ){
                                let daysinayear = currentyear % 4 == 0 ? 366 :365;
                                let interestValiddays = 0;
                                if(currentyear != startyear &&  currentyear != endyear){
                                    interestValiddays = daysinayear;
                                }else{
                                    if(currentyear == startyear){
                                        interestValiddays = ((this.getLastDayOfYear(currentyear) -new Date(childstartdate_LP))/(1000 * 60 * 60 * 24))+1;
                                    }
                                    if(currentyear == endyear){
                                        interestValiddays = (new Date(childendadate_LP) - this.getFirstDayOfYear(currentyear))/(1000 * 60 * 60 * 24);
                                    }
                                }
                                tempint += temptotalworth*e.fixedreturns/100/daysinayear*interestValiddays;
                                console.log(daysinayear,currentyear,interestValiddays,temptotalworth*e.fixedreturns/100/daysinayear*interestValiddays,ele.Name);
                                currentyear++;
                            }
                        }
                        // tempint = temptotalworth*e.fixedreturns/100/365*tempdayscount;
                        totalint += tempint;
                        dayscnt += tempdayscount;
                        _children.push({
                                    startdate:this.formatdate(childstartdate_LP),
                                    enddate:this.formatdate(childendadate_LP),
                                    oppId:ele.Id+childrencount,
                                    totalworth:temptotalworth,
                                    dayscnt:tempdayscount,
                                    totalint:tempint,
                                    returnspercentage : e.fixedreturns/100,
                                    opporId:ele.Id,
                                });
                        childrencount++;                         
                    }
                })
                this.totalinterset = this.totalinterset+totalint;
                this.tablerows.push({
                    Name:ele.Name,
                    oppId:ele.Id,
                    startdate:this.formatdate(startdate),
                    enddate:this.formatdate(enddate),
                    dayscnt,
                    totalint,
                    _children,
                    icnname:'utility:close'
                });
            });
            }catch(e){console.log(e)};
        }
    }
    get fixedreturns(){
        return this.selectedProd.Fixed_Returns__c/100;
    }
    proceed(){
        // let wraplst = [];
        // this.tablerows.forEach(ele =>{
        //     wraplst.push({
        //         numofdays : ele.dayscnt,
        //         oppId : ele.oppId,
        //         startdate : ele.startdate,
        //         enddate : ele.enddate,                
        //     });
        // });
        createFunddisuirsment({prodId : this.selectedProd.Id,endate : this.formatdate(this.selectedenddate),jsonstr : JSON.stringify(this.tablerows).replaceAll('_children','children')})
        .then(r =>{
            this.showNotification('Interest Dividend has been processed','','success');
        })
        .catch(e=>{console.log(e)});
    }
    get proccedbtndisabled(){
        return !this.totalinterset > 0 ;
    }
    showNotification(title,message,variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
    }
    handleRowAction(event){
        let ind;
        this.opplst.forEach((e,index=0) => {
            if(e.Id == event.detail.row.oppId){
                ind = index ;
            }
        });
        this.opplst.splice(ind,1);
        this.calculatetablerows();
    }
    formatdate(s){
        let dat = new Date(s);
        return dat.getDate()+'-'+(dat.getMonth()+1)+'-'+dat.getFullYear();
    }
    getLastDayOfYear(year) {
        let datstr = year+'-12-31';
        return new Date(datstr);
    }
    getFirstDayOfYear(year) {
        let datstr = year+'-01-01';
        return new Date(datstr);
    }
}
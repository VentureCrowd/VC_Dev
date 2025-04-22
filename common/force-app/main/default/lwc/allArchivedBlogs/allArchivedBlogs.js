import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import fetchMonthlyArchives from '@salesforce/apex/CustomBlogSideBarCntrl.fetchMonthlyArchives';

import VC_CF_Moment from '@salesforce/resourceUrl/VC_CF_Moment';
import {loadScript} from 'lightning/platformResourceLoader'

export default class AllArchivedBlogs extends LightningElement {

   archiveMonth;
   archiveYear;
   archiveList = [];
   currentPageReference = null; 
   urlStateParameters = null;
 
   /* Params from Url */
   urlId = null;
   urlLanguage = null;
   urlType = null;

   lstMonths=[];
   isMomentJSLoaded=false;

   renderedCallback() {
      if(!this.isMomentJSLoaded) {
         this.isMomentJSLoaded = true;
         Promise(
            loadScript(this, VC_CF_Moment)
         )
         .then(() => {})
         .catch(error=>{
            console.log("erro while loading css>>",error);
         });
      }
   }

   @wire(CurrentPageReference)
   getStateParameters(currentPageReference) {
      if (currentPageReference) {
         this.urlStateParameters = currentPageReference.state;
         this.setParametersBasedOnUrl();
      }
   }
   
   setParametersBasedOnUrl() {
      // Safeguard to stop the builder from breaking.
      if(this.urlStateParameters.month && this.urlStateParameters.year) {
         this.archiveMonth = this.urlStateParameters.month || null;
         this.archiveYear = this.urlStateParameters.year || null;
      } else {
         this.archiveMonth = 'May';
         this.archiveYear = '2021';
      }
      
   }

   connectedCallback() {
      // console.log('===Month number===>', moment().month('September'));
      this.lstMonths = [{ strMonthKey : "January", strMonthVal : 1 },
                        { strMonthKey : "February", strMonthVal : 2 }, 
                        { strMonthKey : "March", strMonthVal : 3 }, 
                        { strMonthKey : "April", strMonthVal : 4 }, 
                        { strMonthKey : "May", strMonthVal : 5 }, 
                        { strMonthKey : "June", strMonthVal : 6 },
                        { strMonthKey : "July", strMonthVal : 7 }, 
                        { strMonthKey : "August", strMonthVal : 8 }, 
                        { strMonthKey : "September", strMonthVal : 9 }, 
                        { strMonthKey : "October", strMonthVal : 10 }, 
                        { strMonthKey : "November", strMonthVal : 11 }, 
                        { strMonthKey : "December", strMonthVal : 12 }];
      this.getAllArchives();
   }

   getAllArchives() {
      
      fetchMonthlyArchives({
         strMonth : this.getMonthInteger(this.archiveMonth),
         strYear : this.archiveYear
      })
      .then(result => {
         console.log('===All Data result===>', result);

         let tempBlogList = JSON.parse(JSON.stringify(result));
         console.log('===All Data tempBlogList===>', tempBlogList);

         if(tempBlogList && tempBlogList.length > 0 ) {
            tempBlogList.forEach(ele => {
               ele['fromattedDate'] = moment(ele.Date__c).format('MMMM DD, YYYY');
            })
         }

         this.archiveList = tempBlogList;
      })
      .catch(error => {
         console.log('*** Error Occured in getting data from Salesforce. *** ', error);
      });
   }

   get getHeaderStyling() {
      return `background-image: url('https://assets.venturecrowd.vc/uploads/2020/11/Monthly-Archive-VC.jpg')`;
   }

   getMonthInteger(strMonthName) {
      let monthInt = (this.lstMonths).filter(ele => ele.strMonthKey == strMonthName);
      return monthInt[0]['strMonthVal'];
   }
}
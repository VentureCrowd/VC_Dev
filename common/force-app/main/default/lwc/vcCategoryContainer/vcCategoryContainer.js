import { LightningElement, track,wire } from 'lwc';
// import getNewsBlogs from "@salesforce/apex/ProductController.getNewsBlogs";
import getNewsBlogsForNewsContainerByCategory from "@salesforce/apex/ProductController.getNewsBlogsForNewsContainerByCategory";
import VC_CF_Moment from '@salesforce/resourceUrl/VC_CF_Moment';
import {loadScript} from 'lightning/platformResourceLoader'


export default class VcNewsContainer extends LightningElement {

    isShowSpinner = true;
    newsBlogList = [];
    totalBlogsCount = 0;
    rowLimit = 24;
    rowOffSet = 0;

    isMomentJSLoaded=false;
    @track paramValue;
    catgoreyimagurl;
    currentcategory;
    

    get backgroundstyle(){
        return `background-image: url('${this.catgoreyimagurl}')`;
    }

    renderedCallback() {
        if(!this.isMomentJSLoaded) {
            this.isMomentJSLoaded = true;
            Promise(
                loadScript(this, VC_CF_Moment)
            ).then(() => {
                
            }).catch(error=>{
                console.log("erro while loading css>>",error);
            });
        }
    }

    connectedCallback() {
        this.getURLParameterValue();
        this.currentcategory=decodeURIComponent(this.paramValue.category).trim();
        this.loadData(false);

    }

    loadData(isLazyLoading){
        if((this.newsBlogList).length <= this.totalBlogsCount) {
            try{
                getNewsBlogsForNewsContainerByCategory({ limitSize: this.rowLimit , offset : this.rowOffSet, categoryName: this.currentcategory })
                .then(result => {
                    console.log(result);
                    if(!isLazyLoading) {
                    let tempBlogList;
                        if(result) {
                            tempBlogList = JSON.parse(JSON.stringify(result));
                        } else {
                            tempBlogList = null;
                        }
                        if(tempBlogList && tempBlogList.length > 0 ) {
                            tempBlogList.forEach(ele => {
                                ele['fromattedDate'] = moment(ele.Date__c).format('MMMM DD, YYYY');
                            })
                        }
                        
                        this.newsBlogList = tempBlogList;
                        this.categoryimagurl=result[0].CategoryBanner_Img_Url__c; 
                    } else {
                        let tempBlogList =  JSON.parse(JSON.stringify([...this.newsBlogList, ...result]));
                        if(tempBlogList && tempBlogList.length > 0 ) {
                            tempBlogList.forEach(ele => {
                                ele['fromattedDate'] = moment(ele.Date__c).format('MMMM DD, YYYY');
                            })
                        }

                        this.newsBlogList = tempBlogList;
                        this.totalBlogsCount = result.totalBlogsCount;
                    }
                    this.error = !result.isSuccess ? result.errorMsg : null;
                    this.isShowSpinner = false;
                })
                .catch(error => {
                    console.log('===Load Data Error Catch 111===>', error);
                    this.error = error;
                    this.newsBlogList = undefined;
                    this.isShowSpinner = false;
                });
            } catch(error) {
                this.isShowSpinner = false;
                console.log('===Load Data Error Catch 222===>', error.message);
            }
        }
    }

    handleScroll(event) {
        let area = this.template.querySelector('.scrollArea');
        let threshold = 2 * event.target.clientHeight;
        let areaHeight = area.clientHeight;
        let scrollTop = event.target.scrollTop;

        if(areaHeight - threshold < scrollTop) {
            this.loadMoreData(event);
        }
    }

    loadMoreData(event) {
        console.log('Load more data');
        this.isShowSpinner = true;

        this.rowOffSet = this.rowOffSet + this.rowLimit;
        this.loadData(true)
        .then(()=> {
            this.isShowSpinner = false;
        });   
    }

    getURLParameterValue() {
 
        var querystring = location.search.substr(1);
        var paramValue = {};
        querystring.split("&").forEach(function(part) {
            var param = part.split("=");
           // paramValue[param[0]] = decodeURIComponent(param[1]);
            paramValue[param[0]] = param[1];
        });
 
        console.log('paramValue-' , paramValue);
        this.paramValue=paramValue;
    }

}
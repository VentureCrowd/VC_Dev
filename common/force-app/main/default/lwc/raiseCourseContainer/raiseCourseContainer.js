import { LightningElement, api, track, } from 'lwc';

import apex__getRaiseDetails from '@salesforce/apex/RaiseController.getRaiseDetails'
import apex_getCoursesFromLearning from '@salesforce/apex/KnowledgeController.getCoursesFromLearning'
import apex_getArticleDetailsFromCourse from '@salesforce/apex/KnowledgeController.getArticleDetailsFromCourse';
import apex_getPublicImageUrl from '@salesforce/apex/FileUploadController.getPublicImageUrl';
import apex_getProgressFromLearning from '@salesforce/apex/KnowledgeController.getProgressFromLearning';
import apex_getRaiseStatuses from '@salesforce/apex/RaiseController.getRaiseStatuses';
import apex_unlockCourse from '@salesforce/apex/RaiseController.unlockRaiseCourse';

import { NavigationMixin } from 'lightning/navigation';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import banner from '@salesforce/resourceUrl/Banner_Knowledge';
import ventureCrowdTheme from "@salesforce/resourceUrl/ventureCrowdTheme";


export default class RaiseCourseContainer extends NavigationMixin(LightningElement) {
    @track _raiseId;



    @track courseData;
    

    @track title;

    @track eoiId;

    @api
    get raiseId(){
        return this._raiseId;
    }
    set raiseId(v){
        this._raiseId = v;
    }


    @track showFeesLocked = false;

    @track showWelcome = false;


    @track stepperValues = [
        { id: 1, label: 'Pre Raise Checklist', completed: true, active: false, variation: 'light'},
        { id: 2, label: 'Raise Information', completed: true, active: false, variation: 'light'},
        { id: 3, label: 'Approvals', completed: true, active: false, variation: 'light'},
        { id: 5, label: 'Capital Raising 101 Course', completed: false, active: true, variation: 'light'},
        { id: 6, label: 'Raise Live', completed: false, active: false, variation: 'light'},
    ];

    @track isLoading = false;

    @track investType;

    courseUnlockedImgUrl = ventureCrowdTheme + '/Images/courseUnlocked.png';

    /**
     * @method getRaise
     * @description Fetches raise details from the server based on the provided raise ID.
     * @param {string} raiseId - The ID of the raise.
     * @returns {Promise} - A promise that resolves to the parsed raise details.
     */
    getRaise(raiseId){
        return new Promise(async(resolve,reject)=>{
            const raiseDetails = await apex__getRaiseDetails({raiseId: raiseId});
            const parsedData = JSON.parse(raiseDetails);

            resolve(parsedData)
        })
    }

    /**
     * @method getRaiseStatuses
     * @description Fetches the status of the raise from the server based on the provided raise ID.
     * @param {string} raiseId - The ID of the raise.
     * @returns {Promise} - A promise that resolves to the raise statuses.
     */
    getRaiseStatuses(raiseId){
        return new Promise(async(resolve,reject)=>{
            const raiseStatuses = await apex_getRaiseStatuses({raiseId: raiseId});
            resolve(raiseStatuses);
        })
    }


    /**
     * @method loadData
     * @description Loads all necessary data for the raise including details, statuses, courses, and progress.
     * @param {string} raiseId - The ID of the raise.
     * @returns {Promise} - A promise that resolves to the combined raise data.
     */
    loadData(raiseId){
        return new Promise(async(resolve,reject)=>{
            try{
                let raiseDetails = await this.getRaise(raiseId);
                this.title = raiseDetails.name ? raiseDetails.name : '';


                this.eoiId = raiseDetails.eoi ? raiseDetails.eoi : null;

                let raiseStatuses = await this.getRaiseStatuses(raiseId);

                let learningId = raiseDetails.learning ? raiseDetails.learning : '';

                // if learning data exists then load the modules, courses and progress objects & raise statuses
                if(this.learningId !== ''){

                    // get learning data

                    let courses = await this.getCoursesFromLearningId(learningId);

                    let modules = await this.getArticleDetails(courses[0].id)

                    let progress = await this.getProgress(learningId);


                    let modulesWithImages = await Promise.all(
                        modules.map(async (module)=>{
                            try{
                                let progressMatch = progress.find(progress => progress.articleId === module.id);
                                let bannerImgUrl = banner;
                                try{
                                    const imageUrl = await apex_getPublicImageUrl({ recordId : module.id});
                                    bannerImgUrl = imageUrl;
                                    return {...module, 
                                        bannerURL:imageUrl, 
                                        moduleUrl: window.location.origin + "/articles/module/" + module.urlName + `?id=${this.raiseId}`,
                                        learningProgId : progressMatch.id,
                                        completed: progressMatch.completed
                                    };
                                }catch(err){
                                    // dont show error to user
                                }

                                return {...module,
                                    bannerURL : bannerImgUrl,
                                    moduleUrl: window.location.origin + "/articles/module/" + module.urlName + `?id=${this.raiseId}`,
                                    learningProgId : progressMatch.id,
                                    completed: progressMatch.completed
                                };
                            }catch(error){
                                console.error(error);
                               
                            }
                        })
                    )

                    
                    let returnData = {
                        raiseDetails: raiseDetails,
                        raiseStatus: raiseStatuses,
                        courses: courses,
                        course: courses[0],
                        modules : modulesWithImages,
                    }

                    resolve(returnData);
                }
                
            }catch(error) {
                reject(error);
            }
        })
    }

    /**
     * @method getArticleDetails
     * @description Fetches the article details for a specific course.
     * @param {string} courseId - The ID of the course.
     * @returns {Promise} - A promise that resolves to the course details.
     */
    getArticleDetails(courseId){
        return new Promise(async(resolve,reject)=>{
            let courses = await apex_getArticleDetailsFromCourse({courseId:courseId});
            resolve(courses);
        })
    }

    /**
     * @method getProgress
     * @description Fetches the learning progress for a specific learning ID.
     * @param {string} learningId - The ID of the learning.
     * @returns {Promise} - A promise that resolves to the progress details.
     */
    getProgress(learningId){
        return new Promise(async(resolve,reject)=>{
            let progress =  await apex_getProgressFromLearning({learningId : learningId})
            resolve(progress);
        })
    }

    /**
     * @method connectedCallback
     * @description Lifecycle hook that runs when the component is connected to the DOM.
     * It initializes the component by loading necessary data and setting the initial state.
     */
    connectedCallback(){
        
        this.isLoading = true;


        this.getQueryParameters().then((result)=>{
             let raiseId = result.id

             this.loadData(raiseId)
             .then((result)=>{
                this.courseData = result;
                
             })
             .catch(error => console.error(error))
             .finally(()=>{

                // show fees if payment is not received
                if(this.courseData.raiseStatus.paymentReceived === true){
                    this.showFeesLocked = false;
                }else{
                    this.showFeesLocked = true;
                }

                // show welcome message if paymentReceived = true & courseUnlocked = false
                if(this.courseData.raiseStatus.paymentReceived  && this.courseData.raiseStatus.courseUnlocked === false){
                    this.showWelcome = true;
                    this.showFeesLocked = false;
                }else if(this.courseData.raiseStatus.paymentReceived && this.courseData.raiseStatus.courseUnlocked){
                    this.showFeesLocked = false;
                    this.showWelcome = false;
                }

                // set loading state to false
                this.isLoading = false;
                    
             });

             this.raiseId = raiseId
         })
         
      
     }

     /**
     * @method unlockRaiseCourse
     * @description Unlocks the course for a specific raise ID.
     * @param {string} raiseId - The ID of the raise.
     * @returns {Promise} - A promise that resolves when the course is unlocked.
     */
     unlockRaiseCourse(raiseId){
        return new Promise(async(resolve,reject)=>{
            let unlockCourse = await apex_unlockCourse({raiseId:raiseId});
            resolve(unlockCourse);
        })
     }

    /**
     * @method handleUnlockCourse
     * @description Handles the unlocking of the raise course by calling the unlockRaiseCourse method and showing a toast message.
     * @param {Event} e - The event triggered by the unlock course action.
     */
     handleUnlockCourse(e){
        this.unlockRaiseCourse(this.raiseId).then((result)=>{
            if(result.courseUnlocked === true){
                this.showWelcome = false;
                this.showToast('Success', 'Course unlocked!', 'success');
            }else{
                this.showToast('Error', 'There was an error unlocking the course', 'error');
                console.error(JSON.stringify(result));
            }
        })
        .catch((err)=>{
            this.showToast('Error', 'There was an error unlocking the course', 'error');
            console.error(err);
        });
     }

    /**
     * @method navigateToEOI
     * @description Navigates to the EOI (Expression of Interest) page for the current raise.
     */ 
     navigateToEOI(){
        let siteApiName = 'manage_eoi__c';

        this[NavigationMixin.Navigate]({
            // Define navigation type and target page name
            type: 'comm__namedPage',
            attributes: {
                name: siteApiName // Page name for my Companies
            },
            state:{
                id : this.eoiId
            }
        });
     }

     /**
     * @method getCoursesFromLearningId
     * @description Fetches the courses for a given learning ID.
     * @param {string} learningId - The ID of the learning.
     * @returns {Promise<Object[]>} - A promise that resolves with the courses.
     */
     getCoursesFromLearningId(learningId){
        return new Promise(async(resolve,reject)=>{
            try{
                let courses = await apex_getCoursesFromLearning({learningId :learningId})

                resolve(courses);
            }catch(e){
                console.error(e);
            }
        })
     }
 
    /**
     * @method returnToCompanies
     * @description Navigates back to the 'My Companies' page.
     * @param {Event} event - The event triggered by the navigation action.
     */
    returnToCompanies(event) {
        this[NavigationMixin.Navigate]({
            // Define navigation type and target page name
            type: 'comm__namedPage',
            attributes: {
                name: 'my_companies__c' // Page name for my Companies
            }
        });
     }
 
    /**
     * @method getQueryParameters
     * @description Parses the query parameters from the URL.
     * @returns {Promise<Object>} - A promise that resolves with the query parameters.
     */
     getQueryParameters() {
         return new Promise((resolve,reject)=>{
             var params = {};
             var search = location.search.substring(1);
 
             if (search) {
                 params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                     return key === "" ? value : decodeURIComponent(value)
                 });
             }
             resolve(params);
         })
     
        }

         /**
     * Displays a toast message.
     * @param {string} title - The title of the toast message.
     * @param {string} message - The message content of the toast.
     * @param {string} variant - The variant of the toast message, e.g., 'error', 'success'.
     */
    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(toastEvent);
    }
    
    }
import { LightningElement, api, track} from 'lwc';
import apex_getKnowledgeStatus from '@salesforce/apex/KnowledgeController.getArticleContent';
import apex_getPublicImageUrl from '@salesforce/apex/FileUploadController.getPublicImageUrl';
import apex__getRaiseDetails from '@salesforce/apex/RaiseController.getRaiseDetails'
import apex_getCoursesFromLearning from '@salesforce/apex/KnowledgeController.getCoursesFromLearning'
import apex_updateLearningCompletion from '@salesforce/apex/KnowledgeController.updateLearningCompletion';
import apex_getProgressFromLearning from '@salesforce/apex/KnowledgeController.getProgressFromLearning';
import apex_getArticleDetailsFromCourse from '@salesforce/apex/KnowledgeController.getArticleDetailsFromCourse';

import { NavigationMixin } from 'lightning/navigation';

import banner from '@salesforce/resourceUrl/Banner_Knowledge';


export default class KnowledgeArticleComponent extends NavigationMixin(LightningElement) {
    @api recordId
    @track knowledgeFinalData = {
        title: '',
        estimatedCompletionTime: '',
        objective: '',
        answer: '',
    };
    @track bannerImageUrl;
    @track nextModuleUrl;
    @track raiseId;
    @track learningProgressId;
    @track isLoading;

    /**
     * Get method to format the estimated completion time.
     * @returns {string} - Formatted completion time
     */
    get completionTime(){
        return this.knowledgeFinalData.estimatedCompletionTime === 1 ? `${this.knowledgeFinalData.estimatedCompletionTime} Hour`  : `${this.knowledgeFinalData.estimatedCompletionTime} Hours` 
    }

    /**
     * Method to get the public image URL for a given record ID.
     * @param {Id} recordId - The ID of the record
     * @returns {Promise<string>} - The URL of the public image
     */
    getImageUrl(recordId){
        return new Promise(async(resolve,reject)=>{
            try{
                let res =  await apex_getPublicImageUrl({recordId : recordId});
                resolve(res);
    
            }catch(err){
                reject(err);
            }
        })
    }

    /**
     * Method to get the knowledge article data for a given record ID.
     * @param {Id} recordId - The ID of the record
     * @returns {Promise<Object>} - The knowledge article data
     */    
    async getKnowledgeArticle(recordId) {
        try {
            let knowledgeData = await apex_getKnowledgeStatus({articleId : recordId});

            // Set a banner Image if nothing is found use a default one
            this.getImageUrl(recordId).then((res)=>{
                this.bannerImageUrl = `background-image: url(${res});`;
            }).catch((err)=>{
                this.bannerImageUrl = `background-image: url(${banner});`;
                console.error(err)
            })
            return knowledgeData;
        } catch (error) {
            console.error('Error fetching Data for Knowledge', error);
            throw error
        }
    }

    /**
     * @description Method to load data related to a raise.
     * @param {Id} raiseId - The ID of the raise
     * @returns {Promise<Object>} - The loaded data
     */    
    loadData(raiseId){
        return new Promise(async(resolve,reject)=>{
            try{
                let raiseDetails = await this.getRaise(raiseId);
                let learningId = raiseDetails.learning ? raiseDetails.learning : '';
                // if learning data exists then load the modules, courses and progress objects & raise statuses
                if(this.learningId !== ''){
                    // get learning data
                    let courses = await this.getCoursesFromLearningId(learningId);

                    let progress = await this.getProgress(learningId);

                    let modules = await this.getArticleDetails(courses[0].id)

                    let modulesUrls = modules.map(module => module.urlName);

                    let returnData = {
                        raiseDetails: raiseDetails,
                        courses: courses,
                        progress: progress,
                        modules: modules,
                        modulesUrls : modulesUrls,
                    }
                    resolve(returnData);
                }      
            }catch(error) {
                reject(error);
            }
        })
    }


    /**
     * Method to get courses from a learning ID.
     * @param {Id} learningId - The ID of the learning
     * @returns {Promise<Array>} - The list of courses
     */    
    getCoursesFromLearningId(learningId){
        return new Promise(async(resolve)=>{
            try{
                let courses = await apex_getCoursesFromLearning({learningId :learningId})

                resolve(courses);
            }catch(e){
                console.error(e);
            }
        })
    }

    /**
     * Method to get the details of a raise.
     * @param {Id} raiseId - The ID of the raise
     * @returns {Promise<Object>} - The details of the raise
     */
    getRaise(raiseId){
        return new Promise(async(resolve,reject)=>{
            const raiseDetails = await apex__getRaiseDetails({raiseId: raiseId});
            const parsedData = JSON.parse(raiseDetails);
            resolve(parsedData)
        })
    }

    /**
     * Method to get article details from a course ID.
     * @param {string} courseId - The ID of the course
     * @returns {Promise<Array>} - The list of articles
     */
    getArticleDetails(courseId){
        return new Promise(async(resolve,reject)=>{
            let courses = await apex_getArticleDetailsFromCourse({courseId:courseId});
            resolve(courses);
        })
    }

    /**
     * Method to get the progress of learning from a learning ID.
     * @param {Id} learningId - The ID of the learning
     * @returns {Promise<Object>} - The progress of the learning
     */
    getProgress(learningId){
        return new Promise(async(resolve,reject)=>{
            let progress =  await apex_getProgressFromLearning({learningId : learningId})
            resolve(progress);
        })
    }


    connectedCallback(){
        this.isLoading = true;
        this.getQueryParameters().then((result)=>{
            // Set the raise Id based on the URL
            let raiseId = result.id
            this.raiseId = raiseId;
            // Get the current module eg module-1
            let currentModule = result.module;
            if(raiseId){
                this.loadData(raiseId)
                .then((result)=>{
                    let filterUrl = this.getNextModule(result.modulesUrls, currentModule)
                    this.nextModuleUrl = filterUrl;

                    // Get the learning Id; 
                    const module = result.modules.find(mod => mod.urlName === currentModule);
                    if (!module) {
                        return null;
                    }
                    // Find the progress related to the module's articleId
                    const progress = result.progress.find(prog => prog.articleId === module.id);
                    const finalId = progress ? progress.id : null;
                    this.learningProgressId = finalId;
                })
                .catch(error => {
                    this.isLoading = false;
                    console.error(error)
                })
                .finally(()=>{
                    this.isLoading=false;
                })
            }
            
        });

        // Get the knowledge article and set the variables to handle errors

        this.getKnowledgeArticle(this.recordId)
            .then((result) => {
                this.knowledgeFinalData.title = result.title ? result.title : '';
                this.knowledgeFinalData.estimatedCompletionTime = result.estimatedCompletionTime ? result.estimatedCompletionTime : '';
                this.knowledgeFinalData.objective = result.objective ? result.objective : '';
                this.knowledgeFinalData.answer = result.answer ? result.answer : '';
            }).catch((err) => {
                console.error(err);
                this.isLoading=false;

            }).finally(()=>  {
                this.isLoading=false
            });
    }


    

    /**
     * Method to get the next module URL.
     * @description  get the next module for example if you have ["Module_1", "Module_2", "Module_3"] 
     * this will return the next module. In this case if it's in module_2 will return module_2 if doesn't
     * have any module after this will return to the capital raise 101
     * @param {Array} modulesUrls - The list of module URLs
     * @param {string} currentModule - The current module
     * @returns {string} - The next module URL
     */

    getNextModule (modulesUrls, currentModule) {
        let currentIndex = modulesUrls.indexOf(currentModule);
        if (currentIndex !== -1 && currentIndex < modulesUrls.length - 1) {
            return modulesUrls[currentIndex + 1];
        } else {
            return "capital-raising-101";
        }
    }

    /**
     * Method to handle the save button click. 
     * @description Invokes the Apex method to update learning completion.
     * @param {Event} e - The event triggered by user interaction
     * @returns {Promise<void>}
     */
    async handleSave(e){
        try{
            let updateCompletion = await apex_updateLearningCompletion({ learningProgId: this.learningProgressId , completed: true})
            let url;
            
            // Format the url based if it the last module
            if (this.nextModuleUrl === 'capital-raising-101') {
                url = 'https://'+window.location.host+`/s/portal/my-companies/${this.nextModuleUrl}?id=${this.raiseId}`
            } else {
                url = `/module/${this.nextModuleUrl}?id=${this.raiseId}`
    
            }
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: url
                },
            });

        }catch(err){
            console.error(err);
        }
    }

    /**
     * Method to get query parameters from the URL.
     * @returns {Promise<Object>} - The query parameters
     */
    getQueryParameters() {
        return new Promise((resolve, reject) => {
            let params = {};
            let search = location.search.substring(1);
    
            if (search) {
                params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                    return key === "" ? value : decodeURIComponent(value);
                });
            }
            
            let pathSegments = location.pathname.split('/');
            let moduleIndex = pathSegments.indexOf('module');
            if (moduleIndex !== -1 && moduleIndex + 1 < pathSegments.length) {
                params.module = pathSegments[moduleIndex + 1];
            }
    
            resolve(params);
        });
    }


    /**
     * Method to navigate back to the capital raising 101 page.
     * @returns {void}
     */
    navigateBack(){
        let url = 'https://' + window.location.host +`/s/portal/my-companies/capital-raising-101?id=${this.raiseId}`
        //change url
        window.location.href = url;
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: url
        //     },
        //     state: {
        //         id: this.raiseId
        //     }
        // });
    }

    /**
     * Method to handle the back button click. 
     * @description If the next module is capitalRaising1101 will go to the course page otherwise to the next module
     * @returns {void}
     */
    backButton() {
        let url;
        if (this.nextModuleUrl === 'capital-raising-101') {
            url = 'https://' + window.location.host +`/s/portal/my-companies/${this.nextModuleUrl}?id=${this.raiseId}`
        } else {
            url = `/module/${this.nextModuleUrl}?id=${this.raiseId}`

        }
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: url
            },
            state: {
                id: this.raiseId
            }
        });
    }

    @track hasRendered
    renderedCallback(){
        // Use InnerHTML to insert the content from SF. Do it in this way to have
        // a better control to the CSS classes
        const container = this.template.querySelector('.answer-html-container');
        if (container) {
            container.innerHTML = this.knowledgeFinalData.answer;
        }

        // Scrolling action
        if(!this.hasRendered && this.isLoading === false){
            const hash = window.location.hash.substring(1);
            const id = hash.split('?')[0];
            if(id){
                const targetElement = document.getElementById(`${id}`);
                if(targetElement){
                    targetElement.scrollIntoView({ behavior: 'smooth' });
                }
            }
            this.hasRendered = true
        }
    }
}
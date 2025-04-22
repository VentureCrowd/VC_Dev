/**
 * RaiseCapitalRaisingCourse Component
 * @description This component handles the logic and UI for displaying the capital raising course modules. It allows users to track their progress through the course, mark modules as complete, and ultimately complete the entire course. The component interacts with Apex controllers to update learning progress and complete the learning course.
 * 
 * @example
 *  <c-raise-capital-raising-course
 *      learning-data={learningData}
 *  >
 *  </c-raise-capital-raising-course>
 * 
 * @example
 * // Example data structure for learningData
 * {
 *     course: {
 *         title: 'Capital Raising 101 Course',
 *         description: 'We have prepared some information for you around the ins and outs of capital raising...',
 *         progress: '20',
 *         completed: false,
 *     },
 *     modules: [
 *         {
 *             id: 'module1',
 *             title: 'Module 1: Introduction to Capital Raising',
 *             url: 'module1',
 *             description: 'An overview of capital raising...',
 *             estimatedCompletionTime: 2,
 *             tags: ['Introduction', 'Capital'],
 *             completed: false,
 *         },
 *         {
 *             id: 'module2',
 *             title: 'Module 2: Advanced Strategies',
 *             url: 'module2',
 *             description: 'Advanced strategies in capital raising...',
 *             estimatedCompletionTime: 4,
 *             tags: ['Advanced', 'Strategies'],
 *             completed: false,
 *         }
 *     ],
 *     raiseDetails: {
 *         learning: 'a1B1r00000F5N3AEAV',
 *         id: 'a1C1r00000G5N3BEAV',
 *         status: 'Waiting to complete learning course',
 *     }
 * }
 */
import { LightningElement ,api, track} from 'lwc';

import apex_updateLearningCompletion from '@salesforce/apex/KnowledgeController.updateLearningCompletion';
import apex_completeLearning from '@salesforce/apex/KnowledgeController.completeLearningCourse';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import ventureCrowdTheme from "@salesforce/resourceUrl/ventureCrowdTheme";


export default class RaiseCapitalRaisingCourse extends NavigationMixin(LightningElement) {
    @track course;
    @track modules;
    @track status;
    
    @track _learningData;

    @track completedPercentage = 0;

    @track learningId;

    @track raiseId;

    @track hasRendered=false;

    completeCourseImg = ventureCrowdTheme + '/Images/completeCourse.png';

    @api 
    get learningData(){
        return this._learningData;
    }
    set learningData(value){
        this._learningData = value;

        this.course = this._learningData.course ? this._learningData.course : {};
        // this.modules = this._learningData.modules ? this._learningData.modules : [];
        this.learningId = this._learningData?.raiseDetails?.learning;
        this.raiseId = this._learningData?.raiseDetails?.id;
        this.status = this._learningData?.raiseDetails?.status;

        if(this._learningData.modules.length > 0){
            let updatedModules = this._learningData.modules.map(module => {
                return{
                    ...module,
                    estimatedCompletionTimeFormatted : module.estimatedCompletionTime === 1 ? `${module.estimatedCompletionTime} Hour` : `${module.estimatedCompletionTime} Hours`
                }
            })

            this.modules = [...updatedModules];
        }else{
            this.modules = []
        }

    }

    completedOption = [
        {id:1, label:"Complete", value:false, checked:false},
    ];

    get displayCourseCompletedButton(){
        return this.status === "Waiting to complete learning course"
    }

    get isNotCompleted(){
        let isCompleted = this.modules.every(module => module.completed === true)
        return !isCompleted;
    }

    /**
     * @method handleCheckboxChange
     * @description Handles the change event for checkboxes to update the completion status of the modules.
     * @param {Event} event - The change event from the checkbox.
     */
    handleCheckboxChange(event){
        event.stopPropagation()

        const inputChanged = event.detail

        const newValue = inputChanged.value[0]

        const id = inputChanged.name;

        const newModules = this.modules.map((module)=>{
            if(module.id === id){
                if(newValue){
                    return {...module, completed: newValue}
                }else{
                    return {...module, completed: false}
                }
            }else{
                return module
            }
        })

        this.modules = [...newModules]
        this.completedPercentage = this.updateCourseProgress();
        this.updateProgressBar(this.completedPercentage)
        
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
    
    /**
     * @method handleSave
     * @description Handles the save event to update the completion status of all modules.
     * @param {Event} e - The event triggered by the save action.
     */
    handleSave(e){
        this.modules.forEach(async module => {
            try{
                this.completeModule(module.learningProgId , module.completed).then((res)=>{
                    this.showToast('Success', 'Learning progress saved succesfully', 'success');
                })
            }catch(err){
                console.error(err);
                this.showToast('Error', 'There was an error saving your learning progress', 'error');
            }
        })

    }

    /**
     * @method handleComplete
     * @description Handles the completion of the entire course and updates the learning object.
     * @param {Event} e - The event triggered by the complete action.
     */
    handleComplete(e){
        // update the learning object using the raiseId
        if(this.learningId && this.raiseId){
            this.completeAllModules().then((res)=>{
                this.completeLearning(this.learningId, this.raiseId).then((res)=>{
                    this.showToast('Success', 'Learning course has been succesfully completed', 'success');
                })
            })
           
        }else{
            console.error("There was an error completing your learning course: ", this.learningId);
            this.showToast('Error', 'There was an error completing your learning course', 'error');
        }
        
    }

    /**
     * @method completeAllModules
     * @description Completes all modules by marking them as completed.
     * @returns {Promise} - A promise that resolves when all modules are completed.
     */
    completeAllModules(){
        return new Promise(async(resolve,reject)=>{
            let promises = [];
            this.modules.forEach((module)=>{
                let pendingPromise = this.completeModule(module.learningProgId, true);
    
                promises.push(pendingPromise)
            })
    
            try{
                const results = await Promise.all(promises);
                resolve(results);
            }catch(error){
                reject(error);
            }
        })
    }

    /**
     * @method completeModule
     * @description Marks a specific module as completed.
     * @param {string} learningProgId - The ID of the learning progress record.
     * @param {boolean} completed - The completion status of the module.
     * @returns {Promise} - A promise that resolves when the module is marked as completed.
     */
    completeModule(learningProgId,completed){
        return new Promise(async(resolve,reject)=>{
            let retData = await apex_updateLearningCompletion({learningProgId:learningProgId , completed: completed})
            resolve(retData);
        })
    }

    /**
     * @method completeLearning
     * @description Marks the entire learning course as completed.
     * @param {string} learningId - The ID of the learning record.
     * @param {string} raiseId - The ID of the raise record.
     * @returns {Promise} - A promise that resolves when the learning course is marked as completed.
     */ 
    completeLearning(learningId, raiseId){
        return new Promise(async(resolve,reject)=>{
            let retData = await apex_completeLearning({learningId : learningId , raiseId : raiseId});
            resolve(retData)
        })
    }
    
    /**
     * @method updateCourseProgress
     * @description Updates the course progress by calculating the percentage of completed modules.
     * @returns {number} - The percentage of completed modules.
     */
    updateCourseProgress(){
       // Initialize a counter for completed modules
        let completedCount = 0;

        // Loop through each object in the array
        this.modules.forEach(module => {
            // Check if the 'completed' property is true
            if (module.completed === true) {
            // Increment the counter
            completedCount++;
            }
        });

        // Calculate the percentage
        let percentage = (completedCount / this.modules.length) * 100;

        // Return the final percentage
        return percentage;
    }

    /**
     * @method updateProgressBar
     * @description Updates the progress bar with the given progress percentage.
     * @param {number} progressPercentage - The progress percentage to set on the progress bar.
     */
    updateProgressBar(progressPercentage){
        const progressBarSelector = this.template.querySelector(".progress-bar-width");
            if(progressBarSelector){
                let progressBarWidth = String(progressPercentage) + '%'
                progressBarSelector.style.width = progressBarWidth;
            }

    }

    /**
     * @method setCheckboxFields
     * @description Sets the checkbox fields with the current module completion status.
     */
    setCheckboxFields(){
        let checkboxFields = this.template.querySelectorAll(`c-core-checkbox`)
            for(let checkBox of checkboxFields){
                
                let matchedModule = this.modules.find(module => module.id === checkBox.name);
                if(matchedModule){
                    checkBox.values = [{id:1, label:"Complete", value: true, checked: matchedModule.completed}]
                }else{
                    checkBox.values = [{id:1, label:"Complete", value: true, checked: false}]
                }

            }
    }

    /**
     * @method renderedCallback
     * @description Lifecycle hook that runs after the component's elements have been rendered.
     */
    renderedCallback(){
        if(!this.hasRendered){
            // query selector the div to add the description
            const courseDescElement = this.template.querySelector(".course-description");
            if(courseDescElement && this.course.description){
                courseDescElement.innerHTML = this.course.description;   
            }

            this.completedPercentage = this.updateCourseProgress();
            const progressBarSelector = this.template.querySelector(".progress-bar-width");

            if(progressBarSelector){
                let progressBarWidth = String(this.completedPercentage) + '%'
                progressBarSelector.style.width = progressBarWidth;
            }

            // set fields
            this.setCheckboxFields();

            this.hasRendered = true;
        }
    }

    /**
     * @method returnToCompanies
     * @description Navigates back to the 'My Companies' page.
     */
    returnToCompanies(){
        this[NavigationMixin.Navigate]({
            // Define navigation type and target page name
            type: 'comm__namedPage',
            attributes: {
                name: 'my_companies__c' // Page name for my Companies
            }
        });
    }

}
import { LightningElement, track , api} from 'lwc';
import apex_createLearningForRaise from '@salesforce/apex/RaiseController.createLearningForRaise';

export default class RaiseRecordPageLearning extends LightningElement {
    @api recordId;

    @track learningData;
    @track isLoading

    createLearningForRaise(raiseId){
        return new Promise(async(resolve,reject)=>{
            try{
                let returnData = await apex_createLearningForRaise({raiseId :raiseId});
                resolve(returnData)
            }catch(err){
                reject(err);
                console.error('An error occured:', err);
            }
            
        })
    }

    handleCreateLearning(){
        this.isLoading = true;
        if(this.recordId){
            this.createLearningForRaise(this.recordId).then(result => {
                this.learningData = result;
                console.log(JSON.stringify(this.learningData));
            })
            .catch(err => {
                console.error("An error has occured:", err)
            })
            .finally(()=>{
                this.isLoading = false;
            });
        }
    }


}
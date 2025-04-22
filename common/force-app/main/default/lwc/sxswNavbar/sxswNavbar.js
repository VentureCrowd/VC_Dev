import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class SxswNavbar extends NavigationMixin(LightningElement) {
    handleNavigateToHome(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
    }
}
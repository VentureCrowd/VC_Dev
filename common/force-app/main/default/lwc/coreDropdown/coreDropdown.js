import { LightningElement, api } from 'lwc';

export default class CoreDropdown extends LightningElement {

    @api values;

    //! Delete values
    values = [
        {value: 'Camels', label: 'Option 1'},
        {value: 'Wolfs', label: 'Option 2'},
        {value: 'Cows', label: 'Option 3'},
        {value: 'Pigs', label: 'Option 4'},
        {value: 'Toro', label: 'Option 5'},
        {value: 'Rest', label: 'Option 6'}
    ]



}
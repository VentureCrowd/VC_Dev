import { LightningElement, api } from 'lwc';

export default class CoreBadges extends LightningElement {

/**
 * Core Badge component
 * @example 
    <c-core-badges
        value="Interest Paid"
        background-color="#D9FFE5"
        text-color="var(--black)"
        icon-name="interestPaid"
        icon-color="#27B48A">
    </c-core-badges>
**/ 

    /**
    Values - values to be displayed on the badge
    @parameter value
    @example 'This is a badge'
    **/
    @api value;

    /**
    Values - Background color
    @example '#fff' or 'var(--black) -> You can use variables
    **/
    @api backgroundColor;


    /**
    Values - Text color
    @example '#fff' or 'white'
    **/
    @api textColor;

    /**
    Values - Icon name 
    @example 'lock'
    **/
    @api iconName;

    /**
    Values - Icon color 
    @example 'var(--white)'
    **/
    @api iconColor;

    /**
    Values - Icon color 
    **/
    renderedCallback() {
        this.style.setProperty('--badge-background-color', this.backgroundColor);
        this.style.setProperty('--badge-text-color', this.textColor);
        this.style.setProperty('--icon-color', this.iconColor);
        // Change to render correctly the padding of the badge text
        if (this.iconName) {
            this.style.setProperty('--padding-text', '10px 15px');
        } else {
            this.style.setProperty('--padding-text', '10px 30px');
        }
    }
}
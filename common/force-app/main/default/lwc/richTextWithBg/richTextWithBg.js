import { LightningElement, api } from 'lwc';

export default class RichTextWithBg extends LightningElement {
    @api text = 'Founder Opportunity'; // Default text
    @api backgroundColor = 'Blue'; // Default background color
    @api textColor = 'White'; // Default text color
    @api textAlignment = 'center'; // Default alignment

    // Map color names to hex values
    colorMap = {
        'Blue': '#0070D2',
        'Red': '#FF0000',
        'Green': '#28A745',
        'Yellow': '#FFC107',
        'Purple': '#6F42C1',
        'Black': '#000000',
        'White': '#FFFFFF'
    };

    // Ensure alignment is only 'left', 'center', or 'right'
    get validTextAlignment() {
        const allowedValues = ['left', 'center', 'right'];
        return allowedValues.includes(this.textAlignment) ? this.textAlignment : 'center';
    }

    // Compute CSS styles dynamically using valid color names and alignment
    get computedStyle() {
        const bgColor = this.colorMap[this.backgroundColor] || '#0070D2'; // Default if invalid
        const txtColor = this.colorMap[this.textColor] || '#FFFFFF'; // Default if invalid

        return `background-color: ${bgColor}; color: ${txtColor}; padding: 15px; 
                border-radius: 5px; font-size: 18px; font-weight: bold; text-align: ${this.validTextAlignment};`;
    }
}
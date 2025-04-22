import { LightningElement, api } from 'lwc';

export default class HomeCarousel extends LightningElement {

    @api RightImageURL1;
    @api titleText1;
    @api DescriptionText1;

    @api RightImageURL2;
    @api titleText2;
    @api DescriptionText2;

    @api RightImageURL3;
    @api titleText3;
    @api DescriptionText3;

    @api RightImageURL4;
    @api titleText4;
    @api DescriptionText4;

    @api backgroundColor;
    bgColorClass = { 'White': 'component-bg-white', 'Grey': 'component-bg-gray', 'Dark Navy': 'component-bg-dark-navy' };

    slides;
    dots;
    index;
    isRendered=false;

    renderedCallback() {
        if(!this.isRendered) {
            this.isRendered = true;

            // Add Inner HTML for description sections
            const descpTextSec_1 = this.template.querySelector('.descpTextSec_1');
            if(descpTextSec_1) descpTextSec_1.innerHTML = this.DescriptionText1;

            const descpTextSec_2 = this.template.querySelector('.descpTextSec_2');
            if(descpTextSec_2) descpTextSec_2.innerHTML = this.DescriptionText2;

            const descpTextSec_3 = this.template.querySelector('.descpTextSec_3');
            if(descpTextSec_3) descpTextSec_3.innerHTML = this.DescriptionText3;

            const descpTextSec_4 = this.template.querySelector('.descpTextSec_4');
            if(descpTextSec_4) descpTextSec_4.innerHTML = this.DescriptionText4;

            // Update Slides & its css classes
            this.slides = this.template.querySelectorAll('.slide');
            this.dots = this.template.querySelectorAll('.dot');
            this.index = 0;
            this.changeSlide();
        }
    }

    prevSlide(event) {
        let n = -1;
        this.index += n;
        this.changeSlide();
    }

    nextSlide(event) {
        let n = 1;
        this.index += n;
        this.changeSlide();
    }

    gotoSlide(event){
        let slideIndex  = event.target.dataset.id;
        this.index = slideIndex;
        this.changeSlide();
    }

    changeSlide() {
        if (this.index > (this.slides).length - 1)
            this.index = 0;

        if (this.index < 0)
            this.index = (this.slides).length - 1;

        for (let i = 0; i < (this.slides).length; i++) {
            (this.slides)[i].style.display = "none";
            (this.dots)[i].classList.remove("active");
        }

        (this.slides)[this.index].style.display = "block";
        (this.dots)[this.index].classList.add("active");
    }

    get getComponentStyleClasses() {
        return 'component-container ' + this.bgColorClass[this.backgroundColor];
    }
}
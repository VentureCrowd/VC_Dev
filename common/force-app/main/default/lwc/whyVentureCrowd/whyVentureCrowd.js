import { LightningElement,track,api,wire } from 'lwc';

// Style/JS Imports
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
export default class WhyVentureCrowd extends LightningElement {


    @api HeadingText;
    @api ParagraphText;
    @api Totalmembers;
    @api TotalmembersLabel;
    @api Totalraised;
    @api TotalraisedsLabel;
    @api portfoliosize;
    @api portfoliosizeLabel;
    @api TotalmembersColor;

    // Prevent renderedCallback from firing multiple times. Garbage system and probably incorrect.
    @track hasRendered = true;
    @track inViewport = false;

    // Begin garbage
    renderedCallback() {
        if (this.hasRendered) {
            var elContainer = this.template.querySelector('.component-container');
            //console.log(elContainer);

            document.addEventListener('scroll', () =>  {
                const rect = elContainer.getBoundingClientRect();
                //console.log(rect);

                if(!this.inViewport) {

                    if(rect.top < 0) {
                        var elCounters = this.template.querySelectorAll('.cell .digits');
                        elCounters.forEach((el, index) => {
                            var elInnerText = el.innerText;
                            // Remove the dollar sign from text.
                            var number = elInnerText;
                            var prefix = '';
                            if(elInnerText.includes("$")) {
                               number = elInnerText.replace("$", "");
                               prefix = '$';
                            }
                            this.animateNumber(el, 0, parseInt(number, 10), 3500, prefix);
                        });
                        // Only fire once.
                        this.inViewport = true;
                    }
                }
            
            }, {
                passive: true
            });

            this.hasRendered = false;
        }

    }

    animateNumber(obj, start, end, duration, prefix) {
        let startTimestamp = null;
        const step = (timestamp) => {
          if (!startTimestamp) startTimestamp = timestamp;
          const progress = Math.min((timestamp - startTimestamp) / duration, 1);
          obj.innerHTML = prefix + new Intl.NumberFormat().format(Math.floor(progress * (end - start) + start));
          if (progress < 1) {
            window.requestAnimationFrame(step);
          }
        };
        window.requestAnimationFrame(step);
      }
      

    colorCombination = { 'Teal': '#05c5d1', 'Pink': '#dd5cff', 'Navy':'#0F141E' };

    get getTextColor() {
        return 'color:' + (this.Totalmembers ? (this.colorCombination)[this.Totalmembers] : 'Teal');
    }

    // Colours

    @api backgroundColor;
    @api highlightColor;
    colorCombination = { 'White': '#FFF', 'Gray': '#02c8c81a', 'Black': '#000000', 'Teal': '#05c5d1', 'Pink': '#dd5cff', 'Navy':'#0F141E' };

    bgColorClass = { 'White': 'bg-white', 'Gray': 'bg-gray', 'Black': 'bg-black' };

    accentColorClass = { 'Teal': 'accent-teal', 'Pink': 'accent-pink', 'Navy': 'accent-navy', 'Black': 'accent-black', 'White': 'accent-white' };

    get getStyling() {
        return 'background-color : ' + this.colorCombination[this.backgroundColor];
    }
    get getComponentStyleClasses() {
        return 'component-container text-center ' + this.bgColorClass[this.backgroundColor] + ' ' + this.accentColorClass[this.highlightColor];
    }
}
import { LightningElement,api, track } from 'lwc';

class tabPkg {
    constructor(tabName, tabContent) {
        this.tabName = tabName;
        this.tabContent = tabContent;
    }
}

export default class VerticalTabslist extends LightningElement {
    @api flexipageRegionWidth;
    @api tabNames;
    @api tabContent;
    tablist = [];
    tabindex = [];
    tabcontentlist = [];
    tabcontenttodisplay;
    @track hasRendered = true;
    @track isMobile = false;
    formFactorName;
    widthDiff = 1200;
    tabPkgArray = [];
    selectedIndex = 0;

    connectedCallback(){
        // this.tabNames = "What is crowdfunding, What are crowdfunding platforms, How crowdfunding works,Crowdfunding for Investors,Crowdfunding for Businesses";
        // this.tabContent = "";
        window.addEventListener('resize', this.computeformfactor.bind(this));
        this.isMobile = window.innerWidth < this.widthDiff ? true : false;
        this.tablist = this.tabNames.split(',');
        this.tabcontentlist = this.tabContent.split('--tabSplit--'); // FIXME: split text
        

        if(this.tablist != undefined) {
            for(let i=0; i < this.tablist.length; i++) {
                this.tabPkgArray.push( new tabPkg(this.tablist[i], this.tabcontentlist[i]) );
            }
        }
        console.log(this.tabPkgArray);
    }

    @track renderedNewFormFactor = false;
    computeformfactor() {
        console.log('called computeformfactor');
        var current = window.innerWidth < this.widthDiff ? true : false;
        if(current != this.isMobile) {
            this.isMobile = current;
            this.renderedNewFormFactor = true;
        }
    }
    
    renderedCallback() {
        if (this.hasRendered) {
            // Select all the tab items.
            try{
                if(!this.isMobile && (this.selectedIndex == null || this.selectedIndex == undefined)) {
                    this.selectedIndex = 0;
                }
                if(!this.isMobile) {
                    console.log('rendered callback fired');
                    console.log('isMobile ' + this.isMobile);
                    if(!this.renderedCallback) {
                        this.selectedIndex = 0;
                    }
                    let elTabItems = this.template.querySelectorAll('.tab-card');
                    let el = elTabItems[this.selectedIndex];
                    el.classList.add('active');
                    this.tabcontenttodisplay = this.tabcontentlist[this.selectedIndex];
                    // Set had rendered to false to prevent duplicate renderCallback execution.
                    this.hasRendered = false;
                }
            } catch(e){console.log(e)}
        }
        if(this.renderedNewFormFactor) {
            try{
                if(!this.isMobile && (this.selectedIndex == null || this.selectedIndex == undefined)) {
                    this.selectedIndex = 0;
                }
                
                eval("$A.get('e.force:refreshView').fire();");
                console.log('computed new form factor');
            
                let tabItems = this.template.querySelectorAll('.tab-card');
                tabItems.forEach(item => {
                    item.classList.remove('active');
                });
                let el = tabItems[this.selectedIndex];
                el.classList.add('active');
                this.tabcontenttodisplay = this.tabcontentlist[this.selectedIndex];
                if(this.isMobile) {
                    console.log('mobile');
                    try{
                        let tabContents = this.template.querySelectorAll('.tab-content');
                        tabContents.forEach(content => {
                            content.classList.add('slds-hide');
                        });
                        let el = tabContents[this.selectedIndex];
                        el.classList.remove('slds-hide');
                        console.log('mobile success');

                        let tabIcons = this.template.querySelectorAll('.tab-icon');
                        tabIcons.forEach((el) => {
                            el.iconName = 'utility:chevronright';
                        });
                        tabIcons[this.selectedIndex].iconName = 'utility:chevrondown';
                    } catch(e){console.log(e)}
                }
                this.renderedNewFormFactor = false;
            } catch(e){console.log(e)}
        }

    }

    handletabclick(event){
        try{
            let index = event.currentTarget.dataset.num;
            if(this.selectedIndex == index) {
                this.selectedIndex = null;
                let tabItems = this.template.querySelectorAll('.tab-card');
                event.preventDefault();
                tabItems.forEach((tabItem) => {
                    tabItem.classList.remove('active');
                });
                let tabContents = this.template.querySelectorAll('.tab-content');
                    tabContents.forEach(content => {
                        content.classList.add('slds-hide');
                    });
                let tabIcons = this.template.querySelectorAll('.tab-icon');
                    tabIcons.forEach((el) => {
                        el.iconName = 'utility:chevronright';
                    });
            } else {
                this.selectedIndex = index;
                console.log('selected ' + this.selectedIndex);
                eval("$A.get('e.force:refreshView').fire();");
                
                let tabItems = this.template.querySelectorAll('.tab-card');
                event.preventDefault();
                let el = tabItems[this.selectedIndex];
                this.tabcontenttodisplay = this.tabcontentlist[this.selectedIndex];

                // Remove active class from all except the current.
                tabItems.forEach((tabItem) => {
                    tabItem.classList.remove('active');
                });
                el.classList.add('active');
                if(this.isMobile) {
                    let tabContents = this.template.querySelectorAll('.tab-content');
                    tabContents.forEach(content => {
                        content.classList.add('slds-hide');
                    });
                    let el = tabContents[this.selectedIndex];
                    el.classList.remove('slds-hide');
                    event.target.scrollIntoView();

                    let tabIcons = this.template.querySelectorAll('.tab-icon');
                    tabIcons.forEach((el) => {
                        el.iconName = 'utility:chevronright';
                    });
                    tabIcons[this.selectedIndex].iconName = 'utility:chevrondown';
                }
            }


        } catch(e){console.log(e)}

    }
}
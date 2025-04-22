import { LightningElement, api, track } from 'lwc';

export default class VcHomeFaq extends LightningElement {
    @api label_Tab_1_Name; @api label_Tab_1_Header; @api label_Tab_1_Context;

    @api label_Tab_2_Name; @api label_Tab_2_Header; @api label_Tab_2_Context;

    @api label_Tab_3_Name; @api label_Tab_3_Header; @api label_Tab_3_Context;

    @api label_Tab_4_Name; @api label_Tab_4_Header; @api label_Tab_4_Context;

    @api label_Tab_1_ShowColumn; @api label_Tab_2_ShowColumn; @api label_Tab_3_ShowColumn; @api label_Tab_4_ShowColumn;

    @api label_Tab_1_Column_1;
    @api label_Tab_1_Column_2;
    @api label_Tab_2_Column_1;
    @api label_Tab_2_Column_2;
    @api label_Tab_3_Column_1;
    @api label_Tab_3_Column_2;
    @api label_Tab_4_Column_1;
    @api label_Tab_4_Column_2;

    @api themecolor;

    // Prevent shitty renderedCallback from firing more than once.
    @track hasRendered = true;

    bgColorClass = { 'White': 'component-bg-white', 'Grey': 'component-bg-gray', 'Dark Navy': 'component-bg-dark-navy', "Dark Grey": 'component-bg-dark-grey', "Black": 'component-bg-black' };

    renderedCallback() {

        if ( this.hasRendered ) {
            // Select all the tab items.
            var elTabItems = this.template.querySelectorAll( '.tab-menu ul li a' );

            // Select tab body element.
            var elTabHeader = this.template.querySelector( 'h3.tab-heading' );

            // Select tab body element.
            var elTabContent = this.template.querySelector( '.tab-body-content' );

            // 2 Column Markup
            var col2MarkupStart = `<div class="col-lg-6 mb-3">`;

            // 1 Column Markup
            var col1MarkupStart = `<div class="col-lg-12">`;

            // Column Markup End
            var colMarkupEnd = `</div>`;

            // Add event listeners for each tab item click.
            elTabItems.forEach( ( el, index ) => {
                el.addEventListener( 'click', ( e ) => {

                    // Stop the page from scrolling to the top.
                    e.preventDefault();

                    // Remove active class from all except the current.
                    elTabItems.forEach( ( tabItem, index ) => {
                        tabItem.classList.remove( 'active' );
                    } );

                    el.classList.add( 'active' );

                    // Get the active tab number.
                    var activeTab = e.target.dataset.tab;

                    // Update heading
                    // elTabHeader.innerHTML = this['label_Tab_' + activeTab + '_Header'];
                    elTabHeader.innerHTML = this[ 'label_Tab_' + activeTab + '_Header' ];

                    // Check if it is single or two column content.
                    if ( this[ 'label_Tab_' + activeTab + '_ShowColumn' ] ) {

                        // Safe guards to prevent 'undefined' being returned.
                        var contentCol1 = ( this[ 'label_Tab_' + activeTab + '_Column_1' ] ) ? this[ 'label_Tab_' + activeTab + '_Column_1' ] : '';
                        var contentCol2 = ( this[ 'label_Tab_' + activeTab + '_Column_2' ] ) ? this[ 'label_Tab_' + activeTab + '_Column_2' ] : '';

                        // Dynamically update the tab body content.
                        elTabContent.innerHTML = `
                            ${ col2MarkupStart } ${ contentCol1 } ${ colMarkupEnd }
                            ${ col2MarkupStart } ${ contentCol2 } ${ colMarkupEnd }
                        `;
                    } else {

                        // Dynamically update the tab body content.
                        elTabContent.innerHTML = `${ col1MarkupStart } ${ this[ 'label_Tab_' + activeTab + '_Context' ] } ${ colMarkupEnd }`;
                    }
                } );
            } );

            // Display initial content on the page from Tab #1.
            if ( this[ 'label_Tab_1_ShowColumn' ] ) {
                elTabContent.innerHTML = `
                    ${ col2MarkupStart } ${ this[ 'label_Tab_1_Column_1' ] } ${ colMarkupEnd }
                    ${ col2MarkupStart } ${ this[ 'label_Tab_1_Column_2' ] } ${ colMarkupEnd }
                `;
            } else {
                elTabContent.innerHTML = `${ col1MarkupStart } ${ this[ 'label_Tab_1_Context' ] } ${ colMarkupEnd }`;
            }

            // Set had rendered to false to prevent duplicate renderCallback execution.
            this.hasRendered = false;
        }

    }

    get getComponentStyleClasses() {
        return 'component-container ' + this.bgColorClass[ this.themecolor ];
    }

}
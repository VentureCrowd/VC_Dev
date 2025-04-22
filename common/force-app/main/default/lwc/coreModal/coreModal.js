/**
 * CoreModal Component
 * @description The `coreModal` component is a versatile modal dialog component. It includes properties for label, variation, mode, and showCloseButton to customize the appearance and behavior of the modal. The modal supports slots for header, body, and footer content, allowing for flexible content placement. The modal can be opened and closed programmatically and supports event handling for modal button clicks.
 * 
 * @example
 *  <c-core-modal 
 *      label="Open Modal" 
 *      variation="primary" 
 *      mode="light"
 *      show-close-button="True"
 *      onbuttonclick={openModal}
*       hideOpenButton (OPTIONAL)
 *  >
 *      <!-- Modal Header Slot -->
 *      <template slot="header">
 *          <h2>Modal Header</h2>
 *      </template>
 * 
 *      <!-- Modal Body Slot -->
 *      <template slot="body">
 *          <p>This is the modal body content.</p>
 *      </template>
 * 
 *      <!-- Modal Footer Slot -->
 *      <template slot="footer">
 *          <c-core-button label="Close" onbuttonclick={closeModal}></c-core-button>
 *      </template>
 *  </c-core-modal>
 */

import { LightningElement, api } from 'lwc';

export default class CoreModal extends LightningElement {
    // Exposed properties
    @api mode = "light";
    @api variation = "primary";
    @api label = "";
    @api disabled;
    @api showCloseButton;
    @api hideOpenButton;
    @api width;
    @api icon;
    @api iconPosition;
    // Follow the following structure = '10px 25px'
    @api buttonSize;

    get disabledBool(){
        if (this.disabled) {
            return true;
        } 
        return false;
    }

    get showButton(){
        if(this.showCloseButton==='False'){
            return false;
        }
        return true;
    }

    get showOpenButton(){
        return !this.hideOpenButton;
    }

    renderedCallback(){
        if(this.width){
            this.template.querySelector('.core-modal').style.width=this.width+'px';
        }
    }

    /**
     * Handles the click event on the modal.
     */
    handleClick() {
        this.openModal();
    }

    /**
     * Opens the modal by removing the 'hidden' class and disables body scroll.
     */
    @api
    openModal() {
        this.template.querySelector('.modal-wrapper').classList.remove("hidden");
        document.body.style.overflow = 'hidden';
        this.dispatchEvent(new CustomEvent('modalbutton'));
    }

    /**
     * Handles the close event on the modal.
     * Closes the modal by adding the 'hidden' class and enables body scroll.
     */ 
    @api
    handleClose(){
        this.template.querySelector('.modal-wrapper').classList.add("hidden");
        // this.template.querySelector('.core-overlay').classList.add("hidden");
        document.body.style.overflow = '';
        // Send event to close the button
        const closebutton = new CustomEvent('closebutton',{
            detail: this.label,
            bubbles: true,
            composed : false,
        });

        this.dispatchEvent(closebutton);
    }

    disconnectedCallback(){
        document.body.style.overflow = '';
    }
}
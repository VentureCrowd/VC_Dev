import { LightningElement , api , track} from 'lwc';

export default class CoreToastMessage extends LightningElement {
    @api variant;
    @api title;
    @api body;

    @api isVisible=false;

    @track lastScrollTop = 0; // Track the last scroll position


    connectedCallback() {
        window.addEventListener('scroll', this.handleScroll);
    }

    disconnectedCallback() {
        window.removeEventListener('scroll', this.handleScroll);
    }

    handleScroll = () => {
        const toastContainer = this.template.querySelector('.core-toast-message-container');
        const stickyOffset = toastContainer.offsetTop;
        const currentScroll = window.scrollY;

        // Detect if the user is scrolling up
        if (currentScroll < this.lastScrollTop && currentScroll > 72) {
            toastContainer.style.transform = `translateY(72px)`;
        }else if(currentScroll < this.lastScrollTop && currentScroll < 72){
            toastContainer.style.transform = `translateY(${currentScroll}px)`;
        }
        else if (currentScroll > this.lastScrollTop && currentScroll < 100) {
            toastContainer.style.transform = `translateY(${currentScroll < 72 ? currentScroll : 72 }px)`;
        }else{
            toastContainer.style.transform = 'translateY(0)';
        }

        // Update the last scroll position
        this.lastScrollTop = currentScroll;
    }

    get iconName(){
        return this.variant;
    }


    get containerClass(){
        return `core-toast-message-container ${this.variant} ${this.isVisible ? 'visible' : ''}`;
    }

    @api
    showToast(){
        this.isVisible = true;
    }

    @api
    handleClose(){
        this.isVisible = false;
    }


}
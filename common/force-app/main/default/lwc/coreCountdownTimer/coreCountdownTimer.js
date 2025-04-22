import { LightningElement, api, track } from 'lwc';
/**
 * Core Countdown Timer
 * @example 
 * <c-core-countdown-timer
        closeDate={date}
        altText={startText}>
        endText={endText}
    </c-core-countdown-timer>
**/
export default class CoreCountdownTimer extends LightningElement {

    /**
    Alt Text - String to display alongside the counter
    @type String
    @example 'Closes In'
    **/
    @api altText;

    /**
    Closed Date- String to display after the counter finishes
    @type String
    @example 'Closed On'
    **/
    @api endText;

    /**
    Closed Date- Time to end the counter | You don't need to format this value if it comes directly from SF
    @type String
    @parameter date
    @example '2024-05-24'
    **/
    @track _closeDate;


    /**
    * Public set method to update the closeDate property
    * @api decorator exposes the closeDate property as a public API
    * @param {any} value - The new value to be set to the internal _closeDate property
    * If the value is truthy, it calls the startCountdown method
    */
    @api
    set closeDate(value) {
        this._closeDate = value;
        if (value) {
            this.startCountdown();
        }
    }

    /**
    * Public getter method to access the closeDate property
    * @returns {any} - The current value of the internal _closeDate property
    */
    get closeDate() {
        return this._closeDate;
    }

    /**
     * @property {boolean} _dealLive - Internal state indicating whether the deal is live
     * Default value is set to false
     */
    _dealLive = false;


    /**
     * Public get method to access the dealLive state
     * @returns {boolean} - The current value of the internal _dealLive property
     */
    get dealLive() {
        return this._dealLive;
    }

    /**
     * Public set method to update the dealLive state
     * @param {boolean} value - The new value to be set to the internal _dealLive property
     * Calls dispatchEvent to notify about the state change with a custom event 'deallivechange'
     * The event detail contains the updated dealLive state
     */
    set dealLive(value) {
        this._dealLive = value;
        this.dispatchEvent(new CustomEvent('deallivechange', { detail: { dealLive: value } }));
    }

    // letiables for different elements of the countdown
    days;
    hours;
    minutes;
    seconds;

    /**
    * Currently this is set to close at 11:55pm 
    * Starts a countdown timer to a target date specified by the closeDate property.
    * If the current date and time is past the target date, it sets the timer to a fixed end state.
    * Updates the timer every second.
    */
    startCountdown() {
        const targetDate = new Date(this.closeDate + "T23:59:00").getTime();
        this.dealLive = true;
        const updateTimer = () => {
            // const now = new Date().getTime();
            const now = this.getCorrectTime(600);
            const distance = targetDate - now;
            if (distance < 0) {
                this.dealLive = false;
                this.altText = this.endText;
                const date = new Date(this.closeDate);
                // Render the original date to the following format: 'May 24, 2024'
                this.days = date.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric'});
                this.hours = '11'
                this.minutes = this.seconds = '59';
                return;
            }

            this.days = Math.floor(distance / (1000 * 60 * 60 * 24));
            this.hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            this.minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
            this.seconds = Math.floor((distance % (1000 * 60)) / 1000);
            //Updates the timer every second
            setTimeout(updateTimer, 1000);
        };
        updateTimer();
    }

    /**
     * This function calculates the correct time based on the provided offset from the local timezone (Brisbane time).
     * It adjusts the current time to match the desired timezone offset.
     * @param {number} offset - The desired timezone offset in minutes. A positive value indicates a timezone ahead of the local timezone, while a negative value indicates a timezone behind.
     * @returns {number} - The correct time in milliseconds since January 1, 1970, 00:00:00 UTC.
    */
    getCorrectTime(offset) {
        let timezone = new Date();
        let n = timezone.getTimezoneOffset();
        if (n < 0) {
            let abs = Math.abs(n);
            if (abs == offset) {
            let now = new Date().getTime();
            return now;
            }else if (abs > offset) {
                let time = abs - offset;
                let now = new Date().getTime() - (time*60*1000);
                return now;
            }else if (abs < offset) {
                let time = offset - abs;
                let now = new Date().getTime() + (time*60*1000);
                return now;
            }
        }else {
            let abs = Math.abs(n);
            let time = abs + offset;
            let now = new Date().getTime() + (time*60*1000);
            return now;
        }
    }


    /**
     * Lifecycle hook that runs when the component is connected to the DOM.
     * If the set value is not set above will start this countdown
     */
    connectedCallback() {
        if (this.closeDate) {
            this.startCountdown();
        }
    }
}
/**
 * mcpTrendingToast Component
 * @description The `mcpTrendingToast` component is a Lightning Web Component designed to display 
 * a toast message in the bottom left corner of the page, when a campaign event from MCP is received.
 * The toast message indicates that the current deal is trending, with the number of views included 
 * in the toast message text. This component should only be used on deal pages (Ventures or Property).
 */
import { LightningElement, track } from 'lwc';

export default class McpTrendingToast extends LightningElement {

    /**
     * Page Views - Total page views for current page
     * @type {number}
     */
    @track pageViews = 0;

    /**
     * MCP Experience ID - Value uniquely identifies MCP exp
     * @type {string}
     */
    @track mcpExperienceId = '';

    /**
     * Lookback Hours - Number of hours to retrieve page views for
     * @type {number}
     */
    @track lookbackHours = 0;

    /**
     * Registers event listener when the component is initialized
     */
    connectedCallback() {
        // Register MCP data listener
        this.addCampaignPayloadListener();
    }

    /**
     * Removes event listener when the component is removed from DOM
     */
    disconnectedCallback() {
        // Remove MCP data listener
        this.removeCampaignPayloadListener();
    }

    /**
     * Handles closing/dismissal of the toast
     * @param {Event} event - The click event
     */
    closeToast(event) {
        // Move toast to outside screen
        this.template.querySelector('[data-id="mcp-trending-toast"]').classList.remove('active');

        // Hide toast from page after 1 second to allow animation
        setTimeout(() => {
            this.template.querySelector('[data-id="mcp-trending-toast"]').classList.remove('visible');
        }, 1000);
        
        // Send dismissal analytics to MCP if closed by user (clicked icon)
        if (event) {
            // Send MCP Dismissal Stat
            this.sendStat('Dismissal', this.mcpExperienceId);
        }
    }

    /**
     * Trigger toast to display on page
     * @param {number} autoCloseSeconds - number of seconds to wait before automatically closing toast
     */
    showToast(autoCloseSeconds) {
        // Display toast and move into screen
        this.template.querySelector('[data-id="mcp-trending-toast"]').classList.add('visible');
        this.template.querySelector('[data-id="mcp-trending-toast"]').classList.add('active');

        // Auto close toast after configured seconds
        if (autoCloseSeconds > 0) {
            setTimeout(() => {
                this.closeToast();
            }, autoCloseSeconds*1000);
        }
    }

    /**
     * Register MCP campaign data event listener
     */
    addCampaignPayloadListener() {
        document.addEventListener('mcp_campaign_trendingdealtoast', this.handleMcpEvent);
    }

    /**
     * Remove MCP campaign data event listener
     */
    removeCampaignPayloadListener() {
        document.removeEventListener('mcp_campaign_trendingdealtoast', this.handleMcpEvent);
    }

    /**
     * Handle event listener callback for MCP campaign data
     * @param {Event} e - page event with campaign data payload from MCP
     */
    handleMcpEvent = (e) => {
        // Validate all parameters from MCP exist in payload and are the correct type
        if (e.detail && this.isValidPayload(e.detail)) {
            // Store values after sanitising inputs
            this.pageViews = this.sanitiseInput(e.detail.pageViews);
            this.mcpExperienceId = this.sanitiseInput(e.detail.experience);
            this.lookbackHours = this.sanitiseInput(e.detail.lookbackHours);

            // Delay display of toast by configured seconds
            setTimeout(() => {
                // Display toast
                this.showToast(e.detail.closeSeconds);

                // Send MCP impression analytics
                this.sendStat('Impression', this.mcpExperienceId);
            }, e.detail.delaySeconds*1000);
        }
    }

    /**
     * Send analytics event to MCP
     * @param {string} stat - type of analytics event to send (Impression | Clickthrough | Dismissal)
     * @param {string} experienceId - unique value to identify MCP exp
     */
    sendStat(stat, experienceId) {
        // Validate parameters are supplied
        if (!stat && !experienceId) return;

        const payload = {
            campaignStats: [
                {
                    stat: stat,
                    experienceId: experienceId,
                    control: false, // Control group not used for this use case
                }
            ]
        };

        // Send event to MCP
        document.dispatchEvent(new CustomEvent('lwc_onstatsend', { 
            bubbles: true,
            composed: true,
            detail: payload 
        }));
    }

    /**
     * Validate MCP Campaign Event payload to ensure fields exist and are of the correct type
     * @param {Event} payload - page event with campaign data payload from MCP
     */
    isValidPayload(payload) {
        // Basic checks: ensure all required fields exist and are of the correct type
        return (
            typeof payload.pageViews === 'number' &&
            typeof payload.experience === 'string' &&
            typeof payload.lookbackHours === 'number' &&
            typeof payload.closeSeconds === 'number' &&
            typeof payload.delaySeconds === 'number'
        );
    }

    /**
     * Helper function to sanitise inputs
     * @param {any} input - value to sanitise (Strng, Number, other types)
     */
    sanitiseInput(input) {
        if (typeof input === 'string') {
            // Basic sanitisation to remove unwanted characters or HTML tags
            const element = document.createElement('div');
            element.textContent = input;
            return element.innerHTML; // Returns a safe, escaped string
        }
        return input; // For numbers or other types, just return as-is
    }
}
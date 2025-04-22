/**
 * mcpPopupModal Component
 * @description The `mcpPopupModal` component is a Lightning Web Component designed to display 
 * a popup modal with an image, header, subheader & cta button, when a campaign event from MCP is received.
 */
import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class McpPopupModal extends NavigationMixin(LightningElement) {
    /**
     * Show Modal - Controls if the modal is currently displayed
     * @type {boolean}
     */
    @track showModal = false;

    /**
     * MCP Experience ID - Value uniquely identifies MCP exp
     * @type {string}
     */
    @track mcpExperienceId = '';

    /**
     * Image URL - Image displayed at the top of the modal
     * @type {string}
     */
    @track imageUrl = '';

    /**
     * Image Alt Text - Alt text for image
     * @type {string}
     */
    @track imageAltText = '';

    /**
     * Header Text - Heading text/copy displayed within modal
     * @type {string}
     */
    @track headerText = '';

    /**
     * Sub Heading Text - Sub heading text/copy displayed within modal
     * @type {string}
     */
    @track subheaderText = '';

    /**
     * CTA Text - Call to action text displayed within button
     * @type {string}
     */
    @track ctaText = '';

    /**
     * CTA URL - Call to action link URL
     * @type {string}
     */
    @track ctaUrl = '';

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
     * Navigate to an external URL
     * @param {string} url - full url to navigate too
     */
    navigateToExternalUrl(url) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: url
            }
        });
    }

    /**
     * Handles closing/dismissal of the modal
     */
    closeModal() {
        // Hide modal
        this.showModal = false;
        // Send MCP Dismissal Stat
        this.sendStat('Dismissal', this.mcpExperienceId);
    }

    /**
     * Handles clickthrough on CTA button
     */
    ctaClick() {
        // Send MCP Clickthrough Stat
        this.sendStat('Clickthrough', this.mcpExperienceId);
        // Hide modal
        this.showModal = false;
        // Navigate to URL
        this.navigateToExternalUrl(this.ctaUrl);
    }

    /**
     * Register MCP campaign data event listener
     */
    addCampaignPayloadListener() {
        document.addEventListener('mcp_campaign_popup', this.handleMcpEvent);
    }

    /**
     * Remove MCP campaign data event listener
     */
    removeCampaignPayloadListener() {
        document.removeEventListener('mcp_campaign_popup', this.handleMcpEvent);
    }

    /**
     * Handle event listener callback for MCP campaign data
     * @param {Event} e - page event with campaign data payload from MCP
     */
    handleMcpEvent = (e) => {
        // Validate all parameters from MCP exist in payload and are the correct type
        if (e.detail && this.isValidPayload(e.detail)) {
            // Store values after sanitising inputs
            this.mcpExperienceId = this.sanitiseInput(e.detail.experience);
            this.imageUrl = this.sanitiseInput(e.detail.imageUrl);
            this.imageAltText = this.sanitiseInput(e.detail.imageAltText);
            this.headerText = this.sanitiseInput(e.detail.header);
            this.subheaderText = this.sanitiseInput(e.detail.subheader);
            this.ctaText = this.sanitiseInput(e.detail.ctaText);
            this.ctaUrl = this.sanitiseInput(e.detail.ctaUrl);

            // Display modal
            this.showModal = true;

            // Send MCP impression analytics
            this.sendStat('Impression', this.mcpExperienceId);
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
            typeof payload.experience === 'string' &&
            typeof payload.imageUrl === 'string' &&
            typeof payload.imageAltText === 'string' &&
            typeof payload.header === 'string' &&
            typeof payload.subheader === 'string' &&
            typeof payload.ctaText === 'string' &&
            typeof payload.ctaUrl === 'string'
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
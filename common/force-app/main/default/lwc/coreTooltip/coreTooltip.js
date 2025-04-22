import { LightningElement, api } from 'lwc';

export default class CoreTooltip extends LightningElement {
    @api helpText;
    @api size;
    
    // Track the tooltip state (visible or not)
    tooltipVisible = false;

    // Helper to get the tooltip element
    get tooltip() {
        return this.refs.containerTooltip;
    }

    handleMouseOver() {
        // Only use hover behavior if not on mobile
        if (this.isTouchDevice()) return;

        this.showTooltip();
    }

    handleMouseLeave() {
        this.hideTooltip();
    }

    toggleTooltip() {
        // On mobile devices (or when using click to toggle), we use this method
        if (this.tooltipVisible) {
            this.hideTooltip();
        } else {
            this.showTooltip();
        }
    }

    showTooltip() {
        const tooltip = this.tooltip;
        if (!tooltip) return;

        tooltip.style.opacity = '1';
        tooltip.style.visibility = 'visible';

        // Immediately measure the layout
        const rect = tooltip.getBoundingClientRect();
        const viewportWidth = window.innerWidth;

        // Adjust if tooltip goes off the right edge
        if (rect.right > viewportWidth) {
            const offset = rect.right - viewportWidth;
            tooltip.style.transform = `translateX(calc(-66% - ${offset}px))`;
        }
        // Adjust if tooltip goes off the left edge
        else if (rect.left < 0) {
            const offset = Math.abs(rect.left);
            tooltip.style.transform = `translateX(calc(-50% + ${offset}px))`;
        } else {
            tooltip.style.transform = 'translateX(-50%)';
        }
        this.tooltipVisible = true;
    }

    hideTooltip() {
        const tooltip = this.tooltip;
        if (!tooltip) return;

        tooltip.style.transform = 'translateX(-50%)';
        tooltip.style.opacity = '0';
        tooltip.style.visibility = 'hidden';
        this.tooltipVisible = false;
    }

    // Utility to detect if the device supports touch
    isTouchDevice() {
        return 'ontouchstart' in window || navigator.maxTouchPoints > 0;
    }
}
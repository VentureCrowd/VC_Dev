// qrCodeGenerator.js
import { LightningElement, api, track } from 'lwc';

export default class QrCodeGenerator extends LightningElement {
    // Public property to set the target URL dynamically via Experience Builder
    @api targetUrl = 'https://default-experience-site.com/page'; // Default URL

    // Public property to set the size of the QR code
    @api qrCodeSize = '200x200'; // Format: WIDTHxHEIGHT

    // Public property to set the error correction level (optional)
    @api errorCorrectionLevel = 'H'; // Options: L, M, Q, H

    // Computed property for the QR code image URL
    get qrCodeUrl() {
        // Encode the target URL to ensure it's URL-safe
        const encodedUrl = encodeURIComponent(this.targetUrl);
        return `https://api.qrserver.com/v1/create-qr-code/?data=${encodedUrl}&size=${this.qrCodeSize}&ecc=${this.errorCorrectionLevel}`;
    }
}
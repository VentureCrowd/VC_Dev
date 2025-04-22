/**
 * @description Child component to download and merge the PDF documents
 * @createdBy Cesar
 * @createdDate 2024-09-26
 * @version 1.0
 **/

import { LightningElement, api } from 'lwc';
import pdfLib from "@salesforce/resourceUrl/PDFLib"; 
import { loadScript } from 'lightning/platformResourceLoader';
import apex_retrieveTaxStatements from '@salesforce/apex/PipoController.getTaxDocuments';
import userId from "@salesforce/user/Id";

export default class PipoTaxStatements extends LightningElement {
    pdfLibInitialized = false;
    pdfLibInstance;

    @api label;
    @api year;
    files = []; // Array to hold the PDF URLs
    pdfUrls;
    loadingButton = false;

    /**
     * Initializes PDFLib library if not already initialized.
     *
     * @returns {void}
     */
    renderedCallback() {
        if (this.pdfLibInitialized) {
            return;
        }

        // Load PDFLib script dynamically
        loadScript(this, pdfLib) 
            .then(() => {
                this.pdfLibInitialized = true;
                this.pdfLibInstance = window.pdfLib || window.PDFLib;
            })
            .catch(error => {
                console.error('Error loading PDF Library:', error);
        });
    }

    /**
     * Merges multiple PDFs into a single PDF using PDFLib library.
     *
     * @param {void}
     * @returns {void}
     */
    async mergePdfs() {
        if (!this.pdfLibInitialized) {
            console.error('PDFLib is not loaded yet.');
            return;
        }

        try {
            const { PDFDocument } = this.pdfLibInstance;
            const mergedPdf = await PDFDocument.create();
            for (let base64Pdf of this.pdfUrls) {
                // Convert base64 to Uint8Array
                const pdfBytes = Uint8Array.from(atob(base64Pdf), c => c.charCodeAt(0));
                const pdfDoc = await PDFDocument.load(pdfBytes);
                const copiedPages = await mergedPdf.copyPages(pdfDoc, pdfDoc.getPageIndices());
                copiedPages.forEach(page => mergedPdf.addPage(page));
            }
            // Save the merged PDF
            const mergedPdfBytes = await mergedPdf.save();
            this.saveByteArray(this.label + '.pdf', mergedPdfBytes);

        } catch (error) {
            console.error('Error merging PDFs:', error);
        }
    }

    /**
     * Method to save the PDF document as a downloadable file
     * @param {string} pdfName - The name of the PDF file to be saved
     * @param {Uint8Array} byte - The byte array of the PDF document
     */
    saveByteArray(pdfName, byte) {
        let blob = new Blob([byte], { type: "application/pdf" }); 
        let link = document.createElement('a');
        link.href = window.URL.createObjectURL(blob);
        link.download = pdfName; 
        link.click();
        URL.revokeObjectURL(link.href); // Clean up the URL object
    }

    /**
     * Fetches the Base64 encoded PDF data from the provided files array and stores them in the pdfUrls array.
     * @function getPDFLinks
     * @returns {void}
     * @throws Will throw an error if there's an issue fetching or parsing the PDF data.
     *
     */
    async getPDFLinks() {
        try {
            this.pdfUrls = this.files.map(doc => doc.Base64Data); 
        } catch (error) {
            console.error('Error fetching or parsing PDF data:', error);
        }
    }

    /**
     * Handles the click event on the component.
     * Fetches the PDF links and then merges them into a single PDF.
     *
     * @returns {void}
     */
    handleClick() {
        this.loadingButton = true;
        let data = apex_retrieveTaxStatements({
            userId: userId,
            fileName: 'FY' + this.year + '_Tax_Statement',
            base64: true
        }).then( result => {
            this.files = result;
            this.getPDFLinks()
                .then(() => {
                    // Ensure PDF links are fetched before merging
                    return this.mergePdfs(); // Merge PDFs after fetching the PDF links
                })
                .catch(error => {
                    console.error('Error fetching or merging PDFs:', error);
            });
        }).finally(() => {
            this.loadingButton = false;
        })
    }
}
import { LightningElement, api} from 'lwc'; 
import pdfLib from "@salesforce/resourceUrl/PDFLib"; 
import { loadScript } from 'lightning/platformResourceLoader';

/**
 * How to use this component? - Refer to raiseTcsPDF for one example
 * Core Fill Form
 * @example 
 * 1. You need to upload one PDF form
 * 2. Assign a PDF Title -> this.pdfTitle = ''
 * 3. Init the PDF
 *  const { pdfDoc, form } = await this.initializePdf(formUrl, transformedData);
 * 4. For all the fields that you prepared in the form , you need to set their values
 *  const allocationAmount = form.getTextField('allocation_amount'); -> 'allocation_amount' belongs for the name field in the PDF form
 *  allocationAmount.setValue(transformedData.allocationAmount);
 * 5. Call the savePdf method to save the PDF
 *  await this.savePdf(pdfDoc, transformedData);
**/
export default class CoreFillFormPDF extends LightningElement {
    // Flag to check if PDFLib is loaded
    pdfLibInitialized = false; 

    /**
     * @property {string} pdfTitle - Public property to hold the title of the PDF
     * @api decorator exposes the pdfTitle property as a public API
     */
    @api pdfTitle;
    
    // Arrays to hold number words for conversion of numbers to words
    a = ['','one ','two ','three ','four ', 'five ','six ','seven ','eight ','nine ','ten ','eleven ','twelve ','thirteen ','fourteen ','fifteen ','sixteen ','seventeen ','eighteen ','nineteen '];
    b = ['', '', 'twenty','thirty','forty','fifty', 'sixty','seventy','eighty','ninety'];
    
    /**
     * Method to convert a number to words
     * @param {number} num - The number to be converted to words
     * @returns {string} - The number in words
     */
    inWords(num) {
        if ((num = num.toString()).length > 12) return 'overflow';
        let n = ('00000000000' + num).substr(-12).match(/^(\d{3})(\d{3})(\d{3})(\d{1})(\d{2})$/);
        if (!n) return; 
        let str = '';
        str += (n[1] != 0) ? (Number(n[1]) > 99 ? this.a[Number(n[1][0])] + 'hundred ' : '') + (this.a[Number(n[1])] || this.b[n[1][1]] + ' ' + this.a[n[1][2]]) + 'billion ' : '';
        str += (n[2] != 0) ? (Number(n[2]) > 99 ? this.a[Number(n[2][0])] + 'hundred ' : '') + (this.a[Number(n[2])] || this.b[n[2][1]] + ' ' + this.a[n[2][2]]) + 'million ' : '';
        str += (n[3] != 0) ? (Number(n[3]) > 99 ? this.a[Number(n[3][0])] + 'hundred ' : '') + (this.a[Number(n[3])] || this.b[n[3][1]] + ' ' + this.a[n[3][2]]) + 'thousand ' : '';
        str += (n[4] != 0) ? (this.a[Number(n[4])] || this.b[n[4][0]] + ' ' + this.a[n[4][1]]) + 'hundred ' : '';
        str += (Number(n[5]) !== 0) ? ((str !== '') ? 'and ' : '') + (this.a[Number(n[5])] || this.b[n[5][0]] + ' ' + this.a[n[5][1]]) + '' : '';
        return str;
    }

    // Lifecycle hook called after the component is rendered
    renderedCallback() {
        if (this.pdfLibInitialized) {
            return; 
        }
        // Load the PDFLib script
        loadScript(this, pdfLib)
            .then(() => {
                this.pdfLibInitialized = true;
            })
            .catch(error => {
                console.error('Error loading PDF Library:', error);
            });
    }

    /**
     * Method to format the numbers
     * @param {number} number - The number to be formatted
     * @returns {string} - The formatted number with commas for thousands
     */
    formatNumber(number) {
        // Format the number with commas for thousands
        return new Intl.NumberFormat('en-US').format(number);
    }

    /**
     * Method to fetch and initialize the PDF document
     * @param {string} formUrl - The URL of the PDF form to be fetched
     * @returns {object} - An object containing the PDF document and form
     */
    async initializePdf(formUrl) {
        // Fetch the PDF document
        const formPdfBytes = await fetch(formUrl).then(res => res.arrayBuffer());
        const pdfDoc = await PDFLib.PDFDocument.load(formPdfBytes);
        // Set the title of the PDF
        
        // pdfDoc.setTitle('CSF ' + transformedData.investmentType + ' Terms & Conditions - ' + transformedData.name);
        pdfDoc.setTitle(this.pdfTitle);

        // Initialize the form
        const form = pdfDoc.getForm();
        return { pdfDoc, form };
    }

    /**
     * Method to save the filled PDF document
     * @param {object} pdfDoc - The PDF document to be saved
     */
    async savePdf(pdfDoc) {
        // Flatten the form to make fields uneditable
        pdfDoc.getForm().flatten();
        // Save the filled PDF document
        const pdfBytes = await pdfDoc.save();
        // Return the file name
        // this.saveByteArray('CSF ' + transformedData.investmentType + ' Terms & Conditions - ' + transformedData.name + '.pdf', pdfBytes);
        this.saveByteArray(this.pdfTitle + '.pdf', pdfBytes)
    }

    /**
     * Method to save the PDF document as a downloadable file
     * @param {string} pdfName - The name of the PDF file to be saved
     * @param {Uint8Array} byte - The byte array of the PDF document
     */
    saveByteArray(pdfName, byte) {
        // Create a blob from the byte array
        let blob = new Blob([byte], { type: "application/pdf" }); 
        let link = document.createElement('a');
        // Create an object URL for the blob
        link.href = window.URL.createObjectURL(blob); 
        let fileName = pdfName;
        // Set the download attribute with the file name
        link.download = fileName; 
        // Trigger the download
        link.click(); 
    }
}
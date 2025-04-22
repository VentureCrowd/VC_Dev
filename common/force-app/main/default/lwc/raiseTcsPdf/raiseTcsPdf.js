import { api } from 'lwc';
import CoreFillFormPDF from 'c/coreFillFormPDF';
import apex__getRaisePageFields from '@salesforce/apex/RaiseController.getRaisePageDetailsRaiseId';
import templateResources from "@salesforce/resourceUrl/TermsConditions_Template"; 

export default class RaiseTcsPdf extends CoreFillFormPDF {
    // Public properties exposed via @api decorator
    @api raiseId;
    @api label;
    @api icon;
    @api size;
    @api iconPosition;

    /**
     * Method to fill the PDF form with the necessary data
     * @api decorator exposes the fillForm method as a public API
     */
    @api
    async fillForm() {
        if (!this.pdfLibInitialized) {
            console.error('PDFLib is not loaded yet.');
            return;
        }
        try {
            // Call Apex method to get raise page details
            let returnData = await apex__getRaisePageFields({ raiseId: this.raiseId });
            let transformedData = JSON.parse(returnData); // Parse the returned JSON data
            let formUrl;
            
            // Set the PDF title. Inherited from coreFillFormPDF
            this.pdfTitle = 'CSF ' + transformedData.investmentType + ' Terms & Conditions - ' + transformedData.name;


            // Decide which document to retrieve based on investment type
            if (transformedData.investmentType === 'Retail') {
                formUrl = templateResources + '/Retail_Template.pdf';
            } else if (transformedData.investmentType === 'Wholesale') {
                formUrl = templateResources + '/Wholesale_Template.pdf';
            }

            // Initialize the PDF document and form
            const { pdfDoc, form } = await this.initializePdf(formUrl, transformedData);

            // Get form fields and set their values for Retail
            if (transformedData.investmentType === 'Retail') {
                const allocationAmount = form.getTextField('allocation_amount');
                const pricePerShare = form.getTextField('price_per_share');
                const campaignStartDate = form.getTextField('campaign_start_date');
                const campaignEndDate = form.getTextField('campaign_end_date');
                const minSubAmount = form.getTextField('min_sub_amount');
                const maxSubAmount = form.getTextField('max_sub_amount');

                allocationAmount.setText('The amount raised by VentureCrowd on behalf of the Company, as is agreed between the parties (minimum of ' +
                    this.inWords(transformedData.minTarget) + '$' + this.formatNumber(transformedData.minTarget) + ' to a maximum of ' + this.inWords(transformedData.maxTarget) + '$' + this.formatNumber(transformedData.maxTarget) + ')');
                pricePerShare.setText('Ordinary Shares: $' + this.formatNumber(transformedData.sharePrice) + ' price per share ');
                campaignStartDate.setText(transformedData.launchDate + ', or as otherwise agreed between the parties in writing');
                campaignEndDate.setText(transformedData.offerCloseDate + ', or as otherwise agreed between the parties in writing, but in any event no later than 3 months from the Campaign Start Date.');
                minSubAmount.setText('$' + this.formatNumber(transformedData.minInvestAmount) + ', or as otherwise agreed between the parties in writing');
                maxSubAmount.setText('$' + this.formatNumber(transformedData.maxTarget) + ', or as otherwise agreed between the parties in writing');
            }

            // Get form fields and set their values for Wholesale
            // Get text field values belongs from the PDF Form 
            if (transformedData.investmentType === 'Wholesale') {
                const allocationAmount = form.getTextField('allocation_amount');
                const pricePerShare = form.getTextField('price_per_security');
                const campaignStartDate = form.getTextField('campaign_start_date');
                const campaignEndDate = form.getTextField('campaign_end_date');
                const targetAmt = form.getTextField('target_amt');

                if (transformedData.targetAmt) {
                    allocationAmount.setText('The amount raised by VentureCrowd on behalf of the Company, being not less than ' +
                        this.inWords(transformedData.targetAmt) + ' dollars (AU$' + this.formatNumber(transformedData.targetAmt) + ') or such other amount as may be agreed between the parties in writing.');
                }

                if (transformedData.investmentProductType === 'Ordinary Shares') {
                    pricePerShare.setText(transformedData.investmentProductType + ': $' + this.formatNumber(transformedData?.sharePrice) + ' price per share');
                } else if (transformedData.investmentProductType === 'Convertible Note' || transformedData.investmentProductType === 'Promissory Note' || transformedData.investmentProductType === 'SAFE Note') {
                    pricePerShare.setText(transformedData.investmentProductType + ': $' + this.formatNumber(transformedData?.pricePerNote) + ' price per note');
                } else if (transformedData.investmentProductType === 'Preference Shares') {
                    pricePerShare.setText(transformedData.investmentProductType + ': $' + this.formatNumber(transformedData?.pricePerShare) + ' per share');
                }

                campaignStartDate.setText(transformedData.launchDate + ', or as otherwise agreed between the parties in writing');
                campaignEndDate.setText(transformedData.offerCloseDate + ', or as otherwise agreed between the parties in writing');
                targetAmt.setText('$' + this.formatNumber(transformedData.targetAmt));
            }

            // Save the filled PDF document
            await this.savePdf(pdfDoc, transformedData);
        } catch (error) {
            console.error('Error filling the PDF form:', JSON.stringify(error));
        }
    }
}
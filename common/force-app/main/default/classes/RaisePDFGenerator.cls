public virtual class RaisePDFGenerator {
    
    // Wrapper class to hold input parameters for PDF generation and linking
    public class PDFGenerationRequest {
        @InvocableVariable(label='Raise Record ID' description='ID of the Raise__c record to generate PDF from' required=true)
        public Id raiseId;

        @InvocableVariable(label='Target Record ID' description='ID of the record to link the generated PDF to' required=true)
        public Id targetRecordId;
    }

    @InvocableMethod(label='Generate and Save Raise PDF' description='Generate PDF from Raise and save as ContentVersion linked to any record')
public static void generateAndSaveRaisePDF(List<PDFGenerationRequest> requests) {
    RaisePDFGenerator generator;

    if (Test.isRunningTest()) {
        generator = (RaisePDFGenerator) Type.forName('TestRaisePDFGeneratorFailMock').newInstance();
    } else {
        generator = new RaisePDFGenerator();
    }

    generator.generateAndSaveRaisePDFInternal(requests);
}


    public virtual void generateAndSaveRaisePDFInternal(List<PDFGenerationRequest> requests) {
        for (PDFGenerationRequest req : requests) {
            try {
                // Validate that both IDs are present
                if (req.raiseId == null || req.targetRecordId == null) {
                    System.debug('Missing Raise ID or Target Record ID for one of the requests.');
                    continue; // Skip this iteration
                }

                // Generate PDF Blob by passing Raise ID to the VF page
                Blob pdfBlob = getPDFBlob(req.raiseId);

                if (pdfBlob != null && pdfBlob.size() > 0) {
                    // Retrieve the Raise__c record for naming purposes
                    Raise__c raiseRecord = [
                        SELECT Name 
                        FROM Raise__c 
                        WHERE Id = :req.raiseId 
                        LIMIT 1
                    ];

                    // Create ContentVersion record
                    ContentVersion contentVersion = new ContentVersion();
                    contentVersion.Title = 'Offer Document_' + raiseRecord.Name + '.pdf';
                    contentVersion.PathOnClient = 'Offer Document_' + raiseRecord.Name + '.pdf';
                    contentVersion.VersionData = pdfBlob;
                    contentVersion.Form_field__c = 'Offer Document'; // Update custom field as needed
                    contentVersion.Origin = 'H';
                    insert contentVersion;

                    // Retrieve ContentDocumentId from the inserted ContentVersion
                    Id contentDocumentId = [
                        SELECT ContentDocumentId 
                        FROM ContentVersion 
                        WHERE Id = :contentVersion.Id 
                        LIMIT 1
                    ].ContentDocumentId;

                    // Create ContentDocumentLink record to link PDF to the target record
                    ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                    contentDocumentLink.ContentDocumentId = contentDocumentId;
                    contentDocumentLink.LinkedEntityId = req.targetRecordId;
                    contentDocumentLink.ShareType = 'V'; // Viewer permission
                    contentDocumentLink.Visibility = 'AllUsers'; // Adjust as needed
                    insert contentDocumentLink;

                    // create public content distribution
                    ContentDistribution distribution = new ContentDistribution();
                    distribution.Name = 'Public Distribution for ' + contentVersion.ContentDocumentId;
                    distribution.ContentVersionId = contentVersion.Id;
                    distribution.PreferencesAllowViewInBrowser = true;
                    distribution.PreferencesLinkLatestVersion = true;
                    distribution.PreferencesNotifyOnVisit = false;
                    distribution.PreferencesPasswordRequired = false;
                    distribution.PreferencesAllowOriginalDownload = true;
                    insert distribution;
                }
            } catch (Exception e) {
                // Log the error and continue with the next request
                System.debug('Error generating PDF for Raise ID: ' + req.raiseId + ' - ' + e.getMessage());
                // Optionally, implement further error handling or logging mechanisms
            }
        }
    }

    // Static flag to control behavior during testing
    public static Boolean throwExceptionInGetPDFBlob = false;

    protected virtual Blob getPDFBlob(Id raiseId) {
        // Reference the Visualforce page
        PageReference pageRef = Page.RaisePDFPage; // Ensure this matches your VF page name

        // Pass the Raise ID as a parameter
        pageRef.getParameters().put('raiseId', raiseId);

        // Generate the PDF
        Blob pdfBlob;
        try {
            if (throwExceptionInGetPDFBlob) {
                throw new VisualforceException('Simulated PDF generation failure.');
            }
            pdfBlob = pageRef.getContentAsPDF();
        } catch (VisualforceException e) {
            // Handle exceptions, such as governor limits or page rendering issues
            System.debug('Error generating PDF for Raise ID: ' + raiseId + ' - ' + e.getMessage());
            throw new CalloutException('Failed to generate PDF for Raise ID: ' + raiseId);
        }

        return pdfBlob;
    }
}
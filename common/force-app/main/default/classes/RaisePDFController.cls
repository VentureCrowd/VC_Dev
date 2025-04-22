// File: RaisePDFController.cls
public with sharing class RaisePDFController {
    public String HTMLContent { get; private set; }

    public RaisePDFController() {
        String raiseId = ApexPages.currentPage().getParameters().get('raiseId');
        if (String.isBlank(raiseId)) {
            throw new AuraHandledException('Missing Raise ID.');
        }

        // Fetch the Raise record and related Team and Advisors
        Raise__c raiseRecord = [
            SELECT Name, 
                Form_Company_Legal_Trading_Name__c,
                Form_Registered_Aus__c,
                Form_ABN__c,
                Form_ACN__c,
                Form_Company_Street_Address__c,
                Form_Company_Overview__c,
                Form_Business_strategy__c,
                Form_Business_model__c,
                Form_Organisation_structure__c,
                Form_Proprietary_company__c, 
                Form_Public_company__c, 
                Form_Financial_information_summary__c,
                Form_Debt_funding_and_other_funding__c,
                Form_Legal_or_disciplinary_action__c,
                Form_Risks_facing_the_business__c,
                Form_Planned_use_of_funds__c,
                Form_Offer_launch_date__c,
                Form_Offer_close_date__c,
                Form_Investment_Product_Type__c,
                Form_Valuation__c,
                Form_Number_of_shares_on_issue__c,
                Form_Share_price__c,
                Form_Rights_associated_with_shares__c,
                Form_Details_of_previous_CSF_offers__c,
                Form_Target_amount__c,
                Form_Minimum_target__c,
                Form_Maximum_target__c,
                Form_Minimum_Investment_amount__c,
                Form_Risk_warning__c,
                Form_Cooling_off_rights__c,
                Form_Glossary__c
            FROM Raise__c 
            WHERE Id = :raiseId 
            LIMIT 1
        ];

        List<Raise_Team_and_Advisors__c> teamRecords = [
            SELECT Role__c, Name 
            FROM Raise_Team_and_Advisors__c 
            WHERE Related_Raise__c = :raiseId
        ];

        // Generate HTML content
        HTMLContent = generateHtmlContent(raiseRecord, teamRecords);
    }

    /**
     * Generates the HTML content for the PDF based on the Raise record and related Team records.
     *
     * @param raiseRecord The Raise__c record.
     * @param teamRecords The list of related Raise_Team_and_Advisors__c records.
     * @return A string containing the HTML content.
     */
    private String generateHtmlContent(Raise__c raiseRecord, List<Raise_Team_and_Advisors__c> teamRecords) {
        String htmlContent = '<h1>' + escapeHtml(raiseRecord.Name) + ' Offer Document</h1>';
        htmlContent += '<table>';

        htmlContent += generateTableRow('Company\'s Full Legal Trading Name:', raiseRecord.Form_Company_Legal_Trading_Name__c);
        htmlContent += generateTableRow('Is Your Company Registered in Australia:', String.valueOf(raiseRecord.Form_Registered_Aus__c));
        htmlContent += generateTableRow('ABN:', raiseRecord.Form_ABN__c);
        htmlContent += generateTableRow('ACN:', raiseRecord.Form_ACN__c);
        htmlContent += generateTableRow('Company Street Address:', raiseRecord.Form_Company_Street_Address__c);
        htmlContent += generateTableRow('Who Are We:', raiseRecord.Form_Company_Overview__c);
        htmlContent += generateTableRow('Business Strategy:', raiseRecord.Form_Business_strategy__c);
        htmlContent += generateTableRow('Business Model:', raiseRecord.Form_Business_model__c);
        htmlContent += generateTableRow('Organisation Structure:', raiseRecord.Form_Organisation_structure__c);
        htmlContent += generateTableRow('Proprietary Company:', String.valueOf(raiseRecord.Form_Proprietary_company__c));
        htmlContent += generateTableRow('Public Company:', String.valueOf(raiseRecord.Form_Public_company__c));
        htmlContent += generateTableRow('Financial Information Summary:', raiseRecord.Form_Financial_information_summary__c);
        htmlContent += generateTableRow('Debt Funding and Other Funding:', raiseRecord.Form_Debt_funding_and_other_funding__c);
        htmlContent += generateTableRow('Legal or Disciplinary Action:', raiseRecord.Form_Legal_or_disciplinary_action__c);
        htmlContent += generateTableRow('Risks Facing the Business:', raiseRecord.Form_Risks_facing_the_business__c);
        htmlContent += generateTableRow('Planned Use of Funds:', raiseRecord.Form_Planned_use_of_funds__c);
        htmlContent += generateTableRow('Offer Launch Date:', String.valueOf(raiseRecord.Form_Offer_launch_date__c));
        htmlContent += generateTableRow('Offer Close Date:', String.valueOf(raiseRecord.Form_Offer_close_date__c));
        htmlContent += generateTableRow('Investment Product Type:', raiseRecord.Form_Investment_Product_Type__c);
        htmlContent += generateTableRow('Valuation:', String.valueOf(raiseRecord.Form_Valuation__c));
        htmlContent += generateTableRow('Number of Shares on Issue:', String.valueOf(raiseRecord.Form_Number_of_shares_on_issue__c));
        htmlContent += generateTableRow('Share Price:', String.valueOf(raiseRecord.Form_Share_price__c));
        htmlContent += generateTableRow('Rights Associated with Shares:', raiseRecord.Form_Rights_associated_with_shares__c);
        htmlContent += generateTableRow('Details of Previous CSF Offers:', raiseRecord.Form_Details_of_previous_CSF_offers__c);
        htmlContent += generateTableRow('Target Amount:', String.valueOf(raiseRecord.Form_Target_amount__c));
        htmlContent += generateTableRow('Minimum Target:', String.valueOf(raiseRecord.Form_Minimum_target__c));
        htmlContent += generateTableRow('Maximum Target:', String.valueOf(raiseRecord.Form_Maximum_target__c));
        htmlContent += generateTableRow('Minimum Investment Amount:', String.valueOf(raiseRecord.Form_Minimum_Investment_amount__c));
        htmlContent += generateTableRow('Risk Warning:', raiseRecord.Form_Risk_warning__c);
        htmlContent += generateTableRow('Cooling-off Rights:', String.valueOf(raiseRecord.Form_Cooling_off_rights__c));
        htmlContent += generateTableRow('Glossary:', raiseRecord.Form_Glossary__c);

        // Add Team and Advisors Section
        htmlContent += '<tr><th colspan="2">Team and Advisors</th></tr>';
        for (Raise_Team_and_Advisors__c teamRecord : teamRecords) {
            htmlContent += generateTableRow(escapeHtml(teamRecord.Role__c) + ':', escapeHtml(teamRecord.Name));
        }

        htmlContent += '</table>';
        return htmlContent;
    }

    /**
     * Generates an HTML table row with two columns: label and value.
     *
     * @param label The label for the row.
     * @param value The value for the row.
     * @return A string containing the HTML table row.
     */
    private String generateTableRow(String label, String value) {
        if (value != null && !String.isEmpty(value)) {
            return '<tr><td><strong>' + escapeHtml(label) + '</strong></td><td>' + escapeHtml(value) + '</td></tr>';
        }
        return '';
    }

    /**
     * Escapes HTML special characters to prevent rendering issues.
     *
     * @param input The input string to escape.
     * @return The escaped string.
     */
    private String escapeHtml(String input) {
        if (input == null) return '';
        return input.escapeHtml4();
    }

}
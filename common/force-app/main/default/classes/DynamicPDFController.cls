public class DynamicPDFController {
    public String htmlContent { get; set; }

    public DynamicPDFController() {
        try {
            // Retrieve the HTML content from the page parameters
            htmlContent = ApexPages.currentPage().getParameters().get('htmlContent');
            if (htmlContent == null) {
                throw new VisualforceException('htmlContent parameter is missing');
            }
            System.debug('HTML content retrieved: ' + htmlContent);
        } catch (Exception e) {
            System.debug('Error in DynamicPDFController: ' + e.getMessage());
            throw e;
        }
    }
}
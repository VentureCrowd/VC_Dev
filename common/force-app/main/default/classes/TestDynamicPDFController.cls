@isTest
public class TestDynamicPDFController {
    @isTest
    static void testDynamicPDFController() {
        // Create a page reference with the necessary parameters
        String testHtmlContent = '<html><body><h1>Test HTML Content</h1></body></html>';
        PageReference pageRef = Page.DynamicPDFPage;
        pageRef.getParameters().put('htmlContent', testHtmlContent);
        Test.setCurrentPage(pageRef);

        // Instantiate the controller
        DynamicPDFController controller = new DynamicPDFController();

        // Verify the controller's functionality
        System.assertEquals(testHtmlContent, controller.htmlContent, 'HTML content should match the test HTML content');
    }

    @isTest
    static void testDynamicPDFControllerException() {
        // Create a page reference without the necessary parameters to trigger an exception
        PageReference pageRef = Page.DynamicPDFPage;
        Test.setCurrentPage(pageRef);

        // Instantiate the controller and expect an exception
        try {
            DynamicPDFController controller = new DynamicPDFController();
            System.assert(false, 'Exception should have been thrown due to missing parameters.');
        } catch (Exception e) {
            System.assertEquals('htmlContent parameter is missing', e.getMessage());
        }
    }
}
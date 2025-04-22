public class TestRaisePDFGeneratorFailMock extends RaisePDFGenerator {
    protected override Blob getPDFBlob(Id raiseId) {
        throw new CalloutException('Failed to generate PDF for Raise ID: ' + raiseId);
    }
}
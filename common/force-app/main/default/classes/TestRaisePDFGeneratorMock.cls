@isTest
public class TestRaisePDFGeneratorMock extends RaisePDFGenerator {
    protected override Blob getPDFBlob(Id raiseId) {
        return Blob.valueOf('Mock PDF Content');
    }
}
@isTest
public class ImageInfoControllerTest {
@isTest
    public static void testimaginfo(){
        List<Image_Info__c> infoList=new List<Image_Info__c>();
        Image_Info__c img1=new Image_Info__c(Image_Unique_Name__c='Test1',Image_Public_URL__C='https://google.com/myimage1');
         Image_Info__c img2=new Image_Info__c(Image_Unique_Name__c='Test2',Image_Public_URL__C='https://google.com/myimage2');
        infoList.add(img1);
         infoList.add(img2);
        insert  infoList;
        ImageInfoController infoctrl=new ImageInfoController();
       System.assert(infoctrl.imageNameURLMap.containsKey('Test1'));
    }
}
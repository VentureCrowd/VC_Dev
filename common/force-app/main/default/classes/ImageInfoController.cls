public class ImageInfoController {
    public Map<String,String> imageNameURLMap{get;set;}
    public ImageInfoController(){
       	imageNameURLMap=new  Map<String,String>();
        for(Image_Info__c img:[Select Image_Unique_Name__c,Image_Public_URL__C from Image_Info__c]){
          this.imageNameURLMap.put(img.Image_Unique_Name__c,img.Image_Public_URL__C);  
        }
    }
}
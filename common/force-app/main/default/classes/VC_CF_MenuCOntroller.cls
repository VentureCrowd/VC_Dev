public class VC_CF_MenuCOntroller {
    public User usr{get;set;}
    public VC_CF_MenuCOntroller(){
        Map<string,List<CommunityUserDetailController.navheader>> getheaders = CommunityUserDetailController.getheaders();
        getInvestdetails = getheaders.get('INVEST');
        getLearndetails = getheaders.get('LEARN');
        getRaisedetails = getheaders.get('RAISE');
        getPropertydetails = getheaders.get('PROPERTY');
        getAboutdetails = getheaders.get('ABOUT');
        getNewsdetails = getheaders.get('NEWS');
        getVenturesdetails = getheaders.get('VENTURES');
        usr=[Select Name,SmallPhotoUrl from User where Id=:UserInfo.getUserId() Limit 1];
    }
     public PageReference navigateToPage() {
         string passedParam1 = Apexpages.currentPage().getParameters().get('navigateurl');
         System.debug('passedParam1='+passedParam1);
         PageReference pg= new PageReference(passedParam1);
         String currenturl=ApexPages.CurrentPage().getUrl();
         System.debug('current page url='+currenturl);
         pg.setRedirect(false);
         aura.redirect(pg);
          return pg;
    }
    public List<CommunityUserDetailController.navheader> getInvestdetails{get;set;}
    public List<CommunityUserDetailController.navheader> getLearndetails{get;set;}
    public List<CommunityUserDetailController.navheader> getRaisedetails{get;set;}
    public List<CommunityUserDetailController.navheader> getPropertydetails{get;set;}
    public List<CommunityUserDetailController.navheader> getAboutdetails{get;set;}
    public List<CommunityUserDetailController.navheader> getNewsdetails{get;set;}
    public List<CommunityUserDetailController.navheader> getVenturesdetails{get;set;}
    
}
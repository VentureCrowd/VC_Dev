public interface IRaiseTeamFactory {
    List<Raise_Team_and_Advisors__c> getTeamMembersByRaiseId(Id raiseId, String category);
    Raise_Team_and_Advisors__c createTeamMember(Id raiseId, String name, String category, String picture, String description, String linkedIn, String role);
    void deleteTeamMember(Id teamMemberId);
    Raise_Team_and_Advisors__c editTeamMember(Id teamMemberId, String name, String picture, String description, String linkedIn, String role);
    Raise_Team_and_Advisors__c getTeamMemberById(Id teamMemberId);
}
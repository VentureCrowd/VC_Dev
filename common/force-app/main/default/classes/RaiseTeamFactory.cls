public class RaiseTeamFactory implements IRaiseTeamFactory {
    public List<Raise_Team_and_Advisors__c> getTeamMembersByRaiseId(Id raiseId, String category) {
        try {
            List<Raise_Team_and_Advisors__c> teamMembers = [
                SELECT Id, Name, Category__c, Picture__c, Description__c, LinkedIn__c, Role__c, Related_Raise__c
                FROM Raise_Team_and_Advisors__c
                WHERE Related_Raise__c = :raiseId AND Category__c = :category
            ];
            Logger.logMessage('RaiseApp', 'RaiseTeamFactory', 'getTeamMembersByRaiseId', 'Successfully retrieved team members for raiseId: ' + raiseId);
            return teamMembers;
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseTeamFactory', 'getTeamMembersByRaiseId', raiseId, null, null, null, e, 'Failed to retrieve team members for raiseId: ' + raiseId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public Raise_Team_and_Advisors__c createTeamMember(Id raiseId, String name, String category, String picture, String description, String linkedIn, String role) {
            Raise_Team_and_Advisors__c newTeamMember = new Raise_Team_and_Advisors__c();
            newTeamMember.Related_Raise__c = raiseId;
            newTeamMember.Name = name;
            newTeamMember.Category__c = category;
            newTeamMember.Picture__c = picture;
            newTeamMember.Description__c = description;
            newTeamMember.LinkedIn__c = linkedIn;
            newTeamMember.Role__c = role;

            insert newTeamMember;

            Logger.logMessage('RaiseApp', 'RaiseTeamFactory', 'createTeamMember', 'Successfully created team member for raiseId: ' + raiseId);
            return newTeamMember;

    }

    public void deleteTeamMember(Id teamMemberId) {
        try {
            Raise_Team_and_Advisors__c teamMember = [SELECT Id FROM Raise_Team_and_Advisors__c WHERE Id = :teamMemberId LIMIT 1];
            
            if(teamMember != null){
            	delete teamMember;    
                Logger.logMessage('RaiseApp', 'RaiseTeamFactory', 'deleteTeamMember', 'Successfully deleted team member with id: ' + teamMemberId);
            }else{
                Logger.logMessage('RaiseApp', 'RaiseTeamFactory', 'deleteTeamMember', 'Team member not found with id: ' + teamMemberId);
            }
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseTeamFactory', 'deleteTeamMember', teamMemberId, null, null, null, e, 'Failed to delete team member with id: ' + teamMemberId);
            throw new AuraHandledException('Failed to delete team member with id: ' + teamMemberId);
        }
    }

    public Raise_Team_and_Advisors__c editTeamMember(Id teamMemberId, String name, String picture, String description, String linkedIn, String role) {
        try {
            Raise_Team_and_Advisors__c existingTeamMember = [SELECT Id, Name, Category__c, Picture__c, Description__c, LinkedIn__c, Role__c FROM Raise_Team_and_Advisors__c WHERE Id = :teamMemberId LIMIT 1];
            existingTeamMember.Name = name;
            existingTeamMember.Picture__c = picture;
            existingTeamMember.Description__c = description;
            existingTeamMember.LinkedIn__c = linkedIn;
            existingTeamMember.Role__c = role;

            update existingTeamMember;

            Logger.logMessage('RaiseApp', 'RaiseTeamFactory', 'editTeamMember', 'Successfully edited team member with id: ' + teamMemberId);
            return existingTeamMember;
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseTeamFactory', 'editTeamMember', teamMemberId, null, null, null, e, 'Failed to edit team member with id: ' + teamMemberId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public Raise_Team_and_Advisors__c getTeamMemberById(Id teamMemberId) {
        try {
            Raise_Team_and_Advisors__c teamMember = [
                SELECT Id, Name, Category__c, Picture__c, Description__c, LinkedIn__c, Role__c
                FROM Raise_Team_and_Advisors__c
                WHERE Id = :teamMemberId
                LIMIT 1
            ];

            Logger.logMessage('RaiseApp', 'RaiseTeamFactory', 'getTeamMemberById', 'Successfully retrieved team member details for Id: ' + teamMemberId);
            return teamMember;
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseTeamFactory', 'getTeamMemberById', teamMemberId, null, null, null, e, 'Failed to retrieve team member details for Id: ' + teamMemberId);
            throw new AuraHandledException(e.getMessage());
        }
    }
}
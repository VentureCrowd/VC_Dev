public without sharing class RaiseTeamService {
    private RaiseTeamFactory factory = new RaiseTeamFactory();

    public List<Map<String, String>> getTeamMembersByRaiseId(Id raiseId, String category) {
        List<Map<String, String>> formattedTeamMembers = new List<Map<String, String>>();
        try {
            List<Raise_Team_and_Advisors__c> teamMembers = factory.getTeamMembersByRaiseId(raiseId, category);
            for (Raise_Team_and_Advisors__c teamMember : teamMembers) {
                Map<String, String> teamMemberMap = new Map<String, String>();
                teamMemberMap.put('id', teamMember.Id);
                teamMemberMap.put('name', teamMember.Name);
                teamMemberMap.put('category', teamMember.Category__c);
                teamMemberMap.put('picture', teamMember.Picture__c);
                teamMemberMap.put('description', teamMember.Description__c);
                teamMemberMap.put('linkedIn', teamMember.LinkedIn__c);
                teamMemberMap.put('role', teamMember.Role__c);
                formattedTeamMembers.add(teamMemberMap);
            }
            Logger.logMessage('RaiseApp', 'RaiseTeamService', 'getTeamMembersByRaiseId', 'Successfully formatted team members for raiseId: ' + raiseId);
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseTeamService', 'getTeamMembersByRaiseId', raiseId, null, null, null, e, 'Failed to retrieve and format team members for raiseId: ' + raiseId);
            throw new AuraHandledException(e.getMessage());
        }
        return formattedTeamMembers;
    }

    public Map<String, String> createTeamMember(Id raiseId, String name, String category, String picture, String description, String linkedIn, String role) {
        try {
            Raise_Team_and_Advisors__c newTeamMember = factory.createTeamMember(raiseId, name, category, picture, description, linkedIn, role);
            Map<String, String> teamMemberMap = new Map<String, String>();
            teamMemberMap.put('id', newTeamMember.Id);
            teamMemberMap.put('name', newTeamMember.Name);
            teamMemberMap.put('category', newTeamMember.Category__c);
            teamMemberMap.put('picture', newTeamMember.Picture__c);
            teamMemberMap.put('description', newTeamMember.Description__c);
            teamMemberMap.put('linkedIn', newTeamMember.LinkedIn__c);
            teamMemberMap.put('role', newTeamMember.Role__c);

            Logger.logMessage('RaiseApp', 'RaiseTeamService', 'createTeamMember', 'Successfully created team member for raiseId: ' + raiseId);
            return teamMemberMap;
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseTeamService', 'createTeamMember', raiseId, null, null, null, e, 'Failed to create team member for raiseId: ' + raiseId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public void deleteTeamMember(Id teamMemberId) {
        try {
            factory.deleteTeamMember(teamMemberId);
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseTeamService', 'deleteTeamMember', teamMemberId, null, null, null, e, 'Failed to delete team member with id: ' + teamMemberId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public Map<String, String> editTeamMember(Id teamMemberId, String name, String picture, String description, String linkedIn, String role) {
        try {
            Raise_Team_and_Advisors__c updatedTeamMember = factory.editTeamMember(teamMemberId, name, picture, description, linkedIn, role);
            Map<String, String> teamMemberMap = new Map<String, String>();
            teamMemberMap.put('id', updatedTeamMember.Id);
            teamMemberMap.put('name', updatedTeamMember.Name);
            teamMemberMap.put('picture', updatedTeamMember.Picture__c);
            teamMemberMap.put('description', updatedTeamMember.Description__c);
            teamMemberMap.put('linkedIn', updatedTeamMember.LinkedIn__c);
            teamMemberMap.put('role', updatedTeamMember.Role__c);

            Logger.logMessage('RaiseApp', 'RaiseTeamService', 'editTeamMember', 'Successfully edited team member with id: ' + teamMemberId);
            return teamMemberMap;
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseTeamService', 'editTeamMember', teamMemberId, null, null, null, e, 'Failed to edit team member with id: ' + teamMemberId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public Map<String, String> getTeamMemberById(Id teamMemberId) {
        try {
            Raise_Team_and_Advisors__c teamMember = factory.getTeamMemberById(teamMemberId);
            Map<String, String> teamMemberMap = new Map<String, String>();
            teamMemberMap.put('id', teamMember.Id);
            teamMemberMap.put('name', teamMember.Name);
            teamMemberMap.put('category', teamMember.Category__c);
            teamMemberMap.put('picture', teamMember.Picture__c);
            teamMemberMap.put('description', teamMember.Description__c);
            teamMemberMap.put('linkedIn', teamMember.LinkedIn__c);
            teamMemberMap.put('role', teamMember.Role__c);

            Logger.logMessage('RaiseApp', 'RaiseTeamService', 'getTeamMemberById', 'Successfully retrieved team member details for Id: ' + teamMemberId);
            return teamMemberMap;
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseTeamService', 'getTeamMemberById', teamMemberId, null, null, null, e, 'Failed to retrieve team member details for Id: ' + teamMemberId);
            throw new AuraHandledException(e.getMessage());
        }
    }
}
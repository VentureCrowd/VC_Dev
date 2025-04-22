public without sharing class RaiseTeamController {
    @TestVisible private static RaiseTeamService raiseTeamService = new RaiseTeamService();

    @AuraEnabled
    public static List<Map<String, String>> getTeamMembersByRaiseId(Id raiseId, String category) {
        try {
            return raiseTeamService.getTeamMembersByRaiseId(raiseId, category);
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseTeamController', 'getTeamMembersByRaiseId', raiseId, null, null, null, e, 'Failed to retrieve team members for raiseId: ' + raiseId);
            throw e;
        }
    }

    @AuraEnabled
    public static Map<String, String> createTeamMember(Id raiseId, String name, String category, String picture, String description, String linkedIn, String role) {
        try {
            return raiseTeamService.createTeamMember(raiseId, name, category, picture, description, linkedIn, role);
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseTeamController', 'createTeamMember', raiseId, null, null, null, e, 'Failed to create team member for raiseId: ' + raiseId);
            throw e;
        }
    }

    @AuraEnabled
    public static Boolean deleteTeamMember(Id teamMemberId) {
        try {
            raiseTeamService.deleteTeamMember(teamMemberId);
            return true;
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseTeamController', 'deleteTeamMember', teamMemberId, null, null, null, e, 'Failed to delete team member with id: ' + teamMemberId);
            return false;
        }
    }

    @AuraEnabled
    public static Map<String, String> editTeamMember(Id teamMemberId, String name, String picture, String description, String linkedIn, String role) {
        try {
            return raiseTeamService.editTeamMember(teamMemberId, name, picture, description, linkedIn, role);
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseTeamController', 'editTeamMember', teamMemberId, null, null, null, e, 'Failed to edit team member with id: ' + teamMemberId);
            throw e;
        }
    }

    @AuraEnabled
    public static Map<String, String> getTeamMemberById(Id teamMemberId) {
        try {
            return raiseTeamService.getTeamMemberById(teamMemberId);
        } catch (Exception e) {
            Logger.logError('RaiseApp', 'RaiseTeamController', 'getTeamMemberById', teamMemberId, null, null, null, e, 'Failed to retrieve team member details for Id: ' + teamMemberId);
            throw new AuraHandledException('Failed to retrieve team member details for Id: ' + teamMemberId);
        }
    }
}
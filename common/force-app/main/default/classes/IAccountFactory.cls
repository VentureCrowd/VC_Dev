// Interface for Account Factory
public interface IAccountFactory {
    Id getAccountId(Id userId);
    Account getUserAccountInfo(Id accountId);
}
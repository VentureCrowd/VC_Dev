/**

**/
public with sharing class UserEmailUpdateScheduler implements Schedulable{
    public String CRON_EXP = '0 0 6 * * ?';
    public Integer batchSize = 200;
    public void execute(SchedulableContext SC) {
        UserEmailUpdateBatch userBatch = new UserEmailUpdateBatch();
        Database.executeBatch(userBatch,batchSize);
    }
}
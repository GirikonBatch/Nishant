global class Scheduler_BatchScheduleRestore implements schedulable
{
    String query;
     Integer RecordSize;
    global Scheduler_BatchScheduleRestore(String Query,integer sz)
    {
         this.query=Query;
        RecordSize=sz;
        // execute(null);
    }
    global void execute(SchedulableContext sc)
    {
    BatchScheduleRestore b = new BatchScheduleRestore(query); //ur batch class
      database.executebatch(b,RecordSize);
         
    }
    
}
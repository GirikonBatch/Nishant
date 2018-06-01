global class Scheduler_BatchScheduleArchive implements schedulable
{
    String query;
    Integer RecordSize;
    String ids;
    global Scheduler_BatchScheduleArchive(String Query,integer sz)
    {
         this.query=Query;
         RecordSize=sz;
       	//execute(null);
    }
    global void value(String v)
    {
        ids=v;
    }
    global void execute(SchedulableContext sc)
    {
    BatchScheduleArchive b = new BatchScheduleArchive(query,ids); //ur batch class
      database.executebatch(b,RecordSize);
         
    }
    
}
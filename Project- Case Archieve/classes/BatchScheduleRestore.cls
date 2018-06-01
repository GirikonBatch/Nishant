global class BatchScheduleRestore implements Database.Batchable<sObject>
{
     public transient String CaseStatus{get;set;}
    public transient String CaseReason{get;set;}
    public transient String CaseOrigin{get;set;}
    public transient String CaseCreatedOlder{get;set;}
    public transient Integer RecordSize{get;set;}
    public transient String CaseClosedOlder{get; set;}
     String Query;
     String Case_Status;
     String Case_Reason;
     String Case_Origin;
     String Case_Created_Older;
     String Case_Closed_Older;
    Map<id,case> map_case_arc;
    map<id, EmailMessage> map_mail; 
     map<id, attachment> map_attm;
      Map<integer,List<id>> EmailAttachementMap=new Map<integer,List<id>>();
     map<id,attachment> map_attall;
      string attach_ids='';
     list<EmailMessage> mail_del = new list<EmailMessage>();
    list<attachment> att_insert = new list<attachment>();
    list<attachment> mail_insert = new list<attachment>();
      List<EmailMessage> NewEmailList=new List<EmailMessage>();
  global BatchScheduleRestore(String Q)
  {
	 	Query=q;
  }
 global Database.queryLocator start(Database.BatchableContext bc )
 {
      return Database.getQueryLocator(Query);
      
 }
  
  global void execute(Database.BatchableContext bc, List<Case> case_ar)
   {
       integer i=0;
        List<Attachment> atmList=new List<Attachment>();
      List<Attachment> atmLis=new List<Attachment>();
        NewEmailList.clear();
        EmailAttachementMap.clear();	
   		
        atmList.clear();
     atmLis.clear();
        
        
         list<case> case_arc=case_ar;
        
        
         map_case_arc =  new map<id,case>(case_arc);
        case_arc.clear();
         map_attm = new  map<id, attachment>([SELECT Body,BodyLength,ContentType,CreatedById,CreatedDate,Description,Id,
                                             IsDeleted,IsPrivate,LastModifiedById,LastModifiedDate,Name,OwnerId,ParentId,
                                             SystemModstamp FROM Attachment where ParentId in : map_case_arc.keySet() and name like '%Parser.txt']);
     
      
     
     		map_attall=new map<id,attachment>([SELECT Body,BodyLength,ContentType,CreatedById,CreatedDate,Description,Id,
                                             IsDeleted,IsPrivate,LastModifiedById,LastModifiedDate,Name,OwnerId,ParentId,
                                             SystemModstamp FROM Attachment where ParentId in : map_case_arc.keySet()]  );     
             For(Attachment Parserfiles:map_attm.values())
                  {
                                        String ParseStringBody;
             ParseStringBody='';
       		 ParseStringBody= Parserfiles.body.toString();
        	 String[] Parserfilelines = new String[]{};
            Parserfilelines = ParseStringBody.split('#%#'); 
             System.debug('++++++++++++++++++++'+Parserfilelines); 
              String[]AttachementFileNames=new String[]{};
         AttachementFileNames=Parserfilelines[13].split(';');
              System.debug('++++++++++++++++AttFileName'+AttachementFileNames);
      
        String[]ParentIdFileNames=new String[]{};
			ParentIdFileNames=Parserfilelines[8].split('=');
         EmailMessage NewEmail= new EmailMessage(ParentId=ParentIdFileNames[1]);
         
          String[]BccFileNames=new String[]{};
			BccFileNames=Parserfilelines[1].split('=');
               if(BccFileNames[1]=='null')
              {
        		 NewEmail.BccAddress='';
              }
              else if(BccFileNames[1]!='null')
              {
                 NewEmail.BccAddress=BccFileNames[1];
              }
       	

		String[]CcFileNames=new String[]{};
			CcFileNames=Parserfilelines[2].split('=');
              if(CcFileNames[1]=='null')
              {
        		NewEmail.CcAddress='';
              }
              else if(CcFileNames[1]!='null')
              {
                  NewEmail.CcAddress=CcFileNames[1];
              }

		String[]FromAddressFileNames=new String[]{};
		FromAddressFileNames=Parserfilelines[3].split('=');
        NewEmail.FromAddress=FromAddressFileNames[1];

		String[]FromNameFileNames=new String[]{};
		FromNameFileNames=Parserfilelines[4].split('=');
        NewEmail.FromName=FromNameFileNames[1];
		
		String[]HeadersFileNames=new String[]{};
		HeadersFileNames=Parserfilelines[5].split('=');
        NewEmail.Headers=HeadersFileNames[1];

		String[]IncomingFileNames=new String[]{};
		IncomingFileNames=Parserfilelines[6].split('=');
        NewEmail.Incoming=Boolean.valueOf(IncomingFileNames[1]);

		String[]MessageDateFileNames=new String[]{};
		MessageDateFileNames=Parserfilelines[7].split('=');
        NewEmail.MessageDate=Datetime.valueOf(MessageDateFileNames[1]);
        
        String[]TextBodyFileNames=new String[]{};
		TextBodyFileNames=Parserfilelines[9].split('=');
        NewEmail.TextBody=TextBodyFileNames[1];

		String[]StatusFileNames=new String[]{};
		StatusFileNames=Parserfilelines[10].split('=');
        NewEmail.Status=StatusFileNames[1];

		String[]ToAddressFileNames=new String[]{};
		ToAddressFileNames=Parserfilelines[11].split('=');
        NewEmail.ToAddress=ToAddressFileNames[1];

		String[]SubjectFileNames=new String[]{};
		SubjectFileNames=Parserfilelines[12].split('=');
        NewEmail.Subject=SubjectFileNames[1];
           NewEmailList.add(NewEmail);            
                      
               List<id> AttachmentsID=new List<id>();
                      
                      
                      For(integer k=1;k<AttachementFileNames.size();k++)
        {	 
         	
          
            AttachmentsID.add(AttachementFileNames[k]);
           
            
        } 
                     AttachmentsID.add(NULL); 
           EmailAttachementMap.put(i++,AttachmentsID);
            ParseStringBody='';
         }// for loop parser file
        
     map_attm.clear(); 
     
         insert NewEmailList;
            Map<id,List<id>> EmailAttachementMap1=new Map<id,List<id>>();
			
        
        for(integer j=0;j<NewEmailList.size();j++){
        EmailAttachementMap1.put(NewEmailList[j].id, EmailAttachementMap.get(j)) ;  
        EmailAttachementMap.remove(j);
        }//for loop close 
             
        System.debug('+++++++++++++*****************'+EmailAttachementMap1);
              
      NewEmailList.clear();
         for(id p_id : EmailAttachementMap1.keySet() ){
               List<id>attid=new List<id>();
             if(EmailAttachementMap1.get(p_id) != NULL){
              
                 attid=EmailAttachementMap1.get(p_id);
                 
                System.debug('*****************attid'+attid);
                 if(attid.size()>0)
                 {
             for(id att :attid )
             {		
                 if(att!=NULL)
                 {
                    attachment attm=new attachment();
                attm=map_attall.get(att);
                 System.debug('+++++++++++++++++++++++attm'+attm);
                    attachment atch = new attachment();
                 	
                    atch.Body = attm.Body;
                    atch.ContentType = attm.ContentType;
                    atch.Description = attm.Description;
                    atch.IsPrivate =  attm.IsPrivate;
                    atch.Name  = attm.Name.substringAfterLast('_') ;
                    atch.OwnerId = attm.OwnerId;
                    atch.ParentId =p_id;
                    atmList.add(atch);  
                    atmLis.add(attm);  
                 }
				}
             }//if
             } //if 
        }//For loop close    
     
     /////////
     map_attall.clear();
     map_attm.clear();
           if(atmList.size()>0)
        {
       		insert atmList; 
        }
     	
        if(atmLis.size()>0)
        {
        delete atmLis;
        Database.emptyRecycleBin(atmLis);
        }
                                    
         del();                           
         
       
   }
    void del()
    {
        List<Attachment> ParserfilesDelete=new List<Attachment>();
        List<Attachment> EmailfilesDelete=new List<Attachment>();
         ParserfilesDelete=[Select Id,ParentId,Name,body,ContentType From Attachment where name like '%Parser.txt%' and ParentId in :map_case_arc.keySet()];
         EmailfilesDelete=[Select Id,ParentId,Name,body,ContentType From Attachment where name like '%Email.pdf%' and ParentId in :map_case_arc.keySet()];
        if(ParserfilesDelete.size()>0)
        {
        Delete ParserfilesDelete;
        Database.emptyRecycleBin(ParserfilesDelete);
        }
         if(EmailfilesDelete.size()>0)
        {
        Delete EmailfilesDelete;
        Database.emptyRecycleBin(EmailfilesDelete);
        }
        List<case> c=New List<Case>();
        For(Case cc:map_case_arc.values())
        {
        cc.IsArchived__c=False;
            c.add(cc);
        }
        Update c;
    }//delete
    
    


 global void finish(Database.BatchableContext BC) {
   AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors,     JobItemsProcessed,
      TotalJobItems, CreatedBy.Email
      from AsyncApexJob where Id =:BC.getJobId()];
        
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          String[] toAddresses = new String[] {a.CreatedBy.Email};
          mail.setToAddresses(toAddresses);
          mail.setSubject('Records Restored ' + a.Status);
          mail.setPlainTextBody('Records Processed ' + a.TotalJobItems +
         ' with '+ a.NumberOfErrors + ' Failures.');
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    

//then use the active job id and abort it
system.abortJob('RestoreBatch');
      
}
}
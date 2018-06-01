public class zArchiveEmailByCaseController {
    
    public transient String CaseStatus{get;set;}
    public transient String CaseReason{get;set;}
    public transient String CaseOrigin{get;set;}
    public transient String CaseCreatedOlder{get;set;}
    public transient Integer RecordSize{get;set;}
    public transient Integer StartTime{get;set;}
    public transient String CaseClosedOlder{get; set;}
    public time tt{get;set;}
     public date dd{get;set;}
    public boolean DisArchive{get;set;}
    public boolean DisRestore{get;set;}
     public boolean SDisArchive{get;set;}
    public boolean SDisRestore{get;set;}
    String Query;
    String Case_Status;
    String Case_Reason;
    String Case_Origin;
    String Case_Created_Older;
    String Case_Closed_Older;
    public boolean b{get;set;}
    map<id , case> map_case_arc;
    public transient list<Case> c{get;set;}
    map<id, EmailMessage> map_mail;         
    map<id, attachment> map_attm;
    map<id,attachment> map_attall;
    Map<integer,List<id>> EmailAttachementMap=new Map<integer,List<id>>();
    integer j=0;
    string attach_ids='';
    list<EmailMessage> mail_del = new list<EmailMessage>();
    list<attachment> att_insert = new list<attachment>();
    list<attachment> mail_insert = new list<attachment>();
    public zArchiveEmailByCaseController()
    {
        b=false;
        Query='';
        Case_Status='';
        Case_Origin='';
        Case_Created_Older='';
        Case_Closed_Older='';
        DisArchive=True;
        DisRestore=True;
        SDisArchive=True;
        SDisRestore=True;
        dd=Date.today()+1;
        tt=Time.newInstance(00, 00,00, 59);

    }
    public Void ArchiveCases()
    {	
        mail_del.clear();
        att_insert.clear();
        mail_insert.clear();
        Query='SELECT AccountId,AssetId,CaseNumber,CFACE__Archived_Count__c,CFACE__Archive_Date__c,CFACE__Is_Archived__c,'+
            'ClosedDate,ContactEmail,ContactFax,ContactId,ContactMobile,ContactPhone,CreatedById,CreatedDate,datett__c,'+
            'Days_Since_Last_Update__c,Description,EngineeringReqNumber__c,first__c,Id,IsArchived__c,IsClosed,IsDeleted,'+
            'IsEscalated,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Origin,OwnerId,ParentId,'+
            'PotentialLiability__c,Priority,Product__c,Reason,SLAViolation__c,SourceId,Status,Subject,SuppliedCompany,'+
            'SuppliedEmail,SuppliedName,SuppliedPhone,SystemModstamp,Type FROM Case where IsArchived__c=false';
        Case_Status=(CaseStatus=='z'? '' :CaseStatus=='closed'? ' AND IsClosed  = true' : ' AND status =  \''+CaseStatus+'\'');
        case_Origin=(CaseOrigin=='z'? '' : ' AND origin =  \''+CaseOrigin+'\'');
        case_created_older=(CaseCreatedOlder=='All'? '' : ' AND CreatedDate < LAST_N_DAYS:'+CaseCreatedOlder);
        case_closed_older=(CaseClosedOlder=='All'? '' : ' AND ClosedDate < LAST_N_DAYS:'+CaseClosedOlder);
        Query+=Case_Status+case_Origin+case_created_older+case_closed_older+' limit '+RecordSize;
        list<case> case_arc=Database.query(Query);
        map_case_arc =  new map<id,case>(case_arc);
        case_arc.clear();
        map_mail = new map<id, EmailMessage>([SELECT ActivityId,BccAddress,CcAddress,CreatedById,CreatedDate,EmailNumber__c,FromAddress,FromName,
                                              HasAttachment,Headers,HtmlBody,Id,Incoming,IsClientManaged,IsDeleted,IsExternallyVisible,
                                              LastModifiedById,LastModifiedDate,MessageDate,MessageIdentifier,ParentId,RelatedToId,
                                              ReplyToEmailMessageId,Status,Subject,SystemModstamp,TextBody,ThreadIdentifier,ToAddress,
                                              ValidatedFromAddress FROM EmailMessage where ParentId in : map_case_arc.keySet() ]) ;
               map_attm = new  map<id, attachment>([SELECT Body,BodyLength,ContentType,CreatedById,CreatedDate,Description,Id,
                                             IsDeleted,IsPrivate,LastModifiedById,LastModifiedDate,Name,OwnerId,ParentId,
                                             SystemModstamp FROM Attachment where ParentId in : map_mail.keySet()]);
        for(attachment att : map_attm.values()){
           attachment atch = new attachment();
            EmailMessage ec =  map_mail.get(att.ParentId);
            atch.Body = att.Body;
            atch.ContentType = att.ContentType;
            atch.Description = att.Description;
            atch.IsPrivate =  att.IsPrivate;
            atch.Name  =  ec.EmailNumber__c+'_'+ec.Subject+'_Attachment_'+ att.Name;
            atch.OwnerId = att.OwnerId;
            atch.ParentId = ec.ParentId ;
            att_insert.add(atch);
        }
        map_attm.clear();
        if(att_insert.size()>0)
            insert att_insert;   
        for( EmailMessage caseMial : map_mail.values() ){
            attach_ids = '';  
            for(attachment a:att_insert ){
                string s = a.Name;
                if(s.startsWith(caseMial.EmailNumber__c+'_'+caseMial.Subject+'_Attachment_')){
                    attach_ids = attach_ids+a.Id+';' ;
                } 
            }
            attachment atch = new attachment();
            atch.ParentId =  caseMial.ParentId;
            atch.Name = caseMial.EmailNumber__c+'_'+caseMial.Subject+'_Email.pdf';
            //atch.Body = blob.toPDF(caseMial.FromName+'<br/>'+caseMial.FromAddress+'<br/>'+caseMial.CcAddress +'<br/>' +caseMial.CcAddress+'<br/>'+caseMial.Subject+'<br/>' +caseMial.TextBody.replaceAll('<','^^') +'<br/>'  );
            atch.Body =  blob.toPDF('<br/><b>Name : </b>'+(caseMial.FromName==Null? ' ' : caseMial.FromName)+
                                    '<br/><b>Address : </b>'+(caseMial.FromAddress==Null? ' ' : caseMial.FromAddress)+
                                    '<br/><b>BccAddress : </b>'+(caseMial.BccAddress==Null? ' ' : caseMial.BccAddress)+
                                    '<br/><b>CcAddress : </b>'+(caseMial.CcAddress==Null? ' ' : caseMial.CcAddress)+
                                    '<br/><br/><b>Subject : </b>'+caseMial.Subject+
                                    '<br/><br/>' +caseMial.TextBody.replaceAll('<','^').replaceAll('\n','<br/>') +
                                    '<br/>'  );
             mail_insert.add(atch);
            attachment atchtxt = new attachment();
            atchtxt.ParentId = caseMial.ParentId;
            atchtxt.Name = caseMial.EmailNumber__c+'_'+caseMial.Subject+'_Parser.txt';
            atchtxt.Body =  blob.valueOf('#%#BccAddress='+caseMial.BccAddress+'#%#CcAddress='+caseMial.CcAddress+
                                         '#%#FromAddress='+caseMial.FromAddress+'#%#FromName='+caseMial.FromName+
                                         '#%#Headers='+caseMial.Headers+'#%#Incoming='+caseMial.Incoming+'#%#MessageDate='+
                                         caseMial.MessageDate+'#%#ParentId='+caseMial.ParentId+'#%#TextBody&%$'+caseMial.TextBody+'#%#Status='+caseMial.Status+'#%#ToAddress='+
                                         caseMial.ToAddress+'#%#Subject='+caseMial.Subject+'#%#Attachment=;'+attach_ids);
            mail_insert.add(atchtxt);
             mail_del.add(caseMial);
        }
        att_insert.clear();
        map_mail.clear();        
        insert mail_insert; 
        mail_insert.clear();
        delete mail_del;  
        if(mail_del.size()>0)
            database.emptyRecycleBin(mail_del);
        mail_del.clear();
        list<task> t = [SELECT Id,TaskSubtype,WhatId,WhoId FROM Task WHERE TaskSubtype = 'email' AND WhatId in: map_case_arc.keySet()];
        delete t;
        if(t.size()>0)
            database.emptyRecycleBin(t);
        List<Case> b1=new List<Case>();
        For(Case v:map_case_arc.values())
        {
            v.IsArchived__c=true;
            b1.add(v);
        }
        update b1;    
        b1.clear();   
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Record Archived Successfully.Thank you!'));
         b=False;
    }
    List<EmailMessage> NewEmailList=new List<EmailMessage>();
    public void RestoreCases()
    {	integer i=0;
     List<Attachment> atmList=new List<Attachment>();
     List<Attachment> atmLis=new List<Attachment>();
     NewEmailList.clear();
     EmailAttachementMap.clear();	
      atmList.clear();
     atmLis.clear();
     Query='SELECT AccountId,AssetId,CaseNumber,CFACE__Archived_Count__c,CFACE__Archive_Date__c,CFACE__Is_Archived__c,'+
         'ClosedDate,ContactEmail,ContactFax,ContactId,ContactMobile,ContactPhone,CreatedById,CreatedDate,datett__c,'+
         'Days_Since_Last_Update__c,Description,EngineeringReqNumber__c,first__c,Id,IsArchived__c,IsClosed,IsDeleted,'+
         'IsEscalated,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Origin,OwnerId,ParentId,'+
         'PotentialLiability__c,Priority,Product__c,Reason,SLAViolation__c,SourceId,Status,Subject,SuppliedCompany,'+
         'SuppliedEmail,SuppliedName,SuppliedPhone,SystemModstamp,Type FROM Case where IsArchived__c=true';
     Case_Status=(CaseStatus=='z'? '' :CaseStatus=='closed'? ' AND IsClosed  = true' : ' AND status =  \''+CaseStatus+'\'');
     case_Origin=(CaseOrigin=='z'? '' : ' AND origin =  \''+CaseOrigin+'\'');
     case_created_older=(CaseCreatedOlder=='All'? '' : ' AND CreatedDate < LAST_N_DAYS:'+CaseCreatedOlder);
     case_closed_older=(CaseClosedOlder=='All'? '' : ' AND ClosedDate < LAST_N_DAYS:'+CaseClosedOlder);
     Query+=Case_Status+case_Origin+case_created_older+case_closed_older+' limit '+RecordSize;
     list<case> case_arc=Database.query(Query);
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
         { NewEmail.BccAddress='';
         }
         else if(BccFileNames[1]!='null')
         { NewEmail.BccAddress=BccFileNames[1];
         }
         String[]CcFileNames=new String[]{};
             CcFileNames=Parserfilelines[2].split('=');
         if(CcFileNames[1]=='null')
         { NewEmail.CcAddress='';
         }
         else if(CcFileNames[1]!='null')
         { NewEmail.CcAddress=CcFileNames[1];
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
         
        	String TextBodyFileNames=Parserfilelines[9];
         TextBodyFileNames=TextBodyFileNames.remove('TextBody&%$');  
              
              System.debug('TextBodyFileNames+++++++++++ '+TextBodyFileNames);
        NewEmail.TextBody=TextBodyFileNames;
         
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
         {	 AttachmentsID.add(AttachementFileNames[k]);
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
     NewEmailList.clear();
     for(id p_id : EmailAttachementMap1.keySet() ){
         List<id>attid=new List<id>();
         if(EmailAttachementMap1.get(p_id) != NULL){
               attid=EmailAttachementMap1.get(p_id);
             if(attid.size()>0)
             {
                 for(id att :attid )
                 {		
                     if(att!=NULL)
                     {
                         attachment attm=new attachment();
                         attm=map_attall.get(att);
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
    map_attall.clear();
     map_attm.clear();
     if(atmList.size()>0)
     {  insert atmList; 
     }
     if(atmLis.size()>0)
     {  delete atmLis;
         Database.emptyRecycleBin(atmLis);
     }  
     del();                           
     b=False;
    }
    void del()
    { List<Attachment> ParserfilesDelete=new List<Attachment>();
        List<Attachment> EmailfilesDelete=new List<Attachment>();
        ParserfilesDelete=[Select Id,ParentId,Name,body,ContentType From Attachment where name like '%Parser.txt%' and ParentId in :map_case_arc.keySet()];
        EmailfilesDelete=[Select Id,ParentId,Name,body,ContentType From Attachment where name like '%Email.pdf%' and ParentId in :map_case_arc.keySet()];
        if(ParserfilesDelete.size()>0)
        {  Delete ParserfilesDelete;
            Database.emptyRecycleBin(ParserfilesDelete);
        }
        if(EmailfilesDelete.size()>0)
        {  Delete EmailfilesDelete;
            Database.emptyRecycleBin(EmailfilesDelete);
        }
        List<case> c=New List<Case>();
        For(Case cc:map_case_arc.values())
        {  cc.IsArchived__c=False;
            c.add(cc);
        }
        Update c;
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Record Restored Successfully.Thank you!'));
    }//delete
    public void show()
    {   b=true;DisArchive=False;DisRestore=True;SDisArchive=False;SDisRestore=True;
     Query='SELECT AccountId,AssetId,CaseNumber,CFACE__Archived_Count__c,CFACE__Archive_Date__c,CFACE__Is_Archived__c,'+
         'ClosedDate,ContactEmail,ContactFax,ContactId,ContactMobile,ContactPhone,CreatedById,CreatedDate,datett__c,'+
         'Days_Since_Last_Update__c,Description,EngineeringReqNumber__c,first__c,Id,IsArchived__c,IsClosed,IsDeleted,'+
         'IsEscalated,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Origin,OwnerId,ParentId,'+
         'PotentialLiability__c,Priority,Product__c,Reason,SLAViolation__c,SourceId,Status,Subject,SuppliedCompany,'+
         'SuppliedEmail,SuppliedName,SuppliedPhone,SystemModstamp,Type FROM Case where IsArchived__c=False';
     Case_Status=(CaseStatus=='z'? '' :CaseStatus=='closed'? ' AND IsClosed  = true' : ' AND status =  \''+CaseStatus+'\'');
     case_Origin=(CaseOrigin=='z'? '' : ' AND origin =  \''+CaseOrigin+'\'');
     case_created_older=(CaseCreatedOlder=='All'? '' : ' AND CreatedDate < LAST_N_DAYS:'+CaseCreatedOlder);
     case_closed_older=(CaseClosedOlder=='All'? '' : ' AND ClosedDate < LAST_N_DAYS:'+CaseClosedOlder);
     Query+=Case_Status+case_Origin+case_created_older+case_closed_older+' limit '+RecordSize;
     c = Database.query(Query);
     if(c.size()<=0)
     { b=false;
         ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No Records To Display!'));
     }
   }
    public void ScheduleArchive()
    { Query='SELECT AccountId,AssetId,CaseNumber,CFACE__Archived_Count__c,CFACE__Archive_Date__c,CFACE__Is_Archived__c,'+
            'ClosedDate,ContactEmail,ContactFax,ContactId,ContactMobile,ContactPhone,CreatedById,CreatedDate,datett__c,'+
            'Days_Since_Last_Update__c,Description,EngineeringReqNumber__c,first__c,Id,IsArchived__c,IsClosed,IsDeleted,'+
            'IsEscalated,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Origin,OwnerId,ParentId,'+
            'PotentialLiability__c,Priority,Product__c,Reason,SLAViolation__c,SourceId,Status,Subject,SuppliedCompany,'+
            'SuppliedEmail,SuppliedName,SuppliedPhone,SystemModstamp,Type FROM Case where IsArchived__c=false';
        Case_Status=(CaseStatus=='z'? '' :CaseStatus=='closed'? ' AND IsClosed  = true' : ' AND status =  \''+CaseStatus+'\'');
        case_Origin=(CaseOrigin=='z'? '' : ' AND origin =  \''+CaseOrigin+'\'');
        case_created_older=(CaseCreatedOlder=='All'? '' : ' AND CreatedDate < LAST_N_DAYS:'+CaseCreatedOlder);
        case_closed_older=(CaseClosedOlder=='All'? '' : ' AND ClosedDate < LAST_N_DAYS:'+CaseClosedOlder);
        Query+=Case_Status+case_Origin+case_created_older+case_closed_older+' limit '+RecordSize;
        Scheduler_BatchScheduleArchive v=new Scheduler_BatchScheduleArchive(Query,RecordSize);
        String hour = String.valueOf(tt.hour());
        String min = String.valueOf(tt.minute()); 
		String ss = String.valueOf(tt.second());
        String day=String.valueOf(dd.day());
            String month=String.valueOf(dd.month());
            String year=String.valueOf(dd.year());
       try
        {
		String nextFireTime =ss+' '+min+' '+hour+' '+day+' '+month+' ? '+year;
        String cr=System.schedule('ArchiveBatch'+j, nextFireTime,v);
        j++;
        v.value(cr);
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Batch has been Scheduled Successfully.Thank you!'));
       }
        		 catch(Exception e)
        {
            String error=e.getMessage();
            if(error.contains('will never fire'))
               {   ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,'Scheduled Date And Time Must Be in Future!'));
               }
        }
        b=false;
    }
    public void ScheduleRestore()
    { Query='SELECT AccountId,AssetId,CaseNumber,CFACE__Archived_Count__c,CFACE__Archive_Date__c,CFACE__Is_Archived__c,'+
            'ClosedDate,ContactEmail,ContactFax,ContactId,ContactMobile,ContactPhone,CreatedById,CreatedDate,datett__c,'+
            'Days_Since_Last_Update__c,Description,EngineeringReqNumber__c,first__c,Id,IsArchived__c,IsClosed,IsDeleted,'+
            'IsEscalated,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Origin,OwnerId,ParentId,'+
            'PotentialLiability__c,Priority,Product__c,Reason,SLAViolation__c,SourceId,Status,Subject,SuppliedCompany,'+
            'SuppliedEmail,SuppliedName,SuppliedPhone,SystemModstamp,Type FROM Case where IsArchived__c=true';
        Case_Status=(CaseStatus=='z'? '' :CaseStatus=='closed'? ' AND IsClosed  = true' : ' AND status =  \''+CaseStatus+'\'');
        case_Origin=(CaseOrigin=='z'? '' : ' AND origin =  \''+CaseOrigin+'\'');
        case_created_older=(CaseCreatedOlder=='All'? '' : ' AND CreatedDate < LAST_N_DAYS:'+CaseCreatedOlder);
        case_closed_older=(CaseClosedOlder=='All'? '' : ' AND ClosedDate < LAST_N_DAYS:'+CaseClosedOlder);
        Query+=Case_Status+case_Origin+case_created_older+case_closed_older+' limit '+RecordSize;
        Scheduler_BatchScheduleRestore n=new Scheduler_BatchScheduleRestore(Query,RecordSize);
       String hour = String.valueOf(tt.hour());
        String min = String.valueOf(tt.minute()); 
		String ss = String.valueOf(tt.second());
        String day=String.valueOf(dd.day());
            String month=String.valueOf(dd.month());
            String year=String.valueOf(dd.year());
        try{
		String nextFireTime =ss+' '+min+' '+hour+' '+day+' '+month+' ? '+year;
        System.schedule('RestoreBatch'+j, nextFireTime,n);
      j++;
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Batch has been Scheduled Successfully.Thank you!'));
        }
        catch(Exception e)
        {   String error=e.getMessage();
            if(error.contains('will never fire'))
               { ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,'Scheduled Date And Time Must Be in Future!'));
               }
        }
        b=False;
    }   
    public void show1()
    {   b=true;DisRestore=False;DisArchive=True;SDisRestore=False; SDisArchive=True;
     Query='SELECT AccountId,AssetId,CaseNumber,'+
         'ClosedDate,ContactEmail,ContactFax,ContactId,ContactMobile,ContactPhone,CreatedById,CreatedDate,datett__c,'+
         'Description,Id,IsArchived__c,IsClosed,IsDeleted,'+
         'IsEscalated,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Origin,OwnerId,ParentId,'+
         'Priority,Reason,SourceId,Status,Subject,SuppliedCompany,'+
         'SuppliedEmail,SuppliedName,SuppliedPhone,SystemModstamp,Type FROM Case where IsArchived__c=true';
     Case_Status=(CaseStatus=='z'? '' :CaseStatus=='closed'? ' AND IsClosed  = true' : ' AND status =  \''+CaseStatus+'\'');    
     case_Origin=(CaseOrigin=='z'? '' : ' AND origin =  \''+CaseOrigin+'\'');
     case_created_older=(CaseCreatedOlder=='All'? '' : ' AND CreatedDate < LAST_N_DAYS:'+CaseCreatedOlder);
     case_closed_older=(CaseClosedOlder=='All'? '' : ' AND ClosedDate < LAST_N_DAYS:'+CaseClosedOlder);
     Query+=Case_Status+case_Origin+case_created_older+case_closed_older+' limit '+RecordSize;     
     c = Database.query(Query);
      if(c.size()<=0)
     {  b=false;
         ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No Records To Display!'));
     }
    }
}
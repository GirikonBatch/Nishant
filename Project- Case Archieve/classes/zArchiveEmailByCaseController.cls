 public class zArchiveEmailByCaseController {
    
    public String CaseStatus{get;set;}
    public String CaseReason{get;set;}
    public String CaseOrigin{get;set;}
    public String CaseCreatedOlder{get;set;}
    public Integer RecordSize{get;set;}
    public String CaseClosedOlder{get; set;}
    public String Query;
    public String Case_Status;
    public String Case_Reason;
    public String Case_Origin;
    public String Case_Created_Older;
    public String Case_Closed_Older;
    public boolean b{get;set;}
    map<id , case> map_case_arc;
    public list<Case> c{get;set;}
    map<id, EmailMessage> map_mail;         
    map<id, attachment> map_attm;
   Map<integer,List<id>> EmailAttachementMap=new Map<integer,List<id>>();
    
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
                    
                    system.debug('##jhjkhjkhkhkjhjk#ghgghgjhgggjgjgjgjhgh###########'+ atch);
                     att_insert.add(atch);
      
                  }
        
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
                                 atch.Body = blob.toPDF(caseMial.FromName+'<br/>'+caseMial.FromAddress+'<br/>'+caseMial.CcAddress +'<br/>' +caseMial.CcAddress+'<br/>'+caseMial.Subject+'<br/>' +caseMial.TextBody +'<br/>'  );
                                        
                                        mail_insert.add(atch);
                         
                             attachment atchtxt = new attachment();

                                    atchtxt.ParentId = caseMial.ParentId;
                                    atchtxt.Name = caseMial.EmailNumber__c+'_'+caseMial.Subject+'_Parser.txt';
                                    atchtxt.Body =  blob.valueOf('#%#BccAddress='+caseMial.BccAddress+'#%#CcAddress='+caseMial.CcAddress+
                                                           '#%#FromAddress='+caseMial.FromAddress+'#%#FromName='+caseMial.FromName+
                                                            '#%#Headers='+caseMial.Headers+'#%#Incoming='+caseMial.Incoming+'#%#MessageDate='+
                                                            caseMial.MessageDate+'#%#ParentId='+caseMial.ParentId+'#%#TextBody='+caseMial.TextBody+'#%#Status='+caseMial.Status+'#%#ToAddress='+
                                                            caseMial.ToAddress+'#%#Subject='+caseMial.Subject+'#%#Attachment=;'+attach_ids);
                                        mail_insert.add(atchtxt);
                                
                                
                                       mail_del.add(caseMial);
           
                  }
            
        
            insert mail_insert;      
                delete mail_del;  
                if(mail_del.size()>0)
                database.emptyRecycleBin(mail_del);
        
                 list<task> t = [SELECT Id,TaskSubtype,WhatId,WhoId FROM Task WHERE TaskSubtype = 'email' AND WhatId in: map_case_arc.keySet()];
                    delete t;
                    if(t.size()>0)
                    database.emptyRecycleBin(t);
        List<Case> b=new List<Case>();
        For(Case v:map_case_arc.values())
        {
            v.IsArchived__c=true;
            b.add(v);
        }
        
update b;            
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
        
         map_attm = new  map<id, attachment>([SELECT Body,BodyLength,ContentType,CreatedById,CreatedDate,Description,Id,
                                             IsDeleted,IsPrivate,LastModifiedById,LastModifiedDate,Name,OwnerId,ParentId,
                                             SystemModstamp FROM Attachment where ParentId in : map_case_arc.keySet() and name like '%Parser.txt']);
               
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
        {	 Attachment b=new Attachment();
         	
            b=[SELECT Body,BodyLength,ContentType,CreatedById,CreatedDate,Description,Id,
                IsDeleted,IsPrivate,LastModifiedById,LastModifiedDate,Name,OwnerId,ParentId,SystemModstamp FROM Attachment WHERE id=:AttachementFileNames[k]];
            AttachmentsID.add(b.id);
           
            
        } 
                     AttachmentsID.add(NULL); 
           EmailAttachementMap.put(i++,AttachmentsID);
            ParseStringBody='';
         }// for loop parser file
        
         insert NewEmailList;
            Map<id,List<id>> EmailAttachementMap1=new Map<id,List<id>>();
			
        
        for(integer j=0;j<NewEmailList.size();j++){
        EmailAttachementMap1.put(NewEmailList[j].id, EmailAttachementMap.get(j)) ;  
        EmailAttachementMap.remove(j);
        }//for loop close 
             
        System.debug('+++++++++++++*****************'+EmailAttachementMap1);
              
       
         for(id p_id : EmailAttachementMap1.keySet() ){
              
             if(EmailAttachementMap1.get(p_id) != NULL){
             for(attachment attm : [select Body,BodyLength,ContentType,CreatedById,CreatedDate,Description,Id,
                                    		IsDeleted,IsPrivate,LastModifiedById,LastModifiedDate,Name,OwnerId,
                                    ParentId,SystemModstamp from attachment where id in : EmailAttachementMap1.get(p_id)])
             {
                    
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
        }//For loop close                       
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
     public void show()
    {   b=true;
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
     System.debug('+++++++++++++++++++++++++asdf'+Query);       
     c = Database.query(Query);
        
    }
     public void show1()
    {   b=true;
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
     System.debug('+++++++++++++++++++++++++asdf'+Query);       
     c = Database.query(Query);
        
    }
                
}
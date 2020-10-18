public with sharing class SVMX_Sequence {

public SVMXC__ServiceMax_Processes__c[] TempProcessObjLst = new SVMXC__ServiceMax_Processes__c[]{};
public SVMXC__ServiceMax_Processes__c[] getTempProcessObjLst(){
    return TempProcessObjLst;
}
public void setTempProcessObjLst(SVMXC__ServiceMax_Processes__c[] val){
    this.TempProcessObjLst = val;
}
public String RecordPrcssID{get; set;}
/*public String HeaderRecId;
public String getHeaderRecId(){
    return HeaderRecId;
}
public void setHeaderRecId(String val){
    this.HeaderRecId = val;
}*/
    public SVMX_Sequence(){
    }
    public void shuffle(integer selIndex, boolean isTop ){
            SVMXC__ServiceMax_Processes__c temp;
            if(isTop){
                    temp = TempProcessObjLst[selIndex];
                    for(integer j=selIndex;j>0;j--){
                            TempProcessObjLst[j] = TempProcessObjLst[j-1];
                    }
                    TempProcessObjLst[0] = temp;
            }
            else {
                    temp = TempProcessObjLst[selIndex];
                    for(integer j=selIndex;j<TempProcessObjLst.size()-1;j++){
                            TempProcessObjLst[j] = TempProcessObjLst[j+1];
                    }
                    TempProcessObjLst[TempProcessObjLst.size()-1] = temp;
            }
        }
    
    public integer selIndex = 0;
    public boolean isUpAction = false;
    public boolean isDownAction = false;
    public boolean isTopAction = false;
    public boolean isBottomAction = false;
    public void Top(){
                SVMXC__ServiceMax_Processes__c temp;
                for(integer j=TempProcessObjLst.size()-1;j>0;j--){
                        for(integer i=items.size()-1;i>=0;i--){
                                if(items[i] == TempProcessObjLst[j].Id){
                                        selIndex = j;
                                        isUpAction = false;
                                        isDownAction=false;
                                        isTopAction=true;
                                        isBottomAction=false;
                                        shuffle(selIndex, true);                   
                                }
                        }
                }
                
        }
        public void UP(){
                SVMXC__ServiceMax_Processes__c temp;
                for(integer j=0;j<TempProcessObjLst.size();j++){
                        for(integer i=0;i<items.size();i++){
                                if(items[i]==TempProcessObjLst[0].Id){
                                        TempProcessObjLst[j] = TempProcessObjLst[j];
                                               // break;
                                }
                                else if(items[i]==TempProcessObjLst[j].Id){
                                        temp = TempProcessObjLst[j]; 
                                        TempProcessObjLst[j] = TempProcessObjLst[j-1];
                                        TempProcessObjLst[j-1]=temp;                    
                                        selIndex = j;
                                        isUpAction = true;
                                        isDownAction=false;
                                        isTopAction=false;
                                        isBottomAction=false;
                                        TempProcessObjLst[selIndex-1].SVMXC__Sequence__c=selIndex-1;
                                        TempProcessObjLst[selIndex].SVMXC__Sequence__c = selIndex;
                                }
                        }
                }
        }
        public void Down(){
             SVMXC__ServiceMax_Processes__c temp;
             for(integer j=TempProcessObjLst.size()-1;j>=0;j--){
                     for(integer i=0;i<items.size();i++){
                            if(items[i]==TempProcessObjLst[TempProcessObjLst.size()-1].Id){
                                TempProcessObjLst[j] = TempProcessObjLst[j];
                               // break;
                            }
                            else if(items[i]==TempProcessObjLst[j].Id){
                                        temp = TempProcessObjLst[j]; 
                                        TempProcessObjLst[j] = TempProcessObjLst[j+1];
                                        TempProcessObjLst[j+1]=temp;                    
                                        selIndex = j;
                                        isUpAction = false;
                                        isDownAction=true;
                                        isTopAction=false;
                                        isBottomAction=false;
                                        TempProcessObjLst[selIndex+1].SVMXC__Sequence__c=selIndex+1;
                                        TempProcessObjLst[selIndex].SVMXC__Sequence__c = selIndex;
                            }  
                     }
             }
        }
        public void Bottom(){
                SVMXC__ServiceMax_Processes__c temp;
                for(integer j=0;j<TempProcessObjLst.size()-1;j++){
                        for(integer i=0;i<items.size();i++){
                                if(items[i] == TempProcessObjLst[j].Id){
                                        selIndex = j;
                                        isUpAction = false;
                                        isDownAction=false;
                                        isTopAction=false;
                                        isBottomAction=true;                    
                                        shuffle(selIndex, false); 
                                }
                        }
                }
        }


    public PageReference SVMX_Cancel() {
        return null;
    }
    public pagereference SVMX_SaveSequence()
    {
        SVMXC__ServiceMax_Processes__c temp;
        double t;
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( TempProcessObjLst, COMM_SecurityUtils.Access.Updateable ) ) {
            if(isUpAction)
            {
                for(integer i=0;i<TempProcessObjLst.size();i++)
                {
                    TempProcessObjLst[i].SVMXC__Sequence__c=i+1;
                }
                update TempProcessObjLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else if(isDownAction)
            {
                for(integer i=0;i<TempProcessObjLst.size();i++)
                {
                    TempProcessObjLst[i].SVMXC__Sequence__c=i+1;
                }
                update TempProcessObjLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else if(isTopAction)
            {
                for(integer i=0;i<TempProcessObjLst.size();i++)
                {
                    TempProcessObjLst[i].SVMXC__Sequence__c=i+1;
                }
                update TempProcessObjLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else if(isBottomAction)
            {
                for(integer i=0;i<TempProcessObjLst.size();i++)
                {
                    TempProcessObjLst[i].SVMXC__Sequence__c=i+1;
                }
                update TempProcessObjLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                
            }
        } else {
            if( isUpAction || isDownAction || isTopAction || isBottomAction ) {
            	throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );    
            }
        }
        
        return null;  
    }

    //Action Recs display - Select Options definition, getter method and related methods
    List<SelectOption> ActionOptns = new List<SelectOption>();
    
    public List<SelectOption> getActionOptns(){
        
        if (TempProcessObjLst.Size() >0){
            ActionOptns.clear();
            for(SVMXC__ServiceMax_Processes__c s:TempProcessObjLst){                                                          
                    if (s != null && s.SVMXC__Name__c != null && s.get('Id') != null)
                    ActionOptns.add(new SelectOption(s.Id,s.SVMXC__Name__c));
            }
        }
        return ActionOptns;
    }
    
    
    //Selected Action records getter setters
    public List<String> items;
    public List<String> getitems(){
        return items;
    }
    public void setitems(List<String> val){
        this.items = val;
    }
    public String getTAG001(){ return System.Label.CONF017_TAG013; }//Save Sequence
    public String getTAG002(){ return System.Label.CONF017_TAG002; }//Cancel//CONF017_TAG014
    public String getTAG003(){ return System.Label.CONF017_TAG015; }//Sequence
    public String getTAG004(){ return System.Label.CONF017_TAG017; }//help title
    public String getTAG005(){ return System.Label.CONF017_HLPURL2; }//help url
    public String getTAG006(){ return System.Label.CONF017_TAG008; }//processing...
    public String getTAG007(){ return System.Label.CONF017_TAG007; }//Top
    public String getTAG008(){ return System.Label.CONF017_TAG019; }//Up
    public String getTAG009(){ return System.Label.CONF017_TAG020; }//Down
    public String getTAG010(){ return System.Label.CONF017_TAG021; }//Bottom
}
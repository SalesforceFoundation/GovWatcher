/*
    Copyright (c) 2012, Salesforce.com Foundation
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Salesforce.com Foundation nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
 
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.com Foundation
* @date Salesforce Foundation 2012
* @description Main GovWatcher console controller
*/
public with sharing class FGW_Console_CTRL{
    
    public FGW_Application_Settings__c AppSettings;
    public Id ChatterUserId{get;set;}
    public Id FeedDisplayId{get; set;}
    public List<Legislation__c> followedLegislation;
    public List<Contact> followedLegislators;
    public String FeedName{get;set;}     
    public final String ChatterUserName{get;set;}
    public String adv_query{get;set;} 
    public String advqueryObject{get;set;}
    public String queryObject{get;set;}
    public Integer searchResultsSize{get{return searchResults.size();}}
    public Integer legislatorFollowSize{get{return followedLegislators.size();}}
    public Integer legislationFollowSize{get{return followedLegislation.size();}}
    public Integer savedSearchesSize{get{return SavedSearches.size();}}
    public List<FGW_Saved_Search__c> SavedSearches;
    public List<FGW_Saved_Search__c> getSavedSearches(){
    	   SavedSearches = new List<FGW_Saved_Search__c>();
    	   SavedSearches = [select id, Name, API_Name__c, Search_Description__c, Active__c, Advanced__c from FGW_Saved_Search__c];
    	   return SavedSearches;
    }
    public Id searchObjId{get;set;}
    public FGW_Saved_Search__c loadedSearch{get;set;}    
    
    private FGW_IAPI defaultAPI = FGW_APIFactory.getDefault_Federal_API_Instance();
    
    //available object for the default API to search over
    public List<SelectOption> availableObjs;
    public List<SelectOption> getavailableObjs(){                    	   
    	availableObjs = new List<SelectOption>();
    	availableObjs.add(new SelectOption('', '-Select-'));
    	
    	//get the default API for the search
    	if (defaultAPI.getFieldMapping().containsKey('Contact')){
            availableObjs.add(new SelectOption('Contact', 'Legislator'));                		
    	}
    	if(defaultAPI.getFieldMapping().containsKey('Legislation__c')){
    		availableObjs.add(new SelectOption('Legislation__c', 'Legislation'));
    	}
    	return availableObjs; 
    }
    
    public List<String> objectSearchFields;
    public List<String> getobjectSearchFields(){
        List<String> newList = new List<String>();
        if (queryObject != null && queryObject != ''){    
        	system.debug('QUERYOBJECT' + queryObject);
            Map<String, String> fieldMap = defaultAPI.getFieldMapping().get(queryObject);
            //remove the fulltext search field from the field list if it exists
            if (fieldMap.containsKey('FullText'))
                fieldMap.remove('FullText');

            newList.addAll(fieldMap.keySet());                    	
        }
    	
    	return newList;    	
    }
    
    //search object to hold fields
    public sobject searchObject;
    public sobject getsearchObject(){
    	
    	if (queryObject != null && queryObject != ''){    
    	   //get the selected query object from the picklist
    	   Type t = Type.forName(queryObject);
    	   //create a new object type of the selected queryObject, and put it in the
    	   //search object so we can use the sobject fields
            searchObject = (sobject)t.newInstance();
    	}            
        return searchObject;    	
    }    
    
    //search results
    public List<SearchResult> searchResults{get;set;}
    
    //the name of the non-default API to use for this query 
    public String searchAPIName{get; set;}
    public List<SelectOption> APIOptions{get;set;}
    
    private Map<String, FGW_API_Settings__c> availableFedAPIs;
    private Map<String, FGW_API_Settings__c> availableStateAPIs;
      
    public FGW_Console_CTRL(){
        AppSettings = FGW_Constants.AppSettings;
        ChatterUserId = AppSettings.Chatter_User_Id__c; 
        FeedDisplayId = ChatterUserId;
        FeedName = [select Name from User where Id = :ChatterUserId].Name;
        ChatterUserName = FeedName;
        Map<String, FGW_API_Settings__c> allAPIs = FGW_API_Settings__c.getAll();
        availableFedAPIs = new Map<String, FGW_API_Settings__c>();
        availableStateAPIs = new Map<String, FGW_API_Settings__c>();
        APIOptions = new List<SelectOption>();
        
        for (String s : allAPIs.keySet()){
        	FGW_API_Settings__c a = allAPIs.get(s);
        	if (a.API_Type__c == 'Federal')
        	   availableFedAPIs.put(a.Name, a);
        	else if (a.API_Type__c == 'State')
        	   availableStateAPIs.put(a.Name, a);        
            APIOptions.add(new SelectOption(a.Name,a.Name));
        }
        
        searchAPIName = AppSettings.Federal_API_Name__c;
        //set a default query object
        queryObject = '';        
        
        List<FGW_Search_Result__c> existingResults = new List<FGW_Search_Result__c>();
        existingResults = [select Name from FGW_Search_Result__c order by LastModifiedDate desc];
        searchResults = new List<SearchResult>();
        for (FGW_Search_Result__c sr : existingResults){
        	searchResults.add(new SearchResult(sr));
        }
        
    }
    
    public void viewAllFeeds(){
        FeedDisplayId = ChatterUserId;
        FeedName = [select Name from User where Id = :ChatterUserId].Name;
    }
    
    public void assignFeedName(){           
        String f;
        
        if (((String)FeedDisplayId).startsWith('003'))
            FeedName = [select Name from Contact where Id = :FeedDisplayId].Name;
        else
            FeedName = [select Name from Legislation__c where Id = :FeedDisplayId].Name;
    }
    
    public List<Legislation__c> getfollowedLegislation(){
        followedLegislation = new List<Legislation__c>();
        
        //get all of the legislation IDs that the chatter user follows
        EntitySubscription[] followingES = [select id, parentid, subscriberid, parent.name
                                    from EntitySubscription
                                    where subscriberid =:ChatterUserId];//Set to the User's Id

        List<Id> legIds = new List<Id> ();

        String legSObjectPrefix =  Legislation__c.sObjectType.getDescribe().getKeyPrefix();

        for(EntitySubscription es: followingES){
            if(('' + es.parentid).substring(0,3) == legSObjectPrefix){
                legIds.add(es.parentid);
            }
        }
        
          //use fieldset to make sure we're getting the correct data...
        String q = 'select Name, Id, ';
        for(Schema.FieldSetMember f : SObjectType.Legislation__c.FieldSets.FGW_Legislation_Console_Fields.getFields()) {
            String s = f.getFieldPath();
            if (s.toUpperCase() != 'ID' && s.toUpperCase() != 'NAME')
                q += f.getFieldPath() + ', ';
        }

        q = q.subString(0, q.length() - 2);
        
        q += ' from Legislation__c where id IN :legIds';
        
        followedLegislation = Database.query(q);  
        
        return followedLegislation;
    }    
    
    public List<Contact> getfollowedLegislators(){
        followedLegislators = new List<Contact>();
        
        //get all of the legislation IDs that the chatter user follows
        EntitySubscription[] followingES = [select id, parentid, subscriberid, parent.name
                                    from EntitySubscription
                                    where subscriberid =:ChatterUserId];//Set to the User's Id

        List<Id> conIds = new List<Id> ();

        String conSObjectPrefix =  Contact.sObjectType.getDescribe().getKeyPrefix();

        for(EntitySubscription es: followingES){
            if(('' + es.parentid).substring(0,3) == conSObjectPrefix){
                conIds.add(es.parentid);
            }
        }
        
        
        //use fieldset to make sure we're getting the correct data...
        String q = 'select Name, Id, ';
        for(Schema.FieldSetMember f : SObjectType.Contact.FieldSets.FGW_Legislator_Console_Fields.getFields()) {
            String s = f.getFieldPath();
            if (s.toUpperCase() != 'ID' && s.toUpperCase() != 'NAME')
                q += f.getFieldPath() + ', ';
        }

        q = q.subString(0, q.length() - 2);
        
        q += ' from Contact where id IN :conIds';
        
        followedLegislators = Database.query(q);  
        
        return followedLegislators;
    }
    
    public PageReference runAdvSearch(){
        FGW_RequestFilterParameters rfp = new FGW_RequestFilterParameters();
        rfp.adv_query = adv_query;
        rfp.queryReturnType = FGW_Constants.queryReturntype.Basic;
        if (advqueryObject == 'Legislation')
            rfp.objectName = 'Legislation__c';
        else
            rfp.objectName = 'Contact';            
        
        if (searchAPIName != null && searchAPIName != '')
            rfp.APIName = searchAPIName;
        else
            rfp.APIName = FGW_Constants.FederalAPI.Name;                    
        
        system.debug(rfp.APIName);
        searchResults = runSearches(new List<FGW_RequestFilterParameters>{rfp});
        
        return null;        
    }
    
    
    public PageReference trackMarkedResults(){ 
    	
    	//hold the bioguide or bill ids to be tracked
    	List<FGW_Search_Result__c> srList = new List<FGW_Search_Result__c>();
    	
    	//assignt he remaining result back to the original collection for display
    	List<SearchResult> remainingResults = new List<SearchResult>();    	
    	
    	for (SearchResult sr : searchResults){
    	   	if (sr.isSelected)
                srList.add(sr.SearchResult);
            else
                remainingResults.add(sr);    	   	       		
    	}    	
    	
    	//remove any selected ones from the list as well
    	searchResults.clear();
    	searchResults = remainingResults;    	    	
    	
    	//Convert the search results
    	Integer tracked_objects = FGW_Main.convertSearchResults(srList);
    	
    	//check to see if the number of object tracked is less than the number selected, if so, there's a mismatch
    	//and we need to issue a warning    	
    	if (tracked_objects < srList.size()){
    		
    	}
    	
    	return null;
    }
    
    public PageReference deleteSavedSearch(){
    	return null;
    }
    public PageReference editSavedSearch(){return null;}
    
    
    private List<SearchResult> runSearches(List<FGW_RequestFilterParameters> rfps){
      
        List<Sobject> searchObjs = new List<Sobject>();
        
        searchObjs = FGW_Main.runSearch(rfps);  
        
        for (SObject obj : searchObjs){
            FGW_Search_Result__c sr = FGW_Utilities.convertObjectToSearchResult(obj);
            sr.Retrieved_At__c = system.now();
  //          if(rfp.SavedSearchID != null) sr.Saved_Search__c = rfp.SavedSearchId;
            sr.API_Name__c  = searchAPIName;                        
            searchResults.add(new SearchResult(sr));
        }      
        
        return searchResults;
    }
    
    public class SearchResult{
        public boolean isSelected{get;set;}
        public FGW_Search_Result__c SearchResult{get;set;}
        public SearchResult(FGW_Search_Result__c sr){
        	SearchResult = sr;
        }    	
    }
    
}
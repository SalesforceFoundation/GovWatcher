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
* @author Wai Ho & Salesforce.com Foundation
* @date Exponent Partners 2011, Salesforce Foundation 2012
* @description Access to the Sunlight Foundation Real Time Congress API 
*/
global class FGW_RealTimeCongressAPI implements FGW_IAPI{

    
    public FGW_RealTimeCongressAPI(){
    	
    	system.debug('CONSTRUCTOR FIRED');
    }
    
    
    global List<Legislation__c> getBills(List<FGW_RequestFilterParameters> params){
    	
    	return new List<Legislation__c>();
    }

    global List<Amendment__c> getAmendments(List<FGW_RequestFilterParameters> params){
    	
    	return new List<Amendment__c>();
    }

    global List<Legislator_Vote__c> getVotes(List<FGW_RequestFilterParameters> params){
    	
    	return new List<Legislator_Vote__c>();
    }


    global List<Contact> getLegislators(List<FGW_RequestFilterParameters> params){    	
    	return new List<Contact>();
    }

 
    global Amendment__c getAmendment(String amendmentId){
    	return new Amendment__c();
    }
 
    global Legislation__c getBill(String billId){
    	return new Legislation__c();
    }     
    
    global Contact getLegislator(String bioguide_id){
    	return new Contact();
    }
    
    
    
    




}
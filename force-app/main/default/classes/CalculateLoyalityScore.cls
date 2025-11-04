global class CalculateLoyalityScore implements Database.Batchable<AggregateResult> {
    
    global Iterable<AggregateResult> start(Database.BatchableContext bc){
        
        // String query = 'SELECT  count(Id), Modality__c,Physician__c FROM Referral__c where Physician__c != null GROUP BY Modality__c , Physician__c ORDER BY Physician__c';
        String query = 'SELECT  sum(Volume__c), Modality__c,Physician__c FROM Referral__c where Physician__c != null AND Encounter_Date__c=LAST_MONTH GROUP BY Modality__c , Physician__c ORDER BY Physician__c';
        return new AggregateResultIterable(query);
        
    } 
    // The batch job executes and operates on one batch of records
    global void execute(Database.BatchableContext bc, List<sObject> scope){ 
        map<string,map<string,integer>> modMap = new map<string,map<string,integer>>();
        
        set<string> conid = new set<string>();
        
        for(sObject ar : scope){
            system.debug('ar================> '+ar);
            conid.add(string.valueOf(ar.get('Physician__c')));
            if (!modMap.containsKey(string.valueOf(ar.get('Physician__c')))) {
                modMap.put(string.valueOf(ar.get('Physician__c')), new map<string,integer>());
            }
            modMap.get(string.valueOf(ar.get('Physician__c'))).put(string.valueOf(ar.get('Modality__c')),integer.valueOf(ar.get('expr0')));
            
            
        }
        
        map<id,contact> conMap = new map<id,contact>([SELECT Id,Specialty__c, Specialty__r.Name,Specialty__r.Specialty_Total_Denominator__c FROM Contact where Specialty__c != null and id in :conid ]);
        system.debug('modMap============> '+json.serializePretty(modMap));
        system.debug('conMap============> '+conMap);
        system.debug('conMap size ===============================> '+conMap.size());
        
        decimal BRE = 0 ;
        decimal USG = 0;
        decimal CT = 0 ;
        decimal DEXA = 0;
        decimal DIA = 0 ;
        decimal MR = 0 ;
        decimal PET = 0;
        decimal NM = 0;
        decimal USV  = 0;
        
        List<contact> conUpdate = new list<contact>();
        
        
        for(Id subMapKey: modMap.keySet()){
            system.debug('subMapKey================================================> '+subMapKey);
            map<string,integer> valex = modMap.get(subMapKey);
            system.debug('valex===========================> '+valex);
            if(valex.get('BRE') != null){
                BRE = valex.get('BRE') *  0.04; 
                
                system.debug('BRE  '+BRE);
            }else{
                BRE = 0; 
            }
            
            if(valex.get('USG') != null){
                USG = valex.get('USG')* 0.03; 
                
                system.debug('USG  '+USG);
            }else{
                USG = 0; 
            }
            if(valex.get('DEXA') != null){
                DEXA= valex.get('DEXA')* 0.04; 
                
                system.debug('DEXA  '+DEXA);
            }else{
                DEXA = 0; 
            }
            if(valex.get('CT') != null){
                CT= valex.get('CT')*0.09; 
                
                system.debug('CT  '+CT);
            }else{
                CT = 0; 
            }
            if(valex.get('DIA') != null){
                DIA= valex.get('DIA') * 0.01 ;
                
                system.debug('DIA  '+DIA);
            }else{
                DIA = 0; 
            }
            if(valex.get('MR') != null){
                MR= valex.get('MR') * 0.16;
                
                system.debug('MR '+MR);
            }else{
                MR = 0; 
            }
            if(valex.get('PET') != null){
                PET= valex.get('PET') * 0.48;
                
                system.debug('PET '+PET);
            }else{
                PET = 0; 
            }
            if(valex.get('NM') != null){
                NM= valex.get('NM') * 0.15;
                
                system.debug('NM '+NM);
            }else{
                NM = 0; 
            }
            
            system.debug('SCORES =========> '+ BRE +' '+ USG +' '  + CT +' ' + DEXA +' ' + DIA +' '+ MR +' ' + PET +' ' + NM);
            Decimal sumScore =BRE + USG  + CT  + DEXA  + DIA + MR + PET + NM ;
            
            
            
            
            system.debug('sumScore=========> '+ sumScore);  
            if(conMap.size()>0 && conMap.get(subMapKey) != null && conMap.get(subMapKey).Specialty__r.Specialty_Total_Denominator__c != null){
                
                decimal specDeno = conMap.get(subMapKey).Specialty__r.Specialty_Total_Denominator__c;
                system.debug('Specialty_Total_Denominator__c=========> '+ specDeno); 
                
                // decimal loyaltyScore = (sumScore/specDeno).setScale(2); 
                
                if(specDeno!=null && specDeno>0){
                    decimal loyaltyScore = (sumScore/specDeno);
                    decimal percentloyaltyScore = (loyaltyScore * 100).setScale(2);
                    conUpdate.add(new contact(id= subMapKey , Loyalty_Score__c = percentloyaltyScore)); 
                    system.debug('loyaltyScore=========> '+ loyaltyScore); 
                }
            }
            
        }
        system.debug('conUpdate===========> '+conUpdate);
        if(!conUpdate.isEmpty()){
            update conUpdate;    
        }
        
        
        
        
        
    }
    // The batch job finishes
    global void finish(Database.BatchableContext bc){ }
}
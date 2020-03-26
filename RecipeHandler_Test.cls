//same test class but with two additional methods to do negative test
//Write at least one test method that validates your code doesn’t do something it shouldn’t
//Write at least one method that causes your code to throw an error.  In your test method, catch that error and assert that it is the anticipated error.  (Hint:  look at the addError in IngredientUtil

//positive tests for methods in RecipeHandler class
@isTest
public class RecipeHandler_Test {
    
    @isTest
    	static void testMarkDraft(){

        // create recipe
        Recipe__c rec = new Recipe__c();
        rec.Name = 'Test Recipe 1';
        rec.Description__c = 'This is an incomplete draft recipe.';
        insert rec;
    
		// load the rec record and assert that Draft is TRUE
       	rec = [SELECT Draft__c FROM Recipe__c WHERE Id = : rec.Id];
    
       System.assertEquals(TRUE, rec.Draft__c, 'Recipe should be marked as draft');
    }
    
    @isTest
    static void testMarkComplexity(){
        
        // create recipe
        Recipe__c rec = new Recipe__c();
        rec.Name = 'Test Recipe 2';
        rec.Description__c = 'This is a difficult recipe.';
        rec.Active_Time__c = 120;
        rec.Active_Time_Units__c = 'Minutes';
        insert rec;
        
        // load the rec record and assert that Complexity is difficult
       	rec = [SELECT Complexity__c FROM Recipe__c WHERE Id = : rec.Id];
    
       System.assertEquals(rec.Complexity__c, 'Difficult', 'Recipe should be difficult');
    }
    
    @isTest
    static void testReviewTask(){
        
        // create recipe
        Recipe__c rec = new Recipe__c();
        rec.Name = 'Test Recipe 3';
        rec.Description__c = 'This recipe is used in a cookbook';
        rec.Active_Time__c = 60;
        rec.Active_Time_Units__c = 'Minutes';
        rec.Servings__c = 24;
        insert rec;
        
        //create cookbook
        Cookbook__c cb = new Cookbook__c();
        cb.Name = 'Test Cookbook';
        insert cb;
        
        //create a usage to link them which should create a task on the cookbook
        Recipe_Usage__c ru = new Recipe_Usage__c();
        ru.Recipe__c = rec.Id;
        ru.Cookbook__c = cb.Id;
        insert ru;
        
        rec.Duration__c = 'Quick';
        update rec;
        
        List<Task> taskList = new List<Task> ([SELECT Id FROM Task WHERE WhatId = : cb.Id]);
        
        System.assert(taskList.size() == 1);
    }
    
     @isTest
    static void testNoReviewTask(){
        
        // create recipe
        Recipe__c rec = new Recipe__c();
        rec.Name = 'Test Recipe 3';
        rec.Description__c = 'This recipe is used in a cookbook even though it is a draft';
        insert rec;
        
        //create cookbook
        Cookbook__c cb = new Cookbook__c();
        cb.Name = 'Test Cookbook';
        insert cb;
        
        //create a usage to link them which should create a task on the cookbook
        Recipe_Usage__c ru = new Recipe_Usage__c();
        ru.Recipe__c = rec.Id;
        ru.Cookbook__c = cb.Id;
        insert ru;
        
        rec.Duration__c = 'Quick';
        update rec;
        
        List<Task> taskList = new List<Task> ([SELECT Id FROM Task WHERE WhatId = : cb.Id]);
        
        System.assert(taskList.size() == 0);
    }
       
    @isTest
        static void testNoNameWithError(){
            
        // create recipe
        Recipe__c rec = new Recipe__c();
        rec.Description__c = 'a recipe without a name is not helpful';
        rec.Active_Time__c = 60;
        rec.Active_Time_Units__c = 'Minutes';
		rec.Servings__c = 24;
        
        try {
        insert rec;
       	} catch (System.DmlException e) {
        // Did we get the expected error?
      System.assertEquals(
         StatusCode.REQUIRED_FIELD_MISSING,
         e.getDmlType(0));
   		 }
   }
    
}
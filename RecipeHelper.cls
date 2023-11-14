/* A helper class for our Recipe Management App. This class contains static methods
that provide fuctionality related to recipes
*/
		
public with sharing class RecipeHelper {
    
    //takes ingredient details and creates a corresponding SOBject record with the provided recipe ID as the parent
    public static void addIngredient (String ingredientName, Integer measurementAmount, String measurementType, ID recipeId) {
	
    Ingredient__c newIngredient = new Ingredient__c();
    newIngredient.Name = ingredientName;
    newIngredient.Measurement__c = measurementAmount;
    newIngredient.Measurement_Type__c = measurementType;
    newIngredient.Recipe__c = recipeId;
    insert newIngredient;    

    }

    public static List<String> generateGroceryList(ID recipeId) {
        //Based on the recipe and its' ingredients, generate a shopping list for all items
        //return a list of the names of all the ingredients

        List <Ingredient__c> ingredientNames = [SELECT Name FROM Ingredient__c WHERE Recipe__c = : recipeId];
        List<String> groceryList = new List<String>();
     	//loop over the ingredient names and add them to the grocery list list of strings
        	for(Ingredient__c i : ingredientNames){
           		groceryList.add(i.Name);
    }
        System.debug('Grocery list: '+ groceryList);
        
        //return the list of ingredients on the grocery list
        return groceryList;
    }
    
    public static void scaleRecipeForServings (ID recipeId, Integer desiredServings) {
        // based on the desired servings, scale the recipe ingredients up or down.
        // use system.debug to print out the new ingredient quantity
        List <Ingredient__c> myIngredients = [SELECT Name, Measurement__c, Measurement_Type__c from Ingredient__c WHERE Recipe__c = :recipeId];
        List<String> scaledList = new List <String>();
        Recipe__c recipe = [SELECT Servings__c FROM Recipe__c WHERE Id = : recipeId];
        
        //divide desired servings by servings and multiply measurement
        Decimal scale = desiredServings / recipe.Servings__c;
        System.debug('the scale is: '+ scale);
        Decimal newMeasurement;

        //loop through ingredients and multiply measurement of each by new measurement equation
        //add the result to the list of new measurements
        for (Ingredient__c i : myIngredients){
            newMeasurement = i.Measurement__c * scale;
            scaledList.add(newMeasurement + ' ' + i.Measurement_Type__c + ' '+ i.Name);
        }
        System.debug('New list of measurements '+ scaledList);
    }
}
RecipeHelperTest.cls
@isTest
	public class RecipeHelperTest {
    @TestSetup
        static void createRecipe(){
            Recipe__c rec = new Recipe__c();
                rec.Name = 'Test Recipe 3';
                rec.Active_Time__c = 2;
                rec.Description__c = 'recipe';
                rec.Active_Time_Units__c = 'Hours';
                rec.Servings__c = 4;
                rec.Name__c= 'Test Recipe 3';
    
            insert rec;
            
        }
        //This test is to make sure the ingredient is added to the database with the recipe Id as parent.    
        @isTest static void addIngredientPositiveTest() {
               	Recipe__c rec = [SELECT Id from Recipe__c];
                Test.startTest();
                RecipeHelper.addIngredient('Wheat Flour', 4, 'Cups', rec.Id);
                Test.stopTest();
                Ingredient__c ing = [SELECT Recipe__c,Measurement__c,Measurement_Type__c,Name FROM Ingredient__c];
                System.AssertEquals(rec.Id,ing.Recipe__c,  'expected recipeID');
                System.AssertEquals(4, ing.Measurement__c,'expected 4');
                System.AssertEquals('Cups',ing.Measurement_Type__c, 'I expected Cups');
                System.AssertEquals( 'Wheat Flour', ing.Name,'expected wheat flour');
                System.debug('Recipe Id from ingredient: ' +ing.recipe__c);
            }
        //This test is to make sure the ingredient is added to the database with the recipe Id as parent only ONCE.    
        @isTest static void addIngredientOneTimeTest() {
               	Recipe__c rec = [SELECT Id from Recipe__c];
                Test.startTest();
                RecipeHelper.addIngredient('Wheat Flour', 4, 'Cups', rec.Id);
                Test.stopTest();
                List<Ingredient__c> ing = [SELECT Recipe__c,Measurement__c,Measurement_Type__c,Name FROM Ingredient__c];
				System.Assertequals(1,ing.size(),'expect only one recipe');
                    
                }

        
        
        
            @isTest static void groceryListTest() {
            //setup Data. lookup recipe ID and add 3 ingredients using addIngredient method   	
            Recipe__c rec = [SELECT Id from Recipe__c];
                RecipeHelper.addIngredient('Walnuts', 1, 'Cups', rec.Id);
            	RecipeHelper.addIngredient('Milk', 4, 'Tbl', rec.Id);
            	RecipeHelper.addIngredient('Oil', 1, 'Tbl', rec.Id);
            //add the ingredients to a list for comparison    
            List <String> ingreds = new List <String> ();
            	ingreds.add('Walnuts');
            	ingreds.add('Milk');
            	ingreds.add('Oil');
            	
			Test.startTest();
            //This returns a list of the ingredients because the method returns a list.	
            List<String> groceryList = RecipeHelper.generateGroceryList(rec.id); 
            Test.stopTest();	
            System.AssertEquals(ingreds, groceryList,'expected walnut, milk, oil');

            }
        
    @isTest static void scaleRecipeForServingsTest() {
            //setup Data. lookup recipe ID and add 3 ingredients using addIngredient method   	
            Recipe__c rec = [SELECT Id from Recipe__c];
                RecipeHelper.addIngredient('Walnuts', 1, 'Cups', rec.Id);
            	RecipeHelper.addIngredient('Milk', 4, 'Tbl', rec.Id);
            	RecipeHelper.addIngredient('Oil', 1, 'Tbl', rec.Id);
                
         		//Boolean booboo=false;
             	//List<String> newRatios = new List <String> ();
				
        		Test.startTest();
            	RecipeHelper.scaleRecipeForServings(rec.id,8);
            	Test.stopTest();
        		
            }
@isTest static void scaleRecipeForServingsNegativeTest() {
            //setup Data. lookup recipe ID and add 3 ingredients using addIngredient method   	
            Recipe__c rec = [SELECT Id from Recipe__c];
                RecipeHelper.addIngredient('Walnuts', 1, 'Cups', rec.Id);
            	RecipeHelper.addIngredient('Milk', 4, 'Tbl', rec.Id);
            	RecipeHelper.addIngredient('Oil', 1, 'Tbl', rec.Id);
                
         		Boolean bools=false;
             	
    		Test.startTest();

        try {
            RecipeHelper.scaleRecipeForServings(rec.id,0);
        } catch (Exception e) {
            if(e.getMessage().equalsIgnoreCase('ERROR: desired servings is 0 or negative')) {
                bools = true;
            }
        }
        
        Test.stopTest();
        // This test doesn't work. The error shows up in debug but the try catch doesn't catch it. bools stays false
            System.assertEquals(true,bools, 'Expected error because desired servings is 0 or less.');
    	}	
}

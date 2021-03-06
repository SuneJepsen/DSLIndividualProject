/*
 * generated by Xtext 2.13.0
 */
package com.metagamedsl.individual.validation

import com.metagamedsl.individual.metaGameLanguage.Object
import org.eclipse.xtext.validation.Check
import com.metagamedsl.individual.metaGameLanguage.MetaGameLanguagePackage
import com.metagamedsl.individual.metaGameLanguage.Game
import com.metagamedsl.individual.metaGameLanguage.Declaration
import com.metagamedsl.individual.metaGameLanguage.Location
import com.metagamedsl.individual.metaGameLanguage.Property
import java.util.ArrayList
import java.util.List
import com.metagamedsl.individual.metaGameLanguage.BoolExp
import com.metagamedsl.individual.metaGameLanguage.NumberExp
import com.metagamedsl.individual.metaGameLanguage.Proposition
import com.metagamedsl.individual.metaGameLanguage.And
import com.metagamedsl.individual.metaGameLanguage.Or
import com.metagamedsl.individual.metaGameLanguage.Comparison
import com.metagamedsl.individual.metaGameLanguage.Expression
import com.metagamedsl.individual.metaGameLanguage.Add
import com.metagamedsl.individual.metaGameLanguage.Sub
import com.metagamedsl.individual.metaGameLanguage.Mult
import com.metagamedsl.individual.metaGameLanguage.Div
import com.metagamedsl.individual.metaGameLanguage.Parenthesis
import com.metagamedsl.individual.metaGameLanguage.LocalVariable
import com.metagamedsl.individual.metaGameLanguage.Variable
import java.util.regex.Pattern
import java.util.Map
import java.util.LinkedList
import java.util.HashMap
import com.metagamedsl.individual.metaGameLanguage.ObjectDeclaration
import com.metagamedsl.individual.metaGameLanguage.LocationDeclaration

/**
 * This class contains custom validation rules. 
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class MetaGameLanguageValidator extends AbstractMetaGameLanguageValidator {


	 
 	/*
	 * number test = Agent1.path   
	 * 
	 * Validate on global properties
	 * Agent1 should exist
	 * 
	 * Method: validateObjectLocationName
	 * 
	 *
 	 *
	 * number test = Agent1.path   
	 * 
	 * Validate on global properties
	 * "path" property should then exist on Agent1 else fail
	 * 
	 * Method: validateObjectLocationProperty
	 * 
	 */
	@Check
	def validateGameFieldObjectLocationNameProperty(Game game) {
		// Loop all game properties
		for (Property property : game.fields) {
			// Get property variables e.g Agent1.score, Agent2.score
			property.validateObjectLocationProperty(game, "validateGameFieldObjectProperty")
			property.validateObjectLocationName(game, "validateGameFieldObjectProperty")
		}
	}


	/*
	 * Game Labyrint   
	 *	
	 *	number maxPathLength = 11
	 *	number maxPathLength = 11
	 *	number maxPathLength = 11
	 * 
	 * Fields names should be unique 
	 */
	@Check
	def validateDuplicateGameField(Game game) {
	
	}

	/*
	 * Object Agent1 (0,0) Agent2(1,0)   
	 *     truth value isAgent = true     
	 *   	number path = 0  
	 * Object Agent3 (0,0)   
	 *     truth value isAgent = true    
	 *   	number path = Agent1.score
	 * 
	 * Validate on locale object properties
	 * Agent1.score , score should exist on Agent1 properties 
	 * 
	 * Method: validateObjectLocationProperty 
	 * 
	 *
 	 *
	 * Object Agent1 (0,0) Agent2(1,0)   
	 *     truth value isAgent = true     
	 *   	number path = Agent1111.path 
	 * Object Agent3 (0,0)   
	 *     truth value isAgent = true    
	 *   	number path = Agent1.score
	 * 
	 * Validate on locale object names
	 * Agent1111.path, if Agent1111 do not exist, throw error
	 * 
	 * Method: validateObjectLocationName
	 * 
	 */
	@Check
	def validateObjectLocationNameProperty(Game game) {
		// Loop all game properties
		for (Declaration declaration : game.declarations) {			
			for (Property property : declaration.properties) {
				property.validateObjectLocationProperty(game, "validateObjectLocationProperty")
				property.validateObjectLocationName(game, "validateObjectLocationName")
			}
		}
	}
	

	
	/*
	 * E.g.: Object Agent1 (0,0) Agent1(1,0)   
	 * 	    truth value isAgent = true    
	 * 	  	number path = 0
	 * 
	 * 	Object names should be unique
	 * 
	 *
 	 *
	 * Object Agent1 (0,0) Agent2(1,0)   
	 *     truth value isAgent = true  
	 *     truth value isAgent = true    
	 *   	number path = 0
	 * 
	 * Two properties with same name should not be allowed
	 */
	@Check
	def validateDuplicateObjectLocationNameProperty(Game game) {
		var List<String> seenObjectList = new ArrayList()
		var List<String> seenLocationList = new ArrayList()
		for (Declaration declaration : game.getDeclarations) {
			declaration.validateProperty			
			switch declaration {
				Object: {
					for (ObjectDeclaration objectDeclaration : declaration.declarations) {
						if (seenObjectList.contains(objectDeclaration.name)) {
							error("Object " + objectDeclaration.name + " is a duplicate ", objectDeclaration,
								MetaGameLanguagePackage.Literals.OBJECT_DECLARATION__NAME);
						} else {
							seenObjectList.add(objectDeclaration.name)
						}
					}
				}
				Location: {
					for (LocationDeclaration locationDeclaration: declaration.declarations) {
						if (seenLocationList.contains(locationDeclaration.name)) {
							error("Location " + locationDeclaration.name + " is a duplicate ", locationDeclaration,
								MetaGameLanguagePackage.Literals.LOCATION_DECLARATION__NAME);
						} else {
							seenLocationList.add(locationDeclaration.name)
						}
					}
				}
			}
		}
	}

	/*
	 * Steps in the procedure:
	 * Check if the child is a LocalVariable or a Variable
	 * If LocalVariable -> Get all expression for that child
	 * 	Loop through all of the expression for that child
	 * 	Check if each of the expressions is a LocalVariable or a Variable
	 *  If LocaleVariable -> If seen "before" then throw error 
	 * 				  -> If not add to seen list and do call itself (child=expression, parent=child)
	 *  If Variable -> If seen "before" then throw error 
	 * 				-> If not add to seen list and do call itself (child=expression, parent=child)
	 * 
	 * 
	 * If Variable -> Get all expression for that child
	 * 	Loop through all of the expression for that child
	 * 	Check if each of the expressions is a LocalVariable or a Variable
	 * If LocaleVariable -> If seen "before" then throw error 
	 * 				  -> If not add to seen list and do call itself (child=expression, parent=child)
	 *  If Variable -> If seen "before" then throw error 
	 * 				-> If not add to seen list and do call itself (child=expression, parent=child)
	 *

	 *
	 * System.out.println(localVariable.var_local);	// Agent1			
	 * System.out.println(localVariable.var_prop.name); // path
	 * variable.var_prop.name // test
	 * 
	 * Loop through each entry, foreach entry (test,test2) check if has dependency to test
	 * If yes -> circular dependency
	 * 
	 * Global properties:
	 * test [test2, test3] 
	 * test2 []
	 * test3 [test]
	 * 
	 * Local properties 
	 * 
	 */
	private Map<String, List<Expression>> graph = new HashMap()

	@Check
	def validateCircularReferences(Game game) {
		// Clear graph
		graph = new HashMap()
		
		// Create graph of of all game field properties
		for (Property property : game.fields) {
			var parentName = getPropertyName(property)
			addNode(parentName)

			// Get property variables e.g test2, test3, test
			/**
			 * Game Validate    
			 * 	number test = test2 + test3  
			 * 	number test2 = 1
			 * 	number test3 = test
			 * 
			 */
			// add edge between parent properties
			for (Expression expression : property.getVariables) {
				addEdge(parentName, expression)
			}
		}

		// Add object and location properties to graph
		for (Declaration declaration : game.declarations) {		
			switch declaration {
				Object: declaration.buildObjectLocationGraph
				Location: declaration.buildObjectLocationGraph
				default: throw new Error("Invalid expression in method checkCircularReferencesOnFields")
			}
		}

		var List<String> seen = new ArrayList();
		// Validate graph
		for (Map.Entry<String, List<Expression>> entry : graph.entrySet()) {
			var children = ""
			for (Expression child : entry.getValue()) {
				
				// Only for debugging purpose
				if (child instanceof LocalVariable) { // local variable e.g. Agent1.score
					var localVariable = child as LocalVariable
					children += localVariable.var_local + "." + localVariable.var_prop.name + ", "
				} else {
					var variable = child as Variable
					children += variable.var_prop.name + ", "
				}
	
				seen.add(entry.key)	    	
				validate(child, entry.key, seen)
				seen = new ArrayList() 
				errorThrownOnThisEpression = new ArrayList();
			}
		 //System.out.println(entry.key +": "+ children);
		} 
	}


	// List which is needed to keep track of which elements errors already has been thrown
	// List should avoid to that multiple errors are thrown on same elements
	// Agent1.path : Agent3.path
	// Agent2.path : Agent3.path
	// Agent3.path : Agent2.path
	private List<String> errorThrownOnThisEpression = new ArrayList()

	def boolean validate(Expression child, String parent, List<String> seen) {	
		
		// Only for debugging purpose 
		var seenString = ""
		for (String se : seen) {
			seenString += se + ", "
		}
		// System.out.println("Seen list contains: " + seenString)
		switch child {
			LocalVariable: {
				// local variable e.g. Agent1.score					
				var key = child.var_local + "." + child.var_prop.name // E.g Agent1.score
				if (graph.containsKey(key)) {
					// Get child dependencies
					var children = graph.get(key); // Agent3.path				
					var returnValue = validateExpression(key, children, parent, seen)
					if (returnValue) {
						return true
					}
				}
			}
			Variable: {
				// global variable	
				if (graph.containsKey(child.var_prop.name)) {
					// Get childs dependencies
					var children = graph.get(child.var_prop.name);
					
					if (children.size == 0) {
						return true
					}
					var returnValue = validateExpression(child.var_prop.name, children, parent, seen)
					if (returnValue) {
						return true
					}
				}
			}
			default: throw new Error("Invalid expression in method validate")
		}
		return true
	}

	/*****************************Dispatch methods**********************************/
	def dispatch void validateProperty(Object object) {
		var List<String> propertyList = new ArrayList();
		for (Property property : object.properties) {
			property.validatePropertyName(propertyList, "object")
		}
	}

	def dispatch void validateProperty(Location location) {
		var List<String> propertyList = new ArrayList();
		for (Property property : location.properties) {
			property.validatePropertyName(propertyList, "location")
		}
	}

	def dispatch void validateFieldProperty(Object object, LocalVariable localVariable) {
		var objectName = localVariable.var_local // Agent1
		var propertyName = localVariable.var_prop.name // isAgent	
		
		if(propertyName == null){
			error("Property do not exist on object " + objectName, localVariable,
						MetaGameLanguagePackage.eINSTANCE.localVariable_Var_prop);
		}else{
			// Loop over all object names on object
			var matchPropertyName = false
			for (ObjectDeclaration objectDeclaration : object.declarations) {
				// Check if there is a match
				if (objectDeclaration.name == objectName) {
					for (Property property : object.properties) {
						if (property.name == propertyName) {
							matchPropertyName = true
						}
					}
					if (!matchPropertyName) {
						error("Property do not exist on object " + objectName, localVariable, MetaGameLanguagePackage.eINSTANCE.localVariable_Var_prop);
					}
				}
			}
		}
	}

	def dispatch void validateFieldProperty(Location location, LocalVariable localVariable) {
		var locationName = localVariable.var_local // Agent1
		var propertyName = localVariable.var_prop.name // isAgent	
		
		if(propertyName == null){
			error("Property do not exist on location " + locationName, localVariable, MetaGameLanguagePackage.eINSTANCE.localVariable_Var_prop);
		}else{
			// Loop over all object names on object
			var matchPropertyName = false
			for (LocationDeclaration locationDeclaration: location.declarations) {
				// Check if there is a match
				if (locationDeclaration.name == locationName) {
					for (Property property : location.properties) {
						if (property.name == propertyName) {
							matchPropertyName = true
						}
					}
					if (!matchPropertyName) {
						error("Property do not exist on location " + locationName, localVariable, MetaGameLanguagePackage.eINSTANCE.localVariable_Var_prop);
					}
				}
			}
		}	
	}

	def dispatch boolean validateFieldObjectLocation(Object object, LocalVariable localVariable) {
		var objectName = localVariable.var_local // Agent1	
		// Loop over all object names on object
		var matchObjectName = false
		for (ObjectDeclaration objectDeclaration : object.declarations) {
			// Check if there is a match
			if (objectDeclaration.name == objectName) {
				matchObjectName = true
			}
		}
		matchObjectName
	}

	def dispatch boolean validateFieldObjectLocation(Location location, LocalVariable localVariable) {
		var locationName = localVariable.var_local // Agent1	
		// Loop over all object names on object
		var matchLocationName = false
		for (LocationDeclaration locationDeclaration : location.declarations) {
			// Check if there is a match
			if (locationDeclaration.name == locationName) {				
				matchLocationName = true
			}
		}
		matchLocationName
	}

	def dispatch buildObjectLocationGraph(Object object) {
		for (Property property : object.properties) { 
			var vars = property.getVariables
			var propertyName = getPropertyName(property)

			// Add all parents
			for (ObjectDeclaration objectDeclaration : object.declarations) {
				addNode(objectDeclaration.name + "." + propertyName) 
			}

			// Foreach property, loop through its expression add edge on each expression on all object declarations					
			for (Expression expression : vars) {
				switch expression {
					LocalVariable: {
						for (ObjectDeclaration od : object.declarations) { // Because of the grammar we need to run to all object declarations and add edge between the same expression
							addEdge(od.name + "." + propertyName, expression)
						// System.out.println("(1)Add childs to each parent: " + od.name+"."+propertyName + " Child:" + localVariable.var_local +"."+ localVariable.var_prop.name); 
						}
					}
					Variable: {
						for (ObjectDeclaration od : object.declarations) {
							addEdge(od.name + "." + propertyName, expression)
						// System.out.println("(2)Add childs to each parent: " + od.name+"."+propertyName + " Child:" + variable.var_prop.name); 
						}
					}
					default: throw new Error("Invalid expression in method checkCircularReferencesOnFields")
				}
			}
		}
	}

	def dispatch buildObjectLocationGraph(Location location) {
		// Validate Location properties						
		for (Property property : location.properties) {
			var vars = property.getVariables

			var propertyName = getPropertyName(property)

			// Add all parents
			for (LocationDeclaration locationDeclaration : location.declarations) {
				addNode(locationDeclaration.name + "." + propertyName)
			}

			// Foreach property, loop through its expression add edge on each expression on all location declarations					
			for (Expression expression : vars) { // Start for # 3 
				switch expression {
					LocalVariable: {
						for (LocationDeclaration ld : location.declarations) { // Because of the grammar we need to run to all object declarations and add edge between the same expression
							addEdge(ld.name + "." + propertyName, expression)
						// System.out.println("(1)Add childs to each parent: " + od.name+"."+propertyName + " Child:" + localVariable.var_local +"."+ localVariable.var_prop.name); 
						}
					}
					Variable: {
						for (LocationDeclaration ld : location.declarations) {
							addEdge(ld.name + "." + propertyName, expression)
						// System.out.println("(2)Add childs to each parent: " + od.name+"."+propertyName + " Child:" + variable.var_prop.name); 
						}
					}
					default: throw new Error("Invalid expression in method checkCircularReferencesOnFields")
				}
			}
		}
	}
	/*****************************Helper methods**********************************/
	// Helper method for: validateObjectProperty, validateGameFieldObjectProperty
	def validateObjectLocationProperty(Property property, Game game, String errorMessage) {
		var vars = property.getVariables
		for (Expression expression : vars) {
			switch expression {
				LocalVariable: {
					// Do a look to see if the property exist on object
					for (Declaration declaration : game.getDeclarations) {				
						declaration.validateFieldProperty(expression)
					}
				}
				Variable: {}
				default: throw new Error("Invalid expression in method " + errorMessage)
			}
		}
	}
	
	// Helper method for: validateGameFieldObjectLocationName
	def validateObjectLocationName(Property property, Game game, String errorMessage) {
		var vars = property.getVariables
		for (Expression expression : vars) {
			switch expression {
				LocalVariable: {					
					// Do a look to see if the Object name exist on object
					var matchObjectName = false
					for (Declaration declaration : game.getDeclarations) {
						if (declaration.validateFieldObjectLocation(expression)) {
							matchObjectName = true
						}
					}
					if (!matchObjectName) {						
						error(expression.var_local +" do not exist", expression, MetaGameLanguagePackage.eINSTANCE.localVariable_Var_local);
					}
				}
				Variable: {}
				default: throw new Error("Invalid expression in method " + errorMessage)
			}
		}
	}

	// Helper method for: validateProperty
	def validatePropertyName(Property property, List<String> propertyList, String errorMessage) {
		switch property {
			BoolExp: {
				if (propertyList.contains(property.name)) {
					error("Property " + property.name + " already exist on " + errorMessage, property, MetaGameLanguagePackage.Literals.PROPERTY__NAME);
				} else {
					propertyList.add(property.name);
				}
			}
			NumberExp: {
				if (propertyList.contains(property.name)) {
					error("Property " + property.name + " already exist on " + errorMessage, property, MetaGameLanguagePackage.Literals.PROPERTY__NAME);
				} else {
					propertyList.add(property.name);
				}
			}
			default: throw new Error("Invalid expression in method validateProperty (" + errorMessage + ")")
		}
	}

	// Helper method for: validate(Expression child, String parent, List<String> seen) 
	def Boolean validateExpression(String key, List<Expression> children, String parent, List<String> seen) {
		// Loop over each expression to check if there are name duplicate
		for (Expression expression : children) {
			switch expression {
				LocalVariable: {
					var localVariableKey = expression.var_local + "." + expression.var_prop.name // Agent2.path
					if (seen.contains(localVariableKey)) {
						if (!errorThrownOnThisEpression.contains(localVariableKey)) {
							 System.out.println("1: validation failed " +localVariableKey )
							error("1: Circular reference on property " + parent, expression, MetaGameLanguagePackage.Literals.LOCAL_VARIABLE__VAR_PROP);
							return false
						} else {
							errorThrownOnThisEpression.add(localVariableKey)
						}

					} else {
						// System.out.println("Add to seen list: " + localVariableKey)
						seen.add(localVariableKey)
						if (!validate(expression, key, seen)) {
							 System.out.println("2: validation failed " +localVariableKey )
							if (!errorThrownOnThisEpression.contains(localVariableKey)) {
								return false
							} else {
								errorThrownOnThisEpression.add(localVariableKey)
							}
						}
					}
				}
				Variable: {
					if (seen.contains(expression.var_prop.name)) {
						// System.out.println("Circular reference on " + parent); 	
						error("Circular reference on " + parent, expression, MetaGameLanguagePackage.Literals.VARIABLE__VAR_PROP);
						return false
					} else {
						seen.add(expression.var_prop.name)
						if (!validate(expression, key, seen)) {
							error("Circular reference on " + parent, expression, MetaGameLanguagePackage.Literals.VARIABLE__VAR_PROP);
						}
					}
				}
				default: throw new Error("Invalid expression in method validate(Expression child, String parent, List<String> seen)")
			}
		} // End for					  
		return true
	}

	def String getPropertyName(Property property) {
		switch property {
			BoolExp: return property.name
			NumberExp: return property.name
			default: throw new Error("Invalid expression")
		}
	}

	// Math helper methods
	def List<Expression> getVariables(Property p) {
		switch p {
			BoolExp: p.bool_exp.getBoolVars
			NumberExp: p.math_exp.getMathVars
			default: throw new Error("Invalid expression")
		}
	}

	def List<Expression> getBoolVars(Proposition p) {
		var list = new ArrayList<Expression>()
		switch p {
			And: {
				list.addAll(p.left.getBoolVars)
				list.addAll(p.right.getBoolVars)
			}
			Or: {
				list.addAll(p.left.getBoolVars)
				list.addAll(p.right.getBoolVars)
			}
			Comparison: {
				list.addAll(p.left.getMathVars)
				list.addAll(p.right.getMathVars)
			}
		}
		list
	}

	def List<Expression> getMathVars(Expression e) {
		var list = new ArrayList<Expression>()
		switch e {
			Add: {
				list.addAll(e.left.getMathVars)
				list.addAll(e.right.getMathVars)
			}
			Sub: {
				list.addAll(e.left.getMathVars)
				list.addAll(e.right.getMathVars)
			}
			Mult: {
				list.addAll(e.left.getMathVars)
				list.addAll(e.right.getMathVars)
			}
			Div: {
				list.addAll(e.left.getMathVars)
				list.addAll(e.right.getMathVars)
			}
			Parenthesis:
				list.addAll(e.exp.getMathVars)
			LocalVariable:
				list.add(e)
			Variable:
				list.add(e) 
		}
		list
	}

	// Graph methods
	def void addNode(String name) {
		var List<Expression> list = new LinkedList<Expression>();
		graph.put(name, list);
	}

	def void addEdge(String parent, Expression child) throws Exception {
		var List<Expression> list;
		if (!graph.containsKey(parent)) {
			list = new LinkedList<Expression>();
		} else {
			list = graph.get(parent);
		}
		list.add(child);
		graph.put(parent, list);
	}
}

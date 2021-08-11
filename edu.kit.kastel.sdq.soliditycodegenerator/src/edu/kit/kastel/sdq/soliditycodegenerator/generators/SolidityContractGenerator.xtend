package edu.kit.kastel.sdq.soliditycodegenerator.generators


import org.eclipse.xtend.lib.annotations.Accessors
import static extension edu.kit.kastel.sdq.soliditycodegenerator.util.SolidityNaming.*;
import static extension edu.kit.kastel.sdq.soliditycodegenerator.util.SolidityConstants.*;
import edu.kit.kastel.sdq.soliditycodegenerator.generators.templates.SolidityClassGenerationTemplate
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Contract
import edu.kit.kastel.sdq.soliditymetamodel.rbac.AccessControlRepository
import edu.kit.kastel.sdq.soliditycodegenerator.generators.accesscontrol.ModifierAndContractGenerator
import edu.kit.kastel.sdq.soliditycodegenerator.generators.accesscontrol.AccessControlGenerator
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Function
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Struct
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Event
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Type
import edu.kit.kastel.sdq.soliditymetamodel.soliditysystem.SystemAssembly
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Modifier
import edu.kit.kastel.sdq.soliditymetamodel.rbac.Role
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.ContractType

class SolidityContractGenerator extends SolidityClassGenerationTemplate {
	
	@Accessors(PRIVATE_GETTER) Contract currentTarget;
	@Accessors(PRIVATE_GETTER) SystemAssembly system;
	@Accessors(PRIVATE_GETTER) AccessControlRepository acRepository;
	@Accessors(PRIVATE_GETTER) SolidityHeadAndImportsGenerator headAndImportsGenerator;
	@Accessors(PRIVATE_GETTER) ModifierAndContractGenerator acGenerator;
	@Accessors(PRIVATE_GETTER) SolidityFunctionGenerator functionGenerator;	
	@Accessors(PRIVATE_GETTER) SolidityOverrideGenerator overrideGenerator;
	
	new(SystemAssembly system, AccessControlRepository acRepository){
		this.system = system;
		this.acRepository = acRepository;
		this.headAndImportsGenerator = new SolidityHeadAndImportsGenerator(system, acRepository);
		this.acGenerator = new ModifierAndContractGenerator(acRepository);
		this.functionGenerator = new SolidityFunctionGenerator(acGenerator);
		this.overrideGenerator = new SolidityOverrideGenerator();		

		
	}
	
	override protected generatePragma() {
		return headAndImportsGenerator.generatePragma;
	}
	
	override protected generateModifiers() {
		acGenerator.currentTarget = currentTarget;
		val acModifiers = acGenerator.generatePreconditionModifierDefinitions();
		val modifiers = '''«FOR modifier : currentTarget.modifiers SEPARATOR newLine»«generateModifierDefinition(modifier)»«ENDFOR»''' 
		return '''«acModifiers»«newLine»«modifiers»'''
	}
	
	private def String generateModifierDefinition(Modifier modifier) {
		val virtual = modifier.virtual ? "virtual " : ""
		val overrides = overrideGenerator.generate(modifier)
		val modifierHead = '''modifier «modifier.getModifierName»(«generateModifierParametersDefinition(modifier)») «virtual»«overrides»'''
		return '''«modifierHead.normalizeSpaces»{
	_; //TODO: Auto-generated Modifier
}'''
	}
	
	private def String generateModifierParametersDefinition(Modifier modifier) {
		return '''«FOR param : modifier.parameters SEPARATOR ", "»«getTargetNameForType(param.type, true)» «param.name»«ENDFOR»'''
	}
	
	override protected generatePackage() {
		return "";
	}
	
	override protected generateImports() {
		return headAndImportsGenerator.generateImportStatements(currentTarget, getUsedContractTypes());
	}
	
	private def Iterable<ContractType> getUsedContractTypes() {
		return getAllUsedTypesForCurrentTarget().filter[type | type instanceof ContractType].map[x | x as ContractType]
	}
	
	override protected generateDeclaration() {
		return headAndImportsGenerator.generateContractDefinition(currentTarget); 
	}
	
	override protected generateConstructors() {
		val constructor = currentTarget.constructor
		if(constructor !== null) {
			return '''constructor(«FOR param : constructor.parameters SEPARATOR ", "»«getTargetNameForType(param.type, true)» «param.name»«ENDFOR») {
	//TODO: Auto-generated Constructor
}'''
		} 
		return ""
		
	}
	
	override protected generateFields() {
		val fields = #[generateFieldsFromSystemAssembly, generateFieldForAccessControl, generateFieldsForStateVariables]
		return String.join(newLine, fields)
	}


	private def String generateFieldsFromSystemAssembly(){
		val requiredContracts = headAndImportsGenerator.getCalledContractsFromSystemAssembly(currentTarget);
		var retText = "";

		if (requiredContracts !== null) {
			retText = '''«FOR requiredContract : requiredContracts SEPARATOR newLine»
			«requiredContract.entityName.toFirstUpper» «requiredContract.entityName.toFirstLower»; //TODO: Auto-generated Field«ENDFOR»'''
		}

		return retText;
	}	

	private def String generateFieldForAccessControl() {
		if (acRepository !== null && currentTarget.requiredFunctions.contains(acRepository.accessOperationDef.operation)) {	
			return '''«AccessControlGenerator.accessControlName» «AccessControlGenerator.accessControlName.toFirstLower»; //TODO: Auto-generated Field'''
		} else {
			return ""
		}
		
	}
	
	private def String generateFieldsForStateVariables(){		
		var result = ""
		for (variable : currentTarget.variables) {
			if(acRepository !== null) {
				val varAccessibleByRoles = acGenerator.getVariableAccessibleByRoles(variable)				
				if (!varAccessibleByRoles.empty) {
					val roles = varAccessibleByRoles.map[x | x.roles].flatten
					result += '''«generateRoleCommentForFields(roles)»
					'''		
				}
				
						
			}
			
			result += '''«getTargetNameForType(variable.type, false)» «getTargetNameForVariableVisibility(variable.visibility)» «getTargetNameForVariableMutability(variable.mutability)» «variable.entityName.toFirstLower»; //TODO: Auto-generated Field
			'''		
		}
		return result.normalizeSpaces
	
	}
	
	private def String generateRoleCommentForFields(Iterable<Role> accessibleRoles) {		
		var comment = "//Modifiable by: ";	
			
		if(accessibleRoles.empty){
			return comment + "Nothing"
		}
		
		return comment + '''«FOR role : accessibleRoles SEPARATOR', '»«role.entityName»«ENDFOR»''';
	}
	
	
	override protected generateMethods() {
		val functions = currentTarget.providedFunctions + currentTarget.localFunctions;		
		val methodDefinitions = generateMethodDefinitions(functions).toString;
		return methodDefinitions;
	}
	
	private def String generateMethodDefinitions(Iterable<Function> functions)'''
		«FOR function : functions»
			«executeMethodGeneration(function)»
			
		«ENDFOR»
	'''
	
	protected def String executeMethodGeneration(Function function){
		functionGenerator.currentTarget = function;
		return functionGenerator.generate;
	}
	
	
	override setCurrentTarget(Contract contract) {
		this.currentTarget = contract;
		acGenerator.currentTarget = contract;
		functionGenerator.currentContract = contract;
	}
	
	override protected generateEnums() {
		return '''«FOR en : getUsedEnumsForCurrentTarget SEPARATOR newLine»«generateEnumDefinition(en)»«ENDFOR»'''
	}
		
	private def String generateEnumDefinition(edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Enum en){
		return '''enum «en.entityName» {«FOR member : en.members BEFORE " " SEPARATOR ", " AFTER " "»«member.value»«ENDFOR»}'''
	}
	
	private def Iterable<edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Enum> getUsedEnumsForCurrentTarget() {
		val localEnums = currentTarget.localTypes.filter[type | type instanceof edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Enum]
		val usedGlobalEnums = getAllUsedTypesForCurrentTarget().filter[type | type instanceof edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Enum]
		return (localEnums + usedGlobalEnums).toSet().map[x | x as edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Enum]
	}
	
	override protected generateStructs() {
		return '''«FOR struct : getUsedStructsForCurrentTarget SEPARATOR newLine»«generateStructDefinition(struct)»«ENDFOR»'''
	}
	
	private def String generateStructDefinition(Struct struct) {		
		return '''
		struct «struct.entityName» {
			«FOR member : struct.members SEPARATOR newLine»«getTargetNameForType(member.type, false)» «member.entityName»;«ENDFOR»
		}
		'''
	}
	
	private def Iterable<Struct> getUsedStructsForCurrentTarget() {
		val localStructs = currentTarget.localTypes.filter[type | type instanceof Struct]
		val usedGlobalStructs = getAllUsedTypesForCurrentTarget().filter[type | type instanceof Struct]
		return (localStructs + usedGlobalStructs).toSet().map[x | x as Struct ]
	}
	
	override protected generateEvents() {
		return '''«FOR event : currentTarget.events SEPARATOR newLine»«generateEventDefinition(event)»«ENDFOR»'''
	}
	
	private def String generateEventDefinition(Event event) {
		val anonymous = event.anonymous ? " anonymous" : ""
		return '''event «event.entityName»(«FOR param : event.parameters SEPARATOR ", "»«getTargetNameForType(param.type, false)» «param.indexed ? "indexed " : ""»«param.name»«ENDFOR»)«anonymous»;'''
	}
		
		
	private def Iterable<Type> getAllUsedTypesForCurrentTarget() {
		val constructorParameterTypes = currentTarget.constructor?.parameters?.map[it.type] ?: #[]
		val stateVariableTypes = currentTarget.variables?.map[it.type] ?: #[]
		val modifierParameterTypes = currentTarget.modifiers?.map[it.parameters].flatten.map[it.type] ?: #[]
		val eventParameterTypes = currentTarget.events?.map[it.parameters].flatten.map[it.type] ?: #[]
		val localFunctionParameterTypes = currentTarget.localFunctions?.map[it.parameters].flatten.map[it.type] ?: #[]
		val localFunctionReturnTypes = currentTarget.localFunctions?.map[it.returnVariables].flatten.map[it.type] ?: #[]
		val globalFunctionParameterTypes = currentTarget.providedFunctions?.map[it.parameters].flatten.map[it.type] ?: #[]
		val globalFunctionReturnTypes = currentTarget.providedFunctions?.map[it.returnVariables].flatten.map[it.type] ?: #[]
 
		val allTypes = #[constructorParameterTypes, stateVariableTypes, modifierParameterTypes, eventParameterTypes, 
			localFunctionParameterTypes, localFunctionReturnTypes, globalFunctionParameterTypes, globalFunctionReturnTypes
		]
		
		return allTypes.flatten
	}
	
	

	
 
}

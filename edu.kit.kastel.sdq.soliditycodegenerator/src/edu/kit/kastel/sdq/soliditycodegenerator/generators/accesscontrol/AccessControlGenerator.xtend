package edu.kit.kastel.sdq.soliditycodegenerator.generators.accesscontrol

import static extension edu.kit.kastel.sdq.soliditycodegenerator.util.SolidityConstants.*;
import edu.kit.kastel.sdq.soliditycodegenerator.generators.templates.SolidityClassGenerationTemplate
import edu.kit.kastel.sdq.soliditymetamodel.rbac.AccessControlRepository
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Contract

class AccessControlGenerator extends SolidityClassGenerationTemplate {
	AccessControlRepository acRepository;
	boolean fullAcGeneration;
	
	public static final String accessControlName = '''AccessCtrl''';
	public static final String rolesEnumName = '''Roles''';
	public static final String accessCheckingFunctionName = '''checkAccess'''
	final String admin = '''admin''';
	final String roleMapping = '''mapping(address => bool)'''
	final String addressName = '''entity'''
	final String roleName = '''role'''
	final String standardCheckParameters = '''address «addressName», «rolesEnumName» «roleName»'''
	final String onlyAdmin = '''onlyAdmin'''

	new(AccessControlRepository acRepository, boolean fullAcGeneration) {
		this.acRepository = acRepository;
		this.fullAcGeneration = fullAcGeneration;
	}

	override protected generatePackage() {
		return "";
	}
	

	override protected generateImports() {
		return "";
	}

	override protected generateDeclaration() {
		return '''contract AccessCtrl'''
	}

	override protected generateConstructors() {
		return 
		'''constructor(«IF fullAcGeneration»address admin«ENDIF»){
	«IF fullAcGeneration»
	«admin.toLowerCase»s[admin] = true;
«ELSE» //TODO: Implement constructur
«ENDIF»}'''
	}

	override protected generateFields() {
		return '''«generateMappings»'''
	}
			
	private def generateMappings() {
		return '''
		«IF fullAcGeneration»
			«FOR role : acRepository.roles SEPARATOR "\n"»«roleMapping» «role.entityName.toLowerCase»s;«ENDFOR»
			«roleMapping» «admin.toLowerCase»s;
«ELSE»«""»
«ENDIF»'''
	}

	override protected generateMethods() {
		return '''
		«generateCheckAccess»
		
		«IF fullAcGeneration»
			«generateAddToRole»
			
			«generateRemoveFromRole»
		«ENDIF»
		'''
	}
	
	
	
	private def String generateCheckAccess() '''
		function «accessCheckingFunctionName»(«standardCheckParameters») public returns (bool) {
			«IF fullAcGeneration»
				«FOR role : acRepository.roles»
				«genericRoleCheckingBuilder(role.entityName, '''return «role.entityName.toLowerCase»s[«addressName»];''')»
			«ENDFOR»
				«genericRoleCheckingBuilder(admin, '''return «admin.toLowerCase»s[«addressName»];''')»
«ELSE» //TODO: Implement
«ENDIF»}
		'''
	
	//Not Nice but avoids some copy&pasting
	private def String genericRoleCheckingBuilder(String targetRoleName, String caseBody)'''
	if(«roleName» == «rolesEnumName».«targetRoleName.toUpperCase»){
		«caseBody»
	}
	'''
	
	private def String generateAddToRole()'''
		function addToRole(«standardCheckParameters») public «onlyAdmin» {
			«IF fullAcGeneration»
			«FOR role : acRepository.roles»
				«genericRoleCheckingBuilder(role.entityName, '''«role.entityName.toLowerCase»s[«addressName»] = true;''')»
			«ENDFOR»
			«genericRoleCheckingBuilder(admin, '''«admin.toLowerCase»s[«addressName»] = true;''')»
«ELSE» //TODO: Implement
«ENDIF»}
	'''
	
	private def String generateRemoveFromRole()'''
		function removeFromRole(«standardCheckParameters») public «onlyAdmin» {
			«IF fullAcGeneration»
			«FOR role : acRepository.roles»
				«genericRoleCheckingBuilder(role.entityName, '''«role.entityName.toLowerCase»s[«addressName»] = false;''')»
			«ENDFOR»
			«genericRoleCheckingBuilder(admin, '''«admin.toLowerCase»s[«addressName»] = false;''')»
«ELSE» //TODO: Implement
«ENDIF»}
	'''
	


	override protected generateModifiers() '''
	«IF fullAcGeneration»
	modifier «onlyAdmin» {
		require(«admin»s[msg.sender] == true, "Access denied");
		_;
	}
	«ELSE»«""»
	«ENDIF»
	
	'''
	
	override protected generatePragma() {
		return '''pragma solidity «solidityVersion»;''';
	}
	
	override setCurrentTarget(Contract contract) {
		return;
	}
	
	override protected generateEnums() {
		return '''«generateRoleEnum»'''
	}
	
	private def String generateRoleEnum() {
		return '''enum «rolesEnumName» {«generateEnumRoles()»}'''
	}

	private def String generateEnumRoles() {
			
		var standardRoles = '''«FOR role : acRepository.roles SEPARATOR ", "»«role.entityName.toUpperCase»«ENDFOR»'''
		
		return standardRoles + adminIfFullAccessControlGeneration();
	}
	
	private def String adminIfFullAccessControlGeneration(){
		return  if (fullAcGeneration) ''', «admin.toUpperCase»''' else "";
	}
	
	override protected generateStructs() {
		return ""
	}
	
	override protected generateEvents() {
		return ""
	}
	

	

	
}

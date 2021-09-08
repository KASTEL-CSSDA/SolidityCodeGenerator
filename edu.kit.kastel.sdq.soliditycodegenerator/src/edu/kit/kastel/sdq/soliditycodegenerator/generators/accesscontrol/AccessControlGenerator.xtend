package edu.kit.kastel.sdq.soliditycodegenerator.generators.accesscontrol

import edu.kit.kastel.sdq.soliditymetamodel.rbac.AccessControlRepository
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Contract
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.SolidityContractsFactory
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Constructor
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.PrimitiveTypeEnum
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.StateVariable
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.common.util.BasicEList
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Modifier
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.GlobalFunction
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.FunctionParameter
import java.util.Collection
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.EnumMember
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Mapping

class AccessControlGenerator {
	AccessControlRepository acRepository;
	boolean fullAcGeneration;
	SolidityContractsFactory factory = SolidityContractsFactory.eINSTANCE
	
	public static final String accessControlName = '''AccessCtrl''';
	public static final String rolesEnumName = '''Roles''';
	public static final String accessCheckingFunctionName = '''checkAccess'''
	
	final String admin = '''admin''';
	

	final String addressName = '''entity'''
	final String roleName = '''role'''
	final String onlyAdmin = '''onlyAdmin'''

	new(AccessControlRepository acRepository, boolean fullAcGeneration) {
		this.acRepository = acRepository;
		this.fullAcGeneration = fullAcGeneration;
	}
	
	
	def Contract generateAccessControlContract() {		
		var contract = factory.createContract()
		contract.entityName = accessControlName
		contract.constructor = generateConstructor()
		contract.variables.addAll(generateVariables())
		
		val roles = generateRoleEnum()
		contract.localTypes.add(roles)
		
		val onlyAdminModifier = generateOnlyAdminModifier()		
		contract.providedFunctions.addAll(generateFunctions(roles, onlyAdminModifier))
		contract.modifiers.add(onlyAdminModifier)

		return contract;
		
	}


	private def Constructor generateConstructor() {
		val constructor = factory.createConstructor()
		if(fullAcGeneration) {
			val parameter = factory.createConstructorParameter()
			val parameterType = factory.createPrimitiveType()
			parameterType.type = PrimitiveTypeEnum.ADDRESS
			parameter.name = "admin"
			parameter.type = parameterType
			constructor.parameters.add(parameter)
			constructor.content = '''«admin.toLowerCase»s[admin] = true;'''			
		}

		
		return constructor

	}
	
	
	private def Collection<StateVariable> generateVariables() {
		val variables = newArrayList()
		
		if (fullAcGeneration) {
			val roleNames = newArrayList(admin)
			roleNames.addAll(acRepository.roles.map[it.entityName])
			val mapping = createAddressBoolMapping()				
			
			for(role : roleNames) {
				val variable = factory.createStateVariable()
				variable.entityName = role.toLowerCase + "s"		
				variable.type = mapping
				variables.add(variable)
			}
		}
		return variables		
	}
	
	private def Mapping createAddressBoolMapping() {
		val boolType = factory.createPrimitiveType()
		boolType.type = PrimitiveTypeEnum.BOOL
		val addressType = factory.createPrimitiveType()
		addressType.type = PrimitiveTypeEnum.ADDRESS
		val mapping = factory.createMapping()
		mapping.keyType = addressType
		mapping.valueType = boolType
		return mapping	
	}
	
	private def EList<GlobalFunction> generateFunctions(edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Enum roles, Modifier onlyAdminModifier) {
		val methods = new BasicEList<GlobalFunction>();
		methods.add(generateCheckAccess(roles))
		if(fullAcGeneration) {
			methods.add(generateAddToRole(roles, onlyAdminModifier))
			methods.add(generateRemoveFromRole(roles, onlyAdminModifier))
		}
		return methods
	}	


	
	private def GlobalFunction generateCheckAccess(edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Enum roles) {
		val function = factory.createGlobalFunction()
		function.entityName = accessCheckingFunctionName
		
		val returnType = factory.createPrimitiveType()
		returnType.type = PrimitiveTypeEnum.BOOL
		
		val returnVariable = factory.createReturnVariable()
		returnVariable.type = returnType		
		
		function.returnVariables.add(returnVariable)	
		function.parameters.addAll(generateCheckParameters(roles))
		function.content = generateCheckAccessBody()
		
		return function

	}
	
	private def Collection<FunctionParameter> generateCheckParameters(edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Enum roles) {
		val addressType = factory.createPrimitiveType()
		addressType.type = PrimitiveTypeEnum.ADDRESS
		val parameterAddr = factory.createFunctionParameter()
		
		parameterAddr.name = addressName
		parameterAddr.type = addressType
		
		val parameterRole = factory.createFunctionParameter()
		parameterRole.name = roleName
		parameterRole.type = roles
		return #[parameterAddr, parameterRole]
	}
	
	private def String generateCheckAccessBody() {
		var content = ""
		if(fullAcGeneration) {
			content += '''«FOR role : acRepository.roles»
			«genericRoleCheckingBuilder(role.entityName, '''return «role.entityName.toLowerCase»s[«addressName»];''')»
			«ENDFOR»
«genericRoleCheckingBuilder(admin, '''return «admin.toLowerCase»s[«addressName»];''')»'''
			
		} else {
			content = "//TODO: Implement"
		}
		return content
	}
		
	//Not Nice but avoids some copy&pasting
	private def String genericRoleCheckingBuilder(String targetRoleName, String caseBody)'''
	if(«roleName» == «rolesEnumName».«targetRoleName.toUpperCase»){
		«caseBody»
	}
	'''
	
	private def GlobalFunction generateAddToRole(edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Enum roles, Modifier onlyAdmin) {
		val function = factory.createGlobalFunction()
		function.entityName = "addToRole"
		function.parameters.addAll(generateCheckParameters(roles))
		function.modifiers.add(onlyAdmin)
		function.content = generateAddToRoleBody()

		return function

	}
	
	private def String generateAddToRoleBody() {
		return '''«IF fullAcGeneration»
			«FOR role : acRepository.roles»
				«genericRoleCheckingBuilder(role.entityName, '''«role.entityName.toLowerCase»s[«addressName»] = true;''')»
			«ENDFOR»
			«genericRoleCheckingBuilder(admin, '''«admin.toLowerCase»s[«addressName»] = true;''')»
«ELSE» //TODO: Implement
«ENDIF»'''
	}
	
	private def GlobalFunction generateRemoveFromRole(edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Enum roles, Modifier onlyAdmin) {
		val function = factory.createGlobalFunction()
		function.entityName = "removeFromRole"	
		function.parameters.addAll(generateCheckParameters(roles))
		function.modifiers.add(onlyAdmin)
		function.content = generateRemoveFromRoleBody()

		return function

	}

	
	private def String generateRemoveFromRoleBody()'''		
			«IF fullAcGeneration»
			«FOR role : acRepository.roles»
				«genericRoleCheckingBuilder(role.entityName, '''«role.entityName.toLowerCase»s[«addressName»] = false;''')»
			«ENDFOR»
			«genericRoleCheckingBuilder(admin, '''«admin.toLowerCase»s[«addressName»] = false;''')»
«ELSE» //TODO: Implement
«ENDIF»
	'''
	

	private def Modifier generateOnlyAdminModifier() {
		val modifier = factory.createModifier()
		modifier.entityName = onlyAdmin
		modifier.content = '''require(«admin»s[msg.sender] == true, "Access denied");
_;'''
		return modifier
	}
		
	private def edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Enum generateRoleEnum() {
		val roles = factory.createEnum()
		roles.entityName = rolesEnumName
		roles.members.addAll(generateRoleEnumMembers())
		
		
		return roles
	}	
	
	private def Collection<EnumMember> generateRoleEnumMembers() {
		val enumMembers = newArrayList()
		val roles = newArrayList()
		roles.addAll(acRepository.roles.map[x|x.entityName])
		
		if (fullAcGeneration) {
			roles.add(admin)
		}
		
		for (role : roles) {
			val member = factory.createEnumMember()
			member.value = role.toUpperCase
			enumMembers.add(member)
		}
		
		return enumMembers
	}
	
	
	
	


	


	

	
}

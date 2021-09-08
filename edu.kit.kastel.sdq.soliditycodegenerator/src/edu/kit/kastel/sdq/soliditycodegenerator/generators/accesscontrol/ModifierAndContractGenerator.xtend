package edu.kit.kastel.sdq.soliditycodegenerator.generators.accesscontrol


import java.util.Set
import java.util.Collection
import java.util.ArrayList
import java.util.HashSet
import static extension edu.kit.kastel.sdq.soliditycodegenerator.util.SolidityNaming.*;
import static extension edu.kit.kastel.sdq.soliditycodegenerator.util.SolidityConstants.*;
import org.eclipse.xtend.lib.annotations.Accessors
import edu.kit.kastel.sdq.soliditymetamodel.rbac.AccessControlRepository
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Contract
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.PrimitiveTypeEnum
import edu.kit.kastel.sdq.soliditymetamodel.rbac.OperationAccessibleByRoles
import edu.kit.kastel.sdq.soliditymetamodel.rbac.VariableAccessibleByRoles
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.PrimitiveType
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.CustomArray
import edu.kit.kastel.sdq.soliditymetamodel.rbac.Role
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Function
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.StateVariable

class ModifierAndContractGenerator {

	@Accessors(PUBLIC_SETTER) Contract currentTarget;
	@Accessors(PUBLIC_GETTER) AccessControlRepository acRepository;

	final String solcVerifyPostConditionPrelude = '''/// @notice postcondition'''
	final String solcVerifyOld = '''__verifier_old_'''

	new(AccessControlRepository acRepository) {
		this.currentTarget = currentTarget;
		this.acRepository = acRepository;
	}

	def String generatePreconditionModifierDefinitions() {		
		if(acRepository !== null) {
			val accessibleRolesForContract = filterAccessibleOperationsByRoleForContract(acRepository.accessibleOperationsByRole, currentTarget);
			return generatePreconditionModifierDefinitions(accessibleRolesForContract);	
		} else {
			return ""
		}
	}

	private def Collection<OperationAccessibleByRoles> filterAccessibleOperationsByRoleForContract(
		Collection<OperationAccessibleByRoles> accesibleOperationsByRoles, Contract contract) {
			
		return accesibleOperationsByRoles.filter [ x |
			contract.providedFunctions.exists( function | function.id == x.operation.id)			
		].toList;
	}

	private def String generatePreconditionModifierDefinitions(
		Collection<OperationAccessibleByRoles> accessibleOperationByRoles) {

		val necessaryPermutations = generateUsedPermutationsOfRolesForMethods(accessibleOperationByRoles);

		return '''«FOR roles : necessaryPermutations»«generatePreconditionModifierForRoles(roles)»«newLine»«ENDFOR»''';
	}

	private def Collection<Set<Role>> generateUsedPermutationsOfRolesForMethods(
		Collection<OperationAccessibleByRoles> accessibleOperationByRoles) {
		val necessaryPermutations = new ArrayList<Set<Role>>();

		for (element : accessibleOperationByRoles) {

			val necessaryRoles = new HashSet<Role>;
			
			for (role : element.roles) {
				necessaryRoles.add(role);
			}

			if (!isPermutation(necessaryPermutations, necessaryRoles)) {
				necessaryPermutations.add(necessaryRoles);
			}
		}

		return necessaryPermutations;
	}

	private def boolean isPermutation(Collection<Set<Role>> computedPermutations, Collection<Role> toCheck) {

		for (necessaryPermutation : computedPermutations) {
			var isPermutation = true;
			if (toCheck.size.equals(necessaryPermutation.size)) {
				for (roleToCheck : toCheck) {
					isPermutation = isPermutation && necessaryPermutation.contains(roleToCheck);
				}

				if (isPermutation) {
					return true;
				}
			}
		}

		return false;
	}

	private def String generatePreconditionModifierForRoles(Collection<Role> roles) {
		return assembleModifierForRoles(roles);
	}

	private def String assembleModifierForRoles(Collection<Role> roles) '''
		«createModifierHead(roles)» {
			«createModifierBody(roles)»
		}
	'''


	private def String createModifierHead(Collection<Role> roles) '''modifier «getModifierNameForRoles(roles)»'''

	private def String createModifierBody(Collection<Role> roles) {

		var requireQuery = '''«FOR role : roles SEPARATOR " || \n"»«buildAccessControlQuery(role)»«ENDFOR»'''

		return '''require(«requireQuery»,"Access denied");
_;'''
	}

	def String buildAccessControlQuery(Role role) {
		return '''«AccessControlGenerator.accessControlName.toFirstLower».«AccessControlGenerator.accessCheckingFunctionName»(msg.sender, «AccessControlGenerator.accessControlName.toFirstLower».«AccessControlGenerator.rolesEnumName».«role.entityName.toUpperCase»)''';
	}

	def String generateModifierUsageDefinitions(Function function) {
		val fittingAccessibleOperationsByRole = filterAccessibleOperationsForFunction(function);

		val necessaryRoles = new HashSet<Role>();

		for (element : fittingAccessibleOperationsByRole) {
			necessaryRoles.addAll(element.roles);
		}

		return '''«getModifierNameForRoles(necessaryRoles)»''';
	}

	private def Collection<OperationAccessibleByRoles> filterAccessibleOperationsForFunction(
		Function function) {
		var operationsForModifiersForContract = filterOperationsForModifiersForContract();
		var operationsForModifiersForFunction = new HashSet<OperationAccessibleByRoles>();
		for (element : operationsForModifiersForContract) {
			if (element.operation.id.equals(function.id)) {
				operationsForModifiersForFunction.add(element);
			}
		}

		return operationsForModifiersForFunction;
	}

	private def Collection<OperationAccessibleByRoles> filterOperationsForModifiersForContract() {
		val providedFunctionIdsOfContract =  currentTarget.providedFunctions.map[it.id]		
		if(acRepository !== null) {
			return acRepository.accessibleOperationsByRole.filter[x | providedFunctionIdsOfContract.contains(x.operation.id)].toList
		} else {
			return #[]
		}
		
	}

	private def String generateNotModificationProofObligation(Function function) {
		var varAccessibleByRoles = filterAccessibleVariablesForContract(currentTarget)
		var opAccessibleByRoles = filterAccessibleOperationsForFunction(function);
		var oldClauses = "";

		for (varAcc : varAccessibleByRoles) {
			if (!opAccessibleByRoles.empty) {
				for (opAccessible : opAccessibleByRoles) {
					if (!opAccessible.isSubsetOf(varAcc)) {
						oldClauses = String.format("%s%n%s", oldClauses,
							generateUnmodifyingProofObligationForStateVariable(varAcc.variable));
					}
				}
			} else {
				oldClauses = String.format("%s%n%s", oldClauses,
					generateUnmodifyingProofObligationForStateVariable(varAcc.variable));
			}
		}

		return oldClauses;
	}
	
	private def Iterable<VariableAccessibleByRoles> filterAccessibleVariablesForContract(Contract contract) {
		val contractVariableIds = contract.variables.map(x | x.id)
		if(acRepository !== null) {
			return acRepository.accessibleVariablesByRole.filter[ x | contractVariableIds.contains(x.variable.id)]
		} else {
			return #[]
		}
		
	}

	// TODO: Make this possible to configurate by Generator-Element usage (Common Interface)
	def String generateProofObligationsForOperation(Function operation) {		
		var proofObligationsForOperation = "";

		proofObligationsForOperation = generateNotModificationProofObligation(operation);

		return proofObligationsForOperation;
	}


	private def boolean isSubsetOf(OperationAccessibleByRoles op, VariableAccessibleByRoles variable) {
		for (role : op.roles) {
			if (!variable.roles.contains(role)) {
				return false;
			}
		}

		return true;
	}

	private def String generateUnmodifyingProofObligationForStateVariable(StateVariable stateVariable) {
		if (!(stateVariable.type instanceof CustomArray)) {
			generateUnmodifyingProofObligationForPrimitiveTypeStateVariable(stateVariable);
		} else {
			generateUnmodifyingProofObligationForCustomArrayStateVariable(stateVariable);
		}
	}

	private def String generateUnmodifyingProofObligationForPrimitiveTypeStateVariable(StateVariable stateVariable) {
		if (!(stateVariable.type instanceof CustomArray) &&
			stateVariable.type.checkForSolcComparisonCompatibility) {
			return '''«solcVerifyPostConditionPrelude» «stateVariable.entityName» == «solcVerifyOld»«getTargetNameForType(stateVariable.type, false)»(«stateVariable.entityName»)'''
		}

		return "";
	}

	private def String generateUnmodifyingProofObligationForCustomArrayStateVariable(
		StateVariable stateVariable) {

		if (stateVariable.type instanceof CustomArray &&
			stateVariable.type.checkForSolcComparisonCompatibility) {
			return '''«solcVerifyPostConditionPrelude» forall (uint i) (!( 0 <= i && i < «stateVariable.entityName».length) || «stateVariable.entityName»[i] == «solcVerifyOld»«getTargetNameForType(stateVariable.type, false)»(«stateVariable.entityName»[i]))'''
		}

		return "";

	}

	private dispatch def boolean checkForSolcComparisonCompatibility(PrimitiveType pt) {
		return pt.type.equals(PrimitiveTypeEnum.BOOL) || pt.type.equals(PrimitiveTypeEnum.INT) || pt.type.equals(PrimitiveTypeEnum.ADDRESS)
	}

	private dispatch def boolean checkForSolcComparisonCompatibility(CustomArray arr) {
		return checkForSolcComparisonCompatibility(arr.type);
	}
	
	def Iterable<VariableAccessibleByRoles> getVariableAccessibleByRoles(StateVariable variable) {
		if(acRepository !== null) {
			return acRepository.accessibleVariablesByRole.filter[x | x.variable.id == variable.id]
		} else {
			return #[]
		}
		
	}


}

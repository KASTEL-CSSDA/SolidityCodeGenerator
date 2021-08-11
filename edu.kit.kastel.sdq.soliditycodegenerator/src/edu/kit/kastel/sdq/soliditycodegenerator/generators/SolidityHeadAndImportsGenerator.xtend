package edu.kit.kastel.sdq.soliditycodegenerator.generators

import org.eclipse.xtend.lib.annotations.Accessors
import static extension edu.kit.kastel.sdq.soliditycodegenerator.util.SolidityConstants.*;
import static extension edu.kit.kastel.sdq.soliditycodegenerator.util.SolidityNaming.*;
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Contract
import edu.kit.kastel.sdq.soliditycodegenerator.generators.accesscontrol.AccessControlGenerator;
import edu.kit.kastel.sdq.soliditymetamodel.rbac.AccessControlRepository
import edu.kit.kastel.sdq.soliditymetamodel.soliditysystem.Instance
import edu.kit.kastel.sdq.soliditymetamodel.soliditysystem.ProvidedInterface
import edu.kit.kastel.sdq.soliditymetamodel.soliditysystem.RequiredInterface
import java.util.HashSet
import edu.kit.kastel.sdq.soliditymetamodel.soliditysystem.SystemAssembly
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.ContractType

class SolidityHeadAndImportsGenerator {
	@Accessors(#[PUBLIC_SETTER, PROTECTED_GETTER]) SystemAssembly system;
	@Accessors(#[PUBLIC_SETTER, PROTECTED_GETTER]) AccessControlRepository acRepository;
	new(SystemAssembly system, AccessControlRepository acRepository){
		this.system = system;
		this.acRepository = acRepository
	}
	
	def generatePragma(){
		return '''pragma solidity «solidityVersion»;''' + newLine + newLine;
	}
	
	def generateContractDefinition(Contract contract){
		return '''contract «contract.entityName»«FOR parent : contract.parents BEFORE " is " SEPARATOR ", "»«parent.entityName»«ENDFOR»'''
	}
		
	def String generateImportStatements(Contract contract, Iterable<ContractType> usedContractTypes) {		
		
		val importedContracts = generateImportsFromSystemAssembly(contract) + generateImportsFromParents(contract) + contractTypesToContracts(usedContractTypes)
		val contractFileNames = importedContracts.map[cont | cont.getTargetFileNameForContract] + generateImportStatementFromAccessControl(contract).toSet()
		
		return '''«
				FOR fileName : contractFileNames	
				»import "./«fileName»«targetFileExt»";
				«ENDFOR»
		'''
	}
	
	private def Iterable<String> generateImportStatementFromAccessControl(Contract contract) {
		if(requiresAccessControlOperation(contract)) {
			return #[AccessControlGenerator.accessControlName]
		} else {
			return #[]
		}
	} 

	private def Iterable<Contract> generateImportsFromSystemAssembly(Contract contract) {
		if(system !== null) {
			return getCalledContractsFromSystemAssembly(contract)			
		} else {
			return #[]
		}
	}
	
	private def Iterable<Contract> generateImportsFromParents(Contract contract) {
		return contract.parents ?: #[]
	}
	
	private def Iterable<Contract> contractTypesToContracts(Iterable<ContractType> contractTypes) {
		return contractTypes.map[x | x.contract]	
	}

	
	
	def Iterable<Contract> getCalledContractsFromSystemAssembly(Contract contract) {
		if(system !== null) {
			val contractInstances = system.instances.filter(instance | isInstanceOfContract(instance, contract))
			val requiredInterfacesOfContract = contractInstances.map(instance | instance.requiredInterfaces).flatten()
			
			val calledContracts = new HashSet<Contract>()
			for (req : requiredInterfacesOfContract) {
				for (instance : system.instances) {
					for(prov : instance.providedInterfaces) {
						if(interfacesConnected(req, prov) && !isInstanceOfContract(instance, contract)) {
							calledContracts.add(instance.contract)
						}
					}			
				}		
			}			
			return calledContracts
		} else {
			return emptySet()
		}

	}
	
	private def boolean isInstanceOfContract(Instance instance, Contract contract) {
		return instance.contract.entityName == contract.entityName;
	}	
	
	private def boolean interfacesConnected(RequiredInterface req, ProvidedInterface prov) {				
		return system.connectors.exists(con | con.requiredInterface == req && con.providedInterface == prov)
	}
	
	private def boolean requiresAccessControlOperation(Contract contract) {
		return acRepository !== null && contract.requiredFunctions.contains(acRepository.accessOperationDef.operation)
	}
	


	
	
}

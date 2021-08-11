package edu.kit.kastel.sdq.soliditycodegenerator.generators

import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Contract
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Modifier
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Function
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.OverrideFunction

class SolidityOverrideGenerator {
	
	
	def String generate(Modifier modifier) {
		val contracts = modifier.override ?: #[]
		return '''«generateOverrideString(contracts)» '''
	}
	
	def String generate(Function target, Iterable<OverrideFunction> overrideFunctions) {
		val contracts = overrideFunctions.findFirst[it.overriding.id == target.id]?.baseContracts ?: #[]
		return '''«generateOverrideString(contracts)» '''
	}
	
	private def String generateOverrideString(Iterable<Contract> contracts) {
		if (contracts.isEmpty) {
		 	return ""
		} else if (contracts.size == 1) {
			return "override"
		} else {
			// override multiple contracts
			return'''override(«FOR contract : contracts SEPARATOR ", "»«contract.entityName»«ENDFOR»)'''
		}		
	}
	
}
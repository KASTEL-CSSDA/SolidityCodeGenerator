package edu.kit.kastel.sdq.soliditycodegenerator.generators.templates

import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Contract

interface ContractUsing {
	def void setCurrentTarget(Contract contract);
}
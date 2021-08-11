package edu.kit.kastel.sdq.soliditycodegenerator.generators

import edu.kit.ipd.sdq.mdsd.ecore2txt.generator.AbstractEcore2TxtGeneratorModule

class SolidityGeneratorModule extends AbstractEcore2TxtGeneratorModule {
	
	override protected getFileExtensions() {
		return "soliditycontracts"
	}
	
	override protected getLanguageName() {
		return ""
	}
	
}
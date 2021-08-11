package edu.kit.kastel.sdq.soliditycodegenerator.generators.templates

import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Function

abstract class MethodGenerationTemplate implements M2TGenerator {
	
	override generate() '''
		«generateComments()»
		«generateHeader()»{
			«generateBody()»
		}
	'''
	
	protected def String generateComments();
	protected def String generateHeader();
	protected def String generateBody();
	protected def void setCurrentTarget(Function function);
	
}

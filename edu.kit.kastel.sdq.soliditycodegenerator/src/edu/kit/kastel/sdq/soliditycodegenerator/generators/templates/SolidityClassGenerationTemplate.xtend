package edu.kit.kastel.sdq.soliditycodegenerator.generators.templates

import edu.kit.kastel.sdq.soliditycodegenerator.generators.templates.ClassGenerationTemplate

abstract class SolidityClassGenerationTemplate extends ClassGenerationTemplate {
	
	override String generate(){
		return 
		'''
		«generatePragma»
		
		«generateImports»
		
		«generateDeclaration» {
			«generateEnums»
			
			«generateStructs»
			
			«generateEvents»
			
			«generateFields»
			
			«generateConstructors»
			
			«generateMethods»
			
			«generateModifiers»
		}'''
	}
	
	protected def String generatePragma();
	protected def String generateModifiers();
	protected def String generateEnums();
	protected def String generateStructs();
	protected def String generateEvents();
	
}

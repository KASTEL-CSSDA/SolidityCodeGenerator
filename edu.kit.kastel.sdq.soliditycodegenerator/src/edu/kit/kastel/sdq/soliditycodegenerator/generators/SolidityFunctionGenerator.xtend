package edu.kit.kastel.sdq.soliditycodegenerator.generators

import static extension edu.kit.kastel.sdq.soliditycodegenerator.util.SolidityNaming.*;
import edu.kit.kastel.sdq.soliditycodegenerator.generators.templates.MethodGenerationTemplate
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Function
import edu.kit.kastel.sdq.soliditycodegenerator.generators.accesscontrol.ModifierAndContractGenerator
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.ReturnVariable
import java.util.Collection
import org.eclipse.xtend.lib.annotations.Accessors
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Contract
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Modifier
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.LocalFunction
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.GlobalFunction

class SolidityFunctionGenerator extends MethodGenerationTemplate {

	@Accessors(PRIVATE_GETTER) Function currentFunction;
	@Accessors(PRIVATE_GETTER) ModifierAndContractGenerator acGenerator;
	@Accessors(PRIVATE_GETTER) SolidityOverrideGenerator overrideGenerator;
	@Accessors(PRIVATE_GETTER, PROTECTED_SETTER) Contract currentContract;

	new(ModifierAndContractGenerator acGenerator) {
		this.acGenerator = acGenerator;
		this.overrideGenerator = new SolidityOverrideGenerator();
	}
	
	override protected generateComments() {
		return acGenerator.generateProofObligationsForOperation(currentFunction);
	}

	override protected generateHeader() {
		val returnType = generateReturn(currentFunction)
		val methodName = getFunctionName(currentFunction)		
		val parameterDeclarations = '''«FOR parameter : currentFunction.parameters SEPARATOR ', '»«getTargetNameForType(parameter.type, true)» «parameter.name»«ENDFOR»'''
		val accessControlModifiers = acGenerator.generateModifierUsageDefinitions(currentFunction)
		val modifiers = handleModifiers(currentFunction.modifiers)
		val visibility = generateVisibility(currentFunction)
		val mutability = getTargetNameForFunctionMutability(currentFunction.getMutability)
		val virtual = currentFunction.virtual ? "virtual " : ""
		val overrides = overrideGenerator.generate(currentFunction, currentContract.overrideFunctions)
		val result = '''function «methodName»(«parameterDeclarations») «virtual» «visibility» «mutability» «modifiers» «accessControlModifiers» «overrides» «returnType»'''
		return result.normalizeSpaces
	}
	
	override protected generateBody() {
		if(currentFunction.content === null || currentFunction.content.empty) {
			return '''
		// TODO: implement and verify auto-generated method stub
		revert("TODO: auto-generated method stub");
		'''
			
		} else {
			return currentFunction.content
		}
	}
	
	override protected setCurrentTarget(Function function) {
		this.currentFunction = function;
	}
	
	private def String generateReturn(Function function) {

		var returnVariables = function.returnVariables;

		if (returnVariables === null || returnVariables.empty) {
			return "";
		}

		var returnedVariables = handleReturnVariables(returnVariables);
		
		return '''returns («returnedVariables») ''';
	}


	private def String handleReturnVariables(Collection<ReturnVariable> vars) {
		return '''«FOR variable : vars SEPARATOR ", "»«getTargetNameForType(variable.type, true)» «getReturnVariableName(variable)»«ENDFOR»'''
	}
	
	private def String getReturnVariableName(ReturnVariable variable) {
		if(variable.name === null) {
			return ""
		}
		return variable.name
	}
	
	private def String handleModifiers(Iterable<Modifier> modifiers) {
		return '''«FOR modifier : modifiers SEPARATOR " "»«modifier.getModifierSignature»«ENDFOR»'''
	}
	
	private def String getModifierSignature(Modifier mod) {
		if(mod.parameters.size > 0) {
			return '''«mod.getModifierName»(«FOR param : mod.parameters SEPARATOR ", "»«param.name»«ENDFOR»)'''
		}
		return '''«mod.getModifierName»'''
	}
	
	private def String generateVisibility(Function function) {		
		if(function instanceof LocalFunction) {			
			return getTargetNameForFunctionVisibility(function.visibility)
		} else if (function instanceof GlobalFunction) {
			return getTargetNameForFunctionVisibility(function.visibility)
		}
		return ""
	}
	
	
	
	
	
	
}

package edu.kit.kastel.sdq.soliditycodegenerator.handlers
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException
import edu.kit.ipd.sdq.mdsd.ecore2txt.handler.AbstractEcoreIFile2TxtHandler
import java.util.List
import org.eclipse.core.resources.IFile
import edu.kit.ipd.sdq.mdsd.ecore2txt.util.Ecore2TxtUtil
import edu.kit.kastel.sdq.soliditycodegenerator.generators.SolidityGenerator
import edu.kit.kastel.sdq.soliditycodegenerator.generators.SolidityGeneratorModule

class SolidityCodeGeneratorHandler extends AbstractEcoreIFile2TxtHandler {
	
	override executeEcore2TxtGenerator(List<IFile> filteredSelection, ExecutionEvent event, String plugInID) throws ExecutionException {
		Ecore2TxtUtil.generateFromSelectedFilesInFolder(filteredSelection, new SolidityGeneratorModule, new SolidityGenerator, false, false);
	}
	
	override getPlugInID() {
		return '''edu.kit.kastel.sdq.soliditycodegenerator'''
	}
	
}

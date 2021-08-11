package edu.kit.kastel.sdq.soliditycodegenerator.generators

import static extension edu.kit.kastel.sdq.soliditycodegenerator.util.SolidityConstants.*;
import static extension edu.kit.kastel.sdq.soliditycodegenerator.util.SolidityNaming.*;
import edu.kit.ipd.sdq.mdsd.ecore2txt.generator.AbstractEcore2TxtGenerator
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Contract
import edu.kit.kastel.sdq.soliditymetamodel.rbac.AccessControlRepository
import java.util.ArrayList
import java.util.Collections
import java.util.Comparator
import java.util.List
import org.eclipse.core.resources.IFile
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.internal.xtend.util.Triplet
import edu.kit.kastel.sdq.soliditycodegenerator.generators.accesscontrol.AccessControlGenerator
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Repository
import edu.kit.kastel.sdq.soliditymetamodel.soliditysystem.SystemAssembly

class SolidityGenerator extends AbstractEcore2TxtGenerator {
	
	AccessControlRepository acRepository
	SystemAssembly targetSystem;
	SolidityContractGenerator contractGenerator
	AccessControlGenerator acGenerator
	
	override generateContentsFromResource(Resource inputResource) {
		val contents = new ArrayList<Triplet<String, String, String>>;
		for (element : inputResource.contents) {
			if(element instanceof SystemAssembly) {
				this.targetSystem = element;
				return contents;
			} else if (element instanceof AccessControlRepository){
				this.acRepository = element;
				return contents;
			}
		}

		generateAndAddContents(inputResource, contents);
		return contents;
	}
	
	private def void generateAndAddContents(Resource resource, List<Triplet<String, String, String>> contents) {
		this.contractGenerator = new SolidityContractGenerator(targetSystem, acRepository)
		
		//TODO: Could reduce redundancy by passing contents and add in central method
		
		if(acRepository !== null) {
			this.acGenerator = new AccessControlGenerator(acRepository, true);
			var acContent = acGenerator.generate();
			if (acContent !== null && !acContent.equals("")) {
				contents.add(generateContentTriplet(acContent, AccessControlGenerator.accessControlName));
			}	
		}	
				
		
		for (element : resource.contents) {
			if (element instanceof Repository) {
				for(contract : element.contracts) {
					val content = generateContent(contract);

					if (content !== null && !content.equals("")) {
						contents.add(generateContentTriplet(content, contract));
					}
				}
				
			}
		}

		
	}
	
	
	private def Triplet<String, String, String> generateContentTriplet(String content, String fileName){
		val folderName = targetFolderPrefix;
		val fileNameWithExtension = fileName + getTargetFileExt();
		val contentAndFileName = new Triplet<String, String, String>(content, folderName, fileNameWithExtension);
		
		return contentAndFileName;
	}
	
	private def Triplet<String, String, String> generateContentTriplet(String content, Contract contract){
		return generateContentTriplet(content, getTargetFileNameForContract(contract));
	}
	
	
	
	override getFileNameForResource(Resource inputResource) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override getFolderNameForResource(Resource inputResource) {
	 	return "src-gen"
	}
	
	override postProcessGeneratedContents(String contents) {
		// no post processing necessary
		return contents
	}
	
	override preprocessInputFiles(List<IFile> inputFiles) {
		return sortInputFiles(inputFiles)
	}
	
	private def List<IFile> sortInputFiles(List<IFile> inputFiles) {
		val preprocessedInputFiles = new ArrayList(inputFiles.size)
		preprocessedInputFiles.addAll(inputFiles)
		Collections.sort(preprocessedInputFiles, new Comparator<IFile>() {
			override compare(IFile o1, IFile o2) {
				val fileExtIndex1 = fileExt2Index(o1.fileExtension)
				val fileExtIndex2 = fileExt2Index(o2.fileExtension)
				return fileExtIndex1.compareTo(fileExtIndex2)
			}

			def private int fileExt2Index(String fileExt) {
				switch fileExt {
					case 'soliditysystem': 0
					case 'rbac' : 1
					default: 2
				}
			}
		})
		return preprocessedInputFiles
	}

	private def String generateContent(EObject element) {
		switch element {
			Contract: generateContract(element)
			EObject: generateContentUnexpectedEObject(element)
		}
	}
	
	private def String generateContract(Contract contract) {
		contractGenerator.currentTarget = contract;
		return contractGenerator.generate();
	}
	
	def generateContentUnexpectedEObject(EObject object) {
		"" // "Cannot generate content for generic EObject '" + object + "'!"
	}

	
}
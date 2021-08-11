# SolidityCodeGenerator

A Code Generator for SolidityMetaModel that automatically creates source code with method stubs.

## Setup
This project requires the *SolidityMetaModel* submodule

1. Setup an [Eclipse Modelling Tools 2021-06](https://www.eclipse.org/downloads/packages/release/2021-06/r/eclipse-modeling-tools) (4.20) with the following Plugins:
	* OCL All-In-One SDK (6.15.0.v20210609-1442): [http://download.eclipse.org/modeling/mdt/ocl/updates/releases](http://download.eclipse.org/modeling/mdt/ocl/updates/releases)
	* MDSD.tools Modeling Foundations (1.0.0.202010011104): [https://github.com/MDSD-Tools/Metamodel-Modeling-Foundations](https://github.com/MDSD-Tools/Metamodel-Modeling-Foundations)
	* Ecore2Txt (1.0.0.202106250413) [https://github.com/kit-sdq/Ecore2Txt](https://github.com/kit-sdq/Ecore2Txt)
2. Clone this repository
3. Execute `git submodule init` and `git submodule update` 
4. Import the following projects in Eclipse:
	* `edu.kit.kastel.sdq.soliditymetamodel`
	* `edu.kit.kastel.sdq.soliditymetamodel.edit`
	* `edu.kit.kastel.sdq.soliditymetamodel.editor`
	* `edu.kit.kastel.sdq.soliditycodegenerator`
5. Generate model-content if necessary
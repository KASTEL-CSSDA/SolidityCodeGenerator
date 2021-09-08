package edu.kit.kastel.sdq.soliditycodegenerator.util

import static extension edu.kit.kastel.sdq.soliditycodegenerator.util.SolidityConstants.*
import java.util.Collection
import edu.kit.kastel.sdq.soliditymetamodel.rbac.Role
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.PrimitiveType
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.PrimitiveTypeEnum
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Function
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.DefaultArray
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.DefaultArrayEnum
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.DataLocation
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Contract
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.VariableMutability
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.VariableVisibility
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.FunctionMutability
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.FunctionTypeVisibility
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Struct
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.ContractType
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.CustomArray
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Mapping
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.FunctionType
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Modifier
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.GlobalFunctionVisibility
import edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.LocalFunctionVisibility

class SolidityNaming {

	private new() {}
	

	static def String getModifierNameForRoles(Collection<Role> roles){
		var modifierName = "";
		
		
		for(role : roles.sortBy[x | x.entityName]){
			modifierName += role.getEntityName();
		}
		
		if(modifierName.empty){
			return modifierName;
		} 
		
		return roleModifierPrefix + modifierName;
	}
			
	
	static def String getTargetFileNameForContract(Contract contract) {
		return contract.entityName.toFirstUpper
	}
	
	static def String getFunctionName(Function function) {
		return function.entityName.toFirstLower
	}
	
	static def String getModifierName(Modifier modifier) {
		return modifier.entityName.toFirstLower
	}
	
	static def String normalizeSpaces(String string) {
		return string.replaceAll(" +", " ")
	}
	
	static def String getTargetNameForDataLocation(DataLocation location){	
		switch (location) {
			case DataLocation::CALLDATA : "calldata"
			case DataLocation::STORAGE : "storage"
			case DataLocation::MEMORY : "memory"
			default: ""
		}	
	}
	
	static def String getTargetNameForVariableMutability(VariableMutability mutability){	
		switch (mutability) {
			case VariableMutability::DEFAULT : ""
			case VariableMutability::CONSTANT : "constant"
			case VariableMutability::IMMUTABLE : "immutable"
			default: ""
		}	
	}
	
	static def String getTargetNameForVariableVisibility(VariableVisibility visibility){	
		switch (visibility) {
			case VariableVisibility::PUBLIC : "public"
			case VariableVisibility::INTERNAL : "internal"
			case VariableVisibility::PRIVATE : "private"
			default: ""
		}	
	}
	
	static def String getTargetNameForFunctionVisibility(GlobalFunctionVisibility visibility){	
		switch (visibility) {
			case GlobalFunctionVisibility::PUBLIC : "public"
			case GlobalFunctionVisibility::EXTERNAL : "external"
			default: ""
		}	
	}
	
		static def String getTargetNameForFunctionVisibility(LocalFunctionVisibility visibility){	
		switch (visibility) {
			case LocalFunctionVisibility::INTERNAL : "internal"
			case LocalFunctionVisibility::PRIVATE : "private"
			default: ""
		}	
	}
	
	static def String getTargetNameForFunctionMutability(FunctionMutability mutability){	
		switch (mutability) {
			case FunctionMutability::DEFAULT : ""
			case FunctionMutability::PURE : "pure"
			case FunctionMutability::VIEW : "view"
			case FunctionMutability::PAYABLE : "payable"
			default: ""
		}	
	}
	
	static def String getTargetNameForFunctionTypeVisibility(FunctionTypeVisibility visibility){	
		switch (visibility) {
			case FunctionTypeVisibility::INTERNAL : "internal"
			case FunctionTypeVisibility::EXTERNAL : "external"
			default: ""
		}	
	}
	
	static def String getTargetNameForPrimitiveTypeEnum(PrimitiveTypeEnum pt) {
		switch pt {
			case PrimitiveTypeEnum::ADDRESS: "address"
			case PrimitiveTypeEnum::ADDRESS_PAYABLE : "address payable"
			case PrimitiveTypeEnum::BOOL : "bool"
			case PrimitiveTypeEnum::INT : "int"
			case PrimitiveTypeEnum::UINT : "uint"
			case PrimitiveTypeEnum::BYTES1 : "bytes1"
			case PrimitiveTypeEnum::BYTES2 : "bytes2"
			case PrimitiveTypeEnum::BYTES3 : "bytes3"
			case PrimitiveTypeEnum::BYTES4 : "bytes4"
			case PrimitiveTypeEnum::BYTES5 : "bytes5"
			case PrimitiveTypeEnum::BYTES6 : "bytes6"
			case PrimitiveTypeEnum::BYTES7 : "bytes7"
			case PrimitiveTypeEnum::BYTES8 : "bytes8"
			case PrimitiveTypeEnum::BYTES9 : "bytes9"
			case PrimitiveTypeEnum::BYTES10 : "bytes10"
			case PrimitiveTypeEnum::BYTES11 : "bytes11"
			case PrimitiveTypeEnum::BYTES12 : "bytes12"
			case PrimitiveTypeEnum::BYTES13 : "bytes13"
			case PrimitiveTypeEnum::BYTES14 : "bytes14"
			case PrimitiveTypeEnum::BYTES15 : "bytes15"
			case PrimitiveTypeEnum::BYTES16 : "bytes16"
			case PrimitiveTypeEnum::BYTES17 : "bytes17"
			case PrimitiveTypeEnum::BYTES18 : "bytes18"
			case PrimitiveTypeEnum::BYTES19 : "bytes19"
			case PrimitiveTypeEnum::BYTES20 : "bytes20"
			case PrimitiveTypeEnum::BYTES21 : "bytes21"
			case PrimitiveTypeEnum::BYTES22 : "bytes22"
			case PrimitiveTypeEnum::BYTES23 : "bytes23"
			case PrimitiveTypeEnum::BYTES24 : "bytes24"
			case PrimitiveTypeEnum::BYTES25 : "bytes25"
			case PrimitiveTypeEnum::BYTES26 : "bytes26"
			case PrimitiveTypeEnum::BYTES27 : "bytes27"
			case PrimitiveTypeEnum::BYTES28 : "bytes28"
			case PrimitiveTypeEnum::BYTES29 : "bytes29"
			case PrimitiveTypeEnum::BYTES30 : "bytes30"
			case PrimitiveTypeEnum::BYTES31 : "bytes31"
			case PrimitiveTypeEnum::BYTES32 : "bytes32"
			case PrimitiveTypeEnum::INT8 : "int8" 
			case PrimitiveTypeEnum::INT16 : "int16"
			case PrimitiveTypeEnum::INT24 : "int24"
			case PrimitiveTypeEnum::INT32 : "int32"
			case PrimitiveTypeEnum::INT40 : "int40"
			case PrimitiveTypeEnum::INT48 : "int48"
			case PrimitiveTypeEnum::INT56 : "int56"
			case PrimitiveTypeEnum::INT64 : "int64"
			case PrimitiveTypeEnum::INT72 : "int72"
			case PrimitiveTypeEnum::INT80 : "int80"
			case PrimitiveTypeEnum::INT88 : "int88"
			case PrimitiveTypeEnum::INT96 : "int96"
			case PrimitiveTypeEnum::INT104 : "int104"
			case PrimitiveTypeEnum::INT112 : "int112"
			case PrimitiveTypeEnum::INT120 : "int120"
			case PrimitiveTypeEnum::INT128 : "int128"
			case PrimitiveTypeEnum::INT136 : "int136"
			case PrimitiveTypeEnum::INT144 : "int144"
			case PrimitiveTypeEnum::INT152 : "int152"
			case PrimitiveTypeEnum::INT160 : "int160"
			case PrimitiveTypeEnum::INT168 : "int168"
			case PrimitiveTypeEnum::INT176 : "int176"
			case PrimitiveTypeEnum::INT184 : "int184"
			case PrimitiveTypeEnum::INT192 : "int192"
			case PrimitiveTypeEnum::INT200 : "int200"
			case PrimitiveTypeEnum::INT208 : "int208"
			case PrimitiveTypeEnum::INT216 : "int216"
			case PrimitiveTypeEnum::INT224 : "int224"
			case PrimitiveTypeEnum::INT232 : "int232"
			case PrimitiveTypeEnum::INT240 : "int240"
			case PrimitiveTypeEnum::INT248 : "int248"
			case PrimitiveTypeEnum::INT256 : "int256"
			case PrimitiveTypeEnum::UINT8 : "uint8" 
			case PrimitiveTypeEnum::UINT16 : "uint16"
			case PrimitiveTypeEnum::UINT24 : "uint24"
			case PrimitiveTypeEnum::UINT32 : "uint32"
			case PrimitiveTypeEnum::UINT40 : "uint40"
			case PrimitiveTypeEnum::UINT48 : "uint48"
			case PrimitiveTypeEnum::UINT56 : "uint56"
			case PrimitiveTypeEnum::UINT64 : "uint64"
			case PrimitiveTypeEnum::UINT72 : "uint72"
			case PrimitiveTypeEnum::UINT80 : "uint80"
			case PrimitiveTypeEnum::UINT88 : "uint88"
			case PrimitiveTypeEnum::UINT96 : "uint96"
			case PrimitiveTypeEnum::UINT104 : "uint104"
			case PrimitiveTypeEnum::UINT112 : "uint112"
			case PrimitiveTypeEnum::UINT120 : "uint120"
			case PrimitiveTypeEnum::UINT128 : "uint128"
			case PrimitiveTypeEnum::UINT136 : "uint136"
			case PrimitiveTypeEnum::UINT144 : "uint144"
			case PrimitiveTypeEnum::UINT152 : "uint152"
			case PrimitiveTypeEnum::UINT160 : "uint160"
			case PrimitiveTypeEnum::UINT168 : "uint168"
			case PrimitiveTypeEnum::UINT176 : "uint176"
			case PrimitiveTypeEnum::UINT184 : "uint184"
			case PrimitiveTypeEnum::UINT192 : "uint192"
			case PrimitiveTypeEnum::UINT200 : "uint200"
			case PrimitiveTypeEnum::UINT208 : "uint208"
			case PrimitiveTypeEnum::UINT216 : "uint216"
			case PrimitiveTypeEnum::UINT224 : "uint224"
			case PrimitiveTypeEnum::UINT232 : "uint232"
			case PrimitiveTypeEnum::UINT240 : "uint240"
			case PrimitiveTypeEnum::UINT248 : "uint248"
			case PrimitiveTypeEnum::UINT256 : "uint256"		
			default : ""
		}
	}
	
	static def String getTargetNameForDefaultArrayEnum(DefaultArrayEnum array){	
		switch array {
			case DefaultArrayEnum::BYTES : "bytes"
			case DefaultArrayEnum::STRING :  "string"
			default: ""
		}	
	}
	
	static dispatch def String getTargetNameForType(PrimitiveType pt, boolean includeDataLocation) {
		return getTargetNameForPrimitiveTypeEnum(pt.type)
	}
	
	static dispatch def String getTargetNameForType(edu.kit.kastel.sdq.soliditymetamodel.soliditycontracts.Enum en, boolean includeDataLocation) {
		return en.entityName
	}
	
	static dispatch def String getTargetNameForType(ContractType ct, boolean includeDataLocation) {
		return ct.contract.entityName
	}
	
	static dispatch def String getTargetNameForType(DefaultArray array, boolean includeDataLocation) {
		return '''«getTargetNameForDefaultArrayEnum(array.type)»«IF includeDataLocation» «getTargetNameForDataLocation(array.dataLocation)»«ENDIF»'''
	}
		 
	
	
	static dispatch def String getTargetNameForType(CustomArray array, boolean includeDataLocation) {
		return '''«getTargetNameForType(array.type, false)»[«IF array.size > 0»«array.size»«ENDIF»]«IF includeDataLocation» «getTargetNameForDataLocation(array.dataLocation)»«ENDIF»'''
	}
		
	
	
	static dispatch def String getTargetNameForType(Mapping map, boolean includeDataLocation) {
		val dataLocation = includeDataLocation ? getTargetNameForDataLocation(map.dataLocation) : ""
		return '''mapping(«getTargetNameForType(map.keyType, false)» => «getTargetNameForType(map.valueType, false)») «dataLocation»'''
	}
		
	
	
	static dispatch def String getTargetNameForType(Struct struct, boolean includeDataLocation) {	
		return '''«struct.entityName»«IF includeDataLocation» «getTargetNameForDataLocation(struct.dataLocation)»«ENDIF»'''
	}
	
	static dispatch def String getTargetNameForType(FunctionType ft, boolean includeDataLocation) {
		val returns = ft.returnTypes.size > 0 ? '''[returns («FOR type : ft.returnTypes SEPARATOR ", "»«getTargetNameForType(type, true)»«ENDFOR»)]''' : ""
		val type = '''function(«FOR type : ft.parameterTypes SEPARATOR ", "»«getTargetNameForType(type, true)»«ENDFOR») «getTargetNameForFunctionTypeVisibility(ft.visibility)» «getTargetNameForFunctionMutability(ft.mutability)» «returns»'''
		return type.normalizeSpaces
	}
	
	
	
	
	 

}
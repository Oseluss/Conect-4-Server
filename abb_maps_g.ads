generic
	type Key_Type is private;
	type Value_Type is private;
	with function "=" (K1,K2: Key_Type) return Boolean;
	with function "<" (K1,K2: Key_Type) return Boolean;
	with function ">" (K1,K2: Key_Type) return Boolean;
	with function Key_To_String (K: Key_Type) return String;
	with function Value_To_String (K: Value_Type) return String;                                  
	
package ABB_Maps_G is
	type Map is limited private;
	
	procedure Get(M		: Map;
				  Key		: in Key_Type;
				  Value		: out Value_Type;
				  Success	: out Boolean);
				  
	procedure Put(M			: in out Map;
				  Key		: Key_Type;
				  Value		: Value_Type);
				  	
	procedure Delete(M		: in out Map;
				  	Key		: in Key_Type;
				  	Success	: out Boolean);	
			
	function Map_Length (M: Map) return Integer;

	function Count_Nodes(M: Map) return Integer;
	
	procedure Print_Map(M:in Map);
	
	function Node_Value(M: Map) return Value_Type;
	
	function Map_Left(M: Map) return Map;
	
	function Map_Right(M: Map) return Map;
	
	function Node_Key(M: Map) return Key_Type;
	
	function Is_Map_Null(M: Map) return boolean;
	
private 
	
	type Tree_Node;
	type Map is access Tree_Node;
	type Tree_Node is record
		Key		: Key_Type;
		Value	: Value_Type;
		Left	: Map;
		Right	: Map;
	end record;
	
end ABB_Maps_G;

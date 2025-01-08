with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Exceptions;
with C4_Messages;
with Ada.Text_IO;
with Abb_Maps_G;
with Server_Game;
with Vertical_Dashboard;
with Hash_Maps_G;

package Server_Handler is
	package ASU renames Ada.Strings.Unbounded;
	package LLU renames Lower_Layer_UDP;
	package CM renames C4_Messages;
	package SG renames Server_Game;
	package VD renames Vertical_Dashboard;
	
	function equal(US1,US2: ASU.Unbounded_String) return boolean;
	
	function less(US1,US2: ASU.Unbounded_String) return boolean;
	
	function more(US1,US2: ASU.Unbounded_String) return boolean;
	
	function Game_To_String(C4_Game: SG.C4_Game_Type) return string;
	
	package Abb_Game_Map is new Abb_Maps_G(ASU.Unbounded_String,
									SG.C4_Game_Type,equal,less,more,
									ASU.To_String,Game_To_String);
									
	HASH_SIZE:   constant := 6;

	type Hash_Range is mod HASH_SIZE;
	
	type C4_Value_Type is record
		Ep: LLU.End_Point_Type;
		Game_Key: ASU.Unbounded_String;
	end record;
	
	function Unbounded_String_Hash (US: ASU.Unbounded_String) return Hash_Range;
	
	package Players_Hash_Map is new Hash_Maps_G (Key_Type   => ASU.Unbounded_String,
                                    Value_Type => C4_Value_Type,
                                    "="        => equal,
                                    Hash_Range => Hash_Range,
                                    Hash => Unbounded_String_Hash);
	
	Game_Map: Abb_Game_Map.Map;
	
	Players_Map: Players_Hash_Map.Map;
	
	procedure Server_Handler (From : in LLU.End_Point_Type;
				To : in LLU.End_Point_Type;
				Buffer : access LLU.Buffer_Type);

end Server_Handler;

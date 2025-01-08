with Ada.Text_IO;

package body ABB_Maps_G is 
	
	--ASU renames Ada.Unbounded_String;

	procedure Get(M: Map;Key : in Key_Type; Value: out Value_Type; 
				Success	: out Boolean) is
	begin
		--Value := ASU.Null_Unbounded_String;
		If M = null then
			Success := False;
		elsif M.Key = Key then
			Value := M.Value;
			Success := True;
		elsif Key > M.Key then
			Get (M.Right, Key, Value, Success);
		else
			Get (M.Left, Key, Value, Success);
		end if;
	end Get;
				  
	procedure Put(M: in out Map; Key: Key_Type; Value: Value_Type) is
	begin
		if M = null then
			M := new Tree_Node'(Key, Value, null, null);	
			return;
		end if;
		if Key = M.Key then
			M.Value := Value;
		elsif Key < M.Key then
			Put (M.Left, Key, Value);
		elsif Key > M.Key then
			Put (M.Right, Key, Value);
		end if;
	end Put;
	 	
	procedure Delete(M: in out Map;Key : in Key_Type; Success: out Boolean) is
	Ptr_Aux1, Ptr_Aux2: Map;
	begin
		--Value := ASU.Null_Unbounded_String;
		If M = null then
			Success := False;
		elsif M.Key = Key then
			if M.Right = null and M.Left = null then
				M:= null;
			elsif (M.Right /= null) and (M.Left = null) then
				M:= M.Right;
			elsif (M.Right = null) and (M.Left /= null) then
				M:= M.Left;
			else
				Ptr_Aux1:= M;
				Ptr_Aux2:= Ptr_Aux1.Left;
				while Ptr_Aux2.Right /= null loop
					Ptr_Aux1:= Ptr_Aux2;
					Ptr_Aux2:= Ptr_Aux2.Right;
				end loop;
				M.Value:= Ptr_Aux2.Value;
				M.Key:= Ptr_Aux2.Key;
				if Ptr_Aux1 = M then
					Delete(Ptr_Aux1.Left,Ptr_Aux2.Key,Success);
				else
					Delete(Ptr_Aux1.Right,Ptr_Aux2.Key,Success);
				end if;
			end if;
			Success := True;
		elsif Key > M.Key then
			Delete (M.Right, Key, Success);
		else
			Delete (M.Left, Key, Success);
		end if;
	end Delete;
			
	function Map_Length (M: Map) return Integer is
	Length_Left, Length_Right: Natural;
	begin
		if M = null then
			return 0;
		else
			Length_Left:= Map_Length(M.Left);
			Length_Right:=  Map_Length(M.Right);
			if Length_Left > Length_Right then
				return 1 + Length_Left;
			else
				return 1 + Length_Right;
			end if;
		end if;
	end Map_Length;

	function Count_Nodes(M: Map) return Integer is
	begin
		if M= null then
			return 0;
		else
			return 1 + Count_Nodes(M.Left) + Count_Nodes(M.Right);
		end if;
	
	end Count_Nodes;

	procedure Print_Map(M: in Map) is
	begin
		if M /= null then
			Ada.Text_IO.Put(Key_To_String(M.Key) & "  ");
			Print_Map(M.Left);
			Print_Map(M.Right);
		end if;
	end Print_Map;
	
	function Node_Value(M: Map) return Value_Type is
	begin
		return M.Value;
	end Node_Value;
	
	function Map_Left(M: Map) return Map is
	begin
		return M.Left;
	end Map_Left;
	
	function Map_Right(M: Map) return Map is
	begin
		return M.Right;
	end Map_Right;
	
	function Node_Key(M: Map) return Key_Type is
	begin
		return M.Key;
	end Node_Key;
	
	function Is_Map_Null(M: Map) return boolean is
	begin
		return M=null;
	end Is_Map_Null;
	

end ABB_Maps_G;

with ada.text_io;
package body Hash_Maps_G is
	
	function Map_Length (M : Map) return Natural is
	begin
   		return M.Length;
	end Map_Length;

	function Hash_To_Index(Hash: in Hash_Range) return Cell_Index_Type is
	begin
		return Cell_Index_Type(Natural(Hash) + 1);
	end;
	
	function Int_To_Index(Int: in Natural) return Cell_Index_Type is
	begin
		return Cell_Index_Type(Int);
	end;
	
	
	function To_Int(Int: in Cell_Index_Type) return Integer is
		num: Integer;
	begin
		num:= 1;
		for I in 1..Int loop
			num:= num + 1;
		end loop;
		return num - 1;
	end;
	
	procedure Get (M       : in out Map;
                  Key     : in Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean) is
		Aux_Pos: Hash_Range;
		Inicial_Pos: Hash_Range;
		Map_L: Hash_Range;
		Found: Boolean;
		Empty_Node: Boolean;
	begin
		Inicial_Pos:= Hash(Key);
		Map_L:= 1 + (Hash_Range'Last - Hash_Range'First);
		Empty_Node:= (M.P_Array(Hash_To_Index(Inicial_Pos)).State = Empty);
		Found:= M.P_Array(Hash_To_Index(Inicial_Pos)).Key = Key;
		if Found and (not Empty_Node) then 
			Success:= True;
			Value:= M.P_Array(Hash_To_Index(Inicial_Pos)).Value;
		else
			Aux_Pos:= Inicial_Pos + 1;
			while ((not Empty_Node) and (Aux_Pos /= Inicial_Pos)) and then (not Found) loop 
				Empty_Node:= M.P_Array(Hash_To_Index(Aux_Pos)).State = Empty;
				Found:= M.P_Array(Hash_To_Index(Aux_Pos)).Key = Key;
				if not found then
					Aux_Pos:= Aux_Pos + 1;
				end if;
			end loop;
			if Found and (not Empty_Node) then --And not empty node
				Success:= True;
				Value:= M.P_Array(Hash_To_Index(Aux_Pos)).Value;
			else
				Success:= False;
			end if;
		end if;
	end Get;

	procedure Put (M     : in out Map;
                  Key   : in Key_Type;
                  Value : in Value_Type) is
		Aux_Pos: Hash_Range;
		Inicial_Pos: Hash_Range;
		Success: Boolean;
	begin
		if M.Length >= (1+Natural(Hash_Range'Last - Hash_Range'First)) then
			raise Full_Map;
		end if;
		Inicial_Pos:= (Hash(Key));
		Aux_Pos:= Inicial_Pos;
		if M.P_Array(Hash_To_Index(Aux_Pos)).State = Empty then
			M.P_Array(Hash_To_Index(Aux_Pos)).Key := KEY;
			M.P_Array(Hash_To_Index(Aux_Pos)).Value := Value;
			M.P_Array(Hash_To_Index(Aux_Pos)).State := Full;
			M.Length:= M.Length + 1;
		else
			Aux_Pos:= Aux_Pos + 1;
			while M.P_Array(Hash_To_Index(Aux_Pos)).State /= Empty 
					and Aux_Pos/= Inicial_Pos loop
				Aux_Pos:= Aux_Pos + 1;
			end loop;
			if Aux_Pos = Inicial_Pos then
				Success:= FALSE;
			else
				Success:= True;
				M.P_Array(Hash_To_Index(Aux_Pos)).Key:= KEY;
				M.P_Array(Hash_To_Index(Aux_Pos)).Value:= Value;
				M.P_Array(Hash_To_Index(Aux_Pos)).State := Full;
				M.Length:= M.Length + 1;
			end if;
		end if;	
	end Put;
	
	procedure Reorganize_Map(M: in out Map;
							  Inicial_Pos: Hash_Range) is
		Aux_Pos: Hash_Range;
		Aux_Key: Key_Type;
		Aux_Value: Value_Type;
	begin
		Aux_Pos:= Inicial_Pos;
		while (M.P_Array(Hash_To_Index(Aux_Pos)).State /= Empty) loop
			Aux_Key:= M.P_Array(Hash_To_Index(Aux_Pos)).Key;
			Aux_Value:= M.P_Array(Hash_To_Index(Aux_Pos)).Value;
			M.P_Array(Hash_To_Index(Aux_Pos)).State:= Empty;
			M.Length:= M.Length - 1;
			Put (M, Aux_Key,Aux_Value);
			Aux_Pos:= Aux_Pos + 1;
		end loop;
		
	end Reorganize_Map;

	procedure Delete (M       : in out Map;
                     Key     : in Key_Type;
                     Success : out Boolean) is
		Aux_Pos: Hash_Range;
		Inicial_Pos: Hash_Range;
		Map_L: Hash_Range;
		Found: Boolean;
		Empty_Node: Boolean;
	begin
		Inicial_Pos:= Hash(Key);
		Map_L:= 1 + (Hash_Range'Last - Hash_Range'First);
		Empty_Node:= (M.P_Array(Hash_To_Index(Inicial_Pos)).State = Empty);
		Found:= M.P_Array(Hash_To_Index(Inicial_Pos)).Key = Key;
		if Found and (not Empty_Node) then 
			Success:= True;
			M.P_Array(Hash_To_Index(Inicial_Pos)).State:= Empty;
			M.Length:= M.Length - 1;
			Reorganize_Map(M, Inicial_Pos + 1);
		else
			Aux_Pos:= Inicial_Pos + 1;
			while ((not Empty_Node) and (Aux_Pos /= Inicial_Pos)) and then (not Found) loop 
				Empty_Node:= M.P_Array(Hash_To_Index(Aux_Pos)).State = Empty;
				Found:= M.P_Array(Hash_To_Index(Aux_Pos)).Key = Key;
				if not found then
					Aux_Pos:= Aux_Pos + 1;
				end if;
			end loop;
			if Found and (not Empty_Node) then
				Success:= True;
				M.P_Array(Hash_To_Index(Aux_Pos)).State:= Empty;
				M.Length:= M.Length - 1;
				Reorganize_Map(M, Aux_Pos + 1);
			else
				Success:= False;
			end if;
		end if;
	end Delete;
	
	function First (M : Map) return Cursor is
		i: Cell_Index_Type;
		More_Elements: Boolean;
		C: Cursor;
		Found: Boolean;
	begin
		i:= 1;
		More_Elements:= True;
		Found:=  M.P_Array(i).State /= Empty;
		while not Found and  More_Elements loop
			More_Elements:= i <= Hash_To_Index(Hash_Range'Last - Hash_Range'First);
			if not Found and More_Elements then
				i:= i+1;
				Found:=  M.P_Array(i).State /= Empty;
			end if;
		end loop;
		C.M:= M;
		C.Valid:= Found;
		C.Position:= i;
		return C;
	end First;
	
	procedure Next (C : in out Cursor) is
		i: Cell_Index_Type;
		More_Elements: Boolean;
	begin
		i:= C.Position;
		More_Elements:= i <= (Cell_Index_Type'Last - Cell_Index_Type'First);
		if More_Elements then 
			i:= i + 1;
			More_Elements:= i <= (Cell_Index_Type'Last - Cell_Index_Type'First);
			while (C.M.P_Array(i).State = Empty) and  More_Elements loop
				i:= i+1;
				More_Elements:= i <= (Cell_Index_Type'Last - Cell_Index_Type'First);
			end loop;
		end if;
		C.Valid:= (C.Position /= i) and (C.M.P_Array(i).State /= Empty);
		C.Position:= i;
	
	end;
	
	function Has_Element (C : Cursor) return Boolean is
	begin
		return C.Valid;
	end;
	
	function Element (C : Cursor) return Element_Type is
		Aux_Element: Element_Type;
	begin
		if Has_Element(C) then
			Aux_Element.Value:=  C.M.P_Array(C.Position).Value;
			Aux_Element.Key:=  C.M.P_Array(C.Position).Key;
			return Aux_Element;
		else 
			raise No_Element;
		end if;
	end Element;
   
end Hash_Maps_G;


package body Vertical_Dashboard is

function Dashboard_Is_Full(Dashboard: in Board_Type) return Boolean is
	K: integer := 0;
begin
	for I in Dashboard'First..Dashboard'Last loop
		if not (Dashboard(1,I).Empty) then
			K:= K + 1;
		end if;
	end loop;
	return (K = Dashboard'Last );
end Dashboard_Is_Full;
	
procedure Print_Box(Box_C: in Box) is
begin
	if Box_c.Empty then
		Ada.Text_IO.Put(" - ");
	else
		case Box_c.Player is
			when 1 =>
				Ada.Text_IO.Put(" " & Ada.Characters.Latin_1.ESC & "[91m" & "O" &
					 Ada.Characters.Latin_1.ESC & "[0m" & " ");
			when 2 =>
				Ada.Text_IO.Put(" " & Ada.Characters.Latin_1.ESC & "[93m" & "O" &
						Ada.Characters.Latin_1.ESC & "[0m" & " ");
			when others =>
				Ada.Text_IO.Put("-");
		end case;
	end if;
end Print_Box;

procedure Print_Dashboard(Dashboard: in Board_Type) is
begin
	Ada.Text_IO.Put_Line("");
	for I in Dashboard'First..Dashboard'Last loop
		for J in Dashboard'Range loop
			Print_Box(Dashboard(I,J));
		end loop;
			Ada.Text_IO.Put_Line("");
	end loop;
end Print_Dashboard;
	

function Vertical_Conection(Dashboard: in Board_Type;
			Row: in integer; Column: in Integer; Player: in Integer) return boolean is
	K: Integer;
	J: Integer := 0;
	Players_Token: Boolean;
begin
	K:= Row;
	Players_Token:= True;
	-- Dashboard'Last - 3, we need at least three Token bellow for a conection
	if Row <= (Dashboard'Last - 3) then
		while (K <= Dashboard'Last) and Players_Token loop
			Players_Token:= Dashboard(K,Column).Player = Player and not Dashboard(K,Column).Empty;
			if Players_Token then
				J := J + 1;
			end if;
			K:= K + 1;
		end loop;
		return J >= 4;
	else
		return false;
	end if;
end Vertical_Conection;

function Horizontal_Conection(Dashboard: in Board_Type;
			Row: integer; Column: Integer; Player: Integer) return boolean is
	I: Integer;
	J: Integer := 0;
	Players_Token: Boolean;
begin
	I:= Column;
	Players_Token:= True;
	while (I <= Dashboard'Last) and Players_Token loop
		Players_Token:= Dashboard(Row,I).Player = Player and not Dashboard(Row,I).Empty;
		if Players_Token then
			J := J + 1;
		end if;
		I:= I + 1;
	end loop;
	
	I := Column - 1;
	Players_Token:= True;
	while (I >= Dashboard'First) and Players_Token loop
		Players_Token:= Dashboard(Row,I).Player = Player and not Dashboard(Row,I).Empty;
		if Players_Token then
			J := J + 1;
		end if;
		I:= I - 1;		
	end loop;
	return J >= 4;
end Horizontal_Conection;

function Diagonal_Right_Conection(Dashboard:in Vertical_Dashboard.Board_Type;
			Row: integer; Column: Integer; Player: Integer) return boolean is
	I,K: Integer;
	J: Integer := 0;
	Players_Token: Boolean;
begin
	I:= Column;
	K:= Row;
	Players_Token:= True;
	while (I <= Dashboard'Last) and (K <= Dashboard'Last) and Players_Token loop
		Players_Token:= Dashboard(K,I).Player = Player and not Dashboard(K,I).Empty;
		if Players_Token then
			J := J + 1;
		end if;
		I:= I + 1;
		K:= K + 1;
	end loop;
	
	I := Column - 1;
	K := Row - 1;
	Players_Token:= True;
	while (I >= Dashboard'First) and (K >= Dashboard'First) and Players_Token loop
		Players_Token:= Dashboard(K,I).Player = Player and not Dashboard(K,I).Empty;
		if Players_Token then
			J := J + 1;
		end if;
		I:= I - 1;
		K:= K - 1;		
	end loop;
	return J >= 4;
end Diagonal_Right_Conection;

function Diagonal_Left_Conection(Dashboard:in Vertical_Dashboard.Board_Type;
			Row: integer; Column: Integer; Player: Integer) return boolean is
	I,K: Integer;
	J: Integer := 0;
	Players_Token: Boolean;
begin
	I:= Column;
	K:= Row;
	Players_Token:= True;
	while (I <= Dashboard'Last) and (K >= Dashboard'First) and Players_Token loop
		Players_Token:= Dashboard(K,I).Player = Player and not Dashboard(K,I).Empty;
		if Players_Token then
			J := J + 1;
		end if;
		I:= I + 1;
		K:= K - 1;
	end loop;
	
	I := Column - 1;
	K := Row + 1;
	Players_Token:= True;
	while (I >= Dashboard'First) and (K <= Dashboard'Last) and Players_Token loop
		Players_Token:= Dashboard(K,I).Player = Player and not Dashboard(K,I).Empty;
		if Players_Token then
			J := J + 1;
		end if;
		I:= I - 1;
		K:= K + 1;	
	end loop;
	return J >= 4;
end Diagonal_Left_Conection;

procedure Put_Token(Dashboard: in out Board_Type; Column: in Integer; 	
			Player: in Integer; Winner: out Boolean) is
	Empty_Box: Boolean:= True;
	I: integer := 1;
	Last_Empty_Row: Integer := 0;
begin
	while (Empty_Box) and (I <= Dashboard'Last) loop
		Empty_Box:= Dashboard(I,Column).Empty;
		if (Dashboard(I,Column).Empty) then
			Last_Empty_Row:= Last_Empty_Row + 1 ;
		end if;
		I:= I + 1;
	end loop;
	
	if (Last_Empty_Row /= 0) then
		Dashboard(Last_Empty_Row,Column).Empty := False;
		Dashboard(Last_Empty_Row,Column).Player:= Player;
		Winner:= Vertical_Conection(Dashboard,Last_Empty_Row,Column,Player) or
			Horizontal_Conection(Dashboard,Last_Empty_Row,Column,Player) or
			Diagonal_Left_Conection(Dashboard,Last_Empty_Row,Column,Player) or
			Diagonal_Right_Conection(Dashboard,Last_Empty_Row,Column,Player);
	else
		raise Column_Full;
	end if;
end Put_Token;

procedure Add_Box_To_Us(US: in out ASU.Unbounded_String; Box_C: in Box) is
begin
	if Box_C.Empty then
		US:=ASU.To_Unbounded_String(ASU.To_String(US) & " - ");
	else
		case Box_C.Player is
			when 1 =>
				US:=ASU.To_Unbounded_String(ASU.To_String(US) & " " & Ada.Characters.Latin_1.ESC & "[91m" & "O" &
						 Ada.Characters.Latin_1.ESC & "[0m" & " ");
			when 2 =>
				US:=ASU.To_Unbounded_String(ASU.To_String(US) & " " & Ada.Characters.Latin_1.ESC & "[93m" & "O" &
				Ada.Characters.Latin_1.ESC & "[0m" & " ");
			when others =>
				US:=ASU.To_Unbounded_String(ASU.To_String(US) & "-");
		end case;
	end if;
end Add_Box_To_Us;

function Dashboard_To_US(Dashboard: in Board_Type) return ASU.Unbounded_String is
	Aux_Us: ASU.Unbounded_String;
begin
	for I in Dashboard'First..Dashboard'Last loop
		for J in Dashboard'Range loop
			Add_Box_To_Us(Aux_US,Dashboard(I,J) );
		end loop;
			Aux_US:=ASU.To_Unbounded_String(ASU.To_String(Aux_US) & ASCII.Lf);
	end loop;	
	return Aux_Us;
end;

end Vertical_Dashboard;
	

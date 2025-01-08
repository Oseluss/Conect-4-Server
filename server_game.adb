With Ada.Text_IO;

package body Server_Game is


	function Exists_Nick(C4_Game: in C4_Game_Type; Nick: ASU.Unbounded_String) return Boolean is
		I: Integer:= 1;
		Found_Nick: Boolean:= false;
	begin
		while (I <= C4_Game.Max_Players) and (not Found_Nick) loop
			Found_Nick:= (ASU.To_String(C4_Game.Player_Info(I).Nick) = ASU.To_String(Nick));
			I:= I + 1;		
		end loop;			
		return Found_Nick;
	end Exists_Nick;	

	procedure Set_Player_Info(C4_Game: in out C4_Game_Type; 
					Nick: in ASU.Unbounded_String; 
					EP: in LLU.End_Point_Type) is
					--Exists: out Boolean) is
	begin
		
	--	Exists := Exists_Nick(C4_Game,Nick);
	--	if not Exists then
			C4_Game.Player_Info(C4_Game.Current_Players + 1).Nick:= Nick;
			C4_Game.Player_Info(C4_Game.Current_Players + 1).EP:= EP;
			C4_Game.Current_Players:= C4_Game.Current_Players + 1;
	--	end if;
	end Set_Player_Info;	
	
	function Get_Dashboard(C4_Game: in C4_Game_Type) 
				return access VD.Board_Type is
	begin

		return C4_Game.Dashboard;

	end Get_Dashboard;		

	function Get_Client_EP(C4_Game: in C4_Game_Type; 
				Client: Integer) 
				return LLU.End_Point_Type is
	begin
		if Client >= 0 and Client <= C4_Game.Max_Players then
			return C4_Game.Player_Info(Client).Ep;
		else
			raise Player_Out_Of_Range;
		end if;
	end Get_Client_EP;

	function Get_Client_Name(C4_Game: in C4_Game_Type; 
				Client: Integer) 
				return ASU.Unbounded_String is
	begin
		
		if Client >= 0 and Client <= C4_Game.Max_Players then
			return C4_Game.Player_Info(Client).Nick;	
		else
			raise Player_Out_Of_Range;
		end if;
		
	end Get_Client_Name;
	
	function Get_Number_Players (C4_Game: in C4_Game_Type) 
				return Natural is
	begin
	
		return C4_Game.Current_Players;
	
	end Get_Number_Players;
	
	function Get_Max_Players (C4_Game: in C4_Game_Type) 
				return Natural is
	begin

		return C4_Game.Max_Players;
	
	end Get_Max_Players;
	
	function Get_Current_Turn (C4_Game: in C4_Game_Type) 
				return Natural is
	begin
		
		return C4_Game.Current_Turn;	
	
	end Get_Current_Turn;
	
	procedure Next_Turn(C4_Game: in out C4_Game_Type) is
	begin
		if C4_Game.Max_Players = C4_Game.Current_Turn then
			C4_Game.Current_Turn:= 1;
		else
			C4_Game.Current_Turn:= C4_Game.Current_Turn + 1;
		end if;
	
	end Next_Turn;
	
end Server_Game;

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with C4_Messages;
with Server_Game;
with Vertical_Dashboard;
with Ada.Command_Line;
with Server_Handler;

procedure Server is

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package CM renames C4_Messages;
	package SG renames Server_Game;
	package VD renames Vertical_Dashboard;
	package ACL renames Ada.Command_Line;	
	package SH renames Server_Handler;

Incorrect_Port: Exception;
Ignore_The_Message: Exception;
	
procedure Read_Port(Port : out Integer; Valid_Port: out Boolean) is
	Aux_Number: Integer;
begin
	Aux_Number:= Integer'Value(ACL.Argument(1));
	if  (Aux_Number >= 1024) and (ACL.Argument_Count = 1) then
		Port:= Aux_Number;
		Valid_Port:= True;
	else
		Ada.Text_IO.Put_Line ("Incorrect Port");
		Valid_Port:= False;
	end if; 
	exception
		when Ex:others =>
			Ada.Text_IO.Put_Line ("Argumnet Error");
			Valid_Port:= False;
end Read_Port;

procedure Show_Num_Games(Map: SH.Abb_Game_Map.Map) is
begin
	Ada.Text_IO.PUt_Line("===========NUMBER OF GAMES============");
	Ada.Text_IO.PUt("Server is currently hosting");
	Ada.Text_IO.PUt(Integer'Image(SH.Abb_Game_Map.Count_Nodes(Map)));
	Ada.Text_IO.PUt_Line(" games.");
	Ada.Text_IO.PUt_Line("--------------------------------------");
end Show_Num_Games;

procedure Send_Shutdown(Client_EP: LLU.End_Point_Type) is
	Buffer: aliased LLU.Buffer_Type(2048);
begin
	CM.Message_Type'Output (Buffer'Access, CM.ServerShutdown);
	LLU.Send(Client_EP, Buffer'Access);

end Send_Shutdown;

procedure Server_Shutdown(Players_Map: in out SH.Players_Hash_Map.Map) is
	C: SH.Players_Hash_Map.Cursor := SH.Players_Hash_Map.First(Players_Map);
begin
	while SH.Players_Hash_Map.Has_Element(C) loop
		Send_Shutdown(SH.Players_Hash_Map.Element(C).Value.Ep);
		SH.Players_Hash_Map.Next(C);
	end loop;	
end Server_Shutdown;

	Server_EP: LLU.End_Point_Type;
	Port: Integer;
	Valid_Port: Boolean;
	User_Input: Character;
	Avalible: Boolean;
	
begin
	Read_Port(Port, Valid_Port);
	if Valid_Port then
		Server_EP := LLU.Build (LLU.To_IP(LLU.Get_Host_Name), Port);
		LLU.Bind (Server_EP, Server_Handler.Server_Handler'Access);
		loop
			Ada.Text_IO.Get_Immediate(User_Input,Avalible);
			if Avalible and then User_Input = 'n' then
				Show_Num_Games(SH.Game_Map);
			elsif Avalible and then User_Input = 'c' then
				Server_Shutdown(SH.Players_Map);
				exit;
			end if;
		end loop;
	end if;
	LLU.Finalize;
end Server;

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with C4_Messages;
with Client_Handler;

procedure Client is
	package CH renames Client_Handler;
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package ACL renames Ada.Command_Line;
	package CM renames C4_Messages;
	
Invalid_Imput: Exception;
Welcome_Not_Received: Exception;
Ended_Game_In_Turn: Exception;

-- messages

procedure Send_Join(Server_EP: in LLU.End_Point_Type;
			Client_EP: in LLU.End_Point_Type; 
			Client_EP_Handler: in LLU.End_Point_Type;
			Nick,Key: in ASU.Unbounded_String) is
	Buffer: aliased LLU.Buffer_Type(2048);
begin
	CM.Message_Type'Output(Buffer'Access, CM.Join);
	LLU.End_Point_Type'Output(Buffer'Access, Client_EP);
	LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
	ASU.Unbounded_String'Output(Buffer'Access, Nick);
	ASU.Unbounded_String'Output(Buffer'Access, Key);
	LLU.Send(Server_EP, Buffer'Access);
end Send_Join;

procedure Send_BoardRequest(Server_EP: in LLU.End_Point_Type;
			Client_EP_Handler: in LLU.End_Point_Type;
			Nick: in ASU.Unbounded_String) is
	Buffer: aliased LLU.Buffer_Type(2048);
begin
	CM.Message_Type'Output(Buffer'Access, CM.BoardRequest);
	LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
	ASU.Unbounded_String'Output(Buffer'Access, Nick);
	LLU.Send(Server_EP, Buffer'Access);
end Send_BoardRequest;

procedure Send_Logout(Server_EP: in LLU.End_Point_Type;
			Client_EP: in LLU.End_Point_Type; Nick,Key: in ASU.Unbounded_String) is
	Buffer: aliased LLU.Buffer_Type(2048);
begin
	CM.Message_Type'Output(Buffer'Access, CM.Logout);
	ASU.Unbounded_String'Output(Buffer'Access, Key);	
	ASU.Unbounded_String'Output(Buffer'Access, Nick);
	LLU.End_Point_Type'Output(Buffer'Access, Client_EP);
	LLU.Send(Server_EP, Buffer'Access);
end Send_Logout;

procedure Send_Move(Server_EP: in LLU.End_Point_Type;
			Key: in ASU.Unbounded_String; Column: in Positive) is
	Buffer: aliased LLU.Buffer_Type(2048);
begin
	CM.Message_Type'Output(Buffer'Access, CM.Move);
	Integer'Output(Buffer'Access, Column);
	ASU.Unbounded_String'Output(Buffer'Access, Key);
	LLU.Send(Server_EP, Buffer'Access);
end Send_Move;


--end messages

procedure Welcome_Replay(Buffer: in out LLU.Buffer_Type; Acepted: out Boolean;
						Key: in out ASU.Unbounded_String;
						Nick: in ASU.Unbounded_String) is 
	Aux_US: ASU.Unbounded_String;
begin
	Acepted := Boolean'Input(Buffer'Access);
	Aux_US := ASU.Unbounded_String'Input(Buffer'Access);
	Key := ASU.Unbounded_String'Input(Buffer'Access);
	if Acepted then
		Ada.Text_IO.Put_Line ("Welcome " & ASU.To_String(Nick) &
							 "- Game Key: " &  ASU.To_String(Key));
		Ada.Text_IO.Put_Line ("Waiting for game to start ...");
	else
		Ada.Text_IO.Put_Line (ASU.To_String(Aux_US));
	end if;
end Welcome_Replay;


procedure Recive_Welcome(Buffer: in out LLU.Buffer_Type;
			Client_EP: in LLU.End_Point_Type;
			Acepted: out Boolean;
			Key: out ASU.Unbounded_String;
			Nick: in ASU.Unbounded_String) is
	Expired: Boolean;
	Aux_SM: CM.Message_Type;
begin
	LLU.Receive(Client_EP, Buffer'Access, 10.0, Expired);
	if Expired then
		Ada.Text_IO.Put_Line ("Server unreachable");
		Acepted:= False;
	else
		Aux_SM := CM.Message_Type'Input (Buffer'Access);
		case Aux_SM is
			when CM.Welcome =>	
				Welcome_Replay(Buffer,Acepted,Key,Nick);
			when others =>
				raise Welcome_Not_Received;
		end case;
	end if;
end Recive_Welcome;

procedure Read_Arguments(Server_Name: out ASU.Unbounded_String; Server_Port: out Integer;
			Nick,Key: out ASU.Unbounded_String; Correct_Arguments: out Boolean) is
	Aux_Number: Integer;
begin
	Server_Name:= ASU.To_Unbounded_String(ACL.Argument(1));
	Aux_Number:= Integer'Value(ACL.Argument(2));
	Nick:= ASU.To_Unbounded_String(ACL.Argument(3));
	if  (Aux_Number >= 1024) and (ACL.Argument_Count = 3) then
		Server_Port:= Aux_Number;
		Key:= ASU.Null_Unbounded_String;
		Correct_Arguments:= True;
	elsif  (Aux_Number >= 1024) and (ACL.Argument_Count = 4) then
		Server_Port:= Aux_Number;
		Key:= ASU.To_Unbounded_String(ACL.Argument(4));
		Correct_Arguments:= True;
	else
		Ada.Text_IO.Put_Line ("Incorrect Arguments");
		Correct_Arguments:= False;
	end if; 
	exception
		when Ex:others =>
			Ada.Text_IO.Put_Line ("Argument Error");
			Correct_Arguments:= False;
end Read_Arguments;

procedure Read_Boolean(B: out Boolean) is
	User_Input: ASU.Unbounded_String;
begin
	User_Input:= Asu.To_Unbounded_String(Ada.Text_IO.Get_Line);
	if ASU.To_String(User_Input) = "Y" then
		B:= True;
	elsif ASU.To_String(User_Input) = "N" then
		B:= False;
	else
		Ada.Text_IO.Put_Line("Enter Y/N");
		Read_Boolean(B);
	end if;
end Read_Boolean;

procedure Read_Nick(Nick: out ASU.Unbounded_String) is
begin
	Ada.Text_IO.Put("What game would you like to get?");
	Nick:=ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
end REad_Nick;

procedure Read_Key(End_Game: out Boolean;
					Client_EP_Handler,Server_EP: in LLU.End_Point_Type;
					Nick,Key: in ASU.Unbounded_String) is
	Avalible: Boolean;
	User_Input: Character;
	Aux_Nick: ASU.Unbounded_String;
begin
	Ada.Text_IO.Get_Immediate(User_Input,Avalible);
	if Avalible and then User_Input = 'q' then
		Ada.Text_IO.Put_Line("Do you want exits?");
		Read_Boolean(End_Game);
	else
		if Avalible and then User_Input = 't' then
			Read_Nick(Aux_Nick);
			Send_BoardRequest(Server_Ep,Client_Ep_Handler,Aux_Nick);
		end if;
		End_Game:= False;
	end if;
	if End_Game then
		Send_Logout(Server_EP,Client_EP_Handler,Nick,Key);
		Ada.Text_IO.Put_Line("You have abandoned the game.");
	end if;
end Read_Key;

procedure Read_Input(Number: out Positive; Want_quit: out boolean) is
	User_Input: ASU.Unbounded_String;
	Correct_Input: Boolean:= false;
	Ok: Boolean := False;
begin
	loop
	
		User_Input:= Asu.To_Unbounded_String(Ada.Text_IO.Get_Line);	
-- pregutar si asi es una buena manera
		if CH.Client_State'Image(CH.State) = CH.Client_State'Image(CH.FinishedGame) or
			CH.Client_State'Image(CH.State) = CH.Client_State'Image(CH.ServerShutdown) then
			raise Ended_Game_In_Turn;	
		end if;	
		begin
			Number:= Positive'Value(ASU.To_String(User_Input));
			Want_quit:= False;
			Correct_Input:= True;	
		exception
			when Constraint_Error=> 
-- Preguntar como lolucionar esta vaina
				if ASU.To_String(User_Input) /= "q" then
					Ada.Text_IO.Put_Line("Value rejected. Enter a value between 1 and 10:");
					Correct_Input:= False;
				else
					Ada.Text_IO.Put_Line("Do you want exits?");
					Read_Boolean(Want_quit);
					Correct_Input:= Want_quit;	
					Number:= 1;
				end if;
		end;
		exit when Correct_Input;
	end loop;
end Read_Input;

procedure Turn(Client_EP_Handler,Server_EP: in LLU.End_Point_Type;
			Nick,Key: in ASU.Unbounded_String; End_Game: out Boolean) is 
	Aux_Number: Positive;
	Want_quit: Boolean;
begin
	Read_Input(Aux_Number,Want_quit);
	if not Want_quit then
		Send_Move(Server_EP,Key,Aux_Number);
		End_Game:= False;
	else
		Send_Logout(Server_EP,Client_EP_Handler,Nick,Key);
		Ada.Text_IO.Put_Line("You have abandoned the game.");
		End_Game:= True;
	end if;

end Turn;

procedure Play_Game(Buffer: in out LLU.Buffer_Type;
			Client_EP_Handler,Server_EP: in LLU.End_Point_Type;
			Nick, Key: in ASU.Unbounded_String) is
	End_Game: Boolean:= False;
begin
	loop
		case CH.State is
			when CH.InGame =>
				Read_Key(End_Game,Client_EP_Handler,Server_EP,Nick,Key);
			when CH.OurTurn =>
				Ada.Text_IO.Put_Line ("This is your turn, enter your move:");
				Turn(Client_EP_Handler,Server_Ep,Nick,Key,End_Game);
				-- En el caso de que cabie el valor Finishgame
				-- No entre en un bucle infinito
				-- preguntar si tiene que escribir o algo y como hacerlo para romer la ect
				-- alomejor decirle por introduce cualquier valor
				if CH.Client_State'Image(CH.State) = CH.Client_State'Image(CH.OurTurn) then
					-- Problema de que tarda mas en responder que dar una bueta
					-- Luego he optado por continuar el juego hasta nuevo mensaje
					CH.State:= CH.Ingame;
				end if;		
			when CH.MoveRejected =>
				Turn(Client_EP_Handler,Server_Ep,Nick,Key,End_Game);
				if CH.Client_State'Image(CH.State) = CH.Client_State'Image(CH.MoveRejected) then
					CH.State:= CH.Ingame;
				end if;		
			when CH.FinishedGame =>
				End_Game:= True;
			when CH.WaitingForGame =>
				Read_Key(End_Game,Client_EP_Handler,Server_EP,Nick,Key);
			when CH.ServerShutdown =>
				End_Game:= True;
			when others =>
				Ada.Text_IO.Put(".");
				end case;					
		exit when End_Game;
		end loop;	
end Play_Game;

	Client_EP: LLU.End_Point_Type;
	Client_EP_Handler: LLU.End_Point_Type;
	Server_EP: LLU.End_Point_Type;
	Buffer:    aliased LLU.Buffer_Type(2048);
	Acepted : Boolean:= True;
	Server_Name: ASU.Unbounded_String;
	Server_Port: Integer;
	Nick: ASU.Unbounded_String;
	Correct_Arguments: Boolean;
	Key: ASU.Unbounded_String;
	
begin
	Read_Arguments(Server_Name,Server_Port,Nick,Key,Correct_Arguments);
	if Correct_Arguments then
		Server_EP := LLU.Build(LLU.To_IP(ASU.To_String(Server_Name)), Server_Port);
		LLU.Bind_Any(Client_EP);
		LLU.Bind_Any(Client_EP_Handler, Client_Handler.Client_Handler'Access);
		Send_Join(Server_EP,Client_EP,Client_EP_Handler,Nick,Key);
		Recive_Welcome(Buffer,Client_EP,Acepted,Key,Nick);
		if Acepted then
			Play_Game(Buffer,Client_EP_Handler,Server_EP,Nick,Key);
		end if;
	end if;
	LLU.Finalize;

exception
	when Welcome_Not_Received =>
		Ada.Text_IO.Put_Line ("Welcome not recived");
		LLU.Finalize;
	when Ended_Game_In_Turn =>
		LLU.Finalize;

end Client;

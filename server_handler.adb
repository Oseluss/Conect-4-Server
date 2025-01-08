package body Server_Handler is
	
	function equal(US1,US2: ASU.Unbounded_String) return boolean is
	begin
		return ASU.To_String(US1) = ASU.To_String(US2);
	end equal;
	
	function less(US1,US2: ASU.Unbounded_String) return boolean is
	begin
		return ASU.To_String(US1) < ASU.To_String(US2);
	end less;
	
	function more(US1,US2: ASU.Unbounded_String) return boolean is
	begin
		return ASU.To_String(US1) > ASU.To_String(US2);
	end more;
	
	function Game_To_String(C4_Game: SG.C4_Game_Type) return string is
	begin
		return "Nada";
	end Game_To_String;
	
	
	
	
	--messages
		
	procedure Send_Welcome(Client_EP: in LLU.End_Point_Type;
				Acepted: in Boolean; Reason, Key: in ASU.Unbounded_String) is
		Buffer: aliased LLU.Buffer_Type(2048);
	begin
		CM.Message_Type'Output (Buffer'Access, CM.Welcome);
		Boolean'Output (Buffer'Access,Acepted);
		ASU.Unbounded_String'Output (Buffer'Access, Reason);
		ASU.Unbounded_String'Output (Buffer'Access, Key);
		LLU.Send(Client_EP, Buffer'Access);
	end Send_Welcome;


	procedure Send_MoveRecived(Client_EP: in LLU.End_Point_Type;
				Acepted: in Boolean) is
		Buffer: aliased LLU.Buffer_Type(2048);
	begin
		CM.Message_Type'Output (Buffer'Access, CM.MoveRecived);
		Boolean'Output (Buffer'Access,Acepted);
		LLU.Send(Client_EP, Buffer'Access);
	end Send_MoveRecived;


	procedure Send_Server(Client_EP: in LLU.End_Point_Type; 
				Message: in ASU.Unbounded_String) is
		Buffer: aliased LLU.Buffer_Type(2048);
	begin
		CM.Message_Type'Output (Buffer'Access, CM.Server);
		ASU.Unbounded_String'Output (Buffer'Access, Message);
		LLU.Send(Client_EP, Buffer'Access);
	end Send_Server;
	
	procedure Send_StartGame(C4_game: in SG.C4_Game_Type) is
		Buffer: aliased LLU.Buffer_Type(2048);
	begin
		CM.Message_Type'Output (Buffer'Access, CM.StartGame);
		for I in 1..SG.Get_Number_Players (C4_game) loop
			LLU.Send(SG.Get_Client_EP(C4_game, I), Buffer'Access);
		end loop;
	end Send_StartGame;
	
	procedure Send_EndGameM(Client_EP: in LLU.End_Point_Type;
							Winner,Dashboard,Quitter: in ASU.Unbounded_String;
							You_Win: in Boolean) is
		Buffer: aliased LLU.Buffer_Type(2048);
	begin
		LLU.Reset(Buffer);
		CM.Message_Type'Output (Buffer'Access, CM.EndGame);
		ASU.Unbounded_String'Output (Buffer'Access, Winner);
		ASU.Unbounded_String'Output (Buffer'Access, Dashboard);
		ASU.Unbounded_String'Output (Buffer'Access, Quitter);
		Boolean'Output(Buffer'Access,You_Win);
		LLU.Send(Client_EP, Buffer'Access);
		
	end Send_EndGameM;

	procedure Send_EndGame(C4_Game: in SG.C4_Game_Type;
				Nick: in ASU.Unbounded_String; Win: in Boolean) is
		Dashboard,Winner,Quitter: ASU.Unbounded_String;
	begin
		Dashboard:=	VD.Dashboard_To_US(SG.Get_Dashboard(C4_Game).ALL);
		if ASU.To_String(Nick) = "" then
			for I in 1..SG.Get_Number_Players (C4_game) loop
				Send_EndGameM(SG.Get_Client_EP(C4_game, I),Nick,Dashboard,Nick,False);
			end loop;	
		else
			if Win then
				Winner:= Nick;
				Quitter:=ASU.To_Unbounded_String("");
			else
				Quitter:= Nick;
				Winner:=ASU.To_Unbounded_String("");
			end if;
			for I in 1..SG.Get_Number_Players (C4_game) loop
				Send_EndGameM(SG.Get_Client_EP(C4_game, I),Winner,Dashboard,Quitter,
					ASU.To_String(SG.Get_Client_Name(C4_game, I))=ASU.To_String(Winner));
			end loop;
		end if;
	end Send_EndGame;
	
	procedure Send_YourTurn(C4_Game: in SG.C4_Game_Type) is
		Buffer: aliased LLU.Buffer_Type(2048);
	begin
		LLU.Reset(Buffer);
		CM.Message_Type'Output (Buffer'Access, CM.YourTurn);
		LLU.Send(SG.Get_Client_Ep(C4_Game,SG.Get_Current_Turn(C4_Game)), Buffer'Access);
	end Send_YourTurn;
	--end messages
	
	
	procedure Extract_Join(Buffer:  access LLU.Buffer_Type;
							Client_Ep,CLient_Ep_H: out LLU.End_Point_Type;
							Nick,Key : out ASU.Unbounded_String) is
	begin
		Client_EP := LLU.End_Point_Type'Input (Buffer);
		Client_EP_H:= LLU.End_Point_Type'Input (Buffer);
		Nick := ASU.Unbounded_String'Input (Buffer);
		Key := ASU.Unbounded_String'Input (Buffer);
	end Extract_Join;		
	
	
	function Exists_Nick_Map(Map: in Abb_Game_Map.Map;
							Nick: in ASU.Unbounded_String) return boolean is
	begin
		if Abb_Game_Map.Is_Map_Null(Map) then
			return false;
		else
			if not SG.Exists_Nick(Abb_Game_Map.Node_Value(Map),Nick) then
				if Exists_Nick_Map(Abb_Game_Map.Map_Left(Map),Nick) then
					return true;
				elsif Exists_Nick_Map(Abb_Game_Map.Map_Right(Map),Nick) then
					return true;
				else
					return false;
				end if;
			else
				return True;
			end if;
		end if;
	end Exists_Nick_Map;
	
	procedure Search_Any(Map: in Abb_Game_Map.Map; Key: in out ASU.Unbounded_String;
							Game: out SG.C4_Game_Type; Avalible_Game: in out boolean) is
	begin
			--Value := ASU.Null_Unbounded_String;
		If Abb_Game_Map.Is_Map_Null(Map) then
			Avalible_Game := False;
		else
			if SG.Get_Number_Players (Abb_Game_Map.Node_Value(Map)) < 
								SG.Get_Max_Players (Abb_Game_Map.Node_Value(Map)) then
				Key:= Abb_Game_Map.Node_KEY(Map);
				Avalible_Game := True;
				Game:= Abb_Game_Map.Node_Value(Map);
			else
				Search_Any(Abb_Game_Map.Map_Left(Map), Key, Game, Avalible_Game);
				if not Avalible_Game then
					Search_Any(Abb_Game_Map.Map_Right(Map), Key, Game, Avalible_Game);
				end if;
			end if;
		end if;
	end Search_Any;
	
	procedure Search_Avalible_Game(Map: in Abb_Game_Map.Map;
							Key,Nick: in out ASU.Unbounded_String;-- we use nick when not key
							Game: out SG.C4_Game_Type; 
							Avalible_Game: in out boolean) is
	Exists_Key: Boolean;
	begin
		if ASU.To_String(Key) = ""  then
			Search_Any(Map,Key,Game,Avalible_Game);
			if not Avalible_Game then
				Abb_Game_Map.Get(Map,Nick,Game,Exists_Key);
				-- We know there arent a game with 1 player
				-- Can only be avalible game if dont exists a key equal to the nick
				Avalible_Game:= not Exists_Key;
				Key:= Nick;
			end if;
		else
			Abb_Game_Map.Get(Map,Key,Game,Exists_Key);
			if Exists_Key then
				if SG.Get_Number_Players (Game) < 
									SG.Get_Max_Players (Game) then
					Avalible_Game := True;
				else
					Avalible_Game:= False;
				end if;
			else
				Avalible_Game:= True;
			end if;
		end if;
	end Search_Avalible_Game;
	
	procedure Send_New_Conection(Nick: in ASU.Unbounded_String;
					C4_Game: in out SG.C4_Game_Type) is
		Aux_US: ASU.Unbounded_String;
	begin
		if SG.Get_Number_Players(C4_game) > 1 then
			Aux_US:= ASU.To_Unbounded_String(ASU.To_String(Nick) &  " joins the game " &
				Integer'Image(SG.Get_Number_Players (C4_game)) & "/ " &
				Integer'Image(SG.Get_Max_Players(C4_game)));
			for I in 1..(SG.Get_Number_Players (C4_game) - 1) loop
				Send_Server(SG.Get_Client_EP(C4_game, I),Aux_US);
			end loop;
		end if;
	end Send_New_Conection;
	
	procedure Write_Game_Start(C4_Game: in SG.C4_Game_Type; Key: ASU.Unbounded_String) is
	begin
		Ada.Text_IO.Put(ASU.To_String(SG.Get_Client_Name(C4_game, 1)));
		Ada.Text_IO.Put(" and ");
		Ada.Text_IO.Put(ASU.To_String(SG.Get_Client_Name(C4_game, 2)));
		Ada.Text_IO.Put(" game has started - Game Key: ");
		Ada.Text_IO.Put_LIne(ASU.To_String(Key));
		
	end Write_Game_Start;
	-- It send the message to the player without turn
	procedure Send_Waiting_Server(Game: SG.C4_Game_Type) is
	begin
		case SG.Get_Current_Turn(Game) is
			when 1 =>
				Send_Server(SG.Get_CLient_Ep(Game,2),
							ASU.To_Unbounded_String("Waitting for player 1 .."));
			when 2 =>
				Send_Server(SG.Get_CLient_Ep(Game,1),
							ASU.To_Unbounded_String("Waitting for player 2 .."));
			when others =>
				Ada.Text_IO.Put_Line("Waiting message error");
		end case;
		
	end Send_Waiting_Server;
	
	function Unbounded_String_Hash (US: ASU.Unbounded_String) return Hash_Range is
		N: Natural;
		C: Character;
	begin
		N:= 0;
		for I in 1..ASU.Length(US) loop
			C:= ASU.Element(US,I);	
   			N:= N + (Character'Pos(C));
   		end loop;
		return Hash_Range'Mod(N);
	end Unbounded_String_Hash;
	
	procedure Add_Player(Nick: ASU.Unbounded_String;
						Ep:LLU.End_Point_Type;
						Key: ASU.Unbounded_String) is
		V: C4_Value_Type;
	begin
		V.Ep:= Ep;
		V.Game_Key:= Key;
		Players_Hash_Map.Put (Players_Map, Nick, V);
	end Add_Player;
	
	procedure Delete_Players(Game: SG.C4_Game_Type) is
		Success: Boolean;
	begin
		for I in 1..SG.Get_Number_Players (Game) loop
			Players_Hash_Map.Delete(Players_Map,SG.Get_Client_Name(Game, I),Success);
		end loop;
	end;
					
	procedure Join_Response(Buffer: access LLU.Buffer_Type;Map: in out Abb_Game_Map.Map) is
		Aux_Client_EP : LLU.End_Point_Type;
		Aux_Client_EP_Handler : LLU.End_Point_Type;	
		Aux_Nick : ASU.Unbounded_String;
		Aux_Key: ASU.Unbounded_String;
		
		Aux_Game: SG.C4_Game_Type;
		Avalible_Game: Boolean;
		
		Acepted: Boolean;
		Reason: ASU.Unbounded_String;
	begin
		Extract_Join(Buffer,Aux_Client_EP,Aux_Client_EP_Handler,Aux_Nick,Aux_Key);
		Ada.Text_IO.Put( ASU.To_String(Aux_Nick) & " is trying to join a game...");
		if not Exists_Nick_Map(Map,Aux_Nick) then
			Search_Avalible_Game(Map,Aux_Key,Aux_Nick,Aux_Game,Avalible_Game);	
			if Avalible_Game then
				Add_Player(Aux_Nick,Aux_Client_EP_Handler,Aux_Key);
				SG.Set_Player_Info(Aux_Game,Aux_Nick,Aux_Client_EP_Handler);
				Abb_Game_Map.Put(Map,Aux_Key,Aux_Game);
				Acepted:= True;
				Reason:= ASU.To_Unbounded_String("Acepted");
				Ada.Text_IO.Put_Line("Joined successfully. - Game Key:" & ASU.To_String(Aux_Key));
				Send_Welcome(Aux_Client_EP,Acepted,Reason,Aux_Key);
				Send_New_Conection(Aux_Nick,Aux_Game);
				if not (SG.Get_Number_Players(Aux_Game) < SG.Get_Max_Players(Aux_Game)) then
					Send_StartGame(Aux_Game);
					Write_Game_Start(Aux_Game,Aux_Key);
					Send_YourTurn(Aux_Game);
					Send_Waiting_Server(Aux_Game);
				end if;
			else
				Acepted:= False;
				Reason:= ASU.To_Unbounded_String("Could not join. Game is full.");
				Ada.Text_IO.Put_Line("Rejected. " & ASU.To_String(Reason));
				Send_Welcome(Aux_Client_EP,Acepted,Reason,Aux_Key);
			end if;
		else
			Acepted:= false;
			Reason:= ASU.To_Unbounded_String("Could not join. Duplicated nickname.");
			Ada.Text_IO.Put_Line("Rejected. " & ASU.To_String(Reason));
			Send_Welcome(Aux_Client_EP,Acepted,Reason,Aux_Key);
		end if;
	exception
			when Players_Hash_Map.Full_Map =>
				Acepted:= False;
				Reason:= ASU.To_Unbounded_String("Could not join. Full Players.");
				Ada.Text_IO.Put_Line("Rejected. " & ASU.To_String(Reason));
				Send_Welcome(Aux_Client_EP,Acepted,Reason,Aux_Key);
	end Join_Response;
	
		
	procedure Extract_Move(Buffer:  access LLU.Buffer_Type;
							Column: out Positive;
							Key : out ASU.Unbounded_String) is
	begin
		Column := Positive'Input (Buffer);
		Key := ASU.Unbounded_String'Input (Buffer);
	end Extract_Move;	
	
	function Correct_Column(Column: Integer) return Boolean is
	begin
		return (Column <= 10) and (Column >=1);
	end Correct_Column;

	-- Send the message to the current player
	procedure Send_Dashboard(C4_game: in SG.C4_Game_Type) is
		Aux_US: ASU.Unbounded_String;
		Aux_Number: Integer;
	begin
		Aux_US:= VD.Dashboard_To_US(SG.Get_Dashboard(C4_Game).ALL);
		Aux_Number:= SG.Get_Current_Turn(C4_Game);
		Send_Server(SG.Get_Client_EP(C4_game, Aux_Number),Aux_US);
	end Send_Dashboard;
	
	procedure Send_Server_To_ALL(C4_game: in SG.C4_Game_Type; Message: ASU.Unbounded_String) is
	begin
		for I in 1..SG.Get_Number_Players (C4_game) loop
			Send_Server(SG.Get_Client_EP(C4_game, I),Message);
		end loop;
	end Send_Server_To_ALL;
	
	procedure Move_Response(Buffer: access LLU.Buffer_Type; Map: in out Abb_Game_Map.Map) is
		Aux_Column: Positive;
		Aux_Key: ASU.Unbounded_String;
		Aux_Game: SG.C4_Game_Type;
		Success: Boolean;
		Aux_Nick: ASU.Unbounded_String;
		Winner: Boolean;
		Delete: Boolean;
		Aux_US: ASU.Unbounded_String;
	begin
		Extract_Move(Buffer,Aux_Column,Aux_Key);
		Abb_Game_Map.Get(Map,Aux_Key,Aux_Game,Success);
		if Success then
			Aux_Nick:= SG.Get_Client_Name(Aux_Game,SG.Get_Current_Turn(Aux_Game));
			Ada.Text_IO.Put(ASU.To_String(Aux_Key) & " - ");
			Ada.Text_IO.Put(ASU.To_String(Aux_Nick) & "'s move:" & Integer'Image(Aux_Column));
			if Correct_Column(Aux_Column) then
				VD.Put_Token(SG.Get_Dashboard(Aux_Game).ALL,Aux_Column,
					SG.Get_Current_Turn(Aux_Game), Winner);
				-- It have to be True, correct column
				Send_MoveRecived(SG.Get_Client_Ep(Aux_Game,SG.Get_Current_Turn(Aux_Game)),True);
				Ada.Text_IO.Put_Line("- Valid");
				SG.Next_Turn(Aux_Game);
				Send_Waiting_Server(Aux_Game);
				Send_Dashboard(Aux_Game);
				Abb_Game_Map.Put(Map,Aux_Key,Aux_Game);
				if Winner then
					Send_EndGame(Aux_Game,Aux_Nick,True);
					Ada.Text_IO.Put(ASU.To_String(Aux_Key) & " - ");
					Ada.Text_IO.Put_Line(ASU.To_String(Aux_Nick) & " has won the game!");
				elsif VD.Dashboard_Is_Full(SG.Get_Dashboard(Aux_Game).ALL) then
					Ada.Text_IO.Put(ASU.To_String(Aux_Key) & " - Draw, Nobody wins");
					Send_EndGame(Aux_Game,ASU.To_Unbounded_String(""),False);
				else	
					Send_YourTurn(Aux_Game);
				end if;
				if Winner or VD.Dashboard_Is_Full(SG.Get_Dashboard(Aux_Game).ALL) then
					Abb_Game_Map.Delete(Map,Aux_Key,Delete);
					Delete_Players(Aux_Game);
				end if;
			else
				Aux_US:= ASU.To_Unbounded_String("Move rejected. Enter a value between 1 and 10:");
				Send_Server(SG.Get_Client_Ep(Aux_Game,SG.Get_Current_Turn(Aux_Game)),Aux_US);
				Send_MoveRecived(SG.Get_Client_Ep(Aux_Game,SG.Get_Current_Turn(Aux_Game)),False);
				Ada.Text_IO.Put_Line("- Invalid");
			end if;
		else
			Ada.Text_IO.Put_Line("Ignored move. The game dont exists");
		end if;
		exception
			when VD.Column_Full =>
				Aux_US:= ASU.To_Unbounded_String("Move rejected.Column full, enter a value:");
				Send_Server(SG.Get_Client_Ep(Aux_Game,SG.Get_Current_Turn(Aux_Game)),Aux_US);
				Send_MoveRecived(SG.Get_Client_Ep(Aux_Game,SG.Get_Current_Turn(Aux_Game)),False);
				Ada.Text_IO.Put_Line("- Invalid, Column Full");

	end Move_Response;
	
	procedure Extract_Logout(Buffer: access LLU.Buffer_Type;
							Key,Nick: out ASU.Unbounded_String;
							Client_Ep: out LLU.End_Point_Type) is
	begin
		Key := ASU.Unbounded_String'Input(Buffer);
		Nick := ASU.Unbounded_String'Input (Buffer);
		Client_EP := LLU.End_Point_Type'Input (Buffer);
	end Extract_Logout;
	
	function Exists_Player(Game: in SG.C4_Game_Type; Nick: in ASU.Unbounded_String;
							Client_Ep: in LLU.End_Point_Type) return Boolean is
		I: Integer:= 1;
		Found_Player: Boolean:= false;
	begin
		while (I <= SG.Get_Max_Players(Game)) and (not Found_Player) loop
			Found_Player:= (ASU.To_String(Nick) = ASU.To_String(SG.Get_Client_Name(Game,I)))
							and (LLU.Image(Client_EP) = LLU.Image(SG.Get_Client_EP(Game,I)));
			I:= I + 1;		
		end loop;			
		return Found_Player;
	end Exists_Player;	

	procedure Logout_Response(Buffer: access LLU.Buffer_Type; Map: in out Abb_Game_Map.Map) is
		Aux_Key: ASU.Unbounded_String;
		Aux_Nick: ASU.Unbounded_String;
		Aux_Client_Handler_EP: LLU.End_Point_Type;
		Success: Boolean;
		Delete: Boolean; 
		Aux_Game: SG.C4_Game_Type;
	begin
		Extract_Logout(Buffer,Aux_Key,Aux_Nick,Aux_Client_Handler_EP);
		Ada.Text_IO.Put(ASU.To_String(Aux_Key) & " - ");
		Abb_Game_Map.Get(Map,Aux_Key,Aux_Game,Success);
		if Success then
			if Exists_Player(Aux_Game,Aux_Nick,Aux_Client_Handler_EP) then
				Ada.Text_IO.Put_Line(ASU.To_String(Aux_Nick) &
					" abandoned the game. Game has finished.");
				Send_EndGame(Aux_Game,Aux_Nick,False);
				Delete_Players(Aux_Game);
				Abb_Game_Map.Delete(Map,Aux_Key,Delete);
			else
				Ada.Text_IO.Put_Line(ASU.To_String(Aux_Nick) &
					"is not a player and cant quit");
			end if;
		else
			Ada.Text_IO.Put_Line("The room dont exists");
		end if;
	end Logout_Response;
	
	procedure Board_Request(Buffer: access LLU.Buffer_Type; Map: in out Abb_Game_Map.Map) is
		Aux_Nick: ASU.Unbounded_String;
		Aux_Client_Handler_EP: LLU.End_Point_Type;
		Success: Boolean;
		Aux_Game: SG.C4_Game_Type;
		Message: ASU.Unbounded_String;
		V: C4_Value_Type;
	begin
		Aux_Client_Handler_EP := LLU.End_Point_Type'Input (Buffer);
		Aux_Nick := ASU.Unbounded_String'Input (Buffer);
		Ada.Text_Io.Put_Line("Trying to get " & ASU.To_String(Aux_Nick) & "'s dashboard");
		Players_Hash_Map.Get(Players_Map,Aux_Nick,V,Success);
		if success then
			Abb_Game_Map.Get(Map,V.Game_Key,Aux_Game,Success);
			if success then 
				Message:= VD.Dashboard_To_US(SG.Get_Dashboard(Aux_Game).ALL);
			else
				Message:= ASU.To_Unbounded_String("Game not exit");
			end if;
		else
			Message:= ASU.To_Unbounded_String(ASU.To_String(Aux_Nick) 
											& " is not playing a game right now");
		end if;
		Send_Server(Aux_Client_Handler_EP,Message);
	end;
	
	Client_Message: CM.Message_Type;
	
	procedure Server_Handler(From : in LLU.End_Point_Type;
							To : in LLU.End_Point_Type;
							Buffer : access LLU.Buffer_Type) is
	begin
Ada.Text_IO.Put_Line("");
		Client_Message := CM.Message_Type'Input (Buffer);
		case Client_Message is
			when CM.Join =>
				Join_Response(Buffer,Game_Map);				
			when CM.Move =>
				Move_Response(Buffer,Game_Map);
			when CM.Logout =>
				Logout_Response(Buffer,Game_Map);
			when CM.BoardRequest =>
				Board_Request(Buffer,Game_Map);
			when others =>
				raise Constraint_Error;
		end case;
	end Server_Handler;	
end Server_Handler;

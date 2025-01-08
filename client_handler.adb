with C4_Messages;

package body Client_Handler is

	procedure Client_Handler(From : in LLU.End_Point_Type;
							To : in LLU.End_Point_Type;
							Buffer : access LLU.Buffer_Type) is
	Aux_Number: Integer:= 1;
	Aux_US: ASU.Unbounded_String;
	Aux_US_Winner: ASU.Unbounded_String;
	Aux_US_Quitter: ASU.Unbounded_String;
	Aux_US_Dashboard: ASU.Unbounded_String;
	Aux_SM: CM.Message_Type;
	begin
		Aux_SM := CM.Message_Type'Input (Buffer);
		case Aux_SM is
			when CM.StartGame =>	
				Ada.Text_IO.Put_LIne ("- Game Started -");
				State:= InGame;
			when CM.Server =>
				Aux_US := ASU.Unbounded_String'Input(Buffer);
				Ada.Text_IO.Put_Line (ASU.To_String(Aux_US));
			when CM.YourTurn =>
				State:= OurTurn;
			when CM.MoveRecived =>
				if not Boolean'Input(Buffer) then
					State:= MoveRejected;
				else
					State:= InGame;
				end if;
			when CM.EndGame =>
				Aux_US_Winner:= ASU.Unbounded_String'Input(Buffer);
				Aux_US_Dashboard := ASU.Unbounded_String'Input(Buffer);
				Aux_US_Quitter := ASU.Unbounded_String'Input(Buffer);
				if Boolean'Input(Buffer) then
					Ada.Text_IO.Put_Line ("You has won the game!");
					Ada.Text_IO.Put_Line (ASU.To_String(Aux_US_Dashboard));
				else
					if ASU.To_String(Aux_US_Quitter) /= "" then
						Ada.Text_IO.Put_Line ("Game over, " & ASU.To_String(Aux_US_Quitter) 
											& " quit. Nobody wins.");
					elsif ASU.To_String(Aux_US_Winner) /= "" then
						Ada.Text_IO.Put_Line (ASU.To_String(Aux_US_Winner) & " has won the game!");
						Ada.Text_IO.Put_Line (ASU.To_String(Aux_US_Dashboard));
					else
						Ada.Text_IO.Put_Line ("Draw, Nobody wins");
						Ada.Text_IO.Put_Line (ASU.To_String(Aux_US_Dashboard));
					end if;
				end if;
				if (State = OurTurn) or (State = MoveRejected) then
					Ada.Text_IO.Put_Line ("Please press enter");
				end if;
				State:= FinishedGame;
			when CM.ServerShutdown =>
				State:= ServerShutdown;
				Ada.Text_IO.Put_Line ("The server has been shut down. You have been disconnected. Press enter");
			when others =>
				raise Constraint_Error;
		end case;
	end Client_Handler;

end Client_Handler;

-- el handler recive y el cliente envia
-- se escrive aqui y para enviar no te hace falte el handler

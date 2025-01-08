with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Exceptions;
with C4_Messages;
with Ada.Text_IO;

package Client_Handler is
	package ASU renames Ada.Strings.Unbounded;
	package LLU renames Lower_Layer_UDP;
	package CM renames C4_Messages;
	
	type Client_State is (
		WaitingForGame, InGame, OurTurn,MoveRejected,FinishedGame,ServerShutdown);
	
	State: Client_State:= WaitingForGame;
	
	procedure Client_Handler (From : in LLU.End_Point_Type;
				To : in LLU.End_Point_Type;
				Buffer : access LLU.Buffer_Type);

end Client_Handler;

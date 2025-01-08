with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Characters.Latin_1;

package Vertical_Dashboard is
	package ASU renames Ada.Strings.Unbounded;
	
	Column_Full: exception;
	Max_Players: constant Integer := 2;
	
	subtype Player_Range is Integer range 1..Max_Players;
	
	type Box is record
		Player: Player_Range;
		Empty: Boolean := True;
	end record;
	
	type Board_Type is array (1..10, 1..10) of Box;
	
	function Dashboard_Is_Full(Dashboard: in Board_Type) return Boolean;
	
	procedure Print_Dashboard(Dashboard: in Board_Type);
	
	procedure Put_Token(Dashboard: in out Board_Type; Column: in Integer; 
						Player: in Integer; Winner: out Boolean);

	function Dashboard_To_US(Dashboard: in Board_Type) return ASU.Unbounded_String;
	
end Vertical_Dashboard;

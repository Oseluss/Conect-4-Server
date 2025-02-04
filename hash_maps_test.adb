with Ada.Text_IO;
With Ada.Strings.Unbounded;
with Ada.Numerics.Discrete_Random;
with Hash_Maps_G;


procedure Hash_Maps_Test is
   package ASU  renames Ada.Strings.Unbounded;
   package ATIO renames Ada.Text_IO;

   HASH_SIZE:   constant := 10;

   type Hash_Range is mod HASH_SIZE;

   function Natural_Hash (N: Natural) return Hash_Range is
   begin
      return Hash_Range'Mod(N);
   end Natural_Hash;


   package Maps is new Hash_Maps_G (Key_Type   => Natural,
                                    Value_Type => Natural,
                                    "="        => "=",
                                    Hash_Range => Hash_Range,
                                    Hash => Natural_Hash);


   procedure Print_Map (M : Maps.Map) is
      C: Maps.Cursor := Maps.First(M);
   begin
      Ada.Text_IO.Put_Line ("Map");
      Ada.Text_IO.Put_Line ("===");

      while Maps.Has_Element(C) loop
         Ada.Text_IO.Put_Line (Natural'Image(Maps.Element(C).Key) & " " &
                               Natural'Image(Maps.Element(C).Value));
         Maps.Next(C);
      end loop;
   end Print_Map;




   procedure Do_Put (M: in out Maps.Map; K: Natural; V: Natural) is
   begin
      Ada.Text_IO.New_Line;
      ATIO.Put_Line("Putting" & Natural'Image(K));
      Maps.Put (M, K, V);
      Print_Map(M);
   exception
      when Maps.Full_Map =>
         Ada.Text_IO.Put_Line("Full_Map");
   end Do_Put;


   procedure Do_Get (M: in out Maps.Map; K: Natural) is
      V: Natural;
      Success: Boolean;
   begin
      Ada.Text_IO.New_Line;
      ATIO.Put_Line("Getting" & Natural'Image(K));
      Maps.Get (M, K, V, Success);
      if Success then
         Ada.Text_IO.Put_Line("Value:" & Natural'Image(V));
         Print_Map(M);
      else
         Ada.Text_IO.Put_Line("Element not found!");
      end if;
   end Do_Get;


   procedure Do_Delete (M: in out Maps.Map; K: Natural) is
      Success: Boolean;
   begin
      Ada.Text_IO.New_Line;
      ATIO.Put_Line("Deleting" & Natural'Image(K));
      Maps.Delete (M, K, Success);
      if Success then
         Print_Map(M);
      else
         Ada.Text_IO.Put_Line("Element not found!");
      end if;
   end Do_Delete;



   A_Map : Maps.Map;
	char: character;
	Aux_Value,Aux_Key: Integer;
	avalible: boolean;
	
begin

   -- First puts
   Do_Put (A_Map, 21, 21);
   Do_Put (A_Map, 11, 11);
   Do_Put (A_Map, 12, 12);
   Do_Put (A_Map, 13, 13);
   Do_Put (A_Map, 14, 14);
   Do_Put (A_Map, 15, 15);
   Do_Put (A_Map, 16, 16);
   Do_Put (A_Map, 17, 17);
   Do_Put (A_Map, 18, 18);
   Do_Put (A_Map, 19, 19);
   -- Now deletesq
   Do_Delete (A_Map, 14);
   Do_Put (A_Map, 25,25);
   Do_Delete (A_Map, 16);
   loop
   	ATIO.Get_Immediate(char,avalible);
   	if avalible and then char= 'p' then
   		ATIO.Put("Introduce valor");
   		Aux_Value:= Integer'vALUE(ATIO.Get_Line);
   		ATIO.Put("Introduce key");
   		Aux_Key:= Integer'Value(ATIO.Get_Line);
		Do_Put (A_Map, Aux_Value, Aux_Key);
   	end if;
   	if avalible and then char= 'd' then
   		ATIO.Put("Introduce key");
   		Aux_Key:= Integer'Value(ATIO.Get_Line);
   		Do_Delete (A_Map, Aux_Key);
   	end if;
   	if avalible and then char= 'g' then
  	 	ATIO.Put("Introduce key");
   		Aux_Key:= Integer'Value(ATIO.Get_Line);	
   		Do_Get (A_Map, Aux_Key);
   	end if;
   	
   end loop;
 --
end Hash_Maps_Test;

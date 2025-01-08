generic
   type Key_Type is private;
   type Value_Type is private;
   with function "=" (K1, K2 : Key_Type) return Boolean is <>;
   type Hash_Range is mod <>;
   with function Hash (K : Key_Type) return Hash_Range;
   Max : in Natural := 50;

package Hash_Maps_G is

   type Map is limited private;

   Full_Map : exception;

   procedure Get (M       : in out Map;
                  Key     : in Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean);

   procedure Put (M     : in out Map;
                  Key   : in Key_Type;
                  Value : in Value_Type);

   procedure Delete (M       : in out Map;
                     Key     : in Key_Type;
                     Success : out Boolean);

   function Map_Length (M : Map) return Natural;

   --
   -- Cursor Interface for iterating over Map elements
   -- 
   type Cursor is limited private;
   function First (M : Map) return Cursor;
   procedure Next (C : in out Cursor);
   function Has_Element (C : Cursor) return Boolean;
   type Element_Type is record
      Key   : Key_Type;
      Value : Value_Type;
   end record;
   No_Element : exception;

   -- Raises No_Element if Has_Element(C) = False;
   function Element (C : Cursor) return Element_Type;

private

   type Cell_State is (Empty, Full);

   type Cell is record
      Key   : Key_Type;
      Value : Value_Type;
      State : Cell_State := Empty;
   end record;

   type Cell_Index_Type is new Natural range 1 .. Natural'Max(Max, 1 + Natural(Hash_Range'Last - Hash_Range'First));
   type Cell_Array is array (Cell_Index_Type) of Cell;
   type Cell_Array_A is access Cell_Array;

   type Map is record
      P_Array : Cell_Array_A := new Cell_Array;
      Length  : Natural := 0;
   end record;

   type Cursor is record
      M        : Map;
      Position : Cell_Index_Type;
      Valid    : Boolean;
   end record;

end Hash_Maps_G;


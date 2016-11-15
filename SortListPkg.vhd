
library ieee;
use			ieee.std_logic_1164.all;
use			ieee.numeric_std.all;


package SortListPkg is
	package SortListPkg_int is new work.SortListGenericPkg
		generic map (
			ElementType        => integer,
			"<"  			         => "<",
			"<="  			       => "<=",
			">="  			       => ">=",
			to_string          => to_string,
			element_left       => integer'left
		);
	alias Integer_SortList is SortListPkg_int.SortListPType;
	alias Integer_Array    is SortListPkg_int.ArrayofElementType;

	alias Integer_Sort          is SortListPkg_int.sort[Integer_Array return Integer_Array];
	alias Integer_Reverse_Sort  is SortListPkg_int.revsort[Integer_Array return Integer_Array];
end package SortListPkg ;

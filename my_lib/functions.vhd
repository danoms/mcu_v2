-- synthesis library my_lib
library ieee, my_lib;
use 	ieee.std_logic_1164.all,
		ieee.numeric_std.all,
		my_lib.types.all;
		
package functions is
	 -- null range array constants
	 
	constant NAU : HALF_WORD_U := (others => '0');
	
	 -- implementation controls

  constant NO_WARNING : BOOLEAN := false;  -- default to emit warnings
  
  
  
	-- Id : D.1
	function To_BYTE_U (s : std_logic_vector) return BYTE_U;
	-- Id: D.2
  function TO_HALF_WORD_U (ARG, SIZE : NATURAL) return HALF_WORD_U;
	
	-- Id : D.1
	function TO_HALF_WORD_U (s : std_logic_vector) return unsigned;
end package;

package body functions is
	
	-- Id : D.1
	function To_BYTE_U (s : std_logic_vector)
    return BYTE_U
  is
    alias sv        : std_logic_vector (s'length-1 downto 0) is s;
    variable result : BYTE_U;
  begin
    for i in result'range loop
      result(i) := sv(i);
    end loop;
    return result;
  end function To_BYTE_U;
	
	-- Id : D.1
	function TO_HALF_WORD_U (s : std_logic_vector)
    return unsigned
  is
    alias sv        : std_logic_vector (s'length-1 downto 0) is s;
    variable result : HALF_WORD_U;
  begin
    for i in result'range loop
      result(i) := sv(i);
    end loop;
    return result;
  end function TO_HALF_WORD_U;
  
  -- Id: D.2
  function TO_HALF_WORD_U (ARG, SIZE : NATURAL) return HALF_WORD_U is
    variable RESULT : HALF_WORD_U;
    variable I_VAL  : NATURAL := ARG;
  begin
    if (SIZE < 1) then return NAU;
    end if;
    for I in 0 to RESULT'left loop
      if (I_VAL mod 2) = 0 then
        RESULT(I) := '0';
      else RESULT(I) := '1';
      end if;
      I_VAL          := I_VAL/2;
    end loop;
    if not(I_VAL = 0) then
      assert NO_WARNING
        report "NUMERIC_STD.TO_UNSIGNED: vector truncated"
        severity warning;
    end if;
    return RESULT;
  end function TO_HALF_WORD_U;
  
end package body;

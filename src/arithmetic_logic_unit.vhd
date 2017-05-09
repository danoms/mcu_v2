-- synthesis library my_lib
library ieee, my_lib;
use 	ieee.std_logic_1164.all,
		my_lib.types.all,
		my_lib.instruction_set.all;

entity arithmetic_logic_unit is
	port
	(
		a_i 		: in HALF_WORD_U;
		b_i		: in HALF_WORD_U;
		op_i		: in operation_type;
		
		result 	: out HALF_WORD_U;
		
		SREG_i	: in BYTE;
		SREG_o	: out BYTE
	);
end entity;

architecture avr of arithmetic_logic_unit is
--	(ldi, movw, sub, sbc, cpi, cpc, brlt, adiw, rjmp, sbiw, eor, outt, rcall)
begin
	
ALU_op_logic :
	process(all)
	begin
		case op_i is 
			when sub => 
				sub(a_i, b_i, SREG_i, result, SREG_o);
				
			when sbc =>
				sbc(a_i, b_i, SREG_i, result, SREG_o);
				
			when cpi =>
				cpi(a_i, b_i, SREG_i, result, SREG_o);
				
			when cpc =>
				cpc(a_i, b_i, SREG_i, result, SREG_o);
			
			when adiw =>
				adiw(a_i, b_i, SREG_i, result, SREG_o);
			
			when sbiw =>
				sbiw(a_i, b_i, SREG_i, result, SREG_o);
					
			when eor =>
				eor(a_i, b_i, SREG_i, result, SREG_o);
			
			when ldi =>
				ldi(a_i, SREG_i, result, SREG_o);
				
			when movw =>
				movw(a_i, SREG_i, result, SREG_o);
			
			when others =>
				result 	<= a_i;
				SREG_o	<= SREG_i;
		end case;
	end process;
end architecture;
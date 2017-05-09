-- synthesis library my_lib
library ieee, my_lib;
use ieee.std_logic_1164.all,
		ieee.numeric_std.all,
		my_lib.types.all;

package instruction_set is
	-- Id: 1.0
	procedure sub (signal a_i, b_i 		: in HALF_WORD_U;
						signal SREG_i			: in BYTE;
						signal result			: out HALF_WORD_U;
						signal SREG_o 			: out BYTE);
	-- Id: 2.0
	procedure adiw (signal a_i, b_i 		: in HALF_WORD_U;
						signal SREG_i			: in BYTE;
						signal result			: out HALF_WORD_U;
						signal SREG_o 			: out BYTE);
	-- Id: 3.0 
	procedure sbiw (signal a_i, b_i 		: in HALF_WORD_U;
						signal SREG_i			: in BYTE;
						signal result			: out HALF_WORD_U;
						signal SREG_o 			: out BYTE);
	-- Id: 4.0
	procedure eor (signal a_i, b_i 		: in HALF_WORD_U;
						signal SREG_i			: in BYTE;
						signal result			: out HALF_WORD_U;
						signal SREG_o 			: out BYTE);
	-- Id: 5.0
	procedure ldi (signal a_i		 		: in HALF_WORD_U;
						signal SREG_i			: in BYTE;
						signal result			: out HALF_WORD_U;
						signal SREG_o 			: out BYTE);
	-- Id: 6.0
	procedure movw(signal a_i		 		: in HALF_WORD_U;
						signal SREG_i			: in BYTE;
						signal result			: out HALF_WORD_U;
						signal SREG_o 			: out BYTE);
	-- Id: 7.0 
	procedure sbc (signal a_i, b_i 		: in HALF_WORD_U;
						signal SREG_i			: in BYTE;
						signal result			: out HALF_WORD_U;
						signal SREG_o 			: out BYTE);
	-- Id: 8.0
	procedure cpi (signal a_i, b_i 		: in HALF_WORD_U;
						signal SREG_i			: in BYTE;
						signal result			: out HALF_WORD_U;
						signal SREG_o 			: out BYTE);
	-- Id: 9.0
	procedure cpc (signal a_i, b_i 		: in HALF_WORD_U;
						signal SREG_i			: in BYTE;
						signal result			: out HALF_WORD_U;
						signal SREG_o 			: out BYTE);
end package;

package body instruction_set is
	-- Id: 1.0
	procedure sub (signal a_i, b_i 		: in HALF_WORD_U;
						signal SREG_i			: in BYTE;
						signal result			: out HALF_WORD_U;
						signal SREG_o 			: out BYTE) is
		variable tmp_SREG_o 	: BYTE 	:= SREG_i;
		variable tmp_R 		: HALF_WORD_U;
		
	begin
	-- result
		tmp_R 			:= a_i - b_i;
		
	--!!! set flags	
		tmp_SREG_o(H)	:= (a_i(3)and b_i(3))or(b_i(3)and not(b_i(3)))or(not(tmp_R(3))and a_i(3));
		tmp_SREG_o(S)	:= tmp_R(7) xor ((a_i(7)and b_i(7)and not(tmp_R(7)))or(not(a_i(7))and not(b_i(7))and tmp_R(7)));
		tmp_SREG_o(V)	:= (a_i(7)and b_i(7)and not(tmp_R(7)))or(not(a_i(7))and not(b_i(7))and tmp_R(7));
		tmp_SREG_o(N)	:= tmp_R(7);
		tmp_SREG_o(Z)	:= not(tmp_R(7))and not(tmp_R(6))and not(tmp_R(5))and not(tmp_R(4)) and 
								not(tmp_R(3))and not(tmp_R(2))and not(tmp_R(1))and not(tmp_R(0));
		tmp_SREG_o(C)	:= (a_i(7)and b_i(7))or(b_i(7)and not(tmp_R(7)))or(not tmp_R(7)and a_i(7));
	
	-- out
		result		<= tmp_R;
		SREG_o		<= tmp_SREG_o; 
	end procedure;
	
	-- Id: 2.0
	procedure adiw (signal a_i, b_i 		: in HALF_WORD_U;
						signal SREG_i			: in BYTE;
						signal result			: out HALF_WORD_U;
						signal SREG_o 			: out BYTE) is
		variable tmp_SREG_o 	: BYTE 	:= SREG_i;
		variable tmp_R 		: HALF_WORD_U;
		
	begin
	-- result
		tmp_R 			:= a_i + b_i;
		
	--!!! set flags	
		tmp_SREG_o(H)	:= (a_i(3)and b_i(3))or(b_i(3)and not(b_i(3)))or(not(tmp_R(3))and a_i(3));
		tmp_SREG_o(S)	:= tmp_R(7) xor ((a_i(7)and b_i(7)and not(tmp_R(7)))or(not(a_i(7))and not(b_i(7))and tmp_R(7)));
		tmp_SREG_o(V)	:= (a_i(7)and b_i(7)and not(tmp_R(7)))or(not(a_i(7))and not(b_i(7))and tmp_R(7));
		tmp_SREG_o(N)	:= tmp_R(7);
		tmp_SREG_o(Z)	:= not(tmp_R(7))and not(tmp_R(6))and not(tmp_R(5))and not(tmp_R(4)) and 
								not(tmp_R(3))and not(tmp_R(2))and not(tmp_R(1))and not(tmp_R(0));
		tmp_SREG_o(C)	:= (a_i(7)and b_i(7))or(b_i(7)and not(tmp_R(7)))or(not tmp_R(7)and a_i(7));
	
	-- out
		result	<= tmp_R;
		SREG_o	<= tmp_SREG_o; 
	end procedure;
	
	-- Id: 3.0 
	procedure sbiw (signal a_i, b_i 		: in HALF_WORD_U;
						signal SREG_i			: in BYTE;
						signal result			: out HALF_WORD_U;
						signal SREG_o 			: out BYTE) is
		variable tmp_SREG_o 	: BYTE 	:= SREG_i;
		variable tmp_R 		: HALF_WORD_U;
		
	begin
	-- result
		tmp_R 			:= a_i - b_i;
		
	--!!! set flags	
		tmp_SREG_o(H)	:= (a_i(3)and b_i(3))or(b_i(3)and not(b_i(3)))or(not(tmp_R(3))and a_i(3));
		tmp_SREG_o(S)	:= tmp_R(7) xor ((a_i(7)and b_i(7)and not(tmp_R(7)))or(not(a_i(7))and not(b_i(7))and tmp_R(7)));
		tmp_SREG_o(V)	:= (a_i(7)and b_i(7)and not(tmp_R(7)))or(not(a_i(7))and not(b_i(7))and tmp_R(7));
		tmp_SREG_o(N)	:= tmp_R(7);
		tmp_SREG_o(Z)	:= not(tmp_R(7))and not(tmp_R(6))and not(tmp_R(5))and not(tmp_R(4)) and 
								not(tmp_R(3))and not(tmp_R(2))and not(tmp_R(1))and not(tmp_R(0));
		tmp_SREG_o(C)	:= (a_i(7)and b_i(7))or(b_i(7)and not(tmp_R(7)))or(not tmp_R(7)and a_i(7));
	
	-- out
		result	<= tmp_R;
		SREG_o	<= tmp_SREG_o; 
	end procedure;
	
	-- Id: 4.0
	procedure eor (signal a_i, b_i 		: in HALF_WORD_U;
						signal SREG_i			: in BYTE;
						signal result			: out HALF_WORD_U;
						signal SREG_o 			: out BYTE) is
		variable tmp_SREG_o 	: BYTE 	:= SREG_i;
		variable tmp_R 		: HALF_WORD_U;
		
	begin
	-- result
		tmp_R 			:= a_i xor b_i;
		
	--!!! set flags	
		tmp_SREG_o(H)	:= (a_i(3)and b_i(3))or(b_i(3)and not(b_i(3)))or(not(tmp_R(3))and a_i(3));
		tmp_SREG_o(S)	:= tmp_R(7) xor ((a_i(7)and b_i(7)and not(tmp_R(7)))or(not(a_i(7))and not(b_i(7))and tmp_R(7)));
		tmp_SREG_o(V)	:= (a_i(7)and b_i(7)and not(tmp_R(7)))or(not(a_i(7))and not(b_i(7))and tmp_R(7));
		tmp_SREG_o(N)	:= tmp_R(7);
		tmp_SREG_o(Z)	:= not(tmp_R(7))and not(tmp_R(6))and not(tmp_R(5))and not(tmp_R(4)) and 
								not(tmp_R(3))and not(tmp_R(2))and not(tmp_R(1))and not(tmp_R(0));
		tmp_SREG_o(C)	:= (a_i(7)and b_i(7))or(b_i(7)and not(tmp_R(7)))or(not tmp_R(7)and a_i(7));
	
	-- out
		result	<= tmp_R;
		SREG_o	<= tmp_SREG_o; 
	end procedure;
	
	-- Id: 5.0
	procedure ldi (signal a_i		 		: in HALF_WORD_U;
						signal SREG_i			: in BYTE;
						signal result			: out HALF_WORD_U;
						signal SREG_o 			: out BYTE) is
	variable tmp_SREG_o 	: BYTE 	:= SREG_i;
		variable tmp_R 		: HALF_WORD_U;
		
	begin
	-- result
		tmp_R 			:= a_i;
		
	--!!! set flags	
--		tmp_SREG_o(H)	:= (a_i(3)and b_i(3))or(b_i(3)and not(b_i(3)))or(not(tmp_R(3))and a_i(3));
--		tmp_SREG_o(S)	:= tmp_R(7) xor ((a_i(7)and b_i(7)and not(tmp_R(7)))or(not(a_i(7))and not(b_i(7))and tmp_R(7)));
--		tmp_SREG_o(V)	:= (a_i(7)and b_i(7)and not(tmp_R(7)))or(not(a_i(7))and not(b_i(7))and tmp_R(7));
--		tmp_SREG_o(N)	:= tmp_R(7);
--		tmp_SREG_o(Z)	:= not(tmp_R(7))and not(tmp_R(6))and not(tmp_R(5))and not(tmp_R(4)) and 
--								not(tmp_R(3))and not(tmp_R(2))and not(tmp_R(1))and not(tmp_R(0));
--		tmp_SREG_o(C)	:= (a_i(7)and b_i(7))or(b_i(7)and not(tmp_R(7)))or(not tmp_R(7)and a_i(7));
	
	-- out
		result	<= tmp_R;
		SREG_o	<= tmp_SREG_o; 
	end procedure;
	
	-- Id: 6.0
	procedure movw(signal a_i		 		: in HALF_WORD_U;
						signal SREG_i			: in BYTE;
						signal result			: out HALF_WORD_U;
						signal SREG_o 			: out BYTE) is
	variable tmp_SREG_o 	: BYTE 	:= SREG_i;
		variable tmp_R 		: HALF_WORD_U;
		
	begin
	-- result
		tmp_R 			:= a_i;
		
	--!!! set flags	
--		tmp_SREG_o(H)	:= (a_i(3)and b_i(3))or(b_i(3)and not(b_i(3)))or(not(tmp_R(3))and a_i(3));
--		tmp_SREG_o(S)	:= tmp_R(7) xor ((a_i(7)and b_i(7)and not(tmp_R(7)))or(not(a_i(7))and not(b_i(7))and tmp_R(7)));
--		tmp_SREG_o(V)	:= (a_i(7)and b_i(7)and not(tmp_R(7)))or(not(a_i(7))and not(b_i(7))and tmp_R(7));
--		tmp_SREG_o(N)	:= tmp_R(7);
--		tmp_SREG_o(Z)	:= not(tmp_R(7))and not(tmp_R(6))and not(tmp_R(5))and not(tmp_R(4)) and 
--								not(tmp_R(3))and not(tmp_R(2))and not(tmp_R(1))and not(tmp_R(0));
--		tmp_SREG_o(C)	:= (a_i(7)and b_i(7))or(b_i(7)and not(tmp_R(7)))or(not tmp_R(7)and a_i(7));
	
	-- out
		result 	<= tmp_R;
		SREG_o	<= tmp_SREG_o; 
	end procedure;
	
	-- Id: 7.0 
	procedure sbc (signal a_i, b_i 		: in HALF_WORD_U;
						signal SREG_i			: in BYTE;
						signal result			: out HALF_WORD_U;
						signal SREG_o 			: out BYTE) is 
	variable tmp_SREG_o 	: BYTE 	:= SREG_i;
		variable tmp_R 		: HALF_WORD_U;
		
	begin
	-- result
		tmp_R 			:= a_i - b_i - ("" & SREG_i(C));
		
	--!!! set flags	
		tmp_SREG_o(H)	:= (a_i(3)and b_i(3))or(b_i(3)and not(b_i(3)))or(not(tmp_R(3))and a_i(3));
		tmp_SREG_o(S)	:= tmp_R(7) xor ((a_i(7)and b_i(7)and not(tmp_R(7)))or(not(a_i(7))and not(b_i(7))and tmp_R(7)));
		tmp_SREG_o(V)	:= (a_i(7)and b_i(7)and not(tmp_R(7)))or(not(a_i(7))and not(b_i(7))and tmp_R(7));
		tmp_SREG_o(N)	:= tmp_R(7);
		tmp_SREG_o(Z)	:= not(tmp_R(7))and not(tmp_R(6))and not(tmp_R(5))and not(tmp_R(4)) and 
								not(tmp_R(3))and not(tmp_R(2))and not(tmp_R(1))and not(tmp_R(0));
		tmp_SREG_o(C)	:= (a_i(7)and b_i(7))or(b_i(7)and not(tmp_R(7)))or(not tmp_R(7)and a_i(7));
	
	-- out
		result	<= tmp_R;
		SREG_o	<= tmp_SREG_o; 
	end procedure;
	
	-- Id: 8.0
	procedure cpi (signal a_i, b_i 		: in HALF_WORD_U;
						signal SREG_i			: in BYTE;
						signal result			: out HALF_WORD_U;
						signal SREG_o 			: out BYTE) is
	variable tmp_SREG_o 	: BYTE 	:= SREG_i;
		variable tmp_R 		: HALF_WORD_U;
		
	begin
	-- result
		tmp_R 			:= a_i - b_i;
		
	--!!! set flags	
		tmp_SREG_o(H)	:= (a_i(3)and b_i(3))or(b_i(3)and not(b_i(3)))or(not(tmp_R(3))and a_i(3));
		tmp_SREG_o(S)	:= tmp_R(7) xor ((a_i(7)and b_i(7)and not(tmp_R(7)))or(not(a_i(7))and not(b_i(7))and tmp_R(7)));
		tmp_SREG_o(V)	:= (a_i(7)and b_i(7)and not(tmp_R(7)))or(not(a_i(7))and not(b_i(7))and tmp_R(7));
		tmp_SREG_o(N)	:= tmp_R(7);
		tmp_SREG_o(Z)	:= not(tmp_R(7))and not(tmp_R(6))and not(tmp_R(5))and not(tmp_R(4)) and 
								not(tmp_R(3))and not(tmp_R(2))and not(tmp_R(1))and not(tmp_R(0));
		tmp_SREG_o(C)	:= (a_i(7)and b_i(7))or(b_i(7)and not(tmp_R(7)))or(not tmp_R(7)and a_i(7));
	
	-- out
		result	<= tmp_R;
		SREG_o	<= tmp_SREG_o; 
	end procedure;
	
	-- Id: 9.0
	procedure cpc (signal a_i, b_i 		: in HALF_WORD_U;
						signal SREG_i			: in BYTE;
						signal result			: out HALF_WORD_U;
						signal SREG_o 			: out BYTE) is
	variable tmp_SREG_o 	: BYTE 	:= SREG_i;
		variable tmp_R 		: HALF_WORD_U;
		
	begin
	-- result
		tmp_R 			:= a_i - b_i - ("" & SREG_i(C));
		
	--!!! set flags	
		tmp_SREG_o(H)	:= (a_i(3)and b_i(3))or(b_i(3)and not(b_i(3)))or(not(tmp_R(3))and a_i(3));
		tmp_SREG_o(S)	:= tmp_R(7) xor ((a_i(7)and b_i(7)and not(tmp_R(7)))or(not(a_i(7))and not(b_i(7))and tmp_R(7)));
		tmp_SREG_o(V)	:= (a_i(7)and b_i(7)and not(tmp_R(7)))or(not(a_i(7))and not(b_i(7))and tmp_R(7));
		tmp_SREG_o(N)	:= tmp_R(7);
		tmp_SREG_o(Z)	:= not(tmp_R(7))and not(tmp_R(6))and not(tmp_R(5))and not(tmp_R(4)) and 
								not(tmp_R(3))and not(tmp_R(2))and not(tmp_R(1))and not(tmp_R(0));
		tmp_SREG_o(C)	:= (a_i(7)and b_i(7))or(b_i(7)and not(tmp_R(7)))or(not tmp_R(7)and a_i(7));
	
	-- out
		result	<= tmp_R;
		SREG_o	<= tmp_SREG_o; 
	end procedure;
end package body;
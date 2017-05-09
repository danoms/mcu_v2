-- synthesis library my_lib
library ieee, my_lib;
use 	ieee.std_logic_1164.all,
		ieee.numeric_std.all,
		my_lib.types.all,
		my_lib.functions.all;

entity instruction_decoder is
	generic 
	(
		MUX_COUNT	: positive := 8;
		CLK_COUNT	: positive := 5
	);
		port
		(			
			data_i			: in HALF_WORD;	-- instruction to decode
			
			Rd_addr_o		: out unsigned(4 downto 0);	-- destinatio reg address in GPR
			Rs_addr_o		: out unsigned(4 downto 0);	-- source reg address in GPR
			addr_mode_o		: out BYTE_U;	-- I/O or data addressing
			immed_o			: out HALF_WORD_U;	-- immediate value
			
			op_o				: out operation_type; -- controls ALU
			ctl_line_o		: out std_logic_vector(MUX_COUNT-1 downto 0);
			clk_gating_o	: out std_logic_vector(CLK_COUNT-1 downto 0)
		);
end entity;

architecture nothing of instruction_decoder is
	
	-- for bit signals
--	subtype bit0 is std_logic_vector(0 downto 0);
	
	-- to determine operation type, bits from highest to bot
	signal high3 : std_logic_vector(2 downto 0) := data_i(15 downto 13);
	signal high4 : std_logic_vector(3 downto 0) := data_i(15 downto 12);
	signal high6	: std_logic_vector(5 downto 0) := data_i(15 downto 10);
	signal high8 : std_logic_vector(7 downto 0) := data_i(15 downto 8);
	signal high9 : std_logic_vector(8 downto 0) := data_i(15 downto 7);
	
	-- registers, bits, immediates
	signal Rd5 	: std_logic_vector(4 downto 0) := data_i(8 downto 4);
	signal Rd4	: std_logic_vector(4 downto 0) := "0" & data_i(7 downto 4);
	signal Rd3 	: std_logic_vector(4 downto 0) := "00" & data_i(2 downto 0);
	
	signal Rs5	: std_logic_vector(4 downto 0) := data_i(9) & data_i(3 downto 0);
	
	signal Rs4	: std_logic_vector(4 downto 0) := "0" & data_i(3 downto 0);
	signal Rs3 	: std_logic_vector(4 downto 0) := "00" & data_i(2 downto 0);
	
	signal Kon6 : std_logic_vector(5 downto 0) := (data_i(13) & data_i(11 downto 10) & data_i(2 downto 0));
	
	signal Kon8	: std_logic_vector(15 downto 0) := x"00" & (data_i(11 downto 8) & data_i(3 downto 0));

--	signal carry : bit0 := data_i(12);
--	signal store	: bit0 := data_i(9);

	signal port_addr	: std_logic_vector(15 downto 0) := 10x"000" & (data_i(10 downto 9) & data_i(3 downto 0));
	
	-- slice bits, to determine operation
	signal opcode 			: std_logic_vector(5 downto 0) := data_i(15 downto 10);
	

	signal op_short3		: std_logic_vector(2 downto 0) := (data_i(15 downto 14) & data_i(12));
	
	signal op_short		: std_logic_vector(3 downto 0) := data_i(15 downto 12);
	signal op_long			: std_logic_vector(6 downto 0) := data_i(15 downto 9);
	signal op_long8		: std_logic_vector(7 downto 0) := data_i(15 downto 8);
	signal op_long9 		: std_logic_vector(8 downto 0) := data_i(15 downto 7);
	signal op_long10		: std_logic_vector(9 downto 0) := (data_i(15 downto 7) & data_i(3));
	
	signal sub_long		: std_logic_vector(3 downto 0) := data_i(3 downto 0);
	
	signal op_ldd5			: std_logic_vector(4 downto 0) := (data_i(15 downto 14) & data_i(12) & data_i(9) & data_i(3));
	
	signal op_short5		: std_logic_vector(4 downto 0) := data_i(15 downto 11);
	
	signal op_misc			: std_logic_vector(11 downto 0) := (data_i(15 downto 8) & data_i(3 downto 0));
	
	signal sub_misc		: std_logic_vector(3 downto 0) := data_i(7 downto 4);
begin
	
push_controls : 
	process(all)
	begin
--		if rising_edge(clk_i) then
		
		-- Immediate functions
			if high3 = "011" or (high3 = "001" and data_i(12) = '1') then 
				Rd_addr_o	<= unsigned(Rd4);
				immed_o		<= To_HALF_WORD_U(Kon8);
				
				if op_short 	= "0011" then
					op_o	<= CPI;
				elsif	op_short = "0101" then
					op_o	<= SUBI;
				elsif op_short = "0100" then
					op_o	<= SBCI;
				elsif op_short = "0110" then
					op_o	<= ORI; 	-- SBR
				elsif op_short = "0111" then
					op_o	<= ANDI; -- CBR
				end if;
				
		-- Rd (0 - 31) and Rs (0 - 31) operation
			elsif high3 = "000" or (high3 = "001" and data_i(12) = '0') then
				Rd_addr_o	<= unsigned(Rd5);
				Rs_addr_o	<= unsigned(Rs5);
				
				if opcode 	 = "000101" then
					op_o	<= CP;		
				elsif opcode = "000001" then
					op_o	<= CPC;
				elsif opcode = "000110" then
					op_o	<= SUB;
				elsif opcode = "000010" then
					op_o	<= SBC;
				elsif opcode = "000011" then
					op_o 	<= ADD; 					-- LSL if Rd = Rs
				elsif opcode = "000111" then
					op_o	<= ADC; 					-- ROL if Rd = Rs
				elsif opcode = "000100" then
					op_o	<= CPSE;
				elsif opcode = "001000" then
					op_o	<= ANDD;
				elsif opcode = "001001" then
					op_o	<= EOR;
				elsif opcode = "001010" then
					op_o	<= ORR;
				elsif opcode = "001011" then
					op_o	<= MOV;
				else
					op_o	<= NOP;
				end if;
			end if;
		-- Data operations
			if high6 = "100100" then
				Rd_addr_o	<= unsigned(Rd5);
				
				if op_long = "1001000" then
				
				-- store '0' => LOAD
					if sub_long 	= "0001" then
						op_o	<= LDZP; -- Z+
					elsif sub_long = "1001" then
						op_o	<= LDYP;
					elsif sub_long = "0010" then
						op_o	<= LDZM;
					elsif sub_long = "1010" then
						op_o	<= LDYM;
					elsif sub_long = "1100" then
						op_o	<= LDX;
					elsif sub_long = "1101" then
						op_o	<= LDXP;
					elsif sub_long = "1110" then
						op_o	<= LDXM;
					elsif sub_long = "1111" then
						op_o	<= POP;
				-- no store
					elsif sub_long = "0100" then
						op_o	<=	LPMZ;
					elsif sub_long = "0110" then
						op_o	<= ELPMZ;
					elsif sub_long = "0101" then
						op_o	<= LPMZP;
					elsif sub_long = "0111" then
						op_o	<= ELPMZP;
					else 
						op_o	<= NOP;
					end if;
					
				elsif op_long = "1001001" then
				
				-- store '1' => STORE
					if sub_long 	= "0001" then
						op_o	<= STZP; -- Z+
					elsif sub_long = "1001" then
						op_o	<= STYP;
					elsif sub_long = "0010" then
						op_o	<= STZM;
					elsif sub_long = "1010" then
						op_o	<= STYM;
					elsif sub_long = "1100" then
						op_o	<= LDX;
					elsif sub_long = "1101" then
						op_o	<= LDXP;
					elsif sub_long = "1110" then
						op_o	<= LDXM;
					elsif sub_long = "1111" then
						op_o	<= POP;
				-- no store
					elsif sub_long = "0100" then
						op_o	<= XCH;
					elsif sub_long = "0101" then
						op_o	<= LAS;
					elsif sub_long = "0110" then
						op_o	<= LAC;
					elsif sub_long = "0111" then
						op_o	<= LAT;
					else 
						op_o	<= NOP;
					end if;
				end if;
			end if;
			
			-- Register pair
			if high8 = "00000001" then
				Rd_addr_o	<= unsigned(Rd4);
				Rs_addr_o	<= unsigned(Rs4);
				op_o	<= MOVW;
			end if;
			
			-- Multiplication
			if high8 = "00000010" or high8 = "00000011" then				
				if op_long8 = "00000010" then 
					Rd_addr_o	<= unsigned(Rd4);
					Rs_addr_o	<= unsigned(Rs4);
					op_o			<= MULS;
				elsif	op_long9 = "0000001100" then
					Rd_addr_o	<= unsigned(Rd3);
					Rs_addr_o	<= unsigned(Rs3);
					op_o			<= MULSU;
				elsif	op_long9 = "0000001101" then
					Rd_addr_o	<= unsigned(Rd3);
					Rs_addr_o	<= unsigned(Rs3);
					op_o			<= FMUL;
				elsif	op_long9 = "0000001110" then
					Rd_addr_o	<= unsigned(Rd3);
					Rs_addr_o	<= unsigned(Rs3);
					op_o			<= FMULS;
				elsif	op_long9 = "0000001111" then
					Rd_addr_o	<= unsigned(Rd3);
					Rs_addr_o	<= unsigned(Rs3);
					op_o			<= FMULU;
				end if;
			elsif high6 = "100111" then
				Rd_addr_o	<= unsigned(Rd5);
				Rs_addr_o	<= unsigned(Rs5);
				op_o			<= MUL;
			end if;	
			-- LDD, STD
			if op_short3 = "100" then
				Rd_addr_o	<= unsigned(Rd5);
				-- load
				if op_ldd5 	  = "10001" then -- y
					op_o		<= LDDY;
				elsif op_ldd5 = "10000" then -- z
					op_o		<= LDDZ;
				-- store
				elsif op_ldd5 = "10011" then -- y
					op_o		<= STDY;
				elsif op_ldd5 = "10010" then -- z
					op_o		<= STDZ;
				end if;
			end if;
			-- IN/OUT
			if high4 = "1011" then
				Rd_addr_o	<= unsigned(Rd5);
				immed_o		<= To_HALF_WORD_U(port_addr);
				
				if op_short5 	 = "10110" then
					op_o	<= INN;
				elsif op_short5 = "10111" then
					op_o	<= OUTT;
				end if;
			end if;
			-- MISC instructions
			if op_misc = "100101011000" then
			
				if sub_misc 	= "0000" then
					op_o	<= RET;
				elsif sub_misc = "0001" then
					op_o	<= RETI;
				elsif sub_misc	= "1000" then
					op_o 	<= SLEEP;
				elsif sub_misc = "1001" then
					op_o	<= BREAK;
				elsif sub_misc	= "1010" then
					op_o 	<= WDR;
				elsif sub_misc = "1100" then
					op_o	<= LPM;
				elsif sub_misc	= "1101" then
					op_o 	<= ELPM;
				elsif sub_misc = "1110" then
					op_o	<= SPM;
				elsif sub_misc	= "1111" then
					op_o 	<= SPMZ;
				
				end if;
			end if;
--		end if;
	end process;

end architecture;
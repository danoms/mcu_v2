-- synthesis library my_lib
library ieee, my_lib;
use 	ieee.std_logic_1164.all,
		ieee.numeric_std.all,
		ieee.math_real.all,
		my_lib.types.all,
		my_lib.components.all,
		my_lib.functions.all;

entity central_processing_unit is 
	generic
	(
		MUX_COUNT	: positive := 15;
		CLK_COUNT	: positive := 5;
		
		RAMEND 		: positive := 256
	);
	port
	(
		clk_i			: in std_logic;
		rst_i	 		: in std_logic;
		
		-- FLASH instructions
		inst_data_i		: in HALF_WORD;
		inst_addr_o		: out HALF_WORD_U;
		inst_const_i	: in BYTE_U;
		
		-- Data space -> RAM, I/O data, addresses
		data_addr_o	: out HALF_WORD_U;
		data_data_o	: out HALF_WORD_U;
		data_data_i	: in HALF_WORD_U;
		data_we 		: out std_logic
	);
end entity;

architecture avr of central_processing_unit is 
	-- special registers
	signal PC_reg, PC_next 			: HALF_WORD_U;
	signal SP_reg, SP_next			: HALF_WORD_U;
	signal INST_reg, INST_next		: HALF_WORD;
	signal SREG_reg, SREG_next		: BYTE;
	
	-- instruction_decoder out signals
	signal Rd_addr, Rs_addr 	: unsigned(4 downto 0);
	signal immediate				: HALF_WORD_U;
	signal operation 				: operation_type;
	
	signal hword_en  	: std_logic;
	
	signal ctl_line		: std_logic_vector(MUX_COUNT-1 downto 0);
	signal clk_gating		: std_logic_vector(CLK_COUNT-1 downto 0);
	
	-- GPR signals
	signal Rd, Rs 					: HALF_WORD_U;
	signal x_reg, y_reg, z_reg	: HALF_WORD_U;
	
	signal data 					: HALF_WORD_U;
	
	-- ALU signals
	signal a 		: HALF_WORD_U;
	signal result 	: HALF_WORD_U;
	
	-- after muxes
	signal to_PC_adder 		: HALF_WORD_U;
	signal after_PC_adder	: HALF_WORD_U;
	
	signal after_SP_adder	: HALF_WORD_U;
	
begin
	
update_registers :
	process(clk_i, rst_i)
	begin
		if rst_i then
			PC_reg	<= (others => '0');
			INST_reg	<= (others => '0');
			SP_reg	<= To_HALF_WORD_U(RAMEND, SP_next'length);
			SREG_reg	<= (others => '0');
			
		elsif rising_edge(clk_i) then
			PC_reg		<= PC_next;
			INST_reg		<= INST_next;
			SP_reg		<= SP_next;
			SREG_reg		<= SREG_next;
			
		end if;
	end process;
	
inst_addr_o	<= PC_reg;
	
INST_next	<= inst_data_i;

core_INSTRUCTION_DECODER :
		component instruction_decoder
		generic map (MUX_COUNT	=> MUX_COUNT )
		port map
		(			
			data_i			=> INST_reg,	-- instruction to decode
			
			Rd_addr_o		=> Rd_addr,	-- destinatio reg address in GPR
			Rs_addr_o		=> Rs_addr,	-- source reg address in GPR
			addr_mode_o		=> open,		-- I/O or data addressing
			immed_o			=> immediate,	-- immediate value
			
			op_o				=> operation, -- controls ALU
			ctl_line_o		=> ctl_line,	-- controls muxes
			clk_gating_o	=> clk_gating	-- gated clock enable signal
		);

--with ctl_line(1 downto 0) select
--	data 	<= data_data_i	when "01",
--				result		when others;

--data(7 downto 0) 	<= data_data_i when ctl_line(11) else result(7 downto 0);
data 	<= data_data_i when ctl_line(11) else result;
		
core_GPR : 
	component general_purpose_register
	port map
		(
			clk_i 		=> clk_i,
			rst_i			=> rst_i,
			
			Rd_addr_i	=> Rd_addr,
			Rs_addr_i	=> Rs_addr,
			
			Rd_o			=> Rd,
			Rs_o			=> Rs,
			
			data_i 		=> data,
			hword_en		=>	hword_en,	-- for MOVW, ADIW, SBIW
			
			x_o			=> x_reg,
			y_o 			=> y_reg,
			z_o			=> z_reg
		);

--with ctl_line(1 downto 0) select
--	a	<= immediate 		when "00",
--			x"00" & inst_const_i	when "01",
--			Rd					when others;
				process(all)
				begin
					case ctl_line(1 downto 0) is
						when "00" =>
							a	<= immediate;
							
						when "01" =>
							a	<= x"00" & inst_const_i;
						
						when others =>
							a <= Rd;
							
					end case;
				end process;
--a	<= immediate when ctl_line(immediate) else Rd;

core_ALU :
	component arithmetic_logic_unit 
	port map
	(
		a_i 		=> a,
		b_i		=> Rs,
		op_i		=> operation,
		
		result 	=> result,
		
		SREG_i	=> SREG_reg,
		SREG_o	=> SREG_next
	);

with ctl_line(3 downto 2) select 
	to_PC_adder	<= immediate  	when "01",
						x"0002" 		when "10",
						data 			when "11",
						x"0001"		when others;
						
after_PC_adder	<= PC_reg + to_PC_adder;

with ctl_line(5 downto 4) select
	PC_next	<= immediate		when "01",
					z_reg				when "10",
					after_PC_adder when others;
					
-- to Data ports
with ctl_line(7 downto 6) select
	data_data_o		<= immediate	when "01",
							PC_reg		when "10",
							data			when others;

with ctl_line(10 downto 8) select 
	data_addr_o		<= immediate 	when "001",
							data			when "010",
							x_reg			when "011",
							y_reg			when "100",
							z_reg 		when "101",
							SP_reg		when others;
							
data_we	<= ctl_line(12);

with ctl_line(14 downto 13) select
	after_SP_adder	<= x"0001" when "00",
							x"0002" when "01",
							x"FFFF" when "10",
							x"FFFD" when "11";

SP_next	<= SP_reg + after_SP_adder;
end architecture;
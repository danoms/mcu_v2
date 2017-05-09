-- synthesis library my_lib
library ieee, my_lib;
use ieee.std_logic_1164.all,
		ieee.numeric_std.all,
		my_lib.types.all;

package components is 

	component central_processing_unit is 
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
	end component;

	component instruction_decoder is
		generic 
		(
			MUX_COUNT	: positive := 12;
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
	end component;
	
	component general_purpose_register is
		generic
		(
			gpr_width	: positive := 8;
			gpr_size 	: positive := 32
		);
		port
		(
			clk_i 		: in std_logic;
			rst_i			: in std_logic;
			
			Rd_addr_i	: in unsigned(4 downto 0);
			Rs_addr_i	: in unsigned(4 downto 0);
			
			Rd_o			: out HALF_WORD_U;
			Rs_o			: out HALF_WORD_U;
			
			data_i 		: HALF_WORD_U;
			hword_en		: std_logic;		-- for MOVW, ADIW, SBIW
			
			x_o			: out HALF_WORD_U;
			y_o 			: out HALF_WORD_U;
			z_o			: out HALF_WORD_U
		);
	end component;
	
	component arithmetic_logic_unit is
	port
	(
		a_i 		: in HALF_WORD_U;
		b_i		: in HALF_WORD_U;
		op_i		: operation_type;
		
		result 	: out HALF_WORD_U;
		
		SREG_i	: in BYTE;
		SREG_o	: out BYTE
	);
	end component;
	
end package;
library ieee, my_lib;

use ieee.std_logic_1164.all,
		my_lib.types.all,
		my_lib.components.all;

entity ATtiny13 is 
	port
	(
		clk_i			: in std_logic;
		rst_i	 		: in std_logic		
		
	);
end entity;

architecture avr of ATtiny13 is 
	signal inst_data 		: HALF_WORD;
	signal inst_const 	: BYTE_U;
	signal data_data 		: HALF_WORD_U;
	signal data_we			: std_logic;
begin

CPU :
	component central_processing_unit
	port map
	(
		clk_i			=> clk_i,
		rst_i	 		=> rst_i,
		
		-- FLASH instructions
		inst_data_i		=> inst_data,
		inst_addr_o		=> open,
		inst_const_i	=> inst_const,
		
		-- Data space -> RAM, I/O data, addresses
		data_addr_o		=> open,
		data_data_o		=> open,
		data_data_i		=> data_data,
		data_we 			=> data_we
	);

end architecture;
-- synthesis library my_lib
library ieee, my_lib;
use 	ieee.std_logic_1164.all,
		ieee.numeric_std.all,
		my_lib.types.all;

entity general_purpose_register is
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
end entity;

architecture avr of general_purpose_register is
	
	signal GPR			: GPR_type;
	
	signal Rd_o_reg		: HALF_WORD_U;
	signal Rs_o_reg		: HALF_WORD_U;
	
	signal x_reg, y_reg, z_reg : HALF_WORD_U;
	
	
	
	constant x_addr_l 	: positive := 26;
	constant x_addr_h		: positive := 27;
	
	constant y_addr_l 	: positive := 28;
	constant y_addr_h		: positive := 29;
	
	constant z_addr_l		: positive := 30;
	constant z_addr_h		: positive := 31;
	
	signal Rd_addr_reg : unsigned(4 downto 0);
	signal Rs_addr_reg : unsigned(4 downto 0);
begin



--update_registers : 
--	process(clk_i, rst_i)
--	begin
--		if rst_i	then -- clear
--			GPR 	<= (others => (others => '0'));
--			
--		elsif clk_i then -- write
--			if hword_en then -- write two bytes
--				GPR(to_integer(Rd_addr_i)) 	<= data_i(7 downto 0);
----				GPR(to_integer(Rd_addr_ii)) 	<= data_i(15 downto 8);
--				
--			else -- write one byte
--				GPR(to_integer(Rd_addr_i)) 	<= data_i(7 downto 0);
--				
--			end if;
--		end if;
--	end process;
	
update_address :
	process(clk_i)
		variable Rd_addr_ii : unsigned(4 downto 0);
		variable Rs_addr_ii : unsigned(4 downto 0);
	begin
		if falling_edge(clk_i) then
			Rd_addr_ii := Rd_addr_i + 1;
			Rs_addr_ii := Rs_addr_i + 1;
			Rd_o_reg	<= GPR(to_integer(Rd_addr_ii)) & GPR(to_integer(Rd_addr_i));
			Rs_o_reg	<= GPR(to_integer(Rs_addr_ii)) & GPR(to_integer(Rs_addr_i));
			x_reg 	<=	GPR((x_addr_h)) & GPR(x_addr_l);
			y_reg		<=	GPR((y_addr_h)) & GPR((y_addr_l));
			z_reg		<= GPR((z_addr_h)) & GPR((z_addr_l));
			
			Rd_addr_reg		<= Rd_addr_i;
			Rs_addr_reg 	<= Rs_addr_i;
		elsif rising_edge(clk_i) then
			GPR(to_integer(Rd_addr_reg)) 	<= data_i(7 downto 0);
		end if;
	end process;
	
half_word_output : 
	process(all)
	begin
		Rd_o	<= Rd_o_reg;
		Rs_o	<= Rs_o_reg;
		
		x_o	<= x_reg;
		y_o	<= y_reg;
		z_o	<= z_reg;
	end process;

end architecture;
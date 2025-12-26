--------------- Write Back module 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE work.aux_package.ALL;
-------------- ENTITY --------------------
ENTITY WB IS
	PORT( 
		ALU_Result, read_data	: IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		MemtoReg      			: IN  STD_LOGIC;
		write_data 				: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)		
		);
END 	WB;
------------ ARCHITECTURE ----------------
ARCHITECTURE structure OF WB IS
	SIGNAL write_data_sig : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

	write_data_sig	<= ALU_Result WHEN MemtoReg = '0' ELSE read_data;
	
	write_data 		<= write_data_sig;
	
END structure;
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY EX_MEM IS
    GENERIC (
        DATA_BUS_WIDTH : INTEGER := 32;
        REG_ADDR_WIDTH : INTEGER := 5;
		PC_WIDTH	   : INTEGER := 10
    );
    PORT (
        clk_i          : IN  STD_LOGIC;
        rst_i          : IN  STD_LOGIC;

        -- Inputs from EX stage
        alu_result_i   : IN  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
        write_data_i   : IN  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
        rd_i           : IN  STD_LOGIC_VECTOR(REG_ADDR_WIDTH-1 DOWNTO 0);
        reg_write_i    : IN  STD_LOGIC;
        mem_to_reg_i   : IN  STD_LOGIC;
        mem_read_i     : IN  STD_LOGIC;
        mem_write_i    : IN  STD_LOGIC;
		pc_i 		   : IN	 STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
        instruction_i  : IN  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);

        -- Outputs to MEM stage
        alu_result_o   : OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
        write_data_o   : OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
        rd_o           : OUT STD_LOGIC_VECTOR(REG_ADDR_WIDTH-1 DOWNTO 0);
        reg_write_o    : OUT STD_LOGIC;
        mem_to_reg_o   : OUT STD_LOGIC;
        mem_read_o     : OUT STD_LOGIC;
        mem_write_o    : OUT STD_LOGIC;
		pc_o 		   : OUT	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
        instruction_o  : OUT  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0)
    );
END EX_MEM;

ARCHITECTURE rtl OF EX_MEM IS
BEGIN
    process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            alu_result_o  <= (others => '0');
            write_data_o  <= (others => '0');
            rd_o          <= (others => '0');
			pc_o		  <= (others => '0');
			instruction_o <= (others => '0');
            reg_write_o   <= '0';
            mem_to_reg_o  <= '0';
            mem_read_o    <= '0';
            mem_write_o   <= '0';
        elsif rising_edge(clk_i) then
            alu_result_o  <= alu_result_i;
            write_data_o  <= write_data_i;
            rd_o          <= rd_i;
            reg_write_o   <= reg_write_i;
            mem_to_reg_o  <= mem_to_reg_i;
            mem_read_o    <= mem_read_i;
            mem_write_o   <= mem_write_i;
			pc_o		  <=pc_i;
			instruction_o <=instruction_i;
        end if;
    end process;
END rtl;

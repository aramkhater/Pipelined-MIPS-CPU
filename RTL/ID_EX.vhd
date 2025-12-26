LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- nope as input 
ENTITY ID_EX IS
    GENERIC (
        DATA_BUS_WIDTH : INTEGER := 32;
        REG_ADDR_WIDTH : INTEGER := 5;
        ALU_OP_WIDTH   : INTEGER := 3;
        PC_WIDTH       : INTEGER := 10;
        OPCODE_WIDTH   : INTEGER := 6;
        FUNCT_WIDTH    : INTEGER := 6
    );
    PORT (
        clk_i              : IN  STD_LOGIC;
        rst_i              : IN  STD_LOGIC;

        -- Inputs from ID stage
        pc_plus4_i         : IN  STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
        read_data1_i       : IN  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
        read_data2_i       : IN  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
        sign_extend_i      : IN  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
        rs_i               : IN  STD_LOGIC_VECTOR(REG_ADDR_WIDTH-1 DOWNTO 0);
        rt_i               : IN  STD_LOGIC_VECTOR(REG_ADDR_WIDTH-1 DOWNTO 0);
        rd_i               : IN  STD_LOGIC_VECTOR(REG_ADDR_WIDTH-1 DOWNTO 0);
        alu_op_i           : IN  STD_LOGIC_VECTOR(ALU_OP_WIDTH-1 DOWNTO 0);
        alu_src_i          : IN  STD_LOGIC;
        reg_dst_i          : IN  STD_LOGIC;
        mem_read_i         : IN  STD_LOGIC;
        mem_write_i        : IN  STD_LOGIC;
        mem_to_reg_i       : IN  STD_LOGIC;
        reg_write_i        : IN  STD_LOGIC;
        opcode_i           : IN  STD_LOGIC_VECTOR(OPCODE_WIDTH-1 DOWNTO 0);
        funct_i            : IN  STD_LOGIC_VECTOR(FUNCT_WIDTH-1 DOWNTO 0);
		--stall_i            : IN  STD_LOGIC; -- from datahazard unit
		nope_ctl_i         : IN  STD_LOGIC;
		pc_i 		       : IN	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
        instruction_i      : IN  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		 breakpoinAddr_i : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);

        -- Outputs to EX stage
        pc_plus4_o         : OUT STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
        read_data1_o       : OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
        read_data2_o       : OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
        sign_extend_o      : OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
        rs_o               : OUT STD_LOGIC_VECTOR(REG_ADDR_WIDTH-1 DOWNTO 0);
        rt_o               : OUT STD_LOGIC_VECTOR(REG_ADDR_WIDTH-1 DOWNTO 0);
        rd_o               : OUT STD_LOGIC_VECTOR(REG_ADDR_WIDTH-1 DOWNTO 0);
        alu_op_o           : OUT STD_LOGIC_VECTOR(ALU_OP_WIDTH-1 DOWNTO 0);
        alu_src_o          : OUT STD_LOGIC;
        reg_dst_o          : OUT STD_LOGIC;
        mem_read_o         : OUT STD_LOGIC;
        mem_write_o        : OUT STD_LOGIC;
        mem_to_reg_o       : OUT STD_LOGIC;
        reg_write_o        : OUT STD_LOGIC;
        opcode_o           : OUT STD_LOGIC_VECTOR(OPCODE_WIDTH-1 DOWNTO 0);
        funct_o            : OUT STD_LOGIC_VECTOR(FUNCT_WIDTH-1 DOWNTO 0);
		pc_o 			   : OUT	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
		break_o           : OUT STD_LOGIC;
        instruction_o      : OUT  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0)
    );
END ID_EX;

ARCHITECTURE rtl OF ID_EX IS
SIGNAL break_w   : STD_LOGIC;
BEGIN
        BREAK_LOGIC : PROCESS(pc_i, breakpoinAddr_i)
    BEGIN
        IF pc_i = breakpoinAddr_i THEN
            break_w <= '1';
        ELSE
            break_w <= '0';
        END IF;
    END PROCESS;
    process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            pc_plus4_o      <= (others => '0');
            read_data1_o    <= (others => '0');
            read_data2_o    <= (others => '0');
            sign_extend_o   <= (others => '0');
            rs_o            <= (others => '0');
            rt_o            <= (others => '0');
            rd_o            <= (others => '0');
            alu_op_o        <= (others => '0');
            alu_src_o       <= '0';
            reg_dst_o       <= '0';
            mem_read_o      <= '0';
            mem_write_o     <= '0';
            mem_to_reg_o    <= '0';
            reg_write_o     <= '0';
            opcode_o        <= (others => '0');
            funct_o         <= (others => '0');
			pc_o            <= (others => '0');
			instruction_o	<= (others => '0');
        elsif rising_edge(clk_i) THEN 
		  if break_w='0' then 
            pc_plus4_o      <= pc_plus4_i;
            read_data1_o    <= read_data1_i;
            read_data2_o    <= read_data2_i;
            sign_extend_o   <= sign_extend_i;
            rs_o            <= rs_i;
            rt_o            <= rt_i;
            rd_o            <= rd_i;
            opcode_o        <= opcode_i;
            funct_o         <= funct_i;
			pc_o			<=pc_i;
			instruction_o	<=instruction_i;
		  end if;
			if (nope_ctl_i = '1' or break_w='1') then
				
				alu_op_o      <= (others => '0');
				alu_src_o     <= '0';
				reg_dst_o     <= '0';
				mem_read_o    <= '0';
				mem_write_o   <= '0';
				mem_to_reg_o  <= '0';
				reg_write_o   <= '0';
			else
				
				alu_op_o      <= alu_op_i;
				alu_src_o     <= alu_src_i;
				reg_dst_o     <= reg_dst_i;
				mem_read_o    <= mem_read_i;
				mem_write_o   <= mem_write_i;
				mem_to_reg_o  <= mem_to_reg_i;
				reg_write_o   <= reg_write_i;
			end if;

        end if;
    end process;
	break_o       <= break_w;
END rtl;

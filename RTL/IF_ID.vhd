LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY IF_ID IS
    GENERIC (
        PC_WIDTH       : INTEGER := 10;
        DATA_BUS_WIDTH : INTEGER := 32
    );
    PORT (
        clk_i           : IN  STD_LOGIC;
        rst_i           : IN  STD_LOGIC;
        pc_plus4_i      : IN  STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
        pc_i            : IN  STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
        instruction_i   : IN  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
        flush_i         : IN  STD_LOGIC;  -- from control
        stall_i         : IN  STD_LOGIC;  -- from data hazard
		break_i         : IN  STD_LOGIC;
        --breakpoinAddr_i : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);

        pc_plus4_o      : OUT STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
        pc_o            : OUT STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
        instruction_o   : OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0)
       -- break_o         : OUT STD_LOGIC
    );
END IF_ID;

ARCHITECTURE rtl OF IF_ID IS
    SIGNAL pc_reg    : STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
    SIGNAL pc_w      : STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
    SIGNAL instr_reg : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
    --SIGNAL break_w   : STD_LOGIC;
BEGIN



    -- Pipeline register logic
    PROCESS(clk_i, rst_i)
    BEGIN
        IF rst_i = '1' THEN
            pc_reg    <= (OTHERS => '0');
            pc_w      <= (OTHERS => '0');
            instr_reg <= (OTHERS => '0');

        ELSIF rising_edge(clk_i) and break_i='0' THEN
   
            IF flush_i = '1' THEN
                instr_reg <= (OTHERS => '0');  -- Flush the instruction
            ELSIF stall_i = '0' THEN
                pc_reg    <= pc_plus4_i;
                pc_w      <= pc_i;
                instr_reg <= instruction_i;
            END IF;
        END IF;
    END PROCESS;

    -- Outputs
    pc_plus4_o    <= pc_reg;
    pc_o          <= pc_w;
    instruction_o <= instr_reg;
   -- break_o       <= break_w;

END rtl;

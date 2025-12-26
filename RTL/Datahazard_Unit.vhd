
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Datahazard_Unit IS
	PORT( 	
		clk_i       : in  std_logic;
        rst_i     : in  std_logic;
		
		instruction_i		: IN	STD_LOGIC_VECTOR(31 DOWNTO 0);
		WriteReg_Ex_i       : IN    STD_LOGIC_VECTOR(4 DOWNTO 0); -- to check if stalling inst. dependent on LW. for example add after LW.
	    WriteReg_MEM_i      : IN    STD_LOGIC_VECTOR(4 DOWNTO 0);
		MemRead_Ex_i		: IN	STD_LOGIC; -- if LW in Ex stage it will be 1.
		MemRead_MEM_i		: IN	STD_LOGIC; -- if LW in MEM stage it will be 1.
		breq_i              : IN    STD_LOGIC;
		brneq_i             : IN    STD_LOGIC;
		PCWrite_o			: OUT 	STD_LOGIC; -- freeze the PC. when LW in the pipeline
		nope_ctl_o          : OUT	STD_LOGIC; --when data dependency, reset ID_EX ctl signals.	
		Stall_br_o          : OUT	STD_LOGIC;  -- stall branch till the data hazard resolved
		Stall_o		        : OUT	STD_LOGIC;  --  stall till the data hazard resolved
		STCNT_o   : out std_logic_vector(7 downto 0) --Stall Counter
	);
end Datahazard_Unit;


ARCHITECTURE behavior OF Datahazard_Unit IS
    signal rs_w, rt_w    : STD_LOGIC_VECTOR(4 DOWNTO 0);
    signal lwstall_w          : STD_LOGIC;
	signal stall_counter_reg : std_logic_vector(7 downto 0) := (others => '0');
BEGIN

    rs_w <= instruction_i(25 downto 21);
    rt_w <= instruction_i(20 downto 16);

lwstall_w <= '1' when (
    ( ((rs_w = WriteReg_Ex_i) and (rs_w /= "00000") and (MemRead_Ex_i = '1')) or
      ((rt_w = WriteReg_Ex_i) and (rt_w /= "00000") and (MemRead_Ex_i = '1')) ) or
    ( (breq_i = '1' or brneq_i = '1') and (
        ((rs_w = WriteReg_Ex_i)   and (rs_w   /= "00000") and (MemRead_Ex_i  = '1')) or
        ((rt_w = WriteReg_Ex_i)   and (rt_w   /= "00000") and (MemRead_Ex_i  = '1')) or
        ((rs_w = WriteReg_MEM_i)  and (rs_w   /= "00000") and (MemRead_MEM_i = '1')) or
        ((rt_w = WriteReg_MEM_i)  and (rt_w   /= "00000") and (MemRead_MEM_i = '1'))
    ))
) else '0';

    Stall_o      <= lwstall_w;
    Stall_br_o   <= '1' when (breq_i = '1' or brneq_i = '1') and lwstall_w = '1' else '0';
    nope_ctl_o   <= lwstall_w;
    PCWrite_o    <= (not lwstall_w); --and ((breq_i = '0' and brneq_i = '0'));
    process(clk_i)
    begin
	
		if rst_i = '1' then
            stall_counter_reg <= (others => '0');
        elsif rising_edge(clk_i) then
            if Stall_o = '1' or Stall_br_o='1' then
                stall_counter_reg <= stall_counter_reg + 1;
            end if;
        end if;
    end process;

    STCNT_o <= stall_counter_reg;
END behavior;

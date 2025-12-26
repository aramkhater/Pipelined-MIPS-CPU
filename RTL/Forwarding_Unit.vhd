LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY forwardingUnit IS
    PORT(
        rsD_i       : IN  STD_LOGIC_VECTOR(4 DOWNTO 0); 
        rtD_i       : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        rsE_i       : IN  STD_LOGIC_VECTOR(4 DOWNTO 0); 
        rtE_i       : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        WriteRegE_i : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        WriteRegM_i : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        WriteRegW_i : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        RegWriteE_i : IN  STD_LOGIC; -- rd or rt
        RegWriteM_i : IN  STD_LOGIC;
        RegWriteW_i : IN  STD_LOGIC;
        ForwardAE_o : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        ForwardBE_o : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        ForwardAID_o : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        ForwardBID_o : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
END forwardingUnit;

ARCHITECTURE behavior OF forwardingUnit IS
BEGIN

    -- Forward signals to the ID stage 
    ForwardAID_o <= "10" when ((WriteRegE_i /= "00000") and (rsD_i = WriteRegE_i) and (RegWriteE_i = '1')) else
                      "01" when ((WriteRegM_i /= "00000") and (rsD_i = WriteRegM_i) and (RegWriteM_i = '1') and not (RegWriteE_i = '1' and WriteRegE_i = rsD_i)) else
                      "00";

    ForwardBID_o <= "10" when ((WriteRegE_i /= "00000") and (rtD_i = WriteRegE_i) and (RegWriteE_i = '1')) else
                      "01" when ((WriteRegM_i /= "00000") and (rtD_i = WriteRegM_i) and (RegWriteM_i = '1') and not (RegWriteE_i = '1' and WriteRegE_i = rtD_i)) else
                      "00";

    -- Forward signals to the EX stage  
    ForwardAE_o <= "10" when ((WriteRegM_i /= "00000") and (rsE_i = WriteRegM_i) and (RegWriteM_i = '1')) else
                   "01" when ((WriteRegW_i /= "00000") and (rsE_i = WriteRegW_i) and (RegWriteW_i = '1') and not (RegWriteM_i = '1' and WriteRegM_i = rsE_i)) else
                   "00";

    ForwardBE_o <= "10" when ((WriteRegM_i /= "00000") and (rtE_i = WriteRegM_i) and (RegWriteM_i = '1')) else
                   "01" when ((WriteRegW_i /= "00000") and (rtE_i = WriteRegW_i) and (RegWriteW_i = '1') and not (RegWriteM_i = '1' and WriteRegM_i = rtE_i)) else
                   "00";

END behavior;



-- Components
---------------------------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;
USE work.cond_comilation_package.all;


package aux_package is




COMPONENT Datahazard_Unit IS
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
		Stall_br_o          : OUT	STD_LOGIC;  -- 
		Stall_o		        : OUT	STD_LOGIC;  --
		STCNT_o   : out std_logic_vector(7 downto 0) --Stall Counter

	);
end COMPONENT;

COMPONENT forwardingUnit IS
    PORT(
        rsD_i       : IN  STD_LOGIC_VECTOR(4 DOWNTO 0); 
        rtD_i       : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        rsE_i       : IN  STD_LOGIC_VECTOR(4 DOWNTO 0); 
        rtE_i       : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        WriteRegE_i : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        WriteRegM_i : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        WriteRegW_i : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        RegWriteE_i : IN  STD_LOGIC;
        RegWriteM_i : IN  STD_LOGIC;
        RegWriteW_i : IN  STD_LOGIC;
        ForwardAE_o : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        ForwardBE_o : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        ForwardAID_o : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        ForwardBID_o : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
END COMPONENT;

	component MIPS is
		generic( 
			WORD_GRANULARITY : boolean 	:= G_WORD_GRANULARITY;
	        MODELSIM : integer 			:= G_MODELSIM;
			DATA_BUS_WIDTH : integer 	:= 32;
			ITCM_ADDR_WIDTH : integer 	:= G_ADDRWIDTH;
			DTCM_ADDR_WIDTH : integer 	:= G_ADDRWIDTH;
			PC_WIDTH : integer 			:= 10;
			FUNCT_WIDTH : integer 		:= 6;
			DATA_WORDS_NUM : integer 	:= G_DATA_WORDS_NUM;
			CLK_CNT_WIDTH : integer 	:= 16;
			INST_CNT_WIDTH : integer 	:= 16
		);
		PORT(	
			rst_i		 		:IN	STD_LOGIC;
			clk_i				:IN	STD_LOGIC;
            BPADDR_i            :IN STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);			
			-- Output important signals to pins for easy display in Simulator
			--pc_o				:OUT	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
			--alu_result_o 		:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			--read_data1_o 		:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			--read_data2_o 		:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			--write_data_o		:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			--instruction_top_o	:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			--Branch_ctrl_o		:OUT 	STD_LOGIC_VECTOR(1 downto 0);
			--Zero_o				:OUT 	STD_LOGIC; 
			--MemWrite_ctrl_o		:OUT 	STD_LOGIC;
			--RegWrite_ctrl_o		:OUT 	STD_LOGIC;
			
			IFpc_o				:OUT	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
			IFinstruction_o		:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			IDpc_o				:OUT	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
			IDinstruction_o		:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			EXpc_o				:OUT	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
			EXinstruction_o		:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			MEMpc_o				:OUT	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
			MEMinstruction_o	:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			WBpc_o				:OUT	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
			WBinstruction_o		:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			
			mclk_cnt_o			:OUT	STD_LOGIC_VECTOR(CLK_CNT_WIDTH-1 DOWNTO 0);
			inst_cnt_o 			:OUT	STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0);
			STCNT_o   			:OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
			STRIGGER_o          :OUT   STD_LOGIC;
			FHCNT_o				:OUT	STD_LOGIC_VECTOR(7 DOWNTO 0)

		);		
	end component;
---------------------------------------------------------  
	component control is
		PORT( 	
		opcode_i 			: IN 	STD_LOGIC_VECTOR(5 DOWNTO 0);
		funct_i             : IN    STD_LOGIC_VECTOR(5 DOWNTO 0);
		--nope_i              : IN    STD_LOGIC;
		RegDst_ctrl_o 		: OUT 	STD_LOGIC;
		ALUSrc_ctrl_o 		: OUT 	STD_LOGIC;
		MemtoReg_ctrl_o 	: OUT 	STD_LOGIC;
		RegWrite_ctrl_o 	: OUT 	STD_LOGIC;
		MemRead_ctrl_o 		: OUT 	STD_LOGIC;
		MemWrite_ctrl_o	 	: OUT 	STD_LOGIC;
		Branch_ctrl_o 		: OUT 	STD_LOGIC_VECTOR(1 downto 0);
		ALUOp_ctrl_o	 	: OUT 	STD_LOGIC_VECTOR(2 DOWNTO 0);
		--jal_o               : OUT 	STD_LOGIC;
		jr_o                : OUT 	STD_LOGIC;
		JUMP_o              : OUT   STD_LOGIC
		--flush_o             : OUT   STD_LOGIC;
		--stall_ctl_o         : OUT   STD_LOGIC
	);
	end component;
---------------------------------------------------------	
	component dmemory is
		generic(
		DATA_BUS_WIDTH : integer := 32;
		DTCM_ADDR_WIDTH : integer := 8;
		WORDS_NUM : integer := 256
	);
	PORT(	clk_i,rst_i			: IN 	STD_LOGIC;
			dtcm_addr_i 		: IN 	STD_LOGIC_VECTOR(DTCM_ADDR_WIDTH-1 DOWNTO 0);
			dtcm_data_wr_i 		: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			MemRead_ctrl_i  	: IN 	STD_LOGIC;
			MemWrite_ctrl_i 	: IN 	STD_LOGIC;
			dtcm_data_rd_o 		: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0)
	);
	end component;
	
---------------------------------------------------------
component WB IS
	PORT( 
		ALU_Result, read_data	: IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		MemtoReg      			: IN  STD_LOGIC;
		--jal                     : IN  STD_LOGIC;
		--pc_plus_4               : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		write_data 				: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)		
		);
END 	component;
---------------------------------------------------------		
component  Execute IS
	generic(
		DATA_BUS_WIDTH : integer := 32;
		FUNCT_WIDTH : integer := 6;
		PC_WIDTH : integer := 10
	);
	PORT(	read_data1_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_data2_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			sign_extend_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			funct_i 		: IN 	STD_LOGIC_VECTOR(FUNCT_WIDTH-1 DOWNTO 0);
			ALUOp_ctrl_i 	: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0); --change to 3 bits
			ALUSrc_ctrl_i 	: IN 	STD_LOGIC;
			pc_plus4_i 		: IN 	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
			OPC_i           : IN 	STD_LOGIC_VECTOR(FUNCT_WIDTH-1 DOWNTO 0);
			RegDst_ctrl_i 	: IN 	STD_LOGIC;
			rd_i            : IN    STD_LOGIC_VECTOR( 4 DOWNTO 0);
			rt_i            : IN    STD_LOGIC_VECTOR( 4 DOWNTO 0);
		    ForwardAE       : IN    STD_LOGIC_VECTOR(1 DOWNTO 0);
			ForwardBE       : IN    STD_LOGIC_VECTOR(1 DOWNTO 0);
			Forward_MEM     : IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			Forward_alu     : IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			memtoreg        : IN 	STD_LOGIC;
			Forward_WB      : IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			WriteReg_o      : OUT   STD_LOGIC_VECTOR( 4 DOWNTO 0);			
			zero_o 			: OUT	STD_LOGIC;
			alu_res_o 		: OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			--JAL_o 	        : out 	STD_LOGIC;
			WriteDataE_o    : OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0)
	);
END component;
---------------------------------------------------------		
	component Idecode IS
		generic(
			DATA_BUS_WIDTH : integer := 32
		);
		PORT(	clk_i,rst_i		: IN 	STD_LOGIC;
				instruction_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0); --from ex
				dtcm_data_rd_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);-- from mem
				RegWrite_ctrl_i : IN 	STD_LOGIC;--
				--MemtoReg_ctrl_i : IN 	STD_LOGIC;--
				--RegDst_ctrl_i 	: IN 	STD_LOGIC;--
				pc_plus4_i      : IN    STD_LOGIC_VECTOR(9 DOWNTO 0);
				rd_i            : IN    STD_LOGIC_VECTOR(4 DOWNTO 0);
				jump_ctrl_i	        : IN 	STD_LOGIC;
				ForwardAID_i      : IN    STD_LOGIC_VECTOR(1 DOWNTO 0);
				ForwardBID_i      : IN    STD_LOGIC_VECTOR(1 DOWNTO 0);
				RegWrite_data_Ex_i  : IN    STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
				RegWrite_datamalu_MEM_i : IN    STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);			
				RegWrite_datamem_MEM_i : IN    STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
				stall_br_i          : IN   STD_LOGIC;
				MemtoReg_i          : IN   STD_LOGIC;  
				
				read_data1_o	: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
				read_data2_o	: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
				sign_extend_o 	: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
				jr_i            : IN   STD_LOGIC;
				br_taken_o      : OUT   STD_LOGIC;      --New
				br_addr_o       : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);  --New 
				jump_addr_o		: OUT 	STD_LOGIC_VECTOR(7 DOWNTO 0);
				flush_o			: OUT   STD_LOGIC;
				FlushCNT_o			: OUT 	STD_LOGIC_VECTOR(7 DOWNTO 0);

				rs_o            : OUT   STD_LOGIC_VECTOR(4 DOWNTO 0);
				rt_o            : OUT   STD_LOGIC_VECTOR(4 DOWNTO 0);
				write_reg_data_i  : IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0)
			
		);
	END component;
---------------------------------------------------------		
	component Ifetch is
		generic(
			WORD_GRANULARITY : boolean 	:= False;
			DATA_BUS_WIDTH : integer 	:= 32;
			PC_WIDTH : integer 			:= 10;
			NEXT_PC_WIDTH : integer 	:= 8; -- NEXT_PC_WIDTH = PC_WIDTH-2
			ITCM_ADDR_WIDTH : integer 	:= 8;
			WORDS_NUM : integer 		:= 256;
			INST_CNT_WIDTH : integer 	:= 16
		);
		PORT(	
			clk_i, rst_i 	: IN 	STD_LOGIC;
			add_result_i 	: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
        	Branch_ctrl_i 	: IN 	STD_LOGIC_VECTOR(1 downto 0);
			JUMP_i          : IN    STD_LOGIC;
			br_taken_i      : IN    STD_LOGIC;
		    br_addr_i       : IN    STD_LOGIC_VECTOR(7 DOWNTO 0); 
			pc_write_i      : IN    STD_LOGIC;
			break_i         : IN    STD_LOGIC;
			jump_addr_i     : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
			pc_o 			: OUT	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
			pc_plus4_o 		: OUT	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
			instruction_o 	: OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			inst_cnt_o 		: OUT	STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0)	
		);
	end component;
	
	
---------------------------------------------------------
	COMPONENT PLL port(
	    areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0     		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC );
    END COMPONENT;
---------------------------------------------------------	

COMPONENT Shifter is 
  generic (
    N : integer := 8;
    K : integer := 3
  );
  port( 
    y    : in  std_logic_vector(N-1 downto 0);  
    x    : in  std_logic_vector(K-1 downto 0);  
    dir  : in  std_logic_vector(2 downto 0);    
    res  : out std_logic_vector(N-1 downto 0);  
    cout : out std_logic
  );
end COMPONENT;


-----------------PIPLINED--------------------

------ IF to ID ---------------------
COMPONENT IF_ID IS
    GENERIC (
        PC_WIDTH       : INTEGER := 10;
        DATA_BUS_WIDTH : INTEGER := 32
    );
    PORT (
        clk_i          : IN  STD_LOGIC;
        rst_i          : IN  STD_LOGIC;
        pc_plus4_i     : IN  STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
		pc_i 		   : IN	 STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
        instruction_i  : IN  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		flush_i        : IN  STD_LOGIC;  -- from control
		stall_i        : IN  STD_LOGIC;  -- from data hazard
		break_i         : IN  STD_LOGIC;
		--breakpoinAddr_i: IN	STD_LOGIC_VECTOR(9 DOWNTO 0);
        pc_plus4_o     : OUT STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
        pc_o 			: OUT	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
        instruction_o  : OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0)
		--break_o        : OUT STD_LOGIC
    );
END COMPONENT;
----------------------------------------------------------------------

---- ID to EX---------------------------------------------------------
COMPONENT ID_EX IS
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
		break_o         : OUT STD_LOGIC;
        instruction_o      : OUT  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0)
    );
END COMPONENT;
-------------------------------------------------------------------------------
-------- EX to MEM----------
COMPONENT EX_MEM IS
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
END COMPONENT;
---------------------------------------------------------------------------
----MEM to WB
COMPONENT MEM_WB IS
    PORT (
        clk, rst       : IN  STD_LOGIC;
        -- Inputs from MEM stage
        ALU_Result_in  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        Read_Data_in   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); --from MEM
        MemtoReg_in    : IN  STD_LOGIC;
        RegWrite_in    : IN  STD_LOGIC;
        Write_Reg_in   : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
		pc_i 		   : IN	STD_LOGIC_VECTOR(9 DOWNTO 0);
        instruction_i  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		
        -- Outputs to WB stage
        ALU_Result_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        Read_Data_out  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        MemtoReg_out   : OUT STD_LOGIC;
        RegWrite_out   : OUT STD_LOGIC;
        Write_Reg_out  : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		pc_o 		   : OUT	STD_LOGIC_VECTOR(9 DOWNTO 0);
        instruction_o  : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END COMPONENT;

end aux_package;


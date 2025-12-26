
---------------------------------------------------------------------------------------------
-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all;
USE work.cond_comilation_package.all;
USE work.aux_package.all;


ENTITY MIPS IS
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
	PORT(	rst_i		 		:IN	STD_LOGIC;
			clk_i				:IN	STD_LOGIC;
            BPADDR_i            :IN STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);			
			-- Output important signals to pins for easy display in SignalTap
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
			STCNT_o 			:OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
			STRIGGER_o          :OUT   STD_LOGIC;
			FHCNT_o				:OUT	STD_LOGIC_VECTOR(7 DOWNTO 0)
	);		
END MIPS;
-------------------------------------------------------------------------------------
ARCHITECTURE structure OF MIPS IS
	-- declare signals used to connect VHDL components
	SIGNAL pc_plus4_w 		: STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
	SIGNAL read_data1_w 	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL read_data2_w 	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL sign_extend_w 	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL addr_res_w 		: STD_LOGIC_VECTOR(7 DOWNTO 0 );
	SIGNAL alu_result_w 	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL dtcm_data_rd_w 	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL alu_src_w 		: STD_LOGIC;
	SIGNAL branch_w 		: STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL reg_dst_w 		: STD_LOGIC;
	SIGNAL reg_write_w 		: STD_LOGIC;
	SIGNAL zero_w 			: STD_LOGIC;
	SIGNAL jal_w 			: STD_LOGIC;
	SIGNAL mem_write_w 		: STD_LOGIC;
	SIGNAL MemtoReg_w 		: STD_LOGIC;
	SIGNAL mem_read_w 		: STD_LOGIC;
	SIGNAL alu_op_w 		: STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL instruction_w	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL MCLK_w 			: STD_LOGIC;
	SIGNAL mclk_cnt_q		: STD_LOGIC_VECTOR(CLK_CNT_WIDTH-1 DOWNTO 0);
	SIGNAL inst_cnt_w		: STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0);
	SIGNAL jump_w           : STD_LOGIC;
	SIGNAL pc_w				:STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
	SIGNAL IDpc_w				:STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
	SIGNAL EXpc_w				:STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
	SIGNAL EXinstruction_w		:STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL MEMpc_w				:STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
	SIGNAL MEMinstruction_w     :STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	-- IF to ID
	SIGNAL pc_plus4_IFID      : STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
    SIGNAL instruction_IFID   : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
    
	-- Signals between ID and EX stages
	SIGNAL pc_plus4_IDEX         : STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
	SIGNAL read_data1_IDEX       : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL read_data2_IDEX       : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL sign_extend_IDEX      : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL rs_IDEX               : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL rt_IDEX               : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL rd_IDEX               : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL alu_op_IDEX           : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL alu_src_IDEX          : STD_LOGIC;
	SIGNAL reg_dst_IDEX          : STD_LOGIC;
	SIGNAL mem_read_IDEX         : STD_LOGIC;
	SIGNAL mem_write_IDEX        : STD_LOGIC;
	SIGNAL mem_to_reg_IDEX       : STD_LOGIC;
	SIGNAL reg_write_IDEX        : STD_LOGIC;
	
	SIGNAL opcode_IDEX : STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL funct_IDEX : STD_LOGIC_VECTOR(5 DOWNTO 0);

	-- EX to MEM pipeline signals
	SIGNAL alu_result_EXMEM  : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL write_data_EXMEM  : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL rd_EXMEM          : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_write_EXMEM   : STD_LOGIC;
	SIGNAL mem_to_reg_EXMEM  : STD_LOGIC;
	SIGNAL mem_read_EXMEM    : STD_LOGIC;
	SIGNAL mem_write_EXMEM   : STD_LOGIC;

	--WB
	signal MEM_WB_ALU_Result   : std_logic_vector(31 downto 0);
	signal MEM_WB_read_data    : std_logic_vector(31 downto 0);
	signal MEM_WB_MemtoReg     : std_logic;
	signal MEM_WB_write_data   : std_logic_vector(31 downto 0);  -- output from WB stage
    signal addr_res_EXtoWB     : STD_LOGIC_VECTOR(7 DOWNTO 0 );  -- for JAL
	signal jal_EXtoWB          : std_logic;  
	signal write_reg_data_WBtoID	   : std_logic_vector(31 downto 0); 
	--WB to ID
	signal write_reg_data_w	   : std_logic_vector(31 downto 0); 
	-- ID to IF when Branch
	signal jr_w                : STD_LOGIC;
	signal br_taken_w          : STD_LOGIC;
	signal addr_br_w           :std_logic_vector( 7 downto 0); 
    --
	signal rd_ID_w             :std_logic_vector( 4 downto 0); 
    signal ALU_res_WB_w        : std_logic_vector(31 downto 0); 
    signal Read_data_WB_w      : std_logic_vector(31 downto 0); 
 	signal MemtoReg_WB_w       : STD_LOGIC;
	signal RegWrite_ID_w       : STD_LOGIC;
     
	--
	signal inst_cnt_q : std_logic_vector(INST_CNT_WIDTH-1 downto 0);
	signal RegDst_E_w : STD_LOGIC;
	signal rd_E_w     : STD_LOGIC_VECTOR(4 downto 0);
	signal rt_E_w     : STD_LOGIC_VECTOR(4 downto 0);
	signal WriteReg_E_w    : STD_LOGIC_VECTOR(4 downto 0);
	
	--EX
    signal WriteDataE_w     : std_logic_vector(31 downto 0);
    signal ForwardAE_Ex_w : STD_LOGIC_VECTOR(1 downto 0);
	signal ForwardBE_Ex_w : STD_LOGIC_VECTOR(1 downto 0);
	--CTL
	signal flush_w        : STD_LOGIC;
	signal Stall_br_w     : STD_LOGIC;      
	signal stall_w		  : STD_LOGIC;
	signal pcwrite_w      : STD_LOGIC;
	signal break_w		  : STD_LOGIC;
	signal jump_addr_w    :std_logic_vector( 7 downto 0); 
	
	signal stall_ctl_w    : STD_LOGIC;
	signal nop_ctl_w      : STD_LOGIC;
	signal rsD_w          : STD_LOGIC_VECTOR(4 downto 0);  
	signal rtD_w          : STD_LOGIC_VECTOR(4 downto 0);
	signal ForwardAID_w   : STD_LOGIC_VECTOR(1 downto 0);
	signal ForwardBID_w   : STD_LOGIC_VECTOR(1 downto 0);
BEGIN
					-- copy important signals to output pins for easy 
					-- display in Simulator
   --instruction_top_o 	<= 	instruction_w;
   --alu_result_o 		<= 	alu_result_w;
   --read_data1_o 		<= 	read_data1_w;
   --read_data2_o 		<= 	read_data2_w;
--write_data_o  		<= 	dtcm_data_rd_w WHEN MemtoReg_w = '1' ELSE 
							--alu_result_w;
	
	IFpc_o  <=          pc_w;
	IFinstruction_o		<= instruction_w;
	IDinstruction_o		<=instruction_IFID;
	STRIGGER_o          <= break_w;
   --Branch_ctrl_o 		<= 	branch_w;
   --Zero_o 				<= 	zero_w;
   --RegWrite_ctrl_o 		<= 	reg_write_w;
   --MemWrite_ctrl_o 		<= 	mem_write_w;	
	IDpc_w     			<=IDpc_o;
	EXpc_w				<=EXpc_o;
	EXinstruction_w		<=EXinstruction_o;
	MEMpc_w				<=MEMpc_o;
	MEMinstruction_w	<=MEMinstruction_o;
	-- connect the PLL component
	G0:
	if (MODELSIM = 0) generate
	  MCLK: PLL
		PORT MAP (
			inclk0 	=> clk_i,
			c0 		=> MCLK_w
		);
	else generate
		MCLK_w <= clk_i;
	end generate;
	-- connect the 5 MIPS components   
	IFE : Ifetch
	generic map(
		WORD_GRANULARITY	=> 	WORD_GRANULARITY,
		DATA_BUS_WIDTH		=> 	DATA_BUS_WIDTH, 
		PC_WIDTH			=>	PC_WIDTH,
		ITCM_ADDR_WIDTH		=>	ITCM_ADDR_WIDTH,
		WORDS_NUM			=>	DATA_WORDS_NUM,
		INST_CNT_WIDTH		=>	INST_CNT_WIDTH
	)
	PORT MAP (	
		clk_i 			=> MCLK_w,  
		rst_i 			=> rst_i, 
		add_result_i 	=> addr_res_w,
		Branch_ctrl_i 	=> branch_w,
		--zero_i 			=> zero_w,
		JUMP_i          => jump_w,
		br_taken_i      => br_taken_w,
		br_addr_i       => addr_br_w,
		pc_write_i      => pcwrite_w,
		break_i         => break_w,
		jump_addr_i     => jump_addr_w,
		pc_o 			=> pc_w,
		instruction_o 	=> instruction_w,
    	pc_plus4_o	 	=> pc_plus4_w,
		inst_cnt_o		=> inst_cnt_w
	);

	ID : Idecode
   	generic map(
		DATA_BUS_WIDTH		    => DATA_BUS_WIDTH
	)
	PORT MAP (	
			clk_i 				=> MCLK_w,  
			rst_i 				=> rst_i,
        	instruction_i       => instruction_IFID,
        	dtcm_data_rd_i 		=> dtcm_data_rd_w,
			RegWrite_ctrl_i 	=> RegWrite_ID_w,--reg_write_o
			--MemtoReg_ctrl_i 	=> MemtoReg_w,
			--RegDst_ctrl_i 		=> reg_dst_w,
			pc_plus4_i          => pc_plus4_IFID,
			rd_i                => rd_ID_w,
            jump_ctrl_i	        => jump_w,
			ForwardAID_i        => ForwardAID_w,
			ForwardBID_i        => ForwardBID_w,
			RegWrite_data_Ex_i  => alu_result_w,
            RegWrite_datamalu_MEM_i => alu_result_EXMEM,			
			RegWrite_datamem_MEM_i => dtcm_data_rd_w,
			stall_br_i          => Stall_br_w,
			MemtoReg_i          =>mem_to_reg_EXMEM,
			
			read_data1_o 		=> read_data1_w,
        	read_data2_o 		=> read_data2_w,
			sign_extend_o 		=> sign_extend_w,
			jr_i                => jr_w,
		    br_taken_o          =>br_taken_w,
		    br_addr_o           => addr_br_w,
			jump_addr_o         => jump_addr_w,
			flush_o             => flush_w,
			FlushCNT_o			=>FHCNT_o,
			rs_o                => rsD_w,
			rt_o                => rtD_w,
			write_reg_data_i    => write_reg_data_w
		);

	CTL:   control
	PORT MAP ( 	
			opcode_i      => instruction_IFID(DATA_BUS_WIDTH-1 DOWNTO 26),
			funct_i       => instruction_IFID(FUNCT_WIDTH-1 DOWNTO 0),
			RegDst_ctrl_o 		=> reg_dst_w,
			ALUSrc_ctrl_o 		=> alu_src_w,
			MemtoReg_ctrl_o 	=> MemtoReg_w,
			RegWrite_ctrl_o 	=> reg_write_w,
			MemRead_ctrl_o 		=> mem_read_w,
			MemWrite_ctrl_o 	=> mem_write_w,
			Branch_ctrl_o 		=> branch_w,
			ALUOp_ctrl_o 		=> alu_op_w,
			--jal_o               =>
			jr_o                => jr_w,
			JUMP_o              =>jump_w
		);

	EXE: Execute
	generic map(
		DATA_BUS_WIDTH => DATA_BUS_WIDTH,
		FUNCT_WIDTH    => FUNCT_WIDTH,
		PC_WIDTH       => PC_WIDTH
	)
	port map (
		pc_plus4_i     => pc_plus4_IDEX,
		read_data1_i   => read_data1_IDEX,
		read_data2_i   => read_data2_IDEX,
		sign_extend_i  => sign_extend_IDEX,
		funct_i => funct_IDEX,
		ALUOp_ctrl_i   => alu_op_IDEX,
		ALUSrc_ctrl_i  => alu_src_IDEX,
		OPC_i          => opcode_IDEX, 
        RegDst_ctrl_i  =>reg_dst_IDEX,
		rd_i           =>rd_IDEX,
		rt_i           =>rt_IDEX,	
	    ForwardAE      => ForwardAE_Ex_w,
        ForwardBE      => ForwardBE_Ex_w,
	    Forward_MEM    => dtcm_data_rd_w, -- forward mem res
		Forward_alu    => alu_result_EXMEM, -- forward alu res
		memtoreg     => mem_to_reg_EXMEM,
	    Forward_WB     => write_reg_data_w,
        WriteReg_o     => WriteReg_E_w,		
		zero_o         => zero_w,
		alu_res_o      => alu_result_w,
		--addr_res_o     => addr_res_w,
		--JAL_o          => jal_w,
		WriteDataE_o   => WriteDataE_w
	);

    FW:forwardingUnit 
	port map (
	    rsD_i          => rsD_w,
        rtD_i          => rtD_w,
	    rsE_i          => rs_IDEX,	
        rtE_i          => rt_IDEX,
		WriteRegE_i    => WriteReg_E_w,--rd_IDEX,
        WriteRegM_i    => rd_EXMEM,
		WriteRegW_i    => rd_ID_w,
        RegWriteE_i    => reg_write_IDEX,		
        RegWriteM_i    => reg_write_EXMEM,
        RegWriteW_i    => RegWrite_ID_w,
        ForwardAE_o    => ForwardAE_Ex_w,  
        ForwardBE_o    => ForwardBE_Ex_w,
	    ForwardAID_o   => ForwardAID_w,
        ForwardBID_o   => ForwardBID_w 
    );   
    
	DataHazard: Datahazard_Unit
	port map (
	    clk_i 			=> MCLK_w,  
		rst_i 			=> rst_i,
		instruction_i  => 	instruction_IFID,
    	WriteReg_Ex_i  =>   rt_IDEX, -- for handling LW
	    WriteReg_MEM_i =>   rd_EXMEM, 
		MemRead_Ex_i   =>   mem_to_reg_IDEX, 
		MemRead_MEM_i  =>   mem_to_reg_EXMEM, 
		breq_i         =>   branch_w(0),    
		brneq_i        =>   branch_w(1),  
		PCWrite_o 	   =>   pcwrite_w,
		nope_ctl_o     =>   nop_ctl_w,
		Stall_br_o     =>   Stall_br_w,
		Stall_o	       =>	stall_w,
		STCNT_o   	   =>   STCNT_o --Stall Counter

    );		
					  
	WB_Stage: entity work.WB
    port map (
    ALU_Result => ALU_res_WB_w,
    read_data  => Read_data_WB_w,
	--pc_plus4   => addr_res_EXtoWB,
    MemtoReg   => MemtoReg_WB_w,
	--jal        =>  
	--pc_plus_4  =>                          
    write_data => write_reg_data_w
);


	G1: 
	if (WORD_GRANULARITY = True) generate -- i.e. each WORD has a uniqe address
		MEM:  dmemory
			generic map(
				DATA_BUS_WIDTH		=> 	DATA_BUS_WIDTH, 
				DTCM_ADDR_WIDTH		=> 	DTCM_ADDR_WIDTH,
				WORDS_NUM			=>	DATA_WORDS_NUM
			)
			PORT MAP (	
				clk_i 				=> MCLK_w,  
				rst_i 				=> rst_i,
				dtcm_addr_i 		=> alu_result_EXMEM((DTCM_ADDR_WIDTH+2)-1 DOWNTO 2), -- increment memory address by 4
				dtcm_data_wr_i 		=> write_data_EXMEM, -- need change
				MemRead_ctrl_i 		=> mem_read_EXMEM, 
				MemWrite_ctrl_i 	=> mem_write_EXMEM,
				dtcm_data_rd_o 		=> dtcm_data_rd_w 
			);	
	elsif (WORD_GRANULARITY = False) generate -- i.e. each BYTE has a uniqe address	
		MEM:  dmemory
			generic map(
				DATA_BUS_WIDTH		=> 	DATA_BUS_WIDTH, 
				DTCM_ADDR_WIDTH		=> 	DTCM_ADDR_WIDTH,
				WORDS_NUM			=>	DATA_WORDS_NUM
			)
			PORT MAP (	
				clk_i 				=> MCLK_w,  
				rst_i 				=> rst_i,
				dtcm_addr_i 		=> alu_result_EXMEM(DTCM_ADDR_WIDTH-1 DOWNTO 2)&"00", --edited
				dtcm_data_wr_i 		=> write_data_EXMEM, -- Here too
				MemRead_ctrl_i 		=> mem_read_EXMEM, 
				MemWrite_ctrl_i 	=> mem_write_EXMEM,
				dtcm_data_rd_o 		=> dtcm_data_rd_w
			);
	end generate;
	

-----Register for piplining
-----Stage 1
IF_ID_Stage : entity work.IF_ID
    generic map (
        PC_WIDTH       => PC_WIDTH,
        DATA_BUS_WIDTH => DATA_BUS_WIDTH
    )
    port map (
        clk_i         => MCLK_w,
        rst_i         => rst_i,
        pc_plus4_i    => pc_plus4_w,
		pc_i		  =>pc_w,
        instruction_i => instruction_w,
		flush_i       => flush_w,
		stall_i       => stall_w,
		--breakpoinAddr_i   => BPADDR_i,
		break_i        => break_w,
		
        pc_plus4_o    => pc_plus4_IFID,
		pc_o		 => IDpc_o,
        instruction_o => instruction_IFID
		--break_o        => break_w
		
    );
-------------------------------------------
-----Stage 2
ID_EX_Stage : entity work.ID_EX
    generic map (
        DATA_BUS_WIDTH => DATA_BUS_WIDTH,
        REG_ADDR_WIDTH => 5,
        ALU_OP_WIDTH   => 3,
        PC_WIDTH       => PC_WIDTH,
        OPCODE_WIDTH   => 6
    )
    port map (
        clk_i            => MCLK_w,
        rst_i            => rst_i,

        -- Inputs from ID stage
        pc_plus4_i       => pc_plus4_IFID,
        read_data1_i     => read_data1_w,
        read_data2_i     => read_data2_w,
        sign_extend_i    => sign_extend_w,
        rs_i             => instruction_IFID(25 DOWNTO 21),
        rt_i             => instruction_IFID(20 DOWNTO 16),
        rd_i             => instruction_IFID(15 DOWNTO 11),
        alu_op_i         => alu_op_w,
        alu_src_i        => alu_src_w,
        reg_dst_i        => reg_dst_w,
        mem_read_i       => mem_read_w,
        mem_write_i      => mem_write_w,
        mem_to_reg_i     => MemtoReg_w,
        reg_write_i      => reg_write_w,
        opcode_i         => instruction_IFID(31 DOWNTO 26),
		funct_i          => instruction_IFID(5 DOWNTO 0),
		nope_ctl_i      =>nop_ctl_w,
		--break_i        => break_w,
        pc_i			=>IDpc_w,
		instruction_i	=>instruction_IFID,
		breakpoinAddr_i   => BPADDR_i,
		
        -- Outputs to EX stage
        pc_plus4_o       => pc_plus4_IDEX,
        read_data1_o     => read_data1_IDEX,
        read_data2_o     => read_data2_IDEX,
        sign_extend_o    => sign_extend_IDEX,
        rs_o             => rs_IDEX,
        rt_o             => rt_IDEX,
        rd_o             => rd_IDEX,
        alu_op_o         => alu_op_IDEX,
        alu_src_o        => alu_src_IDEX,
        reg_dst_o        => reg_dst_IDEX,
        mem_read_o       => mem_read_IDEX,
        mem_write_o      => mem_write_IDEX,
        mem_to_reg_o     => mem_to_reg_IDEX,
        reg_write_o      => reg_write_IDEX,
        opcode_o         => opcode_IDEX,
		funct_o  => funct_IDEX,
		pc_o			=>EXpc_o,
		break_o        => break_w,
		instruction_o	=>EXinstruction_o
    );


----------------------------------------------------

----Stage 3
EX_MEM_Stage : entity work.EX_MEM
    generic map (
        DATA_BUS_WIDTH => DATA_BUS_WIDTH,
        REG_ADDR_WIDTH => 5,
		PC_WIDTH	   => PC_WIDTH
    )
    port map (
        clk_i          => MCLK_w,
        rst_i          => rst_i,

        alu_result_i   => alu_result_w,
        write_data_i   => WriteDataE_w,   -- rs2 from ID/EX (for SW)
        rd_i           => WriteReg_E_w,           -- target register from EX
        reg_write_i    => reg_write_IDEX,
        mem_to_reg_i   => mem_to_reg_IDEX,
        mem_read_i     => mem_read_IDEX,
        mem_write_i    => mem_write_IDEX,
		--break_i        => break_w,
		pc_i			=>EXpc_w,
		instruction_i	=>EXinstruction_w,

        alu_result_o   => alu_result_EXMEM,
        write_data_o   => write_data_EXMEM, -- Write data
        rd_o           => rd_EXMEM,
        reg_write_o    => reg_write_EXMEM,
        mem_to_reg_o   => mem_to_reg_EXMEM,
        mem_read_o     => mem_read_EXMEM,
        mem_write_o    => mem_write_EXMEM,
		pc_o			=>MEMpc_o,
		instruction_o	=>MEMinstruction_o
    );

-----------------------------------------------
-----Stage 4
MEM_WB_Stage : entity work.MEM_WB
    
	port map (
	    clk           => MCLK_w,
		rst           => rst_i,
        
        ALU_Result_in => alu_result_EXMEM,
        Read_Data_in  => dtcm_data_rd_w,  
        MemtoReg_in   => mem_to_reg_EXMEM,  
        RegWrite_in   => reg_write_EXMEM, 
        Write_Reg_in  => rd_EXMEM,
		--breakpoinAddr_i   => BPADDR_i,
		pc_i		  =>MEMpc_w,
		instruction_i =>MEMinstruction_w,
        
        ALU_Result_out => ALU_res_WB_w,
        Read_Data_out  => Read_data_WB_w,
        MemtoReg_out   => MemtoReg_WB_w,
        RegWrite_out   => RegWrite_ID_w, --ctl signal
        Write_Reg_out  => rd_ID_w, -- rd_i in ID.
		--break_o        => break_w,
		pc_o		   =>WBpc_o,
		instruction_o  =>WBinstruction_o
		);


---------------------------------------------------------------------------------------
--									IPC - MCLK counter register
---------------------------------------------------------------------------------------
process (MCLK_w , rst_i)
begin
	if rst_i = '1' then
		mclk_cnt_q	<=	(others	=> '0');
	elsif rising_edge(MCLK_w) then
		mclk_cnt_q	<=	mclk_cnt_q + '1';
	end if;
end process;

mclk_cnt_o	<=	mclk_cnt_q;


process (MCLK_w, rst_i)
    begin
	if rst_i = '1' then
		inst_cnt_q <= (others => '0');
	elsif rising_edge(MCLK_w) then
		if instruction_IFID /= x"00000000" and break_w='0' then  -- skip NOPs
			inst_cnt_q <= inst_cnt_q + 1;
		end if;
	end if;
end process;

inst_cnt_o <= inst_cnt_q;
-----------------------------------------------------------------------------------------

END structure; 


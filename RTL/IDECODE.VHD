--  Idecode module (implements the register file for the MIPS computer
LIBRARY IEEE; 		
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.const_package.all;

ENTITY Idecode IS
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
			--WB_res_i               : IN    STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
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
END Idecode;


ARCHITECTURE behavior OF Idecode IS
TYPE register_file IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);

	SIGNAL RF_q					: register_file;
	SIGNAL write_reg_addr_w 	: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_reg_data_w		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL rs_register_w		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL rt_register_w		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL rd_register_w		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL imm_value_w			:STD_LOGIC_VECTOR( 15 DOWNTO 0);
	SIGNAL forward_data1_w	    :STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL forward_data2_w	    :STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	signal opcode_w             : STD_LOGIC_VECTOR(5 DOWNTO 0);
	signal MEM_result_w         :STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	signal read_data1_w         :STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
    signal read_data2_w         :STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	signal WB_result_w         :STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	signal jr_addr_w           :STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal jump_addr_w         :STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	signal flush_counter           :STD_LOGIC_VECTOR(7 DOWNTO 0) :=(others => '0');
BEGIN
	rs_register_w 			<= instruction_i(25 DOWNTO 21);
   	rt_register_w 			<= instruction_i(20 DOWNTO 16);
	rs_o                    <= rs_register_w;
	rt_o                    <= rt_register_w;
   	rd_register_w			<=  rd_i;
   	imm_value_w 			<= instruction_i(15 DOWNTO 0);
	
	-- to test later if branch instruction
	opcode_w <= instruction_i(31 DOWNTO 26);
	-- Read Register 1 Operation
	read_data1_w <= RF_q(CONV_INTEGER(rs_register_w)); 
	
	-- Read Register 2 Operation		 
	read_data2_w <= RF_q(CONV_INTEGER(rt_register_w));
	
	-- choose data from MEM stage, like WB
	MEM_result_w <= RegWrite_datamem_MEM_i when MemtoReg_i='1' else RegWrite_datamalu_MEM_i; 
	--
	--WB_result_w<= WB_res_i;
	-- Forward operands for the branch
	forward_data1_w <=  RegWrite_data_Ex_i    when ForwardAID_i="10" else 
                        MEM_result_w          when ForwardAID_i="01" else
						--WB_result_w           when ForwardAID_i="11" else
                       	read_data1_w;
						
	forward_data2_w <=  RegWrite_data_Ex_i    when ForwardBID_i="10" else 
                        MEM_result_w            when ForwardBID_i="01" else
						--WB_result_w           when ForwardBID_i="11" else
                       	read_data2_w;
						
    read_data1_o    <= write_reg_data_i when (rs_register_w=rd_i and rs_register_w /=0 and RegWrite_ctrl_i = '1') else read_data1_w;--read_data1_w;-- write_reg_data_i when (rd_register_w=rd_i and RegWrite_ctrl_i = '1') else read_data1_w; -- Huge problem
	read_data2_o    <= write_reg_data_i when (rt_register_w=rd_i and rt_register_w /=0 and RegWrite_ctrl_i = '1') else read_data2_w ;
   	
						
	-- Address of the register to write data
	write_reg_addr_w <= rd_i;
						

	
	-- Sign Extend 16-bits to 32-bits
    sign_extend_o <= 	X"0000" & imm_value_w WHEN imm_value_w(15) = '0' ELSE
						X"FFFF" & imm_value_w;
		
	--------Check branch and compute Address
	br_taken_o <= '1' when
		(((opcode_w = BEQ_OPC) and (forward_data1_w = forward_data2_w)) or
		((opcode_w = BNEQ_OPC) and (forward_data1_w /= forward_data2_w))) and (stall_br_i='0')
		else '0';


	br_addr_o  <= pc_plus4_i(9 DOWNTO 2) + sign_extend_o(7 DOWNTO 0);
	
	-- for jump Address
	jump_addr_w <= ("0000" & instruction_i(25 DOWNTO 0) & "00");
	--for jr
	jr_addr_w <= read_data1_o(9 DOWNTO 2);
	--choose between them
	jump_addr_o <= jr_addr_w when jr_i ='1' else jump_addr_w(9 DOWNTO 2);  
	-- flush
	flush_o <= br_taken_o or jump_ctrl_i;
	
	process(clk_i,rst_i)
	begin
		if (rst_i='1') then
			flush_counter<= (others =>'0');
			FOR i IN 0 TO 31 LOOP
				-- RF_q(i) <= CONV_STD_LOGIC_VECTOR(i,32);
				RF_q(i) <= CONV_STD_LOGIC_VECTOR(0,32);
			END LOOP;
		elsif (clk_i'event and clk_i='1') then
			if flush_o='1' then
				flush_counter<=flush_counter+1;
			end if;
			if (RegWrite_ctrl_i = '1' AND write_reg_addr_w /= 0) then
				RF_q(CONV_INTEGER(write_reg_addr_w)) <= write_reg_data_i;
				-- index is integer type so we must use conv_integer for type casting
			end if;
		end if;
end process;
FlushCNT_o<=flush_counter;
END behavior;
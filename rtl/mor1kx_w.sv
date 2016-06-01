/****************************************************************************
 * mor1kx_w.sv
 ****************************************************************************/

`include "mor1kx-defines.v"

/**
 * Module: mor1kx_w
 * 
 * TODO: Add module documentation
 */
module mor1kx_w
		#(
		// {package}{cluster}{core}
		// - my package ID
		// - my cluster ID
		// - my core ID
		parameter MULTICORE_CORE_ID     = 0,
		// {packages}{cluster}{core}
		// - number of packages in the system
		// - number of clusters in my package
		// - number of cores in my cluster
		parameter MULTICORE_NUM_CORES   = 1,
		parameter OPTION_OPERAND_WIDTH	= 32,

		parameter OPTION_CPU0		= "CAPPUCCINO",

		parameter FEATURE_DATACACHE		= "NONE",
		parameter OPTION_DCACHE_BLOCK_WIDTH	= 5,
		parameter OPTION_DCACHE_SET_WIDTH	= 9,
		parameter OPTION_DCACHE_WAYS	= 2,
		parameter OPTION_DCACHE_LIMIT_WIDTH	= 32,
		parameter OPTION_DCACHE_SNOOP = "NONE",
		parameter FEATURE_DMMU		= "NONE",
		parameter FEATURE_DMMU_HW_TLB_RELOAD = "NONE",
		parameter OPTION_DMMU_SET_WIDTH	= 6,
		parameter OPTION_DMMU_WAYS		= 1,
		parameter FEATURE_INSTRUCTIONCACHE	= "NONE",
		parameter OPTION_ICACHE_BLOCK_WIDTH	= 5,
		parameter OPTION_ICACHE_SET_WIDTH	= 9,
		parameter OPTION_ICACHE_WAYS	= 2,
		parameter OPTION_ICACHE_LIMIT_WIDTH	= 32,
		parameter FEATURE_IMMU		= "NONE",
		parameter FEATURE_IMMU_HW_TLB_RELOAD = "NONE",
		parameter OPTION_IMMU_SET_WIDTH	= 6,
		parameter OPTION_IMMU_WAYS		= 1,
		parameter FEATURE_TIMER		= "ENABLED",
		parameter FEATURE_DEBUGUNIT		= "NONE",
		parameter FEATURE_PERFCOUNTERS	= "NONE",
		parameter FEATURE_MAC		= "NONE",

		parameter FEATURE_SYSCALL		= "ENABLED",
		parameter FEATURE_TRAP		= "ENABLED",
		parameter FEATURE_RANGE		= "ENABLED",

		parameter FEATURE_PIC		= "ENABLED",
		parameter OPTION_PIC_TRIGGER	= "LEVEL",
		parameter OPTION_PIC_NMI_WIDTH	= 0,

		parameter FEATURE_DSX		= "ENABLED",
		parameter FEATURE_OVERFLOW		= "ENABLED",
		parameter FEATURE_CARRY_FLAG	= "ENABLED",

		parameter FEATURE_FASTCONTEXTS	= "NONE",
		// Only on trunk
		parameter OPTION_RF_CLEAR_ON_INIT	= 0,
		parameter OPTION_RF_NUM_SHADOW_GPR	= 0,
		parameter OPTION_RF_ADDR_WIDTH	= 5,
		parameter OPTION_RF_WORDS		= 32,

		parameter OPTION_RESET_PC		= {{(OPTION_OPERAND_WIDTH-13){1'b0}},
		`OR1K_RESET_VECTOR,8'd0},

		parameter FEATURE_MULTIPLIER	= "THREESTAGE",
		parameter FEATURE_DIVIDER		= "SERIAL",

		parameter FEATURE_ADDC		= "ENABLED",
		parameter FEATURE_SRA		= "ENABLED",
		parameter FEATURE_ROR		= "NONE",
		parameter FEATURE_EXT		= "NONE",
		parameter FEATURE_CMOV		= "ENABLED",
		parameter FEATURE_FFL1		= "ENABLED",
		parameter FEATURE_ATOMIC		= "ENABLED",

		parameter FEATURE_CUST1		= "NONE",
		parameter FEATURE_CUST2		= "NONE",
		parameter FEATURE_CUST3		= "NONE",
		parameter FEATURE_CUST4		= "NONE",
		parameter FEATURE_CUST5		= "NONE",
		parameter FEATURE_CUST6		= "NONE",
		parameter FEATURE_CUST7		= "NONE",
		parameter FEATURE_CUST8		= "NONE",

		// Only on trunk
		parameter FEATURE_FPU     = "NONE", // ENABLED|NONE: actual for cappuccino pipeline only
    
		parameter OPTION_SHIFTER		= "BARREL",

		parameter FEATURE_STORE_BUFFER	= "ENABLED",
		parameter OPTION_STORE_BUFFER_DEPTH_WIDTH = 8,

		parameter FEATURE_MULTICORE = "NONE",

		parameter FEATURE_TRACEPORT_EXEC = "NONE",

		parameter BUS_IF_TYPE		= "WISHBONE32",

		parameter IBUS_WB_TYPE		= "B3_READ_BURSTING",
		parameter DBUS_WB_TYPE		= "CLASSIC"
		) (
			input						clk,
			input						rstn,
			wb_if.master				iwbm,
			wb_if.master				dwbm,
			input[31:0]					irq_i,
			input[31:0]					snoop_adr_i,
			input						snoop_en_i
		)
		;
		
		wire[31:0]					multicore_coreid_i = MULTICORE_CORE_ID;
		wire[31:0]					multicore_numcores_i = MULTICORE_NUM_CORES;

		// Avalon-bus stub-out wires
		wire [31:0] 		      avm_d_address_o;
		wire [3:0] 		      avm_d_byteenable_o;
		wire 			      avm_d_read_o;
		wire [31:0] 		      avm_d_readdata_i = 0;
		wire [3:0] 		      avm_d_burstcount_o;
		wire 			      avm_d_write_o;
		wire [31:0] 		      avm_d_writedata_o;
		wire 			      avm_d_waitrequest_i = 0;
		wire 			      avm_d_readdatavalid_i = 0;

		wire [31:0] 		      avm_i_address_o;
		wire [3:0] 		      avm_i_byteenable_o;
		wire 			      avm_i_read_o;
		wire [31:0] 		      avm_i_readdata_i = 0;
		wire [3:0] 		      avm_i_burstcount_o;
		wire 			      avm_i_waitrequest_i = 0;
		wire 			      avm_i_readdatavalid_i = 0;

	    // Debug interface
    	wire [15:0] 		      du_addr_i = 0;
    	wire 			      du_stb_i = 0;
    	wire [OPTION_OPERAND_WIDTH-1:0]  du_dat_i = 0;
    	wire 			      du_we_i = 0;
    	wire [OPTION_OPERAND_WIDTH-1:0] du_dat_o = 0;
    	wire 			      du_ack_o;
    	// Stall control from debug interface
    	wire 			      du_stall_i = 0;
    	wire 			      du_stall_o = 0;

    	wire 			     traceport_exec_valid_o;
    	wire [31:0] 		     traceport_exec_pc_o;
    	wire [`OR1K_INSN_WIDTH-1:0]     traceport_exec_insn_o;
    	wire [OPTION_OPERAND_WIDTH-1:0] traceport_exec_wbdata_o;
    	wire [OPTION_RF_ADDR_WIDTH-1:0] traceport_exec_wbreg_o;
    	wire 			     traceport_exec_wben_o;
    	
    	wire							iwbm_rty_i = 0;
    	wire							dwbm_rty_i = 0;
		
	mor1kx #(
		.OPTION_OPERAND_WIDTH             (OPTION_OPERAND_WIDTH            ), 
		.OPTION_CPU0                      (OPTION_CPU0                     ), 
		.FEATURE_DATACACHE                (FEATURE_DATACACHE               ), 
		.OPTION_DCACHE_BLOCK_WIDTH        (OPTION_DCACHE_BLOCK_WIDTH       ), 
		.OPTION_DCACHE_SET_WIDTH          (OPTION_DCACHE_SET_WIDTH         ), 
		.OPTION_DCACHE_WAYS               (OPTION_DCACHE_WAYS              ), 
		.OPTION_DCACHE_LIMIT_WIDTH        (OPTION_DCACHE_LIMIT_WIDTH       ), 
		.OPTION_DCACHE_SNOOP              (OPTION_DCACHE_SNOOP             ), 
		.FEATURE_DMMU                     (FEATURE_DMMU                    ), 
		.FEATURE_DMMU_HW_TLB_RELOAD       (FEATURE_DMMU_HW_TLB_RELOAD      ), 
		.OPTION_DMMU_SET_WIDTH            (OPTION_DMMU_SET_WIDTH           ), 
		.OPTION_DMMU_WAYS                 (OPTION_DMMU_WAYS                ), 
		.FEATURE_INSTRUCTIONCACHE         (FEATURE_INSTRUCTIONCACHE        ), 
		.OPTION_ICACHE_BLOCK_WIDTH        (OPTION_ICACHE_BLOCK_WIDTH       ), 
		.OPTION_ICACHE_SET_WIDTH          (OPTION_ICACHE_SET_WIDTH         ), 
		.OPTION_ICACHE_WAYS               (OPTION_ICACHE_WAYS              ), 
		.OPTION_ICACHE_LIMIT_WIDTH        (OPTION_ICACHE_LIMIT_WIDTH       ), 
		.FEATURE_IMMU                     (FEATURE_IMMU                    ), 
		.FEATURE_IMMU_HW_TLB_RELOAD       (FEATURE_IMMU_HW_TLB_RELOAD      ), 
		.OPTION_IMMU_SET_WIDTH            (OPTION_IMMU_SET_WIDTH           ), 
		.OPTION_IMMU_WAYS                 (OPTION_IMMU_WAYS                ), 
		.FEATURE_TIMER                    (FEATURE_TIMER                   ), 
		.FEATURE_DEBUGUNIT                (FEATURE_DEBUGUNIT               ), 
		.FEATURE_PERFCOUNTERS             (FEATURE_PERFCOUNTERS            ), 
		.FEATURE_MAC                      (FEATURE_MAC                     ), 
		.FEATURE_SYSCALL                  (FEATURE_SYSCALL                 ), 
		.FEATURE_TRAP                     (FEATURE_TRAP                    ), 
		.FEATURE_RANGE                    (FEATURE_RANGE                   ), 
		.FEATURE_PIC                      (FEATURE_PIC                     ), 
		.OPTION_PIC_TRIGGER               (OPTION_PIC_TRIGGER              ), 
		.OPTION_PIC_NMI_WIDTH             (OPTION_PIC_NMI_WIDTH            ), 
		.FEATURE_DSX                      (FEATURE_DSX                     ), 
		.FEATURE_OVERFLOW                 (FEATURE_OVERFLOW                ), 
		.FEATURE_CARRY_FLAG               (FEATURE_CARRY_FLAG              ), 
		.FEATURE_FASTCONTEXTS             (FEATURE_FASTCONTEXTS            ), 
`ifdef UNDEFINED		
		.OPTION_RF_CLEAR_ON_INIT          (OPTION_RF_CLEAR_ON_INIT         ), 
`endif		
		.OPTION_RF_NUM_SHADOW_GPR         (OPTION_RF_NUM_SHADOW_GPR        ), 
		.OPTION_RF_ADDR_WIDTH             (OPTION_RF_ADDR_WIDTH            ), 
		.OPTION_RF_WORDS                  (OPTION_RF_WORDS                 ), 
		.OPTION_RESET_PC                  (OPTION_RESET_PC                 ), 
		.FEATURE_MULTIPLIER               (FEATURE_MULTIPLIER              ), 
		.FEATURE_DIVIDER                  (FEATURE_DIVIDER                 ), 
		.FEATURE_ADDC                     (FEATURE_ADDC                    ), 
		.FEATURE_SRA                      (FEATURE_SRA                     ), 
		.FEATURE_ROR                      (FEATURE_ROR                     ), 
		.FEATURE_EXT                      (FEATURE_EXT                     ), 
		.FEATURE_CMOV                     (FEATURE_CMOV                    ), 
		.FEATURE_FFL1                     (FEATURE_FFL1                    ), 
		.FEATURE_ATOMIC                   (FEATURE_ATOMIC                  ), 
		.FEATURE_CUST1                    (FEATURE_CUST1                   ), 
		.FEATURE_CUST2                    (FEATURE_CUST2                   ), 
		.FEATURE_CUST3                    (FEATURE_CUST3                   ), 
		.FEATURE_CUST4                    (FEATURE_CUST4                   ), 
		.FEATURE_CUST5                    (FEATURE_CUST5                   ), 
		.FEATURE_CUST6                    (FEATURE_CUST6                   ), 
		.FEATURE_CUST7                    (FEATURE_CUST7                   ), 
		.FEATURE_CUST8                    (FEATURE_CUST8                   ), 
`ifdef UNDEFINED		
		.FEATURE_FPU                      (FEATURE_FPU                     ), 
`endif	
		.OPTION_SHIFTER                   (OPTION_SHIFTER                  ), 
		.FEATURE_STORE_BUFFER             (FEATURE_STORE_BUFFER            ), 
		.OPTION_STORE_BUFFER_DEPTH_WIDTH  (OPTION_STORE_BUFFER_DEPTH_WIDTH ), 
		.FEATURE_MULTICORE                (FEATURE_MULTICORE               ), 
		.FEATURE_TRACEPORT_EXEC           (FEATURE_TRACEPORT_EXEC          ), 
		.BUS_IF_TYPE                      (BUS_IF_TYPE                     ), 
		.IBUS_WB_TYPE                     (IBUS_WB_TYPE                    ), 
		.DBUS_WB_TYPE                     (DBUS_WB_TYPE                    )
		) u_core (
		.clk                              (clk                             ), 
		.rst                              (~rstn                           ), 
		.iwbm_adr_o                       (iwbm.ADR                      ), 
		.iwbm_stb_o                       (iwbm.STB                      ), 
		.iwbm_cyc_o                       (iwbm.CYC                      ), 
		.iwbm_sel_o                       (iwbm.SEL                      ), 
		.iwbm_we_o                        (iwbm.WE                       ), 
		.iwbm_cti_o                       (iwbm.CTI                      ), 
		.iwbm_bte_o                       (iwbm.BTE                      ), 
		.iwbm_dat_o                       (iwbm.DAT_W                      ), 
		.iwbm_err_i                       (iwbm.ERR                      ), 
		.iwbm_ack_i                       (iwbm.ACK                      ), 
		.iwbm_dat_i                       (iwbm.DAT_R                      ), 
		.iwbm_rty_i                       (iwbm_rty_i                      ), 
		.dwbm_adr_o                       (dwbm.ADR                      ), 
		.dwbm_stb_o                       (dwbm.STB                      ), 
		.dwbm_cyc_o                       (dwbm.CYC                      ), 
		.dwbm_sel_o                       (dwbm.SEL                      ), 
		.dwbm_we_o                        (dwbm.WE                       ), 
		.dwbm_cti_o                       (dwbm.CTI                      ), 
		.dwbm_bte_o                       (dwbm.BTE                      ), 
		.dwbm_dat_o                       (dwbm.DAT_W                      ), 
		.dwbm_err_i                       (dwbm.ERR                      ), 
		.dwbm_ack_i                       (dwbm.ACK                      ), 
		.dwbm_dat_i                       (dwbm.DAT_R                      ), 
		.dwbm_rty_i                       (dwbm_rty_i                      ), 
		.avm_d_address_o                  (avm_d_address_o                 ), 
		.avm_d_byteenable_o               (avm_d_byteenable_o              ), 
		.avm_d_read_o                     (avm_d_read_o                    ), 
		.avm_d_readdata_i                 (avm_d_readdata_i                ), 
		.avm_d_burstcount_o               (avm_d_burstcount_o              ), 
		.avm_d_write_o                    (avm_d_write_o                   ), 
		.avm_d_writedata_o                (avm_d_writedata_o               ), 
		.avm_d_waitrequest_i              (avm_d_waitrequest_i             ), 
		.avm_d_readdatavalid_i            (avm_d_readdatavalid_i           ), 
		.avm_i_address_o                  (avm_i_address_o                 ), 
		.avm_i_byteenable_o               (avm_i_byteenable_o              ), 
		.avm_i_read_o                     (avm_i_read_o                    ), 
		.avm_i_readdata_i                 (avm_i_readdata_i                ), 
		.avm_i_burstcount_o               (avm_i_burstcount_o              ), 
		.avm_i_waitrequest_i              (avm_i_waitrequest_i             ), 
		.avm_i_readdatavalid_i            (avm_i_readdatavalid_i           ), 
		.irq_i                            (irq_i                           ), 
		.du_addr_i                        (du_addr_i                       ), 
		.du_stb_i                         (du_stb_i                        ), 
		.du_dat_i                         (du_dat_i                        ), 
		.du_we_i                          (du_we_i                         ), 
		.du_dat_o                         (du_dat_o                        ), 
		.du_ack_o                         (du_ack_o                        ), 
		.du_stall_i                       (du_stall_i                      ), 
		.du_stall_o                       (du_stall_o                      ), 
		.traceport_exec_valid_o           (traceport_exec_valid_o          ), 
		.traceport_exec_pc_o              (traceport_exec_pc_o             ), 
		.traceport_exec_insn_o            (traceport_exec_insn_o           ), 
		.traceport_exec_wbdata_o          (traceport_exec_wbdata_o         ), 
		.traceport_exec_wbreg_o           (traceport_exec_wbreg_o          ), 
		.traceport_exec_wben_o            (traceport_exec_wben_o           ), 
		.multicore_coreid_i               (multicore_coreid_i              ), 
		.multicore_numcores_i             (multicore_numcores_i            ), 
		.snoop_adr_i                      (snoop_adr_i                     ), 
		.snoop_en_i                       (snoop_en_i                      )
		);

endmodule



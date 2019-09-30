-- ------------------------------------------------------------------------- 
-- High Level Design Compiler for Intel(R) FPGAs Version 18.1 (Release Build #625)
-- Quartus Prime development tool and MATLAB/Simulink Interface
-- 
-- Legal Notice: Copyright 2018 Intel Corporation.  All rights reserved.
-- Your use of  Intel Corporation's design tools,  logic functions and other
-- software and  tools, and its AMPP partner logic functions, and any output
-- files any  of the foregoing (including  device programming  or simulation
-- files), and  any associated  documentation  or information  are expressly
-- subject  to the terms and  conditions of the  Intel FPGA Software License
-- Agreement, Intel MegaCore Function License Agreement, or other applicable
-- license agreement,  including,  without limitation,  that your use is for
-- the  sole  purpose of  programming  logic devices  manufactured by  Intel
-- and  sold by Intel  or its authorized  distributors. Please refer  to the
-- applicable agreement for further details.
-- ---------------------------------------------------------------------------

-- VHDL created from filter_core_0002_rtl_core
-- VHDL created on Wed Sep 25 15:16:01 2019


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;
use std.TextIO.all;
use work.dspba_library_package.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;
LIBRARY altera_lnsim;
USE altera_lnsim.altera_lnsim_components.altera_syncram;
LIBRARY lpm;
USE lpm.lpm_components.all;

entity filter_core_0002_rtl_core is
    port (
        xIn_v : in std_logic_vector(0 downto 0);  -- sfix1
        xIn_c : in std_logic_vector(7 downto 0);  -- sfix8
        xIn_0 : in std_logic_vector(18 downto 0);  -- sfix19
        xIn_1 : in std_logic_vector(18 downto 0);  -- sfix19
        xIn_2 : in std_logic_vector(18 downto 0);  -- sfix19
        xIn_3 : in std_logic_vector(18 downto 0);  -- sfix19
        busIn_writedata : in std_logic_vector(15 downto 0);  -- sfix16
        busIn_address : in std_logic_vector(1 downto 0);  -- sfix2
        busIn_write : in std_logic_vector(0 downto 0);  -- sfix1
        busIn_read : in std_logic_vector(0 downto 0);  -- sfix1
        busOut_readdatavalid : out std_logic_vector(0 downto 0);  -- sfix1
        busOut_readdata : out std_logic_vector(15 downto 0);  -- sfix16
        xOut_v : out std_logic_vector(0 downto 0);  -- ufix1
        xOut_c : out std_logic_vector(7 downto 0);  -- ufix8
        xOut_0 : out std_logic_vector(28 downto 0);  -- sfix29
        xOut_1 : out std_logic_vector(28 downto 0);  -- sfix29
        xOut_2 : out std_logic_vector(28 downto 0);  -- sfix29
        xOut_3 : out std_logic_vector(28 downto 0);  -- sfix29
        clk : in std_logic;
        areset : in std_logic;
        bus_clk : in std_logic;
        h_areset : in std_logic
    );
end filter_core_0002_rtl_core;

architecture normal of filter_core_0002_rtl_core is

    attribute altera_attribute : string;
    attribute altera_attribute of normal : architecture is "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007";
    
    signal GND_q : STD_LOGIC_VECTOR (0 downto 0);
    signal VCC_q : STD_LOGIC_VECTOR (0 downto 0);
    signal d_busIn_read_12_q : STD_LOGIC_VECTOR (0 downto 0);
    signal d_busIn_writedata_11_q : STD_LOGIC_VECTOR (15 downto 0);
    signal rblookup_q : STD_LOGIC_VECTOR (1 downto 0);
    signal rblookup_h : STD_LOGIC_VECTOR (0 downto 0);
    signal rblookup_e : STD_LOGIC_VECTOR (0 downto 0);
    signal rblookup_c : STD_LOGIC_VECTOR (0 downto 0);
    signal d_rblookup_h_12_q : STD_LOGIC_VECTOR (0 downto 0);
    signal rblookup_valid_q : STD_LOGIC_VECTOR (0 downto 0);
    signal rm_reset0 : std_logic;
    signal rm_ia : STD_LOGIC_VECTOR (7 downto 0);
    signal rm_aa : STD_LOGIC_VECTOR (1 downto 0);
    signal rm_ab : STD_LOGIC_VECTOR (1 downto 0);
    signal rm_iq : STD_LOGIC_VECTOR (7 downto 0);
    signal rm_q : STD_LOGIC_VECTOR (7 downto 0);
    signal d_u0_m0_wo0_compute_q_11_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr1_q : STD_LOGIC_VECTOR (18 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr2_q : STD_LOGIC_VECTOR (18 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr3_q : STD_LOGIC_VECTOR (18 downto 0);
    signal u0_m0_wo0_dec0_e : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_dec0_c : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_cm0_q : STD_LOGIC_VECTOR (7 downto 0);
    signal u0_m0_wo0_dec1_e : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_dec1_c : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_cm1_q : STD_LOGIC_VECTOR (7 downto 0);
    signal u0_m0_wo0_dec2_e : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_dec2_c : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_cm2_q : STD_LOGIC_VECTOR (7 downto 0);
    signal u0_m0_wo0_dec3_e : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_dec3_c : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_cm3_q : STD_LOGIC_VECTOR (7 downto 0);
    signal u0_m0_wo0_oseq_gated_reg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u1_m0_wo0_wi0_r0_delayr1_q : STD_LOGIC_VECTOR (18 downto 0);
    signal u1_m0_wo0_wi0_r0_delayr2_q : STD_LOGIC_VECTOR (18 downto 0);
    signal u1_m0_wo0_wi0_r0_delayr3_q : STD_LOGIC_VECTOR (18 downto 0);
    signal u1_m0_wo0_cm0_q : STD_LOGIC_VECTOR (7 downto 0);
    signal u1_m0_wo0_cm1_q : STD_LOGIC_VECTOR (7 downto 0);
    signal u1_m0_wo0_cm2_q : STD_LOGIC_VECTOR (7 downto 0);
    signal u1_m0_wo0_cm3_q : STD_LOGIC_VECTOR (7 downto 0);
    signal u2_m0_wo0_wi0_r0_delayr1_q : STD_LOGIC_VECTOR (18 downto 0);
    signal u2_m0_wo0_wi0_r0_delayr2_q : STD_LOGIC_VECTOR (18 downto 0);
    signal u2_m0_wo0_wi0_r0_delayr3_q : STD_LOGIC_VECTOR (18 downto 0);
    signal u2_m0_wo0_cm0_q : STD_LOGIC_VECTOR (7 downto 0);
    signal u2_m0_wo0_cm1_q : STD_LOGIC_VECTOR (7 downto 0);
    signal u2_m0_wo0_cm2_q : STD_LOGIC_VECTOR (7 downto 0);
    signal u2_m0_wo0_cm3_q : STD_LOGIC_VECTOR (7 downto 0);
    signal u3_m0_wo0_wi0_r0_delayr1_q : STD_LOGIC_VECTOR (18 downto 0);
    signal u3_m0_wo0_wi0_r0_delayr2_q : STD_LOGIC_VECTOR (18 downto 0);
    signal u3_m0_wo0_wi0_r0_delayr3_q : STD_LOGIC_VECTOR (18 downto 0);
    signal u3_m0_wo0_cm0_q : STD_LOGIC_VECTOR (7 downto 0);
    signal u3_m0_wo0_cm1_q : STD_LOGIC_VECTOR (7 downto 0);
    signal u3_m0_wo0_cm2_q : STD_LOGIC_VECTOR (7 downto 0);
    signal u3_m0_wo0_cm3_q : STD_LOGIC_VECTOR (7 downto 0);
    signal u0_m0_wo0_mtree_madd4_0_cma_reset : std_logic;
    type u0_m0_wo0_mtree_madd4_0_cma_a0type is array(NATURAL range <>) of SIGNED(18 downto 0);
    signal u0_m0_wo0_mtree_madd4_0_cma_a0 : u0_m0_wo0_mtree_madd4_0_cma_a0type(0 to 3);
    attribute preserve : boolean;
    attribute preserve of u0_m0_wo0_mtree_madd4_0_cma_a0 : signal is true;
    type u0_m0_wo0_mtree_madd4_0_cma_c0type is array(NATURAL range <>) of SIGNED(10 downto 0);
    signal u0_m0_wo0_mtree_madd4_0_cma_c0 : u0_m0_wo0_mtree_madd4_0_cma_c0type(0 to 3);
    attribute preserve of u0_m0_wo0_mtree_madd4_0_cma_c0 : signal is true;
    type u0_m0_wo0_mtree_madd4_0_cma_ptype is array(NATURAL range <>) of SIGNED(29 downto 0);
    signal u0_m0_wo0_mtree_madd4_0_cma_p : u0_m0_wo0_mtree_madd4_0_cma_ptype(0 to 3);
    type u0_m0_wo0_mtree_madd4_0_cma_utype is array(NATURAL range <>) of SIGNED(31 downto 0);
    signal u0_m0_wo0_mtree_madd4_0_cma_u : u0_m0_wo0_mtree_madd4_0_cma_utype(0 to 3);
    signal u0_m0_wo0_mtree_madd4_0_cma_w : u0_m0_wo0_mtree_madd4_0_cma_utype(0 to 1);
    signal u0_m0_wo0_mtree_madd4_0_cma_x : u0_m0_wo0_mtree_madd4_0_cma_utype(0 to 0);
    signal u0_m0_wo0_mtree_madd4_0_cma_y : u0_m0_wo0_mtree_madd4_0_cma_utype(0 to 0);
    signal u0_m0_wo0_mtree_madd4_0_cma_s : u0_m0_wo0_mtree_madd4_0_cma_utype(0 to 0);
    signal u0_m0_wo0_mtree_madd4_0_cma_qq : STD_LOGIC_VECTOR (31 downto 0);
    signal u0_m0_wo0_mtree_madd4_0_cma_q : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_madd4_0_cma_ena0 : std_logic;
    signal u0_m0_wo0_mtree_madd4_0_cma_ena1 : std_logic;
    signal u1_m0_wo0_mtree_madd4_0_cma_reset : std_logic;
    signal u1_m0_wo0_mtree_madd4_0_cma_a0 : u0_m0_wo0_mtree_madd4_0_cma_a0type(0 to 3);
    attribute preserve of u1_m0_wo0_mtree_madd4_0_cma_a0 : signal is true;
    signal u1_m0_wo0_mtree_madd4_0_cma_c0 : u0_m0_wo0_mtree_madd4_0_cma_c0type(0 to 3);
    attribute preserve of u1_m0_wo0_mtree_madd4_0_cma_c0 : signal is true;
    signal u1_m0_wo0_mtree_madd4_0_cma_p : u0_m0_wo0_mtree_madd4_0_cma_ptype(0 to 3);
    signal u1_m0_wo0_mtree_madd4_0_cma_u : u0_m0_wo0_mtree_madd4_0_cma_utype(0 to 3);
    signal u1_m0_wo0_mtree_madd4_0_cma_w : u0_m0_wo0_mtree_madd4_0_cma_utype(0 to 1);
    signal u1_m0_wo0_mtree_madd4_0_cma_x : u0_m0_wo0_mtree_madd4_0_cma_utype(0 to 0);
    signal u1_m0_wo0_mtree_madd4_0_cma_y : u0_m0_wo0_mtree_madd4_0_cma_utype(0 to 0);
    signal u1_m0_wo0_mtree_madd4_0_cma_s : u0_m0_wo0_mtree_madd4_0_cma_utype(0 to 0);
    signal u1_m0_wo0_mtree_madd4_0_cma_qq : STD_LOGIC_VECTOR (31 downto 0);
    signal u1_m0_wo0_mtree_madd4_0_cma_q : STD_LOGIC_VECTOR (28 downto 0);
    signal u1_m0_wo0_mtree_madd4_0_cma_ena0 : std_logic;
    signal u1_m0_wo0_mtree_madd4_0_cma_ena1 : std_logic;
    signal u2_m0_wo0_mtree_madd4_0_cma_reset : std_logic;
    signal u2_m0_wo0_mtree_madd4_0_cma_a0 : u0_m0_wo0_mtree_madd4_0_cma_a0type(0 to 3);
    attribute preserve of u2_m0_wo0_mtree_madd4_0_cma_a0 : signal is true;
    signal u2_m0_wo0_mtree_madd4_0_cma_c0 : u0_m0_wo0_mtree_madd4_0_cma_c0type(0 to 3);
    attribute preserve of u2_m0_wo0_mtree_madd4_0_cma_c0 : signal is true;
    signal u2_m0_wo0_mtree_madd4_0_cma_p : u0_m0_wo0_mtree_madd4_0_cma_ptype(0 to 3);
    signal u2_m0_wo0_mtree_madd4_0_cma_u : u0_m0_wo0_mtree_madd4_0_cma_utype(0 to 3);
    signal u2_m0_wo0_mtree_madd4_0_cma_w : u0_m0_wo0_mtree_madd4_0_cma_utype(0 to 1);
    signal u2_m0_wo0_mtree_madd4_0_cma_x : u0_m0_wo0_mtree_madd4_0_cma_utype(0 to 0);
    signal u2_m0_wo0_mtree_madd4_0_cma_y : u0_m0_wo0_mtree_madd4_0_cma_utype(0 to 0);
    signal u2_m0_wo0_mtree_madd4_0_cma_s : u0_m0_wo0_mtree_madd4_0_cma_utype(0 to 0);
    signal u2_m0_wo0_mtree_madd4_0_cma_qq : STD_LOGIC_VECTOR (31 downto 0);
    signal u2_m0_wo0_mtree_madd4_0_cma_q : STD_LOGIC_VECTOR (28 downto 0);
    signal u2_m0_wo0_mtree_madd4_0_cma_ena0 : std_logic;
    signal u2_m0_wo0_mtree_madd4_0_cma_ena1 : std_logic;
    signal u3_m0_wo0_mtree_madd4_0_cma_reset : std_logic;
    signal u3_m0_wo0_mtree_madd4_0_cma_a0 : u0_m0_wo0_mtree_madd4_0_cma_a0type(0 to 3);
    attribute preserve of u3_m0_wo0_mtree_madd4_0_cma_a0 : signal is true;
    signal u3_m0_wo0_mtree_madd4_0_cma_c0 : u0_m0_wo0_mtree_madd4_0_cma_c0type(0 to 3);
    attribute preserve of u3_m0_wo0_mtree_madd4_0_cma_c0 : signal is true;
    signal u3_m0_wo0_mtree_madd4_0_cma_p : u0_m0_wo0_mtree_madd4_0_cma_ptype(0 to 3);
    signal u3_m0_wo0_mtree_madd4_0_cma_u : u0_m0_wo0_mtree_madd4_0_cma_utype(0 to 3);
    signal u3_m0_wo0_mtree_madd4_0_cma_w : u0_m0_wo0_mtree_madd4_0_cma_utype(0 to 1);
    signal u3_m0_wo0_mtree_madd4_0_cma_x : u0_m0_wo0_mtree_madd4_0_cma_utype(0 to 0);
    signal u3_m0_wo0_mtree_madd4_0_cma_y : u0_m0_wo0_mtree_madd4_0_cma_utype(0 to 0);
    signal u3_m0_wo0_mtree_madd4_0_cma_s : u0_m0_wo0_mtree_madd4_0_cma_utype(0 to 0);
    signal u3_m0_wo0_mtree_madd4_0_cma_qq : STD_LOGIC_VECTOR (31 downto 0);
    signal u3_m0_wo0_mtree_madd4_0_cma_q : STD_LOGIC_VECTOR (28 downto 0);
    signal u3_m0_wo0_mtree_madd4_0_cma_ena0 : std_logic;
    signal u3_m0_wo0_mtree_madd4_0_cma_ena1 : std_logic;
    signal rblookup_read_hit_q : STD_LOGIC_VECTOR (0 downto 0);
    signal rmPad_sel_b : STD_LOGIC_VECTOR (15 downto 0);
    signal out0_m0_wo0_lineup_select_delay_0_q : STD_LOGIC_VECTOR (0 downto 0);
    signal out0_m0_wo0_assign_id9_q : STD_LOGIC_VECTOR (0 downto 0);

begin


    -- d_busIn_writedata_11(DELAY,168)@10 + 1
    d_busIn_writedata_11 : dspba_delay
    GENERIC MAP ( width => 16, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => busIn_writedata, xout => d_busIn_writedata_11_q, clk => bus_clk, aclr => h_areset );

    -- rblookup(LOOKUP,4)@10 + 1
    rblookup_c <= STD_LOGIC_VECTOR(busIn_write);
    rblookup_clkproc: PROCESS (bus_clk, h_areset)
    BEGIN
        IF (h_areset = '1') THEN
            rblookup_q <= "00";
            rblookup_h <= "0";
            rblookup_e <= "0";
        ELSIF (bus_clk'EVENT AND bus_clk = '1') THEN
            CASE (busIn_address) IS
                WHEN "00" => rblookup_q <= "00";
                             rblookup_h <= "1";
                             rblookup_e <= rblookup_c;
                WHEN "01" => rblookup_q <= "01";
                             rblookup_h <= "1";
                             rblookup_e <= rblookup_c;
                WHEN "10" => rblookup_q <= "10";
                             rblookup_h <= "1";
                             rblookup_e <= rblookup_c;
                WHEN "11" => rblookup_q <= "11";
                             rblookup_h <= "1";
                             rblookup_e <= rblookup_c;
                WHEN OTHERS => -- unreachable
                               rblookup_q <= (others => '-');
                               rblookup_h <= (others => '-');
                               rblookup_e <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- rm(DUALMEM,7)@11 + 2
    rm_ia <= STD_LOGIC_VECTOR(d_busIn_writedata_11_q(7 downto 0));
    rm_aa <= rblookup_q;
    rm_ab <= rblookup_q;
    rm_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "MLAB",
        operation_mode => "DUAL_PORT",
        width_a => 8,
        widthad_a => 2,
        numwords_a => 4,
        width_b => 8,
        widthad_b => 2,
        numwords_b => 4,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK0",
        outdata_aclr_b => "NONE",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "FALSE",
        init_file => "filter_core_0002_rtl_core_rm.hex",
        init_file_layout => "PORT_B",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken0 => '1',
        clock0 => bus_clk,
        address_a => rm_aa,
        data_a => rm_ia,
        wren_a => rblookup_e(0),
        address_b => rm_ab,
        q_b => rm_iq
    );
    rm_q <= rm_iq(7 downto 0);

    -- rmPad_sel(BITSELECT,163)@13
    rmPad_sel_b <= STD_LOGIC_VECTOR(std_logic_vector(resize(signed(rm_q(7 downto 0)), 16)));

    -- VCC(CONSTANT,1)@0
    VCC_q <= "1";

    -- d_busIn_read_12(DELAY,169)@10 + 2
    d_busIn_read_12 : dspba_delay
    GENERIC MAP ( width => 1, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => busIn_read, xout => d_busIn_read_12_q, clk => bus_clk, aclr => h_areset );

    -- d_rblookup_h_12(DELAY,170)@11 + 1
    d_rblookup_h_12 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rblookup_h, xout => d_rblookup_h_12_q, clk => bus_clk, aclr => h_areset );

    -- rblookup_read_hit(LOGICAL,5)@12
    rblookup_read_hit_q <= d_rblookup_h_12_q and d_busIn_read_12_q;

    -- rblookup_valid(REG,6)@12 + 1
    rblookup_valid_clkproc: PROCESS (bus_clk, h_areset)
    BEGIN
        IF (h_areset = '1') THEN
            rblookup_valid_q <= "0";
        ELSIF (bus_clk'EVENT AND bus_clk = '1') THEN
            rblookup_valid_q <= STD_LOGIC_VECTOR(rblookup_read_hit_q);
        END IF;
    END PROCESS;

    -- busOut(BUSOUT,9)@13
    busOut_readdatavalid <= rblookup_valid_q;
    busOut_readdata <= rmPad_sel_b;

    -- u0_m0_wo0_dec0(LOOKUP,36)@10 + 1
    u0_m0_wo0_dec0_c <= STD_LOGIC_VECTOR(busIn_write);
    u0_m0_wo0_dec0_clkproc: PROCESS (bus_clk, h_areset)
    BEGIN
        IF (h_areset = '1') THEN
            u0_m0_wo0_dec0_e <= "0";
        ELSIF (bus_clk'EVENT AND bus_clk = '1') THEN
            CASE (busIn_address) IS
                WHEN "00" => u0_m0_wo0_dec0_e <= u0_m0_wo0_dec0_c;
                WHEN OTHERS => u0_m0_wo0_dec0_e <= "0";
            END CASE;
        END IF;
    END PROCESS;

    -- u3_m0_wo0_cm0(REG,133)@11 + 1
    u3_m0_wo0_cm0_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u3_m0_wo0_cm0_q <= "01111111";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_dec0_e = "1") THEN
                u3_m0_wo0_cm0_q <= STD_LOGIC_VECTOR(d_busIn_writedata_11_q(7 downto 0));
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_dec1(LOOKUP,39)@10 + 1
    u0_m0_wo0_dec1_c <= STD_LOGIC_VECTOR(busIn_write);
    u0_m0_wo0_dec1_clkproc: PROCESS (bus_clk, h_areset)
    BEGIN
        IF (h_areset = '1') THEN
            u0_m0_wo0_dec1_e <= "0";
        ELSIF (bus_clk'EVENT AND bus_clk = '1') THEN
            CASE (busIn_address) IS
                WHEN "01" => u0_m0_wo0_dec1_e <= u0_m0_wo0_dec1_c;
                WHEN OTHERS => u0_m0_wo0_dec1_e <= "0";
            END CASE;
        END IF;
    END PROCESS;

    -- u3_m0_wo0_cm1(REG,136)@11 + 1
    u3_m0_wo0_cm1_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u3_m0_wo0_cm1_q <= "01111111";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_dec1_e = "1") THEN
                u3_m0_wo0_cm1_q <= STD_LOGIC_VECTOR(d_busIn_writedata_11_q(7 downto 0));
            END IF;
        END IF;
    END PROCESS;

    -- u3_m0_wo0_wi0_r0_delayr1(DELAY,126)@10
    u3_m0_wo0_wi0_r0_delayr1 : dspba_delay
    GENERIC MAP ( width => 19, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => xIn_3, xout => u3_m0_wo0_wi0_r0_delayr1_q, ena => xIn_v(0), clk => clk, aclr => areset );

    -- u0_m0_wo0_dec2(LOOKUP,42)@10 + 1
    u0_m0_wo0_dec2_c <= STD_LOGIC_VECTOR(busIn_write);
    u0_m0_wo0_dec2_clkproc: PROCESS (bus_clk, h_areset)
    BEGIN
        IF (h_areset = '1') THEN
            u0_m0_wo0_dec2_e <= "0";
        ELSIF (bus_clk'EVENT AND bus_clk = '1') THEN
            CASE (busIn_address) IS
                WHEN "10" => u0_m0_wo0_dec2_e <= u0_m0_wo0_dec2_c;
                WHEN OTHERS => u0_m0_wo0_dec2_e <= "0";
            END CASE;
        END IF;
    END PROCESS;

    -- u3_m0_wo0_cm2(REG,139)@11 + 1
    u3_m0_wo0_cm2_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u3_m0_wo0_cm2_q <= "01111111";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_dec2_e = "1") THEN
                u3_m0_wo0_cm2_q <= STD_LOGIC_VECTOR(d_busIn_writedata_11_q(7 downto 0));
            END IF;
        END IF;
    END PROCESS;

    -- u3_m0_wo0_wi0_r0_delayr2(DELAY,127)@10
    u3_m0_wo0_wi0_r0_delayr2 : dspba_delay
    GENERIC MAP ( width => 19, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => u3_m0_wo0_wi0_r0_delayr1_q, xout => u3_m0_wo0_wi0_r0_delayr2_q, ena => xIn_v(0), clk => clk, aclr => areset );

    -- u0_m0_wo0_dec3(LOOKUP,45)@10 + 1
    u0_m0_wo0_dec3_c <= STD_LOGIC_VECTOR(busIn_write);
    u0_m0_wo0_dec3_clkproc: PROCESS (bus_clk, h_areset)
    BEGIN
        IF (h_areset = '1') THEN
            u0_m0_wo0_dec3_e <= "0";
        ELSIF (bus_clk'EVENT AND bus_clk = '1') THEN
            CASE (busIn_address) IS
                WHEN "11" => u0_m0_wo0_dec3_e <= u0_m0_wo0_dec3_c;
                WHEN OTHERS => u0_m0_wo0_dec3_e <= "0";
            END CASE;
        END IF;
    END PROCESS;

    -- u3_m0_wo0_cm3(REG,142)@11 + 1
    u3_m0_wo0_cm3_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u3_m0_wo0_cm3_q <= "01111111";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_dec3_e = "1") THEN
                u3_m0_wo0_cm3_q <= STD_LOGIC_VECTOR(d_busIn_writedata_11_q(7 downto 0));
            END IF;
        END IF;
    END PROCESS;

    -- u3_m0_wo0_wi0_r0_delayr3(DELAY,128)@10
    u3_m0_wo0_wi0_r0_delayr3 : dspba_delay
    GENERIC MAP ( width => 19, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => u3_m0_wo0_wi0_r0_delayr2_q, xout => u3_m0_wo0_wi0_r0_delayr3_q, ena => xIn_v(0), clk => clk, aclr => areset );

    -- u3_m0_wo0_mtree_madd4_0_cma(CHAINMULTADD,167)@10 + 2
    u3_m0_wo0_mtree_madd4_0_cma_reset <= areset;
    u3_m0_wo0_mtree_madd4_0_cma_ena0 <= '1';
    u3_m0_wo0_mtree_madd4_0_cma_ena1 <= u3_m0_wo0_mtree_madd4_0_cma_ena0;
    u3_m0_wo0_mtree_madd4_0_cma_p(0) <= u3_m0_wo0_mtree_madd4_0_cma_a0(0) * u3_m0_wo0_mtree_madd4_0_cma_c0(0);
    u3_m0_wo0_mtree_madd4_0_cma_p(1) <= u3_m0_wo0_mtree_madd4_0_cma_a0(1) * u3_m0_wo0_mtree_madd4_0_cma_c0(1);
    u3_m0_wo0_mtree_madd4_0_cma_p(2) <= u3_m0_wo0_mtree_madd4_0_cma_a0(2) * u3_m0_wo0_mtree_madd4_0_cma_c0(2);
    u3_m0_wo0_mtree_madd4_0_cma_p(3) <= u3_m0_wo0_mtree_madd4_0_cma_a0(3) * u3_m0_wo0_mtree_madd4_0_cma_c0(3);
    u3_m0_wo0_mtree_madd4_0_cma_u(0) <= RESIZE(u3_m0_wo0_mtree_madd4_0_cma_p(0),32);
    u3_m0_wo0_mtree_madd4_0_cma_u(1) <= RESIZE(u3_m0_wo0_mtree_madd4_0_cma_p(1),32);
    u3_m0_wo0_mtree_madd4_0_cma_u(2) <= RESIZE(u3_m0_wo0_mtree_madd4_0_cma_p(2),32);
    u3_m0_wo0_mtree_madd4_0_cma_u(3) <= RESIZE(u3_m0_wo0_mtree_madd4_0_cma_p(3),32);
    u3_m0_wo0_mtree_madd4_0_cma_w(0) <= u3_m0_wo0_mtree_madd4_0_cma_u(0) + u3_m0_wo0_mtree_madd4_0_cma_u(1);
    u3_m0_wo0_mtree_madd4_0_cma_w(1) <= u3_m0_wo0_mtree_madd4_0_cma_u(2) + u3_m0_wo0_mtree_madd4_0_cma_u(3);
    u3_m0_wo0_mtree_madd4_0_cma_x(0) <= u3_m0_wo0_mtree_madd4_0_cma_w(0) + u3_m0_wo0_mtree_madd4_0_cma_w(1);
    u3_m0_wo0_mtree_madd4_0_cma_y(0) <= u3_m0_wo0_mtree_madd4_0_cma_x(0);
    u3_m0_wo0_mtree_madd4_0_cma_chainmultadd_input: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u3_m0_wo0_mtree_madd4_0_cma_a0 <= (others => (others => '0'));
            u3_m0_wo0_mtree_madd4_0_cma_c0 <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u3_m0_wo0_mtree_madd4_0_cma_ena0 = '1') THEN
                u3_m0_wo0_mtree_madd4_0_cma_a0(0) <= RESIZE(SIGNED(u3_m0_wo0_wi0_r0_delayr3_q),19);
                u3_m0_wo0_mtree_madd4_0_cma_a0(1) <= RESIZE(SIGNED(u3_m0_wo0_wi0_r0_delayr2_q),19);
                u3_m0_wo0_mtree_madd4_0_cma_a0(2) <= RESIZE(SIGNED(u3_m0_wo0_wi0_r0_delayr1_q),19);
                u3_m0_wo0_mtree_madd4_0_cma_a0(3) <= RESIZE(SIGNED(xIn_3),19);
                u3_m0_wo0_mtree_madd4_0_cma_c0(0) <= RESIZE(SIGNED(u3_m0_wo0_cm3_q),11);
                u3_m0_wo0_mtree_madd4_0_cma_c0(1) <= RESIZE(SIGNED(u3_m0_wo0_cm2_q),11);
                u3_m0_wo0_mtree_madd4_0_cma_c0(2) <= RESIZE(SIGNED(u3_m0_wo0_cm1_q),11);
                u3_m0_wo0_mtree_madd4_0_cma_c0(3) <= RESIZE(SIGNED(u3_m0_wo0_cm0_q),11);
            END IF;
        END IF;
    END PROCESS;
    u3_m0_wo0_mtree_madd4_0_cma_chainmultadd_output: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u3_m0_wo0_mtree_madd4_0_cma_s <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u3_m0_wo0_mtree_madd4_0_cma_ena1 = '1') THEN
                u3_m0_wo0_mtree_madd4_0_cma_s(0) <= u3_m0_wo0_mtree_madd4_0_cma_y(0);
            END IF;
        END IF;
    END PROCESS;
    u3_m0_wo0_mtree_madd4_0_cma_delay : dspba_delay
    GENERIC MAP ( width => 32, depth => 0, reset_kind => "ASYNC" )
    PORT MAP ( xin => STD_LOGIC_VECTOR(u3_m0_wo0_mtree_madd4_0_cma_s(0)(31 downto 0)), xout => u3_m0_wo0_mtree_madd4_0_cma_qq, clk => clk, aclr => areset );
    u3_m0_wo0_mtree_madd4_0_cma_q <= STD_LOGIC_VECTOR(u3_m0_wo0_mtree_madd4_0_cma_qq(28 downto 0));

    -- u2_m0_wo0_cm0(REG,101)@11 + 1
    u2_m0_wo0_cm0_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u2_m0_wo0_cm0_q <= "01111111";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_dec0_e = "1") THEN
                u2_m0_wo0_cm0_q <= STD_LOGIC_VECTOR(d_busIn_writedata_11_q(7 downto 0));
            END IF;
        END IF;
    END PROCESS;

    -- u2_m0_wo0_cm1(REG,104)@11 + 1
    u2_m0_wo0_cm1_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u2_m0_wo0_cm1_q <= "01111111";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_dec1_e = "1") THEN
                u2_m0_wo0_cm1_q <= STD_LOGIC_VECTOR(d_busIn_writedata_11_q(7 downto 0));
            END IF;
        END IF;
    END PROCESS;

    -- u2_m0_wo0_wi0_r0_delayr1(DELAY,94)@10
    u2_m0_wo0_wi0_r0_delayr1 : dspba_delay
    GENERIC MAP ( width => 19, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => xIn_2, xout => u2_m0_wo0_wi0_r0_delayr1_q, ena => xIn_v(0), clk => clk, aclr => areset );

    -- u2_m0_wo0_cm2(REG,107)@11 + 1
    u2_m0_wo0_cm2_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u2_m0_wo0_cm2_q <= "01111111";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_dec2_e = "1") THEN
                u2_m0_wo0_cm2_q <= STD_LOGIC_VECTOR(d_busIn_writedata_11_q(7 downto 0));
            END IF;
        END IF;
    END PROCESS;

    -- u2_m0_wo0_wi0_r0_delayr2(DELAY,95)@10
    u2_m0_wo0_wi0_r0_delayr2 : dspba_delay
    GENERIC MAP ( width => 19, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => u2_m0_wo0_wi0_r0_delayr1_q, xout => u2_m0_wo0_wi0_r0_delayr2_q, ena => xIn_v(0), clk => clk, aclr => areset );

    -- u2_m0_wo0_cm3(REG,110)@11 + 1
    u2_m0_wo0_cm3_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u2_m0_wo0_cm3_q <= "01111111";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_dec3_e = "1") THEN
                u2_m0_wo0_cm3_q <= STD_LOGIC_VECTOR(d_busIn_writedata_11_q(7 downto 0));
            END IF;
        END IF;
    END PROCESS;

    -- u2_m0_wo0_wi0_r0_delayr3(DELAY,96)@10
    u2_m0_wo0_wi0_r0_delayr3 : dspba_delay
    GENERIC MAP ( width => 19, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => u2_m0_wo0_wi0_r0_delayr2_q, xout => u2_m0_wo0_wi0_r0_delayr3_q, ena => xIn_v(0), clk => clk, aclr => areset );

    -- u2_m0_wo0_mtree_madd4_0_cma(CHAINMULTADD,166)@10 + 2
    u2_m0_wo0_mtree_madd4_0_cma_reset <= areset;
    u2_m0_wo0_mtree_madd4_0_cma_ena0 <= '1';
    u2_m0_wo0_mtree_madd4_0_cma_ena1 <= u2_m0_wo0_mtree_madd4_0_cma_ena0;
    u2_m0_wo0_mtree_madd4_0_cma_p(0) <= u2_m0_wo0_mtree_madd4_0_cma_a0(0) * u2_m0_wo0_mtree_madd4_0_cma_c0(0);
    u2_m0_wo0_mtree_madd4_0_cma_p(1) <= u2_m0_wo0_mtree_madd4_0_cma_a0(1) * u2_m0_wo0_mtree_madd4_0_cma_c0(1);
    u2_m0_wo0_mtree_madd4_0_cma_p(2) <= u2_m0_wo0_mtree_madd4_0_cma_a0(2) * u2_m0_wo0_mtree_madd4_0_cma_c0(2);
    u2_m0_wo0_mtree_madd4_0_cma_p(3) <= u2_m0_wo0_mtree_madd4_0_cma_a0(3) * u2_m0_wo0_mtree_madd4_0_cma_c0(3);
    u2_m0_wo0_mtree_madd4_0_cma_u(0) <= RESIZE(u2_m0_wo0_mtree_madd4_0_cma_p(0),32);
    u2_m0_wo0_mtree_madd4_0_cma_u(1) <= RESIZE(u2_m0_wo0_mtree_madd4_0_cma_p(1),32);
    u2_m0_wo0_mtree_madd4_0_cma_u(2) <= RESIZE(u2_m0_wo0_mtree_madd4_0_cma_p(2),32);
    u2_m0_wo0_mtree_madd4_0_cma_u(3) <= RESIZE(u2_m0_wo0_mtree_madd4_0_cma_p(3),32);
    u2_m0_wo0_mtree_madd4_0_cma_w(0) <= u2_m0_wo0_mtree_madd4_0_cma_u(0) + u2_m0_wo0_mtree_madd4_0_cma_u(1);
    u2_m0_wo0_mtree_madd4_0_cma_w(1) <= u2_m0_wo0_mtree_madd4_0_cma_u(2) + u2_m0_wo0_mtree_madd4_0_cma_u(3);
    u2_m0_wo0_mtree_madd4_0_cma_x(0) <= u2_m0_wo0_mtree_madd4_0_cma_w(0) + u2_m0_wo0_mtree_madd4_0_cma_w(1);
    u2_m0_wo0_mtree_madd4_0_cma_y(0) <= u2_m0_wo0_mtree_madd4_0_cma_x(0);
    u2_m0_wo0_mtree_madd4_0_cma_chainmultadd_input: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u2_m0_wo0_mtree_madd4_0_cma_a0 <= (others => (others => '0'));
            u2_m0_wo0_mtree_madd4_0_cma_c0 <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u2_m0_wo0_mtree_madd4_0_cma_ena0 = '1') THEN
                u2_m0_wo0_mtree_madd4_0_cma_a0(0) <= RESIZE(SIGNED(u2_m0_wo0_wi0_r0_delayr3_q),19);
                u2_m0_wo0_mtree_madd4_0_cma_a0(1) <= RESIZE(SIGNED(u2_m0_wo0_wi0_r0_delayr2_q),19);
                u2_m0_wo0_mtree_madd4_0_cma_a0(2) <= RESIZE(SIGNED(u2_m0_wo0_wi0_r0_delayr1_q),19);
                u2_m0_wo0_mtree_madd4_0_cma_a0(3) <= RESIZE(SIGNED(xIn_2),19);
                u2_m0_wo0_mtree_madd4_0_cma_c0(0) <= RESIZE(SIGNED(u2_m0_wo0_cm3_q),11);
                u2_m0_wo0_mtree_madd4_0_cma_c0(1) <= RESIZE(SIGNED(u2_m0_wo0_cm2_q),11);
                u2_m0_wo0_mtree_madd4_0_cma_c0(2) <= RESIZE(SIGNED(u2_m0_wo0_cm1_q),11);
                u2_m0_wo0_mtree_madd4_0_cma_c0(3) <= RESIZE(SIGNED(u2_m0_wo0_cm0_q),11);
            END IF;
        END IF;
    END PROCESS;
    u2_m0_wo0_mtree_madd4_0_cma_chainmultadd_output: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u2_m0_wo0_mtree_madd4_0_cma_s <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u2_m0_wo0_mtree_madd4_0_cma_ena1 = '1') THEN
                u2_m0_wo0_mtree_madd4_0_cma_s(0) <= u2_m0_wo0_mtree_madd4_0_cma_y(0);
            END IF;
        END IF;
    END PROCESS;
    u2_m0_wo0_mtree_madd4_0_cma_delay : dspba_delay
    GENERIC MAP ( width => 32, depth => 0, reset_kind => "ASYNC" )
    PORT MAP ( xin => STD_LOGIC_VECTOR(u2_m0_wo0_mtree_madd4_0_cma_s(0)(31 downto 0)), xout => u2_m0_wo0_mtree_madd4_0_cma_qq, clk => clk, aclr => areset );
    u2_m0_wo0_mtree_madd4_0_cma_q <= STD_LOGIC_VECTOR(u2_m0_wo0_mtree_madd4_0_cma_qq(28 downto 0));

    -- u1_m0_wo0_cm0(REG,69)@11 + 1
    u1_m0_wo0_cm0_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u1_m0_wo0_cm0_q <= "01111111";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_dec0_e = "1") THEN
                u1_m0_wo0_cm0_q <= STD_LOGIC_VECTOR(d_busIn_writedata_11_q(7 downto 0));
            END IF;
        END IF;
    END PROCESS;

    -- u1_m0_wo0_cm1(REG,72)@11 + 1
    u1_m0_wo0_cm1_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u1_m0_wo0_cm1_q <= "01111111";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_dec1_e = "1") THEN
                u1_m0_wo0_cm1_q <= STD_LOGIC_VECTOR(d_busIn_writedata_11_q(7 downto 0));
            END IF;
        END IF;
    END PROCESS;

    -- u1_m0_wo0_wi0_r0_delayr1(DELAY,62)@10
    u1_m0_wo0_wi0_r0_delayr1 : dspba_delay
    GENERIC MAP ( width => 19, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => xIn_1, xout => u1_m0_wo0_wi0_r0_delayr1_q, ena => xIn_v(0), clk => clk, aclr => areset );

    -- u1_m0_wo0_cm2(REG,75)@11 + 1
    u1_m0_wo0_cm2_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u1_m0_wo0_cm2_q <= "01111111";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_dec2_e = "1") THEN
                u1_m0_wo0_cm2_q <= STD_LOGIC_VECTOR(d_busIn_writedata_11_q(7 downto 0));
            END IF;
        END IF;
    END PROCESS;

    -- u1_m0_wo0_wi0_r0_delayr2(DELAY,63)@10
    u1_m0_wo0_wi0_r0_delayr2 : dspba_delay
    GENERIC MAP ( width => 19, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => u1_m0_wo0_wi0_r0_delayr1_q, xout => u1_m0_wo0_wi0_r0_delayr2_q, ena => xIn_v(0), clk => clk, aclr => areset );

    -- u1_m0_wo0_cm3(REG,78)@11 + 1
    u1_m0_wo0_cm3_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u1_m0_wo0_cm3_q <= "01111111";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_dec3_e = "1") THEN
                u1_m0_wo0_cm3_q <= STD_LOGIC_VECTOR(d_busIn_writedata_11_q(7 downto 0));
            END IF;
        END IF;
    END PROCESS;

    -- u1_m0_wo0_wi0_r0_delayr3(DELAY,64)@10
    u1_m0_wo0_wi0_r0_delayr3 : dspba_delay
    GENERIC MAP ( width => 19, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => u1_m0_wo0_wi0_r0_delayr2_q, xout => u1_m0_wo0_wi0_r0_delayr3_q, ena => xIn_v(0), clk => clk, aclr => areset );

    -- u1_m0_wo0_mtree_madd4_0_cma(CHAINMULTADD,165)@10 + 2
    u1_m0_wo0_mtree_madd4_0_cma_reset <= areset;
    u1_m0_wo0_mtree_madd4_0_cma_ena0 <= '1';
    u1_m0_wo0_mtree_madd4_0_cma_ena1 <= u1_m0_wo0_mtree_madd4_0_cma_ena0;
    u1_m0_wo0_mtree_madd4_0_cma_p(0) <= u1_m0_wo0_mtree_madd4_0_cma_a0(0) * u1_m0_wo0_mtree_madd4_0_cma_c0(0);
    u1_m0_wo0_mtree_madd4_0_cma_p(1) <= u1_m0_wo0_mtree_madd4_0_cma_a0(1) * u1_m0_wo0_mtree_madd4_0_cma_c0(1);
    u1_m0_wo0_mtree_madd4_0_cma_p(2) <= u1_m0_wo0_mtree_madd4_0_cma_a0(2) * u1_m0_wo0_mtree_madd4_0_cma_c0(2);
    u1_m0_wo0_mtree_madd4_0_cma_p(3) <= u1_m0_wo0_mtree_madd4_0_cma_a0(3) * u1_m0_wo0_mtree_madd4_0_cma_c0(3);
    u1_m0_wo0_mtree_madd4_0_cma_u(0) <= RESIZE(u1_m0_wo0_mtree_madd4_0_cma_p(0),32);
    u1_m0_wo0_mtree_madd4_0_cma_u(1) <= RESIZE(u1_m0_wo0_mtree_madd4_0_cma_p(1),32);
    u1_m0_wo0_mtree_madd4_0_cma_u(2) <= RESIZE(u1_m0_wo0_mtree_madd4_0_cma_p(2),32);
    u1_m0_wo0_mtree_madd4_0_cma_u(3) <= RESIZE(u1_m0_wo0_mtree_madd4_0_cma_p(3),32);
    u1_m0_wo0_mtree_madd4_0_cma_w(0) <= u1_m0_wo0_mtree_madd4_0_cma_u(0) + u1_m0_wo0_mtree_madd4_0_cma_u(1);
    u1_m0_wo0_mtree_madd4_0_cma_w(1) <= u1_m0_wo0_mtree_madd4_0_cma_u(2) + u1_m0_wo0_mtree_madd4_0_cma_u(3);
    u1_m0_wo0_mtree_madd4_0_cma_x(0) <= u1_m0_wo0_mtree_madd4_0_cma_w(0) + u1_m0_wo0_mtree_madd4_0_cma_w(1);
    u1_m0_wo0_mtree_madd4_0_cma_y(0) <= u1_m0_wo0_mtree_madd4_0_cma_x(0);
    u1_m0_wo0_mtree_madd4_0_cma_chainmultadd_input: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u1_m0_wo0_mtree_madd4_0_cma_a0 <= (others => (others => '0'));
            u1_m0_wo0_mtree_madd4_0_cma_c0 <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u1_m0_wo0_mtree_madd4_0_cma_ena0 = '1') THEN
                u1_m0_wo0_mtree_madd4_0_cma_a0(0) <= RESIZE(SIGNED(u1_m0_wo0_wi0_r0_delayr3_q),19);
                u1_m0_wo0_mtree_madd4_0_cma_a0(1) <= RESIZE(SIGNED(u1_m0_wo0_wi0_r0_delayr2_q),19);
                u1_m0_wo0_mtree_madd4_0_cma_a0(2) <= RESIZE(SIGNED(u1_m0_wo0_wi0_r0_delayr1_q),19);
                u1_m0_wo0_mtree_madd4_0_cma_a0(3) <= RESIZE(SIGNED(xIn_1),19);
                u1_m0_wo0_mtree_madd4_0_cma_c0(0) <= RESIZE(SIGNED(u1_m0_wo0_cm3_q),11);
                u1_m0_wo0_mtree_madd4_0_cma_c0(1) <= RESIZE(SIGNED(u1_m0_wo0_cm2_q),11);
                u1_m0_wo0_mtree_madd4_0_cma_c0(2) <= RESIZE(SIGNED(u1_m0_wo0_cm1_q),11);
                u1_m0_wo0_mtree_madd4_0_cma_c0(3) <= RESIZE(SIGNED(u1_m0_wo0_cm0_q),11);
            END IF;
        END IF;
    END PROCESS;
    u1_m0_wo0_mtree_madd4_0_cma_chainmultadd_output: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u1_m0_wo0_mtree_madd4_0_cma_s <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u1_m0_wo0_mtree_madd4_0_cma_ena1 = '1') THEN
                u1_m0_wo0_mtree_madd4_0_cma_s(0) <= u1_m0_wo0_mtree_madd4_0_cma_y(0);
            END IF;
        END IF;
    END PROCESS;
    u1_m0_wo0_mtree_madd4_0_cma_delay : dspba_delay
    GENERIC MAP ( width => 32, depth => 0, reset_kind => "ASYNC" )
    PORT MAP ( xin => STD_LOGIC_VECTOR(u1_m0_wo0_mtree_madd4_0_cma_s(0)(31 downto 0)), xout => u1_m0_wo0_mtree_madd4_0_cma_qq, clk => clk, aclr => areset );
    u1_m0_wo0_mtree_madd4_0_cma_q <= STD_LOGIC_VECTOR(u1_m0_wo0_mtree_madd4_0_cma_qq(28 downto 0));

    -- u0_m0_wo0_cm0(REG,37)@11 + 1
    u0_m0_wo0_cm0_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm0_q <= "01111111";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_dec0_e = "1") THEN
                u0_m0_wo0_cm0_q <= STD_LOGIC_VECTOR(d_busIn_writedata_11_q(7 downto 0));
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_cm1(REG,40)@11 + 1
    u0_m0_wo0_cm1_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm1_q <= "01111111";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_dec1_e = "1") THEN
                u0_m0_wo0_cm1_q <= STD_LOGIC_VECTOR(d_busIn_writedata_11_q(7 downto 0));
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr1(DELAY,30)@10
    u0_m0_wo0_wi0_r0_delayr1 : dspba_delay
    GENERIC MAP ( width => 19, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => xIn_0, xout => u0_m0_wo0_wi0_r0_delayr1_q, ena => xIn_v(0), clk => clk, aclr => areset );

    -- u0_m0_wo0_cm2(REG,43)@11 + 1
    u0_m0_wo0_cm2_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm2_q <= "01111111";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_dec2_e = "1") THEN
                u0_m0_wo0_cm2_q <= STD_LOGIC_VECTOR(d_busIn_writedata_11_q(7 downto 0));
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr2(DELAY,31)@10
    u0_m0_wo0_wi0_r0_delayr2 : dspba_delay
    GENERIC MAP ( width => 19, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => u0_m0_wo0_wi0_r0_delayr1_q, xout => u0_m0_wo0_wi0_r0_delayr2_q, ena => xIn_v(0), clk => clk, aclr => areset );

    -- u0_m0_wo0_cm3(REG,46)@11 + 1
    u0_m0_wo0_cm3_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm3_q <= "01111111";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_dec3_e = "1") THEN
                u0_m0_wo0_cm3_q <= STD_LOGIC_VECTOR(d_busIn_writedata_11_q(7 downto 0));
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr3(DELAY,32)@10
    u0_m0_wo0_wi0_r0_delayr3 : dspba_delay
    GENERIC MAP ( width => 19, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => u0_m0_wo0_wi0_r0_delayr2_q, xout => u0_m0_wo0_wi0_r0_delayr3_q, ena => xIn_v(0), clk => clk, aclr => areset );

    -- u0_m0_wo0_mtree_madd4_0_cma(CHAINMULTADD,164)@10 + 2
    u0_m0_wo0_mtree_madd4_0_cma_reset <= areset;
    u0_m0_wo0_mtree_madd4_0_cma_ena0 <= '1';
    u0_m0_wo0_mtree_madd4_0_cma_ena1 <= u0_m0_wo0_mtree_madd4_0_cma_ena0;
    u0_m0_wo0_mtree_madd4_0_cma_p(0) <= u0_m0_wo0_mtree_madd4_0_cma_a0(0) * u0_m0_wo0_mtree_madd4_0_cma_c0(0);
    u0_m0_wo0_mtree_madd4_0_cma_p(1) <= u0_m0_wo0_mtree_madd4_0_cma_a0(1) * u0_m0_wo0_mtree_madd4_0_cma_c0(1);
    u0_m0_wo0_mtree_madd4_0_cma_p(2) <= u0_m0_wo0_mtree_madd4_0_cma_a0(2) * u0_m0_wo0_mtree_madd4_0_cma_c0(2);
    u0_m0_wo0_mtree_madd4_0_cma_p(3) <= u0_m0_wo0_mtree_madd4_0_cma_a0(3) * u0_m0_wo0_mtree_madd4_0_cma_c0(3);
    u0_m0_wo0_mtree_madd4_0_cma_u(0) <= RESIZE(u0_m0_wo0_mtree_madd4_0_cma_p(0),32);
    u0_m0_wo0_mtree_madd4_0_cma_u(1) <= RESIZE(u0_m0_wo0_mtree_madd4_0_cma_p(1),32);
    u0_m0_wo0_mtree_madd4_0_cma_u(2) <= RESIZE(u0_m0_wo0_mtree_madd4_0_cma_p(2),32);
    u0_m0_wo0_mtree_madd4_0_cma_u(3) <= RESIZE(u0_m0_wo0_mtree_madd4_0_cma_p(3),32);
    u0_m0_wo0_mtree_madd4_0_cma_w(0) <= u0_m0_wo0_mtree_madd4_0_cma_u(0) + u0_m0_wo0_mtree_madd4_0_cma_u(1);
    u0_m0_wo0_mtree_madd4_0_cma_w(1) <= u0_m0_wo0_mtree_madd4_0_cma_u(2) + u0_m0_wo0_mtree_madd4_0_cma_u(3);
    u0_m0_wo0_mtree_madd4_0_cma_x(0) <= u0_m0_wo0_mtree_madd4_0_cma_w(0) + u0_m0_wo0_mtree_madd4_0_cma_w(1);
    u0_m0_wo0_mtree_madd4_0_cma_y(0) <= u0_m0_wo0_mtree_madd4_0_cma_x(0);
    u0_m0_wo0_mtree_madd4_0_cma_chainmultadd_input: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_0_cma_a0 <= (others => (others => '0'));
            u0_m0_wo0_mtree_madd4_0_cma_c0 <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_mtree_madd4_0_cma_ena0 = '1') THEN
                u0_m0_wo0_mtree_madd4_0_cma_a0(0) <= RESIZE(SIGNED(u0_m0_wo0_wi0_r0_delayr3_q),19);
                u0_m0_wo0_mtree_madd4_0_cma_a0(1) <= RESIZE(SIGNED(u0_m0_wo0_wi0_r0_delayr2_q),19);
                u0_m0_wo0_mtree_madd4_0_cma_a0(2) <= RESIZE(SIGNED(u0_m0_wo0_wi0_r0_delayr1_q),19);
                u0_m0_wo0_mtree_madd4_0_cma_a0(3) <= RESIZE(SIGNED(xIn_0),19);
                u0_m0_wo0_mtree_madd4_0_cma_c0(0) <= RESIZE(SIGNED(u0_m0_wo0_cm3_q),11);
                u0_m0_wo0_mtree_madd4_0_cma_c0(1) <= RESIZE(SIGNED(u0_m0_wo0_cm2_q),11);
                u0_m0_wo0_mtree_madd4_0_cma_c0(2) <= RESIZE(SIGNED(u0_m0_wo0_cm1_q),11);
                u0_m0_wo0_mtree_madd4_0_cma_c0(3) <= RESIZE(SIGNED(u0_m0_wo0_cm0_q),11);
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_0_cma_chainmultadd_output: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_0_cma_s <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_mtree_madd4_0_cma_ena1 = '1') THEN
                u0_m0_wo0_mtree_madd4_0_cma_s(0) <= u0_m0_wo0_mtree_madd4_0_cma_y(0);
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_0_cma_delay : dspba_delay
    GENERIC MAP ( width => 32, depth => 0, reset_kind => "ASYNC" )
    PORT MAP ( xin => STD_LOGIC_VECTOR(u0_m0_wo0_mtree_madd4_0_cma_s(0)(31 downto 0)), xout => u0_m0_wo0_mtree_madd4_0_cma_qq, clk => clk, aclr => areset );
    u0_m0_wo0_mtree_madd4_0_cma_q <= STD_LOGIC_VECTOR(u0_m0_wo0_mtree_madd4_0_cma_qq(28 downto 0));

    -- GND(CONSTANT,0)@0
    GND_q <= "0";

    -- d_u0_m0_wo0_compute_q_11(DELAY,171)@10 + 1
    d_u0_m0_wo0_compute_q_11 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => xIn_v, xout => d_u0_m0_wo0_compute_q_11_q, clk => clk, aclr => areset );

    -- u0_m0_wo0_oseq_gated_reg(REG,49)@11 + 1
    u0_m0_wo0_oseq_gated_reg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_oseq_gated_reg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_oseq_gated_reg_q <= STD_LOGIC_VECTOR(d_u0_m0_wo0_compute_q_11_q);
        END IF;
    END PROCESS;

    -- out0_m0_wo0_lineup_select_delay_0(DELAY,147)@12
    out0_m0_wo0_lineup_select_delay_0_q <= STD_LOGIC_VECTOR(u0_m0_wo0_oseq_gated_reg_q);

    -- out0_m0_wo0_assign_id9(DELAY,149)@12
    out0_m0_wo0_assign_id9_q <= STD_LOGIC_VECTOR(out0_m0_wo0_lineup_select_delay_0_q);

    -- xOut(PORTOUT,162)@12 + 1
    xOut_v <= out0_m0_wo0_assign_id9_q;
    xOut_c <= STD_LOGIC_VECTOR("0000000" & GND_q);
    xOut_0 <= u0_m0_wo0_mtree_madd4_0_cma_q;
    xOut_1 <= u1_m0_wo0_mtree_madd4_0_cma_q;
    xOut_2 <= u2_m0_wo0_mtree_madd4_0_cma_q;
    xOut_3 <= u3_m0_wo0_mtree_madd4_0_cma_q;

END normal;

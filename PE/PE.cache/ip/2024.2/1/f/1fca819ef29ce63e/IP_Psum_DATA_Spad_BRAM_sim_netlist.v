// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
// Date        : Wed Mar 25 20:59:13 2026
// Host        : Adrian running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ IP_Psum_DATA_Spad_BRAM_sim_netlist.v
// Design      : IP_Psum_DATA_Spad_BRAM
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xck26-sfvc784-2LV-c
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "IP_Psum_DATA_Spad_BRAM,blk_mem_gen_v8_4_9,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_9,Vivado 2024.2" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (clka,
    ena,
    wea,
    addra,
    dina,
    clkb,
    enb,
    addrb,
    doutb);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_mode = "slave BRAM_PORTA" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [4:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [19:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_mode = "slave BRAM_PORTB" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [4:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [19:0]doutb;

  wire [4:0]addra;
  wire [4:0]addrb;
  wire clka;
  wire clkb;
  wire [19:0]dina;
  wire [19:0]doutb;
  wire ena;
  wire enb;
  wire [0:0]wea;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [19:0]NLW_U0_douta_UNCONNECTED;
  wire [4:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [4:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [19:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "5" *) 
  (* C_ADDRB_WIDTH = "5" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "1" *) 
  (* C_COUNT_36K_BRAM = "0" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     0.67392 mW" *) 
  (* C_FAMILY = "zynquplus" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "1" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "1" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "IP_Psum_DATA_Spad_BRAM.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "1" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "32" *) 
  (* C_READ_DEPTH_B = "32" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "20" *) 
  (* C_READ_WIDTH_B = "20" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "32" *) 
  (* C_WRITE_DEPTH_B = "32" *) 
  (* C_WRITE_MODE_A = "NO_CHANGE" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "20" *) 
  (* C_WRITE_WIDTH_B = "20" *) 
  (* C_XDEVICEFAMILY = "zynquplus" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_9 U0
       (.addra(addra),
        .addrb(addrb),
        .clka(clka),
        .clkb(clkb),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(NLW_U0_douta_UNCONNECTED[19:0]),
        .doutb(doutb),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(enb),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[4:0]),
        .regcea(1'b1),
        .regceb(1'b1),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[4:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[19:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
        .web(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2024.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
FPXllyX2NFs/RMngGqZy2bLYbZr92CdofeZrJOHklWXExpaPgHNYp2Lzm4MnflbnrfSkCmLwwKT5
zfRgEip7FKQ5Zhb73p0MAIADixBZ/ZRt4hQkJL0T9brm0waLHfanjnov2aCX6jN3LbQc3ujmDga6
Dd73k78u4xjRTDv1/P4=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
kr7VKKvChFoiyRCReag+OvU3jnmG9pN0cv+BxhNmMKLthg/ksgNZyU3L+fQ7cmIQELtlUjwjkBAP
Jjq5RsCnHbJxj+Ys1GNhriiBsxLqxWCP8onhAVvgZN2xZFOih0UWpqlU8NVP8Eww1ohvkDgxTstC
3kDmYehxIUJjqCC/mgRZmuezqugrFdubYmBoz16tUvD17iA5qqCIMS9xSIXYp2LBNekmWEwrVqzu
R4koEo4UlXl/CEw0XY3QvMoHnlXgu6N/6sc+nxZtKSwjiMVvGnZE9UVvJPAC3Hn3zKFGlK53mmGO
Tj0dWzhwX0ahSYzkyJC/HLdbGZmriL2UNvDyFw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
CaLc9FGt3AdRHfNtGAsGFY/QEvHY1Vv4TvvgCDsdDMqiuDeLizFJDJeskBWjeKDoE2cufK8TxiBq
mySRQNJoeOKnxTiDdf+Rx6m0iR6h/YeswegYwgghpM5KVrl6mSwF3+4yEovPM7a+9ArDQ5vl+WT8
SilNGzyW0KnTwe7+szs=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
cEnudSW1X71p0Xuq6jrXOxHnBku87IA0RA3zKqmeZHZM0r+9rEm5MSzX8RecnQ994yiqeyxbIH2l
fGEzUzr0ZzryS3fkf2LnJuB39f2YARW9eVCSiaeWaraZuY1l89T+h3vgdlurS/1LIraYLS1MyOXa
6F1LAcQp3W4OO4ctc3q1FRMZGldRS1biMsKwJ8Lxj8NEOm67UfgFrJNQAxbVXEfbWRWhKtwNxcTB
JbgC8j4EHkIA46mzoHloeBAL6KieplQUBjKXSSTb66rxglbFhWLy+mirROHcocu9J4ZbvTRYZEww
4lso1lqAllVLAoKYqa3WImZuSRoTbGDngBt9Lg==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
rOyI+x4PlmKcVSFoN3oKgSYpVlmYxc194Ej04il/YmBg10xopy4zmtu5sdCP/uGSNYcNGWeAiw01
mNf98KyNgTUFXruHCA38qjhhEIvl4vfWWn3W3mFRxrIuwmnreT6qTvgMaxIkCdVBDP7Iy7O6WmCf
3Va5X5hnCHhtXgX5UYniBHiLjmupv63B8XMAYDH2n6mQ3H0DF7mtb7psBafd0Z6+IWUbmzwMtKrf
ZrRJBGAhNT0i1KrEjEh/rWjN7Z7N32zQ+Pl1kc5gYCQIX5McfdTdqSaRVXZ/HF90ymS7/8d5LDyj
Er+ORdcjnOn6oAyY4PuUUl4OYUHv5k+RglTe5Q==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2023_11", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
bJa7kPSpDipzoJoQu1APEjc8vFLqBfQZK/grZvWijD7/FgMTerFCWLUY6n8DWeGdvjXvTeyrqCHE
2rP/H57wUqPC8tIJlGm6ZYQGjZ3TgYqLrJshDE5zYMTO//q0vuSraWvZP7A7SLuW6y7tFE/nplpx
L8gbYORx6j70okGUwnamCMS9yhFr7Z2QTJne1k4GNFGvy66URk3k5cBPl5j4/1yc4xGV+aWYl6L8
q8RorRU/CltObHKrji/jdiY1WtdGrkpRyCEFc+XNPazL9xSLLu5bz6XlvKwoks+8a5KYT/VFUovM
JbM0bpAXM8Z7rGaPuXjqXtZBg5praTZLu/WNcA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
PYKBDinOGc/kIVdFzXrz2wA4/QNFxLDrQfTWfR5TjYE6bm49vrZi0bawcr9HXp4OP1+XxPLB3oCP
oV5e/rYeDln531ebt8yEg27XCoSHEX4FU8oG8aBJ8fqgWayOnAMJt025WodOxuZXbhT1zPo7J3uh
6iO9Mv7RtYE2fZ1W+G8oN//FTOEJYPWlKYnt0cDeZrN3I4rHHptZHuu7l8T+df0PYea3x6U3Mvkl
ojZ+TwQtdu0NuYY5j3QNgx3+W2XYq1M773FAnEz/deW54EjE+jf1jjrBk2pl8SYxeKuutS15oPVF
eHdqXYVcJxoUY5JH8z04lITKEnZ4oq6sYS6dog==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
tl+2vFCWZ583gQGsVC7oopz2NCKBiJ9uOHYBGzJZheOHJMqI/ehNvo25l710eBx00tztXzM30AH6
ZhAJg+kJwE2jO0MV5fmG5dnwXmLqoGEJMBs7xwWxvYK7w/0z9M0AJKD7HnuC+IiLhNU/fIxyuE+I
+vWqp//RcfY0tMMp2I2J1yEW6GUahS1ve/4JchssZ7Xu7VthoSDWXMQWATbvsUsDzeSo2+Ruz8Kq
Dc05HqEU8NgBxDPPEKLCcdKLp4byglwj7iCAtCjsPy8P18qjgb2sycFjNgmaiNMMB51WqeD+hneG
hLOue9bqVdEojkrb3q4WbsGZKz0bAGsryxslOlYHP1b8vey3yI2ixA80wyERe8d3GRIeZiSxGykH
qWxsE6x/iyi8QRb5mXZPMApA+Fln8tYmn7+1rFCm8gF4gJWhr1PsSJqTi658symGrzT0Ghjvf2QL
SvvoaeNdy0pOsWs7jLBFndd4GiFA+9K6Y33sziLToU9EvvFokENIslod

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
oYiCujFRj1F3wKsGZlHR9niEtR9MLXEVAVfy+f/3xrmpW6Ye5a+fBCvm4TH+iRQefGHNdMPnzTNW
K/pEPAS9uMJjOdFiu+APT+LYrSRnEg4W0dX5buSDGM6LBWAuMseoTMjbJJoYDGLRckJgW43E30mX
ej4823nkbfwc+Ecbrup825qLyv8RTQLNHafvJA5lSapdqXwnlOIYRmcHn+sfAh5pGv9kW9aokcdh
ObR2XYxX99rYloyvz3x0pmjxD5ILW4SQMB1IUEuuyqX6eb5IQ+kZ41hjvsHIuQH29vzpCfV9Jqha
WC5yxxK1R+cleZSKD1H1gVzbTei8uFs/91Bgeg==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
urNc+S8AFPj+GVFdqJE5V7P8O6QI6MA3nkwYb8NKbYbVufnXKg6voJIRYYeYr7EOa8mrqirozWbY
Lln9SLWnkaAy2LvL/N6WahoQdCt++4RH+xe768XvSrVUFPrIwZRixqMLurc/tPov4i5P/ukZKl18
ZPZvXRzUNlvCZnMPcF+5QCQihqPbjcZ0YyGgWgX/ipTGG3sNqmylGN7qLa4Rgqu/mB5a2xVyu5Wc
911+/X3VVFx697WVaP5V0SbOzYN8R8+8B8kdznwixMA+f4lSbBXyRysVOSzYjo8bKEMqyKMVBQn9
xDmEuV0DvVWXdO7VPvWA1LuJFwS07OxeI2GCcQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
QcP7fsLZxaDrG29e9HQeXfu2TsKsdyW7Yc1vWct6lbmDEfXkWMU1fFWSPIjPzRc9UOnfEu0bRn+B
D+8MWokqes3WF7txljBmgUPiNGZ8arUU6ENa/IY/Wv7iaB/ZKM5PtdnFAkjDIrYyKFCTz/U6Yzwi
hBGGarK/wYQOLzeeKRewiPTiNUL7tztWuMZ1t1msxD951EeKrwjrjcXIIuf/TzrOGUOlWgjHlnrl
4Q/lfMAnRLBNTSWG+5wWewCE8jK2X/gJ5AV4p3x1WP3+JglbxpP39l3pzedXqciZPbuz2XlFnRPV
KByaUaAShzJ56p8+0HjWebibqQdieGNPiPWW0Q==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 22704)
`pragma protect data_block
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
4W/gTgjNBUIqMDJNNfJYuwnX
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif

// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
// Date        : Thu Apr 16 23:25:37 2026
// Host        : Adrian running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ IP_Weight_DATA_Spad_BRAM_sim_netlist.v
// Design      : IP_Weight_DATA_Spad_BRAM
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xck26-sfvc784-2LV-c
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "IP_Weight_DATA_Spad_BRAM,blk_mem_gen_v8_4_9,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_9,Vivado 2024.2" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (clka,
    ena,
    wea,
    addra,
    dina,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_mode = "slave BRAM_PORTA" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [6:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [23:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [23:0]douta;

  wire [6:0]addra;
  wire clka;
  wire [23:0]dina;
  wire [23:0]douta;
  wire ena;
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
  wire [23:0]NLW_U0_doutb_UNCONNECTED;
  wire [6:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [6:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [23:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "7" *) 
  (* C_ADDRB_WIDTH = "7" *) 
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     2.049808 mW" *) 
  (* C_FAMILY = "zynquplus" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "0" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "1" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
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
  (* C_INIT_FILE = "IP_Weight_DATA_Spad_BRAM.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "0" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "100" *) 
  (* C_READ_DEPTH_B = "100" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "24" *) 
  (* C_READ_WIDTH_B = "24" *) 
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
  (* C_WRITE_DEPTH_A = "100" *) 
  (* C_WRITE_DEPTH_B = "100" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "24" *) 
  (* C_WRITE_WIDTH_B = "24" *) 
  (* C_XDEVICEFAMILY = "zynquplus" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_9 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(douta),
        .doutb(NLW_U0_doutb_UNCONNECTED[23:0]),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(1'b0),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[6:0]),
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
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[6:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[23:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 21680)
`pragma protect data_block
iHPuazB2L2mrYc3ztR+WH2CtHQ1dggrX5QfQmHpZg2RUABSqpegFtBQ35U5vIBGCIAKfr8NYgo2P
vELS9iaBJ3dMK6LlqkKVJc8t4/6bp0MFt/9V5Nx9ahaL2pY2i75sFGscS0K9InvmCdViVGr3u/tU
iGtyIcJXiUrFmfq+vg3uECgU8sm6ek4mD+BdPKw57VwYRmQaSE+Sd5iB9OUpBj+q7tuHLA6aoUbw
l8uc/NkUbrt+BmSHpZn8Dh7Ka7m5jTZs36wmFWEiihri7GfGd8r6uVKuD3DmUObce+gIAAlWf3OD
TGQe/zCbtQ6xpslYvXRgv9anOvuDovzHArTO/bpFTp4YE2xHQsELEH6trMx4eV/QZ7HhknFtHSSP
TeKJ4Q2s5CP1Mo6gp5rDHR4X+EA0wh86zt/bDb5sCF3YkT0m1vzlRRGA4mioFQKCRJlpCvBOAQzh
lM1lWbfXQLJlfh16M2rY3kWn7LYCDGAgWRJ5upl2n46zFccDDdNu88fQy1eq4nedT7jckqBEuIt2
/v/Cx85F0NLWMKNhH4EB36V7uoh7vB7/BhbjHxoD7znSNm5H8cPjYMqJ7ehfZZmTR881skoT1v7A
nkfu/9GEjjM9tWNrCAex86HWkealvTBkbkvJOg6vYN2n6USHZMthsSCjnhHVNeqSxnWsu/KEO8Mv
eLcQBd9f0lKRG6u/nWVg+pl5d/PZqD4hk+LY2AGBNC+FCWVbe9Gp0+UuSq7PZXFGoNw7dw3ShlL8
YAAAY83nQbi/bHlB7TXaNb93yCkAZetD+uockr6i0QR/zMvg8Vmz18LY71U8PeGXaRCQzY+q8Hh8
LE0kmyJ5bSjPBGgUvDupNAilXGzsLntx/7GYmwqIjX5WthNUopJDpoaCfSmTL4S6EskuBeMC18qn
+MbCCrKC0/IRNotLdcflOF5RbrqWfwWM96Nz3KRYoxQKL8JsB7NwE+ybSLE8l0Ajb16MQw1vkYt8
faTSorXHz/HjxSWJ2Pzrt7ASOmk/UI5kXWAD2VBpvt6DxL7JBMa67gOOtadfPUD0spsscG/nySwT
E0ih5c8v1sCpyY7GpOh5cwoNVcTV71mD6XAn+uvfUiqz2iiVQl1L9OoIU1CpoIW2hSH3E2qMUoI5
UKhDiBBa2V+8B1Hz6FNqns668KKXOJvHnOi/80fKiDyBH0pkgeo17nGdKxzWQPuDqRj0aGe+Hd9K
RJdO5yfDXppTpD9vP2iwFFKgB2FJb7coNmi+c1GZ9ZUIANVAbhyCj5ns1v4VR4QDjhvPsKuEpiFq
zLL0Y0hCsY71/N+y4F9NeqxroC4rny2iG8jtNQwroRuswdPR4uA5EZD+aBLb2CHCLecDNjdznFFT
yayyBROvFRDSX7DkYnAGQMR6OvF3Ypa2cDRlL9TTn/2Z3t4rWefW4tiPcYi8eg/cfIUNrXIf7h1m
DGdPJGOXFmotHQTeV9E+EY1LhjjOBvM7LAXdqTv1w0FN+w3pj93WcmrQN/YnDNYKR0u9ZHnxwwKB
1yvxlCkmErGO7bouKDIqM9LYVBLgOBrMmoKppUjyTdG6F32ox7Toxoj7bqsaWC6EAqkguRiB4hrr
kV2NnAxzZLat9ADOCJoP80LZsesnLG6r3HwMeIq6owKtWrtv2zODYMx6IyGy9WOCdFlPZsLglLtw
+l/NSUXrXnBrU5p/iFtG/KLk7OIvBZPbsARuvw1TX4xtXdSjFEDnMxVPDQKWaADoVExsmLs7OQCW
gL/afEeCbKBkYOetMQUL/ksfaMZ8GJF1LohaV39mPMuiG1z6EcBZcAk7yPtpefwP0nfyJAh7RP4J
owMuaNNbRvEGbJx3XCsiA0vy/8cImMblIml90V6aIhTcB7kWHqbYhYzQV/Om1jCf30HRS3AnZHyt
Dhq8CJEf3jHNizx7f0U/YFDwHUelxQYjB29ZcgJ1hKKXtf4sh+BJ6F14w6me11Unn+Aqh7MqymLe
f5b89alnMyBpEOcGCufoUcid6CsZOpZ/uVe59Tf3jkpQygSo9ZrXm81r/Crwtfq3bu8ML8TTiMaS
PSZ3grfxhxET5IlKr5P+3tqVY76PCPuCnc2bdqAvQTGkEfCA7Np0WbhLxg6o1DbD6NbPlg52qu+2
QR9P58eumJnskaDD7dl+qAkEFtlt+wQAZ6yiZORDOnlj/qRKtcMX7nhyvI/I/+mbRVOe+Tm5ws/g
2CTaldFsX20mVS9b1BQIe0WdtAtWDEmEArTw4YpZgbOOcbq4sI7boIO5l97BPExWhQbgxnMdP+rT
Xg4QoqWYUAJJLAsJuSvxeSkc1e3zVvd+mNRJ3+M/UrhHhNtXaoXxHDpwyZEp7MtRPQfUt/JTrf7D
gYJ+QYLkmI1VUk33fy7BgwlADNnOcGUvXn6zRejQYHV86qUYED1avqEpN9RYg8dZra5ITLH0dKPJ
Z7g5klV1MSQcuSbIpzgxqoE4ZhLOMaVWxR9+KTnqGBrlJz2309mCY5Sl1BQHlxceaXvNq9CkTvWx
luggPz0oAk09iUVHIJBal16M0uD2irJASGTFBX1kLuCAiC4GMAaJCwOmc7ukJn9a3a8msJYe4jBn
ijNQqImF64+LHu8At460B5ih9OeMKzYUgdWaj9Mc7x0u4+mEXTql7gWKC4+73yO3r3bmmkZTUGhe
mGCrkikMU9z0RA9bvQeK/Gv7DD/r47JV/DhGvfVGZUXXxwqyRGOOmNB4uRjUEic+B6XoQKKNQtRw
W240TfZ4+X+iAFaU1xcuMeTG3+y8geWV475mo39gguYTkeI3mYwKU4aOCDF+yNmShX2g/+74VpiX
W0evL6YL9Tssbc3bFwl1pBjRNfb1GV814SRuhy8C3AsNxOM2fF56yaq8PrAzNfOdQms74wvDfhrX
zxKjXzLvs/hE/jXIInqn51b8t4GjxEgUtd+U4nR6ZSYZ1E2vwjEvjGsKPdyZ7K68H4c7Qd7SitL6
mK55cj/u6fXJYTJcIW1z1nVdPtxnlJqhOKa+eQny5sdDRWC7prZptf05b5MKeWAYH9PB9GY3s1m4
I106ALMJUnT+qVUx5LnAji9pcxa8GuhzovygjcbQ5KnSffYV2HULNPYXMN4FWuXhlKQGy5SUjn4c
F2e5x9bMfY0uYtM6uAv19OoeEd/HJQbovJtYtrhMDBwUk8gBa54GHX4aRWelE3TCTQsk30uiOt64
XPW+YJauvcw7s1x5yz7YrOg+lcIMpqPNqvklEYeXQVNZaODFJYvy5hB4uhJttkOJhSYV6r/RbnHG
mbEemM1tsMN3FiGWTJXpyszBltBv+LyroGLh46XyH00HBBRGwfWTwMfDBAHpOHNk0v7r+xduVc1J
Xzm0ydztllQrG4nHaTgaTtSQzTTAkyXE9y7glyu/Uyn4u5TeC4yDfddHGUL7W9iSdHcG5UyjnhMi
ek2SIEcJHmVeLn/NLaOvx0HNlxi/xnI4SZaSxwPTP6h+g2C+27mWv18vaRfhgIZDHLmyl6236XBx
K9jU3JdBgj7ur4qsjwiRm3xbQp8I3Xqvu6q6bQJ16KCwn0v7mDMydfcGKK0FrByEH9n18asmjsqb
Ic5SWh/Z+DLf8CgjAiTxORkeMoJuu8ILJ/UgqL8nDxtjQhlutJRy5LYgFkasOYBWMAOrRm5Nau1o
4bob2dlBt6N0EfVNmF4qaknw5LraWCAPRwG3riFnqD2R/g8PKSzVkyaGAAC6RqJ94vTbGkZokNiD
y1zPZAsiHtXH4JapAvh2Uw55Qm8InPUDd8Pzx3I7b4UykrWdaD3W3TyP1eL/lQz+hqRItPF4qhIl
bmG9GRWnNiURYNdXD7kQTD6Xcq6/s9f8EW6lU6XDx8yR9qHwlvWekbpsvpvAStzkff8lVNDFFiVr
f3zUzxmlj1vZUycfbnDQYtLbTbtLgCjdXnAPLEgvlTKAjooSQrG67VSp4Cj8MnqJJNWY4JzbEyeS
e7b/JckfpxBruZcW4wdESKHr3Vap/fXB2jQDteSFshPPNQIbM3bU2Pu4oIlG4OXohbmqRoaP7R1O
5N6ik28wi8y6BSe7ohuOV/5cYwp5JZMkGQpHIPY4fFvvbudG4/WLuvfVLp+3PO71i0TyoONPw2x1
wrieBPoGUB3MlZlhMsnHeNEHC06BFO13EXoC3xd5LFJlrn/HNAVOUHsTgJ0tJlWbJufFakOTGoqO
Tr0ro0SkCe2cYGgcSWBoKHVFb0J0XDyqZTRNIVwKY0JwmcWCXzTezrQKsguaK7rYrM7dLdoUa7wL
8I+vV1nJ42TETXj8sDohBuojCVW9yNPc5CIh3RCCgDX6zdeKdoim+/QNJvc2f/ZwBfux/OUB/CLk
2skeoUoZ3zwZY8umFrRDddst79oEicjlq0VHri2vORJKtaE1u0QSh0afzriKWCmm3QeXT200Wust
s4Mot4EYHkbBmfsKg2eeiIzr3JTMePdy+2dikCUfDPEQL+m5qy4g2I3Je6HQYnT6GO98Qv3TuSgb
UtDQ/iHQB6pi4vUMqKSb0brwNr3M1EQYPhcLCCGCCmJXV4s4MPmvg6KyTbafdMFC+eqVDNb2Fovr
mHm0GtJzWaLMHY5YbX60sX5caVqSPFY0bks9c8KI7PnZaEnQIqulOAJpxKDpdZUwAyQbPSjuL5rw
JD6ejYIHkx0soH0KVxEZhKQpn/oc+cxFqZz5FKj6mJQthwdgUO576MWU8fsPqgZK+tMB+LSL143X
nhuPnLPbGmsyUiR03E5SamfrbvRb/g4p7CD5mxoVwqKINsIrJPa9bkimv4llH8weWD+iehaPEot8
FwvPEWEkb0QoO/Hbm3EaNpuAeIkYsWI7e0wUGFlPqTrdnAaJNn1sNfclLN+ZM+Jc3wOmcYJd4ASa
doN69h0iMMRGnLOb35CqbzkUIlQ+U4UHHFDHkikluVzKGI552pj9fUrFeDwH23BzXXbQHELj5743
GyI8Q6UWCEzqmEZHPZquX/DiH1DQSqadDsA2WiTOjdiYdPhKvdiLmyiaJ9lFTdxDSBtLi8Pp5KXQ
+VKTRH/v08G2ZlKne+VH+I31/f4zjqLwy2dYV+uTMVv6U2r1HtC9YvQx9noZhzF7k4gv/F6o0mN4
4Ws4Si6v7+Ktm7aPtNX4i66/SLbYXM31bkyoZyH8RmMzbVjz3T1p3TlrPnptyaZ3JbVki1/SpUuY
Or34ZVZ98kRMeLg11v3Rh+oLEmq7UWhv+BgV3DVih+3ircun32xIKcH/0nyXCUL8MxzXY4BBASw6
XQKLmMeFYIPAm+MtyIL7qnLnV9RWfOZ848nenoW0VUc/ZwDg1DT+OpMVJrQ/sob4rozL1bP6odCS
WLlt5plY3I4vnb9Gc/BR60q6WPX0WfYV+xidfjGYSr+17Il4Xs/DiZXwQlDsE1h3gRt6F8OfRz6w
kmngzSCoi7AlZcPvjMVkFuoVIzXVfIvtfPV7TpJpUbxU+qcgUFCgnqTuTK0IvS0vl91g0uSS4ON4
tXsjfmJl3BScvx/WnABpItYvksruvpnu5WpAf35pNVKWG522NTd7O5JZScaFt3dSEyWVzREGkH5V
th4S3h8FE6nnXAzU5MDSXDYwrNw7yH6l97oOPSR/qX/VjTRRew2LKbREGk0F4ecSDGlfEdyo46dQ
ik5PoEhLAyJIKIne5rhl6bKxWkDf+QUm+iIf9B5sLUHmzWcWPJQ3Rhv2ZHUWpxO8HqteI6DR4W2R
9d2afIVu90woNSgabQZCZbDIhDHygLSBBnFUsn5r7ZPFoTloLmFtNT/scjoZzbVXHE+pwCRgedYy
Ux4PtXmVJIACsNBDPvrayXmbvW8lNIlLLrJkGyqwCnaMIGG4lbkqQaA543uUIpF0HcXDZsJ05an2
fZOPAGRsrU65YsNCdPPDz5/EsHhbtocv7Z9/yP8WaVPX2NMHeG8nwch6DbGNkcafAgg4m063UcZP
x4V1lUn3KMqcLgm6nsjt4gUoYJCbMBQRDea3o97umqB/jY43C+FlSaXwTGG/ZKzrqMC4Xlby0n1d
IIueCVuWGsh/761iAThWPmG0bAGrUfEWFqI3PzxMl3EIF24u308JjNhDsSSLYgehlxSvkxblpKPo
JvUcEkxuu5y0klo4Dz/PSqmauG+hE2xX5oQy66fpLoYtLG+H/rvWdLDEfFtdLv1iWdEAZnj6DT5q
ubsQuHiaZNHZDLfj9+mv7WvesDAM9CrAC/r7wE6vOiKzbQnYa3xxBeFN/wA+FrvDhZJeJdOZrR41
nBtVJeAMiSGxLY2vre8VWu3qHt14L2rTrgH/Cmb+lIbOxmqBiiRM6xg9zUOsS2ihiqdlfgu2248M
aY5JK4cSt4udYN00F3t9dqPC2sr+XAcyb+oOma5GwJ42saNXgBgNWMo3eYtCjS8eMAs4aZyRsKfy
7cYpEYE+XNov0v2myCDS2HL1U9VWMT9dE9T6hiM8rXAAAJiSV98TCMV/qCi3TA9EN7ZBOfoK7wTD
I6kIETwRJ1jihfSuy+lpDjuHv3bP5TRSSOw7px5YmMzGJIyc7fkh9JHuIEpqGlBKm7NmaU5Tmbg9
wPVXrGIGy9PozRBkQAVNtjSvZcd0t0sfYWawtqHsjj63L/pg6phgLYENIF1gL3KTZXPYTOgCmwwI
75zGXJYF60f2Z9sbGBbPR2gWAK+9++4oDZNYbx3fpqWG3X+RXRYzzB+OC9OwNoWVZXcus71eNMeO
KWVEP7vGcUGhgZJvfgVTeR/JLq2UWcuJTSEyMtqyeVT5F4fB3U2CLKXiWeJGWfe6K/6v5VS3Z04O
BJEsfSMuSCBUlbGcgVIeor7l8yfIn9EkrikIBAZsjcLw37GG6WYFNP3vF6MkqHCN2GyelFhrfszb
8uR6CjCo0tPeUiPFKrHNEZfj+Fhn7BqJSkR37jGydUAVGonKRWlDKY6GXlgLU+3gleLUtFCy+fWJ
s4+kkqGoDYbWJY7rdHxl21wckiWCoz3VsAFUM0T2S6VdIF+rmZEtC94SPyvw6Nlh3KVGx06BNMr2
JBs6xL6YqcCsHUnidL85saAZ9iYxFr7wcALqqX4+FeJBFl/lVBx75BIOQznDV+L5qGzgeW5pKIB6
ZAqIOZ+bj1bLUtH14yuwFczNRMcgnHGjZ7zhcQvSlSX0hPtw61hIdgEX0u2WRZSlgVZZf3I3+z9u
0sd4k3tpwrm5QTnpqeB91re0mGTzp9hw/UsYC4xa02dtYLJwK0LuCgEzXYW+97Uuiu6FZIcILyVK
ITxccbkP0zS3W9Ga0sIL0NSfx9gLeO1ae4uZDpKQzcWswjiIMak96NJhmWvuakTqIyRLkk1aJZYZ
GwiF6XmxuH+5PrPkC3D3bESHWePB3H1f+yK11yNqmqzGqttyL8uAiV7wHr7HC0gdvV1c9AGyQYqC
2HoeqjZQ+iX8eZQ8xEhVfz6r7/d2cbLtc6JX8DfRkHi2RZZ3u0B1X9D/ihEOC57RKLc67mO8wZ/H
y+nyHHMAFvO9Etg5gUxS7K9hp3YlTIz9m5Ng40fkvBPULhrtUpjKh4hSeIz+YI2l609avz9nen36
R4DTXS3xQZvwZBAtn4NTmgVwR7V/PhTwTgkqdVEby1AFeZJgBOAfip0/TwmfdNpvjIalw+9ImF5I
8f0PEeklM950ujQYgIGAKW0hy828KyLsybdgFQhpJD+3RLq+DOrscuTQGYsQHX64aYiNTcX7kEjE
jhEy5OL69H0urkg7CbpkZEC1/55CEh1DHY2gUE1kN1WYf/5vnldIMcaibye2nXsDQjPV7o5WZI8Y
nHjpL92GiDzw84Fqf8FjRTnJZfw3S9BXHrLpsgC3Zlq34fu30UJXFB8l1FO+Zy3exQxUuIzEGA+T
2GTLiyc1B+B8X8SqM8TPrEZatsxriuiHo5UEzz+zBW9CrPayyzlEmvoY4asuxJcROlquRmDMz9Zw
tiTRbrm7xAPvDSi+5ml7Ys3y8jA8mwX0O6PRKDfvEgXpZvFm4ReYNOrOT2GUy84NxYrkmSQauZ5R
jNyIwzrZwmUIxDDa7Bqqoqvw8Ahtdbjl7ZC86zGZNY1Kp/XH+S8jTHY8vKvvw7iEuh3JPMPqu3v7
fHlRzL8x6/t9+qTRCDak5IA0hk6pIXZpNYibHEcir8ukVvsxeBnjkKfyMOvN7fhHxTUDRrzrUHyA
Q1jLsw2lCRO8/OdvjaOAwTPthIesfBtXhZsflAL0T0UFXxiOT0qiNXTa+CReiPYoI2IgRgqPY/eI
bZKQC7wYJrVqx7fUP2nkVbDRsIdkinEdGYfR0wWKgEOdpGPLTyUAAdWbZC7fmD2AEkInRLfSwBLn
Nx09GoQOei0mANXGFvRzH8Kepvw0hHLnvOeA/jWgzn2awk5mfQRksEG1+wLwlk4SL72US5WqtDLw
yR9JbfAZWV12SPxWfc+cgSyWtFZuVfQ+OUx/fNzvvNyKLonZdmtaUsnvJaxFIx125nhpfZSjDixP
hdbap3wpEeqXqijlAB+NGBygcCT7ISjc7rmR8Gm20D0krhSmuY7ISuT9Nki5+u/vpbP4ih9Xm59s
N3mxQCvimzSCa9A5bUD0TzkvMAbMAITEaizDwKVWCWFhxHOrxLvESEThRtH40D2LMs95Mp6FjzIA
nVudzmL+DkfNu6CyUzgkMU2hF3XYGVXgU+Ykjpvk+JVZWcHI7re1lpWzdT6TPjn0bFUAUHOjPctX
htZK/LrmM1sJaj05Wg9cV51bO7tPZgx06Wmco9RoriwVdLArEVizlmuCl7ldcbD9wHXnOcHpgjCB
Zbsxfnt6UXX0L0XEHJ54r1su/EE8SdwZ3bMLXBCi68kE112StaO51WPQO7CfnjEYBlcw67CEscza
6H208JYrkmcfKBjAFJClYqFU5QClbmDszDFMBmarEC4lZyyhaIur5BIj61enwIatlxk8FnXcj0Oe
4Haucxu1tC3M0v4bMHiAKvv6QdrZbJeorwF3JHMfHlFcKaqr54VikB14b7bcNb22PFB/s1VDukr4
mVPOL01cSMfHNFOLZioGyDv6LmT2A2VbyJ071mfEXx0lHZjod0FKMjPHKj7vve+CBoSVX66oGyH7
zEY0sTtqDVAYLH6D6JeFCIrS+JPNx+uyBNwWwE3n+u85kSrVdi2NZgtmeQ69PjAnPF47tFy4oiLc
YPBiP+U6Sk893VLJMRKPLUf7APgjdztYuPyHygdLhluFwYNOgsEcNfE8xCFigGJKk9OUkLZM7NWy
y5ss9/1AuFeOVhi/Cdj5xjkJS+1CBSqCX0A4hMvcERqUYHugoPQWBc7SGFJxN1EP4zCSTU1GpAET
ybwKtgQ7OI3QuRKzMjzFtgntV1VcUN6YZ+fej5sYGSS5gXfx+yLPfvA2q2u4i/ylhImSckBYs/WT
1LAvg7qqWbBG+ltgIY2Rn8tX/VfVw8Zor9lXC7KW/scKlVZal7mqauJCp8YJ6xN66On66vKyz3dq
BNL9V+tgrXDutZnCc1Q7Z5RyvVQT8znpFlCyB+7vrWrJw7Nvg9qKhZY0b08OoPTnfBXmnAbNb/Mb
eAmEo/ign7yMkCsi7xhWjbdpC8c82Du7/QrIcRRDz67by0moG0X/TqKOtmDSDxwygNsgT3W92gYs
zVQfMmfWD1vvm7RgOZKWPdvjrQ7fQO3X6rnNZZPtk9arKxAqW9/7FaJAoDAFF8+w5ifX9T+nY1GM
SqXk5iDo9EQpJvIlRosKAk8xl83PLj2NF+T/HBJB5GEhLHxDKjc1Bkj6n952aN8rAimmTrn9BR3/
yE1UVubdI+6T448mOwcCXlvvNBy65wYaBm0Mt9dAnDNDIhTWFszm8hLJdfp6yw/xsFEFjHVGt9sZ
eL547nx2oklt68sh8IDRO53hCHVygfKkLOK6RtYgfUIqPiKDGWeJfJ/+h42tDEbrD9SzSMrqBd4O
a5N8u2I9cq3qsMb2UFEA+DTcXkACIOqQJdQELwD/Rbi9Lz9hKtfXtejkYcSBkMARLZXJf4QGHiwu
2Gm5kV2TRVHqdepqnDs7o/+oTL9Lao/LcSLaRSKog7KuEBoSnb+iCwFjW7TTZ07mnUG1CRkGsgX4
i+5zzRW+EwOJ6HSAIAGfK/JN3/c6CmOo5lNxKba5nKuBKCZAc8UKE9IBySRsDWaX2MItW7OZZX2d
oMBLLF3iDWRcpyQyAE4IMp680jY7J9Aqbax6aPvUfLMfmTlmVQA/kA4G8Jth04Gd6Ew3zPbwuO3V
ldWdz6GINDtN9eBcBdOeZRxQTTyR1VcrabcGL1cC7j9esxaEkXjBjVnXsMJDHHYbu8Y/N9BUy/5J
BD5PMDqqlgdY3eavk1TVq+mEGUs2oCB+4K325VtABBYTAwS38jsV2MOI4HkgVle1jHU7brmVEUXK
gkE67AMuUQIuT+Ca9WA/sJrdOwrgmWSz3MJUQNobuwD7qYYdxY/Q2Qdec/ZHRxxfG2DZHbIeroQz
eJyo4Rz2ltmvIBtxFXwA/WBXK1TWeHjBqXYuYsKRuriPvI2u64jr6jZsSFyilsnKSwr4j7P0b79q
TP08gPA0g8Dl0r0CzVgwmy4M2fAjIBJg7dnhMSwfLsJlfPdQPnLNuI7szE4aImk8/4aZH07Zom55
OF9J+9Oz8E/3hbnJhRq7Xc0KZOjmcSmHNj9RG65nHblYKIy8w4pyDu5I4Owkqr/KlQgSEiintLuA
LEewkPmncLGm+cce2ot5B/Ts+wrJdu8IqbogfNV0CxZqJDKD9AQzkYWtu5KQL70ekLgjDzGuqNz3
xgxi9IvJWboGqlwiheuSyf2Rly6xWjzLH3efIVbV4qX2MYmwbW/l9xRfx5nnCUInv6f2rEYm59MN
YC6kBJmCu2aK+xq/RuOD5jQFN8GUm3ydE9BhazlKnPg54iuTU6In7z88cQbjlzI4hGHAbeknXWVj
XK/ui220ZpCGmxfi1uvct2CsVfsqh2vsqlvGSTB3laMqblwmxx+j0mNQ/Z+QuJClpkmEuNPkDchk
9czOQN5dSi195yVnbp2nkj2dzYceTNSbeSRMMUhAyXByEhn9K5b0+HBfvhl44xhV/e4IEwo4Cf99
Z1Bg7EPNIer4XOqNGe2P1pI9P0IKo5orkwAi6NKMIsUQFJOvWNmC0vOIHwWaThj5l7GePokofTAv
xR4mBaeSNnQ8t36hW3uiK7gwd2BjcMrTmMfiFKg19azLGhlniFrKWYFsVDXL9HLRi9SZLo1Qr1bH
J56kEhil4Hs4ctmpLb8uwt2HZvGQSauUAusdcQfj1iWcfSenXYPsJKsnKPBb/J8GUjPx9UKcaV3e
gi4CSUYo2ZLV8RyOyOhv+yF5sZKdWxOLG0zD/nJiS1eacC+tIW57xio5ozFQdDXYgaFRM1yttPoF
lrjA/0WUIWwI9T1WdFZGevr7ApV+t5+7p0qj4EmDx9Kt2YVvArlkFFo4Au7XJ3HqdwjlAEu9BNgS
GOVfgM9qFVw2EG1Uew/amLyRuDqOq3uv9N9pNN+0id9rqS4QkQAtUfJJuvWQBmGNlZIpt5oRVtzc
qV2ry45QQwblAoGc43Qyny1nApnCnjYdKQZrz4z6qHvn3Eq9iTmFBIYFldDWmOtGJwTcFVqxMJld
waLfWBCZxXcNipHt1iUPx8Pw5/+io6uQYRAe3J39Jxa/9CmJF5NiEvBUBQzvRWJgby7oHpWVM4Am
hU8dJrqTgALOSoMMuoYPjaMgZ0Y4BBkqdWXaB7Y5EVgoNLD//1/x1nH96YnTK1A1ErPwKeUNsdvP
OcG8LHskf2hiqpZWrdn2CGh+zKno4ZMM4C7e2skwd9QkCmmMfu/n0DmERg2Uf0xfe81mTpqU6gh/
1vgV06/w3S77R5Oagst3N/NPu+0RlL4oWvFdPLNMnreRg//RApCkdpqqovhYf4HT9tiRPJ4JzBt8
+Xp11WIp3w9em/OxYA5z5aSCLqaGB/Dur24yRz08aWjFkcz877bIv1sgB9NluSLOWhCJg/BsCSqh
QFiA2WtZxVnCsHKTraq8Wqy6bmVQAveTp0j9P/bpn9Fy+cvqggqkV96vqrSw1bJWep5xB0EB6TpN
kqpcPs9wMneigEvUcK2cxyxEk8Orcsv8IVKoWH2rMVmg6Lgrr58BvcUda8XixPelzQnLVEIZYL1a
fFPEx8EAfU1sR/qmryxf26w287eIXaf26LZctsOrR4aHAKoaE/gILd53oGh5Ot0XFNl+U1poip7t
7MzCrgBjpBavnR129remcfYlosamacTAWXqKMYflaDgsWvHSy6hoaBLL1Aq7wcfvDaOil2ODxcMr
oDJB68+4pLf0hQK6OnSvibD81DNYuyuzjeA3Tyqzpalbi/4AQPhqVQh08xWSzURTAVvu7Wb6Sv/c
O/BeFOffUBpxAdd99/LK4ZF7YXaTBynDIKEjPFHcfXQ/uKORF0QMNivQjw+JHrFOVsPR6c6xa7mi
Qq1NhHG5GVZzjoZIDvybUAsBpqpccns7ds2TRk/0YCVt9TKcY8py/ANf0w0rAqLN0UhFgW4wlxN1
1gCgQWiPJUjUrr+IYyekOTlRLFia8fB/xy20z5NT27uJ/POHuTJ1mcfeU3wm2geiH1rTnK6qKhSa
FhEP2/rEzBJJK73Gec23cTiW/WS9i/lmCgQH0qf98nn1Xdg9L/CnQbKvoFtftQM6VJDBKdN7mLN+
qQ93GxaubIo1BouOszULz5manhpYXs2hdc7SpnzXtU1QRAEpqHxXYF340DLtnVXX3uhu2BuLdvD+
JhCTbyBtZWbd+CWYD4q3zddoK+Eq6BlwA/xhSJOgDqsVT4n/JCw/3rNcchV29r4N/qoajYT1L9nz
PuaQ5c1WB8KyAlYeFWxx7XL1oVoegUeaYfM6VE/MgL2dcxMQ3DRsQfjJKdBMRh7N71zzmFSTTQoN
5+073VzCiGag3cXUeE+quyHalCfiUoa8ygtEP6ItMaKdqclMXB4pzUh8+ym2ud0MA3i434UqlV9u
kC94F1zBJE2N0qJgJIsGFx8yEkGZ1ziiIWmA+mi8lkASikt49Osrc2eIv4lVT4MykkK/d6uSxbb7
bcWEpKKoGIc2v0QLa3eE6zODlrsICO9QUl+ydPUaH3FloZNn3tzJso0OSP1PqmCZhBkgnKP+0BYM
W9OfXgvT6CakrqxbVExbLqGBuLwgd/LwZErNc8FPQdGBUnkqP2I7qJaBIoHzYsascSYVHPDlvKY1
eHBoOpcf4ASAMr+mUT37D0W0JmLlfbe0ZNBaiajbFmobg7cHi/LbZOaF3fbNHDtAEsoe87YYSohQ
MRgL+acSzDQau07a+SfnkBrDNrX+nTWUZ+auN4JOHlk5yUhbgyPvQ36Fvlgvtk637bMquS8ncOky
TiAQGyTwj4fmTayW8dv3ZcPzCRnQWvdFH1+wA4f633sOTIsrsBEHkJmm1gPVdQOUTCO6KYWkrPpv
qNICLFZrpnLDJ5/aqrHcxdE5+uRCyAuIepdHUslLPYi9mu3QfkTJryfEyjneIXzQUPJm61p56Z0m
6LGFfPMjnmRBl8eXYhgsAZ/jxHtJorK9ZF8FKQBh0zB9CBOrhRf/9fAvOFsiYwaZPhh//J79/r6N
O0PZYKgssR2Meu9fl1lcnR8J2bPHGsMEueZO9ZnErVDwOjOZ8w9jRModOWAWb3NFqXRoeWsPeQEv
G3yxvKastHcUP9SQDBAeZv1S5W7xwmxe1OGtp6Ii8yxfzoa35tdAB48jspsT0xnmA2m1i6vV6f8T
EdTl86eqgLkdJp1nv5d60piy4/OKnqk4JOpsdgtSbcMKUGuKOG8+0jPhpeBpbXSjMrAFaRP0UlED
jgxu8iXuoizhy/q4wrYDiJZCim6V7od0s55qweu1/2hFW4GsQROxcbGJHpBaNUVFnBxtupMtXJ5K
tdvkOrDOfAWOboU6IKgd2VxGmy8p1rGhpsqhV9fEt6ToRdrSGuBnz6ooBcJIh+jgIBCdOH17RABS
4LfKk9YzEHHlU6TAGNztPbuark43T4hnmm8RKYaG8h5j/it1edpc3DXDTfqM4k0WHGKwv1lBMF7n
mXDyaY4RUtFRItrVQN4DCEqFwymqPgnUlzbEFG5t3sSeTD4z/dXRrn0D9jOHTCSaj9mj4X8rm9AX
ad4YD4PaF2zes24fM7E/MggPvr2shaodebZqpyY+fni0C/uEwieJ4pTMC9zksgIl56sglpkbbTJ7
fxSsx8dr2vxgQNNgu1FrjCE+nzXPqJjJfx0qKTPgay9kZWS0Aa1b+cMsRe7mlLd+4f9WkMisZ3JY
8UWmYKhs3SAcXRVdZokWyVVEHSDt2nQ+dosMbwaXGn+Z+ouY/bNpthY0ZlS6HnATpJtIsfNUwSVm
PQ/V+3PPkcE2IYmoLoYH2ueEO1yRO/RTsds4kGlCC8QohpfbbJIpGnvPLHVArBePYUf0BVkXqVng
mIAXbplLU8YUML48VkOAHu2tWOAZOGTN76JjyEUGdmkXJ7pR24X4q6bRid2Bs7+CNKOVLidDVtxc
UkiormCxllGUvomtZm6dg5ZSFX6TJkFhk4F2mrL+TY2Cbv6aPLlLPmsNKNNS7FSexcTs0mpMMVMz
QbWi35DsZQ6hRZOd6WOMm47EIoxEWXXkZasK9vfc0Qla8mpVfotldl/vr3UFO54bDv0YGyeEEZf/
PtUKXIa4fQxTki1xjM46YfRY1F7lW1q5R4fJFmu9Q5a/2oYTUuJEwwvcxQiSDGE55R1FToIZCaL3
ZU8478/pEp48NDzdA/M83vIA6EkxHvqNs7lN1Cgp2dtYL5p3qCrZlEx0alG8J5Un6vKg9YU9APsR
uHQZDdEG7BxMP5K5cyiOphy5QJ7HhBHS99/wzyVnuQHb82ak2YQ5SB5NRCSJiVfxPEnP9hnBW42M
RC7ENYbYTPX/a2jNRNKXrxFUHBV8SZLXhheb8HC4QpZJtX6/xEbpW50dS/hWOGuz9ICp0AqXv/+q
mxVmBbWYEhJJNox0lnWDYjHP5de/6B69G5QIoHSk0REWAwGeJoHwLzG/UGgEYvu7pCnRcpnHEBLY
djAdUXByVM3RP0liggSuReWw9xuxqTxUC5MJv2laPiFJGmoGuHK68USCNSvy2UUHcDtaUYP6sM5y
6fsPI/AyoZ5mF2rx8PH+OS2RLrbQrhYNWmdkfK/VLna13b/nVp9i6RSYFztF5jPJzrvJKiJrQ7QD
J8XlSkc8EWPGFlUzzsZSywVczOrdhSdtyDHFN+NcFm7DXWTE3EfEO+MufD3Oes/rwQGzM1ZB9ES9
FEGa17wY8oH3EjZ9kEX4ejOrI7ED1Mzwt665m4vxojeWSGtLVwhG84o4Un4P8Jm9HOsqSExEIr1L
MrAo7mQnDOiqEOHWaoKe5DF7c3V7wsux2oI97VN/P0CaCFNQJrKzwlcGJnQmVpqTw1YOGSElaTko
Tag9Z2bYPy6mV9siBIPae4oQlL5E6orQ6sYOnekfdz+kEJ4TGFErpGRxq+QbxTZpz83AXB/RVwEr
xD/++QBHRrJvabIaVAEwZ2QA4IzKXF2LDTY5aTe6T8fEyHMn45+vouEwkPMrAMkofk/ViTDgdltg
quPhLRnx9h6lBO5//TBpzAiibXpgs79UP38VVKJeCxT6CarOBWCJHb1xSvRZoWU6AHNXTgL0uQwg
iisIdVy/bN/FRdTDE3o/1+9U4PIZV0kdcnI0aOo+XTzIBcDkRbBLCKpd3tLnQ885CwDo+ZZAMp4g
WF7ucyySP42Klh9jxVK0k73YZrd1Jo/hDxA1hdPTrT7boLpdzlaBCrDP3TfagYfQl01B4HGEACRo
c1GM1LHRWUepN0zdxnC0WS1/MKdEmlZ2bYpO8QiqLVbBIH7jfxbfjHXWitiv8NwJ9l7/pEtbO/Hs
PLbSM9/HfsFIpCls5i/QJsasdMq0i48vcfFz2hVVm034EdQI4B4/FP1gxJwIjHarRf1VQjldkM+M
q9r53nwS/kVM55VNCwowP76axgK2emeQpSfHag9eDEbAHnwJHoX1tCc96LGgiYszbaylSAl4fv3d
YFlk6fSdAhpBuZ/EIeyE8XI0UsGxE5q7OoWPrxwnn7enGbtPWCbzzuW9/diqTY/tkommZO7rzZz9
wdjt/pEsFYHfVxSOjF1A8c8umXZvwZ+R22xxbfn0aAUxs1SHbtrkrwq8lRgLHAYwks7x1Z3+x56g
swtLJMLOVgQ8lij3cynD8RwvKDSM1Ys0/lSvMBgzhKeKmFBJXPppqlHX2IJY1mr2mYG3L8502ZGI
EGAASFTq+RXXfy00aWgrwQiOGIm9OB4FX8mjYXBJ0Q2K/gvnYDLJOP1m+QUnPnvqMYll9/i56GMO
x/GmgrpliC5jlz0ujbiwb82Mj6QG4OAK9tWLWl1t2m7Cv2V4SGqNcfESkhgUfc6u7lb2ZDgvuRzv
L3Mn12coCKRybmtj3n+QHJTVlThRXCPis35spIMhHb/dXbflj+HmExkI7rnnysVS67xQsAqQf2mO
7kw6ekAaLKyWuJ8iWRRw14/EdRbC2c1kOWlFaLzYG6iWTxPU9iVk5qvPrpx33Vzfe/iKJMD8oHWK
/cJu0pWaiVJPf9XWCTScJJG0oiD5OIiwQDHoRFkyheyzZehfnATjNXhki6VmnPv4OgdmLKEInuxE
7Z6ZiHSZuXrXJhlGrGjPZYSe/s5Oayne6oD463THAaHWWu2lzDQKf2a/Iu2aMNFixW6g6CWTFC7O
n78J45qYZ8V2FhoZ46J6GsFtpM4GB+AWkzjzYojW4sMbmGMjEyGuAnw52K9TdOE21U0oibVwGueU
wV2FVtjdmvVucxlClbj7mh5zLEJDYQXlvkuoENS0eZfJlG5Zd209N3bei0viLeIo0nBakmAfS4dh
SryhoyAg2uRF6zaMp5YVFYfF5BxGO3/B0iy3Wol1a1sA1yc7LtEHxe9GTIWhy2kACjLpr+cuSW1S
LpirHbcrzucFWqmNYp9UbQ8Wu3aSJHUYE6NJgZLM6Vje87z7kuHJ9JMddF0bg4q8OEYOURz6O54j
a1um0wvNdMPzIaV/RV4mLsuQyjZEgbQb0f6CcthBgcHhmxwLRU1+r+1qWjKTJt3wLILoXn3ZFZtL
9WycXDQUl98iupIq9bTM38SsfVHVbRKz3sSorMlyyNGqbAhcO+3TFTqpUgpqwRtfqs1Q9uSmwiXe
zD6WOZBY50KC7B9Sdw3dLpF/DMBL2LRygTSwMaSZRS7ySEZ2/5U1usdv08psdGq0dHGwB/t+FoPW
XiutZ3uQL+spWLgYOzj8YY8ZuLK+KhMDW6+OKhWHcUDvehgWEMoeNMt5RBEIMu41IPiqmrrzD3P/
S9O+8xHLArItb7MKp7YNcZtO1G1E4uC2xiRv/Mm1RtWcJ+iIAs7blTe4pdfKY8mvw+ywx6OgtWnd
eKmmx5sor37aP8cYcOpibXnlYa5t6eZc9MNDXnna2s4Ymtcz3mQr+CDOivfhrl+fom9Shvb+Yft8
CNosg6Gv++hFI6jBTfYM60A7p9Ewux4v7k6fs9rbBuL+sAn7VK93AcddcqpZx0a1ADHy/feXWWG0
0tYH8TcGWoIHq7PEVu1ZH4ZbZsBoyr8Ithz5+d23dzl3PqW6eeW11DIwgIVanv0nc80uo6MPIqTE
p0QL7mG3u0BD4tTc6boIodrkvJ8Q8TDlhX2cydjmcbpY/2xBzihTjIoXS3yNdX4ddMIbtHgBcCUM
+CqVcy8LTW8gjBeu5iDOkxebl20a9i8thhUI6Jy/abCnSxziv+IILIc0zIfn+uBJmSaKqTwDFkqF
HgaE08dk60dwG+evl0OgBv9T6y3CIjezZEWkDrtbYojO+odoU7UV20nWUgGlf5pDdRnVAZtRh21E
35LN+Xvj5yA1U65hXyW7khFHT+b7yUdS9r74zpM295egE2pGyCMBQiveVIYkfWYj7G+Oj0EujLWJ
eABt+S8JR/Bp3zhB4hX5qeoofs4SDYbmZv7dCKcE/R4gPz9L99CqZPzUuKGvutud5TyiDiud2TwI
iFFYcphnEnmjvr0ah0AYYLV+smc5LayjZTEI7pyMd5StLNjfQvd8VYMQETsqXm4zz3HPU+HV2Few
u79RyGhguEo+zi4DILkx8kf8VA4/RKFbbIoQwC+5QlPuPh3NYmhHM0lv61YL2P5iqv5ZS59gJmTH
vUKDxT/FCSwizeZHIf1CRcmICg5d5wiorSuUiXwZ9JI66P3gi7+YGjrbPR4Jlo8B/fxKxWJX0tfT
fBCj2UmTZR+3RD/OEiGMtq2kZds6g+B4nL3jJTJX+M+DydQ96lBu6ZRPvR7Z3OuiTYMbXfMJ/mhV
vVXUHEVRFcoDubZXNbYbXceGZNIGQmCvtdXCcVX4YbkKkN+ZR3W0xgVGd776G1zmIP5+IlXbRLUb
4O7YtK/uBhBJ32+Vttf+rE0DXlh4ro73HdKMOKYdTd0F5crjr6UPbEaYUB9JE+EVbCS8GEc7U+sF
WeVvKCXsCTUUQJfF2ObiqWKnBeq6PtIcnzGO5Pt/5kghCEBsLXENvgMdV3loqUykBa250Ll9hN8K
uzWSTbJsi4t1bQ9SMrn0tOQk7BQ9l7qvm5ymIL5VtK9fQr6UiEWzTfaWJoqmJhbjA62Wjp07UgGg
pIPrOUafg6ZQbgt3NQ3ZTyrlJutFGUI7eA8C04t1u49LYvTHoHDgZXz84BqylB4Y7vPXHfke8X35
+Bfc01BfXDZwkjumatXQnYrazLURkF/Msghsw7zZ0v6uL8MZbUAZu5dxDGp9jbuYRP74ST8Vl88V
ORaMM0E1aFs5sTVAAPYFz0wKGVDmYCeKvwd+Vzen10ypKPTXHz49JmD+V+jbiGy7frQPr4f54arP
rOkrBA9wFjTqXl1zw7YT0VOYoh6uGYteo3aBizae2I9LkOvZZDhwCh/14fPCvKAGeA3rzuTsk3Lg
tGbQERVolHvEZLNdmZXDbDv+J1QmDWDkwQBDxeq6i9qK0Jsdfm+Xa8z+7L68rBgk/wCO9t2cR7XT
P2AL9ehdI3XIsS9Su5eE3q9/HOCpq1qZmBeB1rHOH29edxIc60uJZV1ZGCG9kpcyEBRVsG1Odtbs
gAgJZFiG2PwFh/74qbEY8m0famnSw8i7E93MkBGu5K/ogNSWXGqMvzUwwmYCZpYqCjvmpIPvKhc8
l8GnMWd6EFlPLUgdP2S2Jju6r8PyJpt88yRgoXE4dHxoLyJ/qOXRCuf5NZoYAx99XFnH+Monhlxd
Bndx61/nEN+7zVgLXM8CEI7w+a4wsA+YfbrmSQRzQqRioHOEEFo+rPawASdFeNRM8WzqaF4mOmyS
AkN2FUTg/ZPB6+mzUeqCZUPdz4oprUIGHZ2gGlKx13B3ycp+RKBXhPN5YgEWBLSwVd6vfidJXyEY
ZcmZc7GqppTcfTdGk8gD53maUE9CereK2Wg/fxgcUsw2OYCfzQX3KoM/PArz65B+4Gid2cNlFrvY
+PM8G0NizkQlPpsjwK6N4JEdAO3Q0IQvTFBmTWQtFmQ+rBMWEn4d5Rkit9Us55C5k3sR1yPewF8R
m4tZW7AsgWvvzS4yaS2wqj0nPOwDMyprnUZyIetazWJx1wFjgPYicroY/O4322Lkr7i6S9hnJin4
EyyIPf/2cN8qdJ2WLXufs2iu5JlweaFul/QVBy/N1y91S6hDErnBWpGJiJTTWrMaceYhWPAz6r8W
AaVfDLMpetPM0s/HQ1Co7FI0WEHQF1sIUvyRQy4svyMvg3cJndXq1DQkIJ1/hlAf8VloTcd0rWHQ
u3t7E/+T6nR0Y4rBeH55rJ0Q19mZcOe3dVJ4hJKncd7UArgoxq0Wg0/b/czzOITymTtujcvpjOpf
tGplVIdTBnixflRhUVXPtWQ9eftxYe8tNVer0pWOEqK/u2KbaCsWTmqC9Tj4GMiwnEGsf53Wph+I
asTnw5FR7Fov1OvEo/Nn++BKaOYq6f7chfRph8Bc4Dp8bIlGDDpzipfTHshGabo6M1dCbuNiEnVq
iNcEz0fZK/SPEtQxssWXQXEX2kcCKveYxF3GlgQQRRN6rVZT9Z35XPVgzfeJvhLr6DKrE8NNvr7s
1CuUPeGWCDiE5lcAPCoOXYVOPPcTqz/eixOcNEeOuo6WAlz7ZVxMfvuYy9fPu4JIoywX18pKzOGG
Lhd4cLytOJRNa+vxpuOVno14x5/IumlNQQuVxAAbqJiD18dACN5gV0AfGaHGrkLUClHwcGvx3yO/
jV9Sz0vSH5xdU8q+3AqejmqM38EUDqBuNMa1fpC5prbvs8DbsNjLGdg/Oy1hpf7d11oPKc84LIge
5k1GhbQLKz0tTpR6Brm4ZHWAg27ZvKuHuoYCFy+Pt7WWpECOKJMnwCSMfhLGyAzWoyknumQElq+b
Hfkpooh0Uekz8wVOVxaxLOdAECoJwgO4MmSBcvSFsotvZ1/I0hWfyZba7Gop4jBoBXHaEPROJRoa
nd4MVi/mQLGIqExQif/J/LW/0cI45DbN9o74BXvNeAq3WwszWhbMung5rQyGaZ/iboVTdyO5Aq58
v61srZ2MdaGFUO/52VTFTbiDFWFxapjsXCzdldNM/pTx5oYKbEctTiyUWitupk4h/XrLA7kiJ0dz
BEnc5E3NkmN/2IZ9CRDCb1ZgDHIQ1oLGspZnOVzQq3PE6KMv0xkgJddzsoJJJbMcPYME0Esdu+KW
G0jkxUlUpBNV58umaBBBwBOBWTOWj3qc4ras+SJwqZKjlZDe5Sw7EqMpzm476zfZrjm4MbCbCwqf
yL4pqsqKqFVeucz5eiA2tMwvXHvf4sQbFCNC7wlEzsIogzkFs/DTY70JbqCD5/+PGJMZGqaOkjtr
5L03rpnZN1U1+NZxKJP+lyPX4x1Q3JFsxdA7op+j0KYv7/33oVDnUKHkrypo6EpBF++4mFxMG1j2
oReoFPQUPiEV195G7JLlxnhH/6WkSO/sLfnSIl3x1rF3xDMVBEHPer0NNOEtbrIEeapY0WGdhKfD
DuXMfdJ0/nCjIXjqX9UezBOtGhcx0jROSo01ZNpA3f0tBD4s/56efNXLdIm/tZ3za2VXMlQhExmi
kpZgVncohi8AVMhjVoz1yX/E70jy/wVHT6cyUpVdjdCn7POXWN5RpRYkxFoww/4e7MHLv1rqMGTq
qKDToYuW/bDAbi4MlIMSSAuf3rioulK/MFq6lQHiGhhRBv4meVNV8aZG0GR0SVuIToBIJc1b7E2s
zCBc8ekJqGjPOeQQSOZUIKpuPWNstHARl1WLS+6Wuy0RhKYd2hubot7xOYWdY0c2AW4uFRF3b3xP
S2UK2o+WC0r4SU/Ja1tbN/riD0Sox5bxHsk+RSCM7S9cXajpaoRiTfLZ8dBU+U2QtdGHnPwwf8mb
9DeMh6VdaZWg+O3g8dtjdlQejzFVEydPkQKjKZLkPMeVqTEbGqOoQ2Brzg8gGZjWJopNL/IvNmi5
EF9fUeBbKKc43+Ar2VQHpgVw00m4mUgTmeHauohzilzWvcsvFFf2SM7I3eBQcqC1//BmjCAZHRRK
Qpeb2PIMLJcceUmL2Gfm6TvNVQaX3bPjCMV4xEF/0OrdHXapXXn3pUUVpxcLr9bU2AvgQu+MH47W
+sBBkQ3xUJMqUHxYoOBSQzxiRuwNFiYuYcYBs3VubEJvNK4tHUixgjMLmDKiirol3JkjMkWdLqdW
Gh6NEzB7aeghLctGCN0n8+nzeLKe7PtwLyfpAe18jwIo8wimz69OCd55WPfIs7+9dIdaGXk3kFIA
2BzHXvdDiM5mBB1SVIOqBWJ22AEHNPiyA7JwB7g7M2PWQwCyBrl5Dx3/8JFXI7iFumF7BQXr0XY9
Ic67LVX9tExoIQzs28FTomDEK1emjIvZsQpTsBvjO+KdQjhlXEGRuPT0Qsp/uxWuNIC3GSqk1rqW
UKyq9+mONZY/y8hpQftPyxhTPnMmx3oumTk5jGrmVSum+HXU8+X4mR66GtkYRRR1m+/2BrvZMQaZ
1UvfKWyITTS87ds8FcAuXSaq6gGryWQJKjIwg8AaulUjC+3q34UaG2WRIeHe2adzLZ+Jt4vQmR0A
0JaIi3llRFQuq54zNWsGLHT4nZn5fp+lrDIgu/D5+j585F1nFHIl/LuDibDa4+mXcGZnskKK+h3x
di6uxgfPX6J4SATNK+r27bgGQPoMJdfnOxYAZSFKug9UnaY/UQ7WlmlBfCwv9v7QCN7FrwQZKKMF
+qA9dsJE3uydUUbBp8ddrlZZZjQpkISI1UxDpoJ1U86LVrH3D4ST6BFbNfjosyQ1Y6Gv8Cg/aeHO
oTEluYJYHMC6Dnif92FaW4OoZRCjZCPFeX46OzCJlp7i2vlrjYr/QeizxQfTVCYmvSlpT0kLdWXK
9E4xgcH8xOtsHNljMk0bQFNtN9rUcbYRa22ibV3wmkavRt9dzAVsTQP/snXKoJYCFd0vnE9gGV2z
IFcgnO4WLJ97t4I1JNiekdKRKSOw3Qf0oHqiTJDP7CgkpSEeaRFfRuR4FHow8NxIUbwg4P4W9fio
8EsM6138VAsV4fQkGcvqt27N9PME6lbVv7O+F1FeMFIrUq178B5+pdbVzqgvCbzN2XYVQtEyW2rt
Zm3JM0eKEznnKS3Mh/18sclza+S058ebV/v3n319rmjfm5S7uZaTAUWvJcdpZDYo/VxEEjJogOdC
sRyGiLUUNOjWO67oR6TpEAhMnPOInu+GI1NoowX+MjL2s2/t7sgxLdBwBj1zWXxKf+8AFxEtcXwe
4b8ljwX3dblva+uY3tBQGxhmL+Mr3bEhMSV8sjRb8yaZNfDr1nHr9KLqdl7jFqX+EsEtldVLsSHy
l6ZTjp+yCsbCl4IFXbLU+pNyp7jqSWN+ierFLd5g09eoHM62Qanv+IDbH+kb7lhk5AmPvQbLV/XN
I0DiTKQ/HHae5it9PTN6dDa5DAp5uAtipEciUvI6WYc+FuejmIg9RxWUthm5dSNd6WiTGz2KeY2a
J2IBbLhn4/USDACiSswXC4/F0TghHQkKnVbP6EN8dFq4PVtZGrQmJwEPC5ML/ej7xZECKgk1CSN8
ArYywpmkG0fLJl5OrmMfcq3/ZdGXMQ5889JrQWG/H/+m0KARQUqOX0783T09gceiU9tLM0nNwtv/
x6Xppe8xmhkEeqRH7PxAzOk7HepXMUclEI32vyy1HhD7UV4hhO4IO776DICfvMtVQuLLFP0a2Lr6
eGSBqQe/2PdwcsmkUsOnXh6hp3WFk19MAKknfr0yVsUHTorM+m+eg93E9Yhm9dXlhXTJm5FjrlTL
YqXTCXfUWqBupjqrtyhnzs9epj4D5uAlRXqUieLyehQiC9r98aeYzCTrzWyhZtjLBWOXtfjlzCd8
MvCF7stpU2Ewa9SdX4IfiTPe6ZUdKeBpRTNjjyb5yMmgU2jKzIGqkmcJaNIt/9CUB9IFBjaPPboj
XTtuNDwQeeJcbG+ix1vpbdEJBMLzTNc+48ghnQuZ7d02zXmCbJM7wi4PaQhL2VzcUTmkMpu6mS4I
2h0wsgoEzNPkrUnfzVxfVdkGzu2Pp0K/9/Wm9EDcdmFUYoQQwPr4YBsYNSGWBiOMteNjpH1/fRHA
70XorWhbkIWbo4f2HTWRk7c4pGdfWoopn+vrcuzsueABCesdseW20jhowz8hO+O73V3AfAw0k/4Q
b+SVr5aFJqtXWz+8KdAA7dPn04VlcLM/NnOQkaDK0zZTjo5ycbCo27cJ0xLfHZH/5pbidNggtFje
hpneAfoaksJtOEXwDOyCLCN2Oyaf4oYmrCBeiidqePrKXKGyUHTKfACXESiHeDYldHZao7FKu/bx
C7oEj7jaUHV5D+M47tqKPX2AaMJPLmHVphX+IgSaMK9cyXcG7E7BFDjBFG1gMTt/GeXqRH3L5eJE
gRpJomwMlcjWN2bh5QH5Z5wTBhrbFv28fif0dLV+mPbpTXfOMWPfxH6sClJlhCPqXlQ2b8ln/3uu
WrHp1L0WLVEBm9giJkOmLFCY7jAy74ihYQPhJ2chKmt2SAP9BVuheV1jBLhMGCwIiA6lRF5o6M3W
+MuVi4TXENrzfjFkTUiPyASwTimaZap1Am0XG5/Bi+MTX5vsILQDRvNSLH1Quu2HPdl/G4/H7kiG
1Iu5ZOrAwJy9+Mbv3A9tLxcCidc1T3bCsFNKuo+gxTfJxMEgKjmGiHvX33+dQUM5E7T73UzQ4OgB
4y1jYBH1g3vV+jXPmMZd6EJcoWyP1s9i1eahFn0Pgci6T1ml86ccdzkuwf1HTKi0/IlX0zJmcC8C
79GeGSbBDDe2iZ37um6mDBgeXfSDVRGCu7O/54xR362RPW/vyC/ZzJHf8WS78WZRLHKfrZ5n3rtn
W47EVL2e4hXFwvPiVJ4f82A1TnKp5xfnWucCsywrEn9i6fbTnb10soou52W2snsGNdtPA9+AJh51
vDS1Txlj8+p7nQdfCf86UciUTyLHoveaRmd+aOwFdNH11AtoPutOf6jg7hDLj4f1vLIdrjDoILqR
YBjIL1q2QSljJcaZvtE9C0AlNCveabplsuHJZujgvtKfyLngEYOiUfeRWjBTRc2CaQnUb5/KCxCu
FnylJ4DdWgfeNS1MYOd9VEyFnIK8cSJmqUdVpo02D3s5ebD8zO9nFLXPQfq5YiBCMqe63BBa0S1E
BHkK1GBvRWf9/pkShTrx+rJKZQnZMlic8IgWVjf1oKTuPqsMyHzghKST+zjREQyIQImee8NNxKzW
hXdXB1kFTvwhAABSrJHswoBP6nyut9iU9dlapw5wwDx9r9W/9auNFndfavj05c+WKoV0XrnZ1DM5
JVpZWvljNqmpGKiHyav79jr7hxO7fPoXFSXjJDacUGR097NvdiKU8vygGNtI+T/WEFkUykwF1dMP
PmHoADsM5NwdP763sq4rRs57ZHjTNY71Xt7cmtiNlEJix283mi1A75eGkODOyzIxwgYJiiZXD1Yb
70Yrq7mftQ3iwPEb/4Cll8sMUtpky/776w7JC0cL5/521c2kk9YHybzPuB7wwoBvFe2tje9BnOwo
kcKypNFzOuXi8FlD+pOZ3VPOSACV7kc1ArragtHwDVqsHiAXDpe3XvQIwZ5f4mrfp0W5BcBrIQiF
9p8vlFqGaEQv71R7Ye+i5bsh69URJYKTEuGbjVWi7+uYJiYLPDTLVvJJZxOdaR0A5qUuNxOyGYXx
ksXmyfg7U5MgdvJgYs3CzICMXgnyK0T5RJUa9aRAIOQesg8/zvAzEkdZtbgkG2fkjWiXIEKw7vfs
5ROSsPyo73y9cZZ3QKVbfzMDlV4gBvsUSrZz2fylYlGSXTDsxzBc3UReGzY33BtaaBJqDX+o/5Wo
E6U+pcFAHmS//jRjtWGMn79znJbhIXsvopN4oWt8A2f6YkMMeuI4HGW1jMDgnGQZARXtRr1kkGPY
6lQnh5p/7TgYJKBNHoAs6OlvPWZ10jshRQpLoxpjWN6kvvZrvpIxXVXeTYMgSi/YMHfCz7PXKZ/D
Q60sf/5KcUaHGnO41q1A/sUWqjK8bVBMj6M4WUgF2tll1MuCcEB+Dv2oLHbdFxXlPnFy4xxkkyUv
WWhy0pAHRR9wjelk3fXvs6wTirdr0hlduMjvivMGVAzRn/h0pTFZoILFHMQBZliZQPvpQwhVuNp3
MHbR0A50B2XKdJPuTLBAT939R5zOJduFWuvIcgy0jVZEP5RcNdhCCZMK0wkugY8gtNczJ29/nX2I
qLO1As5NQaEF8MEnfuDnPHRnxnX7QqIzdDNB5zM8u8H7NHcBmY1Yu/URu1rxkRIZfR2sOMpiKAUp
PgExEcYdPIIPIb5nRI2ru9rK308iBwHNgvZJbE14yRJWPKRVgdek2MBwWu2isRMT96oFAi5zl/iU
AvTuSwXAjWrKqWNTLfUXpXFdnvt6VwPpiSIR3GEFmH2L0TXUaIJPc3aiUzp6u1f7LeLG4u4qRqdB
xZ6SDRsoHqoO5sMjv7ypbNzcOIZEapH/OmyUU8eSBD+kPAdwB0pWqeSbqbmDBajbWWx5j/ZAf6fi
gUXSQfmZzw3FAGRdUirgB+5CWXCULWVFXeMCMKaUmgjKP1KAZB3vq/WVcUQVFjhtK96AiI6y/bYd
jLVwfSdF9ki+mbT2ZJ6ts0FzS3C6jNH0wX/5KVrrnMdEsMt5nFdOfsKdC1y4wyC4b+28SlPQpc86
QEFjkeCah8TFCepWIjiFzw+mKLXVdRPsU15/e8iXhu8HhC4jpdhIy2EbjNaexn+l9/y68b/NWafN
7i8xV9i0/ClWMILgAniYZiwy28GshlX30+yD/vdjU14bWZR3mmxD6qqHAm4fRX4E1bjvLP9KP5ln
fR+ojaAyMncXn5ZPbTH5un75+3bVgOTAzbIpMCRJtI5grZ8Iz1fPhIF95XdKsu0iIJJDH90Vz6As
+VLlZh5CBFVjpslBXaKwRTRYR1DMFbBEhdHmqVY0wAlSusoapbL3WHjIzbYIpFy8LlSR4xibjlx9
lB81YW6qsU/9ph1fkb7YRqcHVMO9buTOjp+6qMBB2rgTZC8uwxhXl24IwvtST6onICJuhtNnR6E+
5ZQFZiru5Af29X/4xa04efjmwCopOTf2cXpV24gw3luney+LedRTIwpLm0yp/BRYAazYucG+22Ka
ztgE1h1kXSG5HhUbqxtR9z2sHy/ZijAv93mo67RLVeC/nx/rih5DnFPIb0jHry2zQ+DFo+Kyr9Hj
OTXW7LgvmRnzKuilJFpCePm1f33ORILEp4fAxlBm40BZ+kw3SrTIXLlOm3WdwRtk6FbUnOxEoNxH
24/ahCBUAOy9ABUCAuU0wS2lz5kOHSSs+XcwV+AJqhrwFi/zwBfUKgg7ieG7KL+nUSvkwtanjtsD
NJjDtQQfa2BLPYeY5tZUuI89m65ktEG+emGU62VUUNa7XnJT5Ba96peOEeYynR2E431Nj36Ss8Rk
9jevETtSgNVE1x8Sf/thfDqmqL4N5rlwmIRJP0Ph9TkT2MYMeI8JlGXndLIO7zc1ETk/NvenxxX8
fPKQ/wWVDjnk9fANrqMkOLHkv1DWiJF988YHLbl8gPwXRtPJ6XKmv+PeOtAZOC/s1/WOlhQVdnVH
HEd4BHYQuSqSc8Q0WARljaVBGmQiFq1ahcHIyUAVBd4j72yMJ5JEUi3/JsxsN1Ej1yTkm0G95Nua
kfik9UVeBYgsriQp3Flk57ORZGijZw8EhG5/2LjwPAgQvdhD8JRBdZ7DGJ1mab1XbV6/u0IgSr+d
+z/VA7JDB7x4RRPqIl+8OGaoqbkxRecMhQLFcf4Gkk4nB6kgfWMqTjC1apdPwxiP/+fJ3JgynXKb
XMCDu4vodfxMK2A/TRJdjlZ27DijfbocrarUKmjyuWE9fsUM9PuYq2bTb6UyNsefM4yp04WxRMHm
mrK5kHybElbys7Vksc4sccOH5HJbPy1FJPbW+Rh8Y5TKyB+BQa5O0fR3AkIieNgJQP3Xy1aPjNyU
TRXSpuJSabqz/y6DieH0EzBgFxn+98sgksGcW+4wBWZ1cV/PHv25Fs9jQdW7QPzGDGTmLxLrlc/Y
BbchvbmeZkUgRFV/bm2H++e66X7+9+WBgHAW6YexkOSzTDO9q1W9S7HbZOyIhFxNFk1LFplYHUmX
+MNKShhi8ICSWEY3dNxo//y5fQ43PGpeKcOMMrMP8zH1FKQl1wl/PQ6GXZ2yNJyU5KdpzhXjqDbS
q+4q+oAm0Wer/LPS5Ih8FF+XTKBFRRgRLKeP+Jawld9Y/UJ92TppbGRcbL47joFf0U0x2twVxFSd
DnpIWQRvuSbI5CNvUkmVfCCb0GH2uxszqhXw8ftfvpJ4Ra7Bfz0tTKOuxEhA0oaBR7Rr7t3rO2yv
u1V1knKnbGB3ekkaVfINtF8iCjOyRWGBFML4ncLjbSU7ti7cFHM1OKA3uudNDfFZYa2dOQL2zwVY
yTEqjnbTcc519MaVxnfd58DNHfOPhtvM8oCDDBIwTb2FZzBFdUn+6wgffKVDk7oK1reWb+VXgJGB
JvYOuaanbCGQXHg62hD90m00TDGSxI0Dsb7+FM0piKpBbV5d9Yp01P8/j62A7DdErEUGgjdYwZyW
A+X9Ye4iFxn4xbktcon0BM4xZtO4jkxKn5If1xSbuGsj0jpBbW/ChmlMJAAo1levrFUeShHpgCAY
RKBZyDo71vaMg7oVUENULq5/Wr8vch1CcoXEAIXe334s4RT42MXnjoU3PmL2X4/E4gFmuIqZ0rBj
W4+FLtVTtJvE96QH5oAsUVVb7e6lS8YQ6A+IXVbcSG3AfJaxL2A01bFsPZklDyB/D68B89qMTve/
5h/r6xto4V48V+cvPQKkpuQy+R3VZcstTtwbMhJMvIu3GDcbCH7jemvoeqw71dNvpSCgMo2Zm9M3
5Adw3XIn25QYGvbwwdL/zmcXe98wGmw8acki4fwr6XkAl5qq8ucZuy+Ho1Tf43sCl7+Cq284Q8jT
YhSMv2HbYI6hUpqhXJnls1XIeGWjVCl5UiWekmTRCpO4/UZO9gDWvWHgzTTRk0ae0LrCvIrGQVlJ
7nsPtrQ75IMJ0W1SWzWym3JsS1t0Akzffi79O0UUX+nFNp55sbOP7yleXI4+hiiyKUSB8HyebXP5
eBLgK+HB4NNmSw6NkYC4N1MAKOTD6SfAZ4/Ylxsfr98d8szlNAhSw0/fNjldz7qF7rX9iEsvTUmb
hJLEzrHZVErB/8gubP5bIV0ztAVAHUeQ2d5KbueWe4W0YEMj5fkbGjRB8W+ktBevDop+xh6hB/hE
0DhIUMLkd4gqLjnLdaieNs1N9D3dBrt6LAZu1bUjVdHXteiW3oe4zkPtqI/OTy4FezdMJCxzPtF+
dr0jNKEhJvyRONWIdraDrKxrgp1MZtGjoefQ1vuYhdhTOb2zK5ILsEBeBViO4f9smwKLXXnoaA6O
9/t4MHuuPOArQE6o0vN1l8bv6Tc2oXuwlPstsc9tx2utHlaavx1/+unpjsfhGn6ICkmu8COHgYw9
wzE/RkHW9+sfJBvq5s08X6fOgCY=
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

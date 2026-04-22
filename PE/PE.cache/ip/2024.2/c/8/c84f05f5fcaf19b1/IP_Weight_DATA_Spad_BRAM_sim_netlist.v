// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
// Date        : Sat Apr 18 16:59:45 2026
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
  (* C_HAS_MEM_OUTPUT_REGS_A = "0" *) 
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
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
9TEcgglu55s2RMIx0ui7blYSi9k=
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

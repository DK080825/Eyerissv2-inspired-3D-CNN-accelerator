// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
// Date        : Sat Apr 18 16:59:46 2026
// Host        : Adrian running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim {d:/Eyeriss v2
//               Accelerator/PE/PE.gen/sources_1/ip/IP_Weight_DATA_Spad_BRAM/IP_Weight_DATA_Spad_BRAM_sim_netlist.v}
// Design      : IP_Weight_DATA_Spad_BRAM
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xck26-sfvc784-2LV-c
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "IP_Weight_DATA_Spad_BRAM,blk_mem_gen_v8_4_9,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_9,Vivado 2024.2" *) 
(* NotValidForBitStream *)
module IP_Weight_DATA_Spad_BRAM
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
  IP_Weight_DATA_Spad_BRAM_blk_mem_gen_v8_4_9 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 21776)
`pragma protect data_block
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
rLg=
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

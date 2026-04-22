// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
// Date        : Wed Mar 25 20:59:14 2026
// Host        : Adrian running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim {d:/Eyeriss v2
//               Accelerator/PE/PE.gen/sources_1/ip/IP_Psum_DATA_Spad_BRAM/IP_Psum_DATA_Spad_BRAM_sim_netlist.v}
// Design      : IP_Psum_DATA_Spad_BRAM
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xck26-sfvc784-2LV-c
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "IP_Psum_DATA_Spad_BRAM,blk_mem_gen_v8_4_9,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_9,Vivado 2024.2" *) 
(* NotValidForBitStream *)
module IP_Psum_DATA_Spad_BRAM
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
  IP_Psum_DATA_Spad_BRAM_blk_mem_gen_v8_4_9 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 22768)
`pragma protect data_block
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
mW3hQKYr2KdiFiLoTuiGWRq9Vh4agKbLfQ==
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

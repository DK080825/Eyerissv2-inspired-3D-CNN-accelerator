// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
// Date        : Wed Mar 25 21:00:19 2026
// Host        : Adrian running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim {d:/Eyeriss v2
//               Accelerator/PE/PE.gen/sources_1/ip/IP_Iact_DATA_Spad_BRAM/IP_Iact_DATA_Spad_BRAM_sim_netlist.v}
// Design      : IP_Iact_DATA_Spad_BRAM
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xck26-sfvc784-2LV-c
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "IP_Iact_DATA_Spad_BRAM,blk_mem_gen_v8_4_9,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_9,Vivado 2024.2" *) 
(* NotValidForBitStream *)
module IP_Iact_DATA_Spad_BRAM
   (clka,
    ena,
    wea,
    addra,
    dina,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_mode = "slave BRAM_PORTA" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [3:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [11:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [11:0]douta;

  wire [3:0]addra;
  wire clka;
  wire [11:0]dina;
  wire [11:0]douta;
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
  wire [11:0]NLW_U0_doutb_UNCONNECTED;
  wire [3:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [11:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "4" *) 
  (* C_ADDRB_WIDTH = "4" *) 
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     1.462048 mW" *) 
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
  (* C_INIT_FILE = "IP_Iact_DATA_Spad_BRAM.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "0" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "16" *) 
  (* C_READ_DEPTH_B = "16" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "12" *) 
  (* C_READ_WIDTH_B = "12" *) 
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
  (* C_WRITE_DEPTH_A = "16" *) 
  (* C_WRITE_DEPTH_B = "16" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "12" *) 
  (* C_WRITE_WIDTH_B = "12" *) 
  (* C_XDEVICEFAMILY = "zynquplus" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  IP_Iact_DATA_Spad_BRAM_blk_mem_gen_v8_4_9 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0}),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(douta),
        .doutb(NLW_U0_doutb_UNCONNECTED[11:0]),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(1'b0),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[3:0]),
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
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[3:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[11:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 22096)
`pragma protect data_block
itp+coeNlM1olkSf9/gVwxzPar0Vd5lRGrW0+s8/jHkhO0wgIKBxhE/pDvkPKpBiaClJAip+zIQb
dF9YGzfwJoO1urZqXNSEEyWswhl5ZoDDbEjKMS5CDm6mZIodPJnhdTE/w11ggsCmLVF2kbaV+RJT
yG+6+aaHQUqL04D+8vUM7O0m4jDMAniAD3fBRjBv7lsVK3GzOxHa8t5WYHYm3lQBVEMgG+9uqZUu
A+2Q863BnF+n4hXrQuy0RepXALfpF+/4DwiEo4W5O4ZPjnfs3/AYmR5KFicb5BfoRxDauufivg/v
Jk7sDqG9RsjK4CopsR1jwW9KQ7MT8FXOA5IqnwXKhIxvgtNFJgBHmO8jsxA2j2FZhIZbIe+QHFzd
APA1IGq6ERckPxXEyXfh9F3tjDsg3Xy2PoiyWgM3HoXu93l6msKgOtsv8O8DPa48mEe2txJd398p
3dtsxcU8rRFHeZWEtPcOgQKkaV3GPAjOIH81puAezq+OhyRAi80PQ9cFp9a7C3c/HpvVGcQtpvN/
Z1KfSRd0a07fdsYno0GyTbHcGGgHn0xvHlRV5PrGGHJYlxFmV2xeU5G/JuliHXDQEZqKsG+TFuAq
rKt/YQChwPolCeiGXbadGsmjnJTGhqwCGLAVVlZSl+SVjNWo+/gj0dDpX+RQkc9C/E2OXe1Kiame
xRKsfHL/u/stHaALqehYWg3EF1SNgt+JJFw+YQ6CW0ZXtkq7DWhs0F2XljgxCTL8Cw+MplCREIHJ
89uihd9ie9PUxVsbIIatH7PZsuRpkhoP7FeLj6guo2WvNwsvhCdU+dlaB0STBrJBGHSt+w/jmKBS
e/H4TeDAbXvB1h0eUwp3QN7xVp6/W1VSDqMq0CYdUmm5fqYnGK/hZ6Uj60v8itvIUBTAgCpaXWl0
2NSHWb2Ql1Au8IFEI1G3kDWrJwxK8GU6UQFXHfPaIys0shSZBZEM/XKkMP2hG0mGw2b6go4rj4jr
SOiMNHVzho1Af36baowJse7XdzrbQwt9QRBsufl2tK8uvsLOs4UKnkKEBCvzynNh0C0DXfZlSRjV
7tlIpunt7dYVgRo4esMJwIOr02vIO7iJCPYH+2rM4wzOi0U9K5dIVruircvcDfzV4GM9mVijVuOn
NhDOZ7ui9ksFpAXfPsVeZ+A4a5Q14k0bkZZtcy6GaZJ17av3Nln3wIKcEy6aT/mFhcrd8tcRmCsq
L1DeM40l0NBhgFTDBgVTHD54XVAC3w3KaU7lJepUVkgov9DKnYXgBSVfrkOs7XYI2LJFUWcn62wO
y0pl69RA5cL1BrqAJbQQXY9sBKgjB4MYHVIT/usFbPv9kumeLhZGBqRTBrweKfecXgsfojZu9xD+
zMLXJCgPNXx9JSG/khBGrh+l4/avDqfy/HnZOfR7BHhbBP3/ySReancBqsQ5HyL9Kd+Ntfh/BueT
kSX4Mhy5Lyh8QyRspGAjYE1+gXBCivc6gB4X3uGZXJgXw8ngXxTM9ksnI0mgJW1cnbsS9EJdNkS4
lsIhednMGWIKdPiZ4bumpkJpbdi91rtCckZgifaBarwqU84/LXl6JKPScIFDVFjFvmimD7hQ24c1
KL1Ku3fIPl0kLte0CVei/drTcNQk0m6Geh9UcP9D7bhGRZNMsLk9CTz7QhaNuWcgncCRRYb7vjAN
C5zoq8iiMQLZXO0RleGxSXsMMMNTmbTAIQwKqJBe1Uml8QS5w+SsV+8LKpPgRBR0RuqJ7rF0yBFV
brCRDmMjNk8TjPjsfN0RX5DZyCejeawWkysT7mkCyvfe/Zki2CFRIcnTQKxC1YQYkMRVYDjH4zvp
4XGjLFvIQKDO9ZtGjWSKWwbXqFEv0eKJYJHk5zmWqnjU4jziDKaM7nr783SaDyo8xYE8+aC6RUjS
XboaJxocwesmy/Y8SY/aIovJW8tBbPiBCQodFJ5IkFvQwkTYeRyKDRwWyozMAv+HmSC9tHONGe56
RDE8yHh/TWUgvlZkfbt/2yClYR/uKiWZjT0HvvUJoISDwVcaMbSPUwQ7A2BmpUdKM40kstXtVgC7
wFDGWkuYXzlpUQrXKCqS8uYFYimgQOTb/BEQ9oJNe1n4odK7cRP7v1+kyM73+GzdJx2d5N9kCX0Q
cUZPlaBPxKn1nuoOuJDzwcvt9lUtciJzdBtEOF15cM/9of2rFhj2OJSkNDQP9+BVLCg/JrNziYqR
Q+putWD0q7iZRn6wZaKzRWo1TCu2FfnjtxbC78mGdVGeTB6Sja5OObf3ciisF87xx2KYDCJlvq5X
1kkhCAhFqFQmNL5FBAurOWqz2nQUtMbSPtqgcX2SlNfGs6POMQyag7V7MjzKYqtbw5Akv7pgszLx
giWxhgKpW9vrRUwfMLVe2s9ZeZ8eOc+vQPMdYRhVczuyI3PZ1rOlpjtArZ8ZzD+2xpiVWsCOExHu
FuD29pAirI+S5K7Y/BJVwF4IbRFlqztUzBuJqBlP3a8XcH68U4ozCUCfJMQGQKoQdRpxgQHopm77
PVTUcGBnw/rbYLhgjVw3rfjltHZL0feP5uRL78UOFBiRZrXbEFvGa+ITvwc3336dohNboSwOhNbF
lkDbaowhuInjNcg2uwVGM69vPQZs20Ns7jEgk7AZ7cVZVlsiQkqDzAk9DHgvklcu/DXUdb6p/53q
PFdiuKSGzJBjE/HEzqm/Ic0LGSZ+cjFQ4BI+da4rKbfyZtjQv+dtd1lb54T4Stft4h3E9dCBNfk1
WpjdwUFcXFtCfce6H+88ncUw56Yuve/qXqYFtC4fXpLTuZprDn2//LsroJ5iDK48c3K7o46zTVYC
v087x90+hqW940We552+NL31imMzv34CW1CCDyHNgc011C1RudiJoHXd+OK6pM2ZMSjoPhlLY65D
L9rlZ9QDcGm7py7tBPddrLJR7+GRf4540XY3Qsx79zf9j2CqiWxCYuShIL5h9PbEy2OJvuRcVUs2
5BXjAlOjREzFk59pttAmJQ/AhQhP8b355NIh5FTDctParHMDl/zph3X8N0ccfSXfuQzPb/RZLvHM
i4pPdYJkgwVLuArvBE8l+2I5jVpzF9xnJduj0xTf7z1ufUXPgwguZr2R8H9gLOf4t2ZNC2sY0zkv
4Pk+cdVvPEh0lQGP5EZZFz7Y1L9x7zDmqX4D0cshPrK6GpikBK06FpE4G7eyCINhobPhXDZUsrxo
15cxYrN23n8PQ7MpJaJF9OzuMUJwUwcWdq0mUtK2IOVV1UMCqr9wBBmn4NXtb7qvqZUXnw9o/ak1
cwqlF/y+M1XIiVekTUDyOo1/vcGB8dAktiwaGH6fq0mAYwZgLFIewc48MxsU8Hn6lsTmWvY4Wf+v
DNAl2+RwQe2Xghi2AJdMLsLu7dXFS0rfRagxTNJ4s+5iMDbxV8iyNWiPIt1J0u6rqjGIK3p6azqK
EkEQ3g3u9yUz8/YXcVh4IfKV03TYmF909HzbMYLhxergOgWdseyEMjBd4LqgZ1wJMJHIYntyBk55
y7/AEhQBXmUoLXvBd7jaoYB7fSGjt0uWTupkgnx2BTGhmOivC70SMjla0cXa7w93W2FMlyHy7lK1
QFUyicBX/25PFXntJJW6WOpVlW0lT8YSDGgRdPzR/kKYUCnn2fHJLWyYD8/PdrKUk9uHlMXqdEGy
FDcEvU+z79MaqF6ql52n89Cn4Ii3ekB0IY/MEhm9G+FSbAWDnv8koJNTFkWApgbuUQs3ZMNjRu51
RwVxdGfPJCi/eG3m0Xe7Ro9c2gkXWXPFgQovqXLzvypCAYc4ki2lVNOD8/kcBLPCHXp9nPhusLE8
U9YGAhsaE+LtrxGOg+NQk2eOkRgfAIYUj8GuQQK6jzyOEyBF8uJXlr1gTW2EPlv/ZWh13mJc7XjV
F1X9bwvv8lrtrzhSa71tbtZ6Pa+dnEWipRyjwp4r5Jar7+W+25JKJE3NpQ+RW6sFVZ2DcJ9ZHA8D
WlqToVzEYRFi48RcZw0wlJz/PliWtJZKymlZ5v+KgEeBG14R1tDQM4iLnindjegl0KhTGsCMaCFf
UGHAoVNJopZJcTTB4TA8ozX+6n/0a5HojHVpMov6IZBA8Tlr+ucyqM5akunMONQAEQsVvyvkZdI9
4xMuLCLGJedLgLrChPs83392Oj7iwa92nnry67sDkOYs/hfSSZwgLtBaPpTrrpkQBW3nEQJgIjBr
XPunvQFuXKiytydRwGyAyqGUvnYv8pkyzHhz/mXDJMOclL7mNnvh5rH0mthBfuPBVfBLY98Lkhr9
Xd6/KSJrfYif4K9N5OrAtSHK9LXZ42IA8CuE7NNFPGC7+gXar/9ox2Rn3xFcvIH8Oobo997a0a3w
b75/Y8Xjj02ZhNzgyesLAo0u3ywQvA+5JgLLY8UhX5EezzyeCsK+kFOFtvp1PqPZtfXyaBcO6qWd
q7VLNLPyKAQWZVv+KhZluDah1wL/zjZrVCjAWrbJX6Xde/+Up3yk2LqXxWOczQ7jJdgmftyfEACb
gmr2BWp3Wc65kPT3upFftDkDmsIghrU2L/omvZ3llAUoiBKxrodI7fhhVeo0UnDvcrgw1pYGK3Qq
Kku8lSYcoLwk7T3YmdSzF0Rj+HgI656T5dWSamwZUTolSDQrgATfbopPLPrq5Lo/nduuOenS9gbt
96B+27fw+TAIGPWlI8jCD6AANErWZaH6dmatvjuaXZN/otmpxP50UTNPLpb+pnouLLi4q7efWnYx
tcU3OXvJk8k9SYVRrENhy5e7PbymUA0Xhbd4HQW5U7HX2gRLpKPLKKR39wliXD4ME8ABW+zi2uu9
8UJOAxisfiq7MondAGNSFxDOyPNfd1FKqprzQPmbx9EvsCZThmF3efXtEtPk1tQpDrpDr+CkQRAW
tyyosAkD6Pkxy6xiiBEzkh+u+JQiSyPT/ygd4/INo6SYYFhYt0iHl6mxCSH/QHF8nefe9BDKAw6D
V6UVAueTnsUKdn3GTsaJW29fQvANklCPrxjUQA9YLVxx8OENvihqh74gjOLrvcZnR5Ya1eB/6s6I
jeCPOGnnUm0XzElzF5udFCPK5erqjCHV6yqUsM00bJtqwMl5OGK1QgVWLJYjuBAJ5Kx3f0qWL2Vs
NMcViphva7zeuNTSzPpbYxzRMF31iDgbPlIkf1tKfKaULSkyneHgyQOhf1Tf16LIgAaQVGjIh9JW
+V6k+L5iMF99eJaDCstPIxTOzPnuk4nkK4qmXAF296WOQ2P9VkAzXDnEe68opW+3PBHXAWYN9PEH
DmPRO/12KDDHP2cBsEYUiiolWcm0BrRQGPg/0fOtoIwWWTgxApWWxIh3yG2VxrcjGChxFpfzGd5a
Vl7J2Xo42c6WALRfUjaaQ26yq2v/2BNgw97GobtslmRuPvRIgaXMJt4uSBZxZQxp2u8KNX77SY3g
W/QvLQtsYYswbH8IJ+znSnEQgeTIbKbzB6+RUMz7vQ30I8zesat3WSOK4aJZjolfZvf6XIDHZ84a
eBVuOngNDMwF7zkc7MmR5j8OX41jX2pd3hDQTAJ7Txvcxvo95o4EaOf6o3uJZoIP0Ewe4IhjeaxC
r8RV6P0V8+FwMj0D1qLqx4CXV2CV3zrlDKaUy+ouPYk3ZLSc9/MKuyw9EdwgVxIdib9RYVqN9bJi
JnMBQPH/xX1i4inASPZ/Jw04Dk01be5iOG7+nAzZw9RkYz7EhTMSvmenNzcQQSaUCH2erTornbmE
s/MTXZ3vs+u/WFFG/a0vs6jHDjdhYQa2qGVCqWFS9QCkPb3FxFp3dyZwPMYBdaExF7bTbGmGA12c
ri/ur+6PU56ht2QHah+TElPd+2cDWRDUGgHndFzhGdFhBwgnLva+JXWpHsFq932W6bfqZjnyVEoo
E9U1v1YvVauViMK8oGeuvThJamAnkcOh4gee0Qm5LAplSN0ilQtzIKIhd+UbXWiQ363D0k69AaU+
SbWhav339coZr2CTTv6J01JJ2zzo7Blc9KBY6dOQ6zwfbvfsXEL7y39d4I/qDvvG4rZGYXEoUDyA
DqFZAwnX2xIB/ol+egi95GF+JjQh2YV5txvlmfWeeaeyMHvnsSRIJ45tD0oPUf20qI5WYAcpZYPZ
ptuhiKSgVCePawOlg80CdFlS7ieddOdY2hN8NDvxFYisacrVVfLLsvFtiIUHhfH/N964630H17O+
IAYsp0Do1i+4MDbjJa1uVb76smaGhLg/eIzAA3O+Pa/rWBs92tjbhh1vEj5U9siswYvBM9keKMEf
7+0chyCph6485D0n8auhF2dBi3a0RKEZVg4A3GxZaR95B95P0R9PTmTjpL14pYEnQRjIC5EACvrd
HBS6ptRhdZg1q6jNCHNqGoMaeOYxyup1vR8OIBAIkXyWZJ86ZbGqc2ZNlxOnv2r+gEx3LQw/89X0
G+nIGXFcSNPs4b6L/iQOtOmRq6YjXPsAhAlDNYybOgOVWrr4JVdgMvBKkkTqUCSnq+ivLkwBhV8L
Gs9swK3zCi5NkXJvCe/HuIEjftOsDpJGk3bAFOG8ljZDcFaZdgPjYFEoM99u3cSoB2mFsrYout8o
9zMVd8z3FAqeoOzfYlIwTy2b4QH76J3yUnOwOlKxtpEG+W/W0t255YnfropU9ELeNwWxAVOHnt+7
T4I+Oc2abgGRbYRkoTdyaHPC4g+BPK9yg/pSEofF9I3b3omSC38NS98e68i/F5qY9YK2sOLU8ElB
xfDyyBUjReQwQHEeCHPCLrksqoKrWnB/Ckk/CyH7XsCvoJ3Kvn6G3VAwvTFzHtDlOSNjhuJx2LMw
rrLs04Cv6XD2M1SXy4nSbQqG2+dTIyTVT/3Ru09++gdIQ5NW7gqNIP+wTbRs2q1HIPkAZKbyU7uc
GXkKV/o/EU6kpClcyukFoXHMUxDN/Psoq8dzSc0DntdkQfGiP08Fv5NmaLBqPtf1paSNxxgS2suz
oIgV38aEz60WeBepPKsRaoxq0F9foPAoDWQySf3KWFK8VWGhd51EBpZbEiVwmLNEbvk8quokaHVu
FdhWKIGqrB5USt66sod2y2wzo9X0fGcCHVCZL/vCVIlFDlC3y18o5JxnN8uXJsMcvYUPtjLIJzXv
vR32OK5uILv+vDyjaRnMYz4zKwnm2f3jcpzyTE9QYdZXIy0rlMGxPpiP1tQGt2mJHhV0j9Cx3dLJ
lCSzmp4IpRnlbjpiohIHWSzIleA7bPW4/+cQSo9J4SgnRpNXF2vajSKwMwRokTCydyOCg8LcQsnC
AJ4jJdRnwyIQsk3aefE36Q+SB5iXuAWep2AOtbAQJ2Flq9oAKiNW986fiCbTbweeOQeZM+phefK/
PGA6vw9EiSLVzm8feWhzG7j0yZZvq/y529n6/jG8zZ1prHl1FJ+JNP/GHPok9PuIW+mm8jo5Us7a
9k4/k8BFcsS5lVN8jm6seuQTq1gYj2RGlFu91KlMGMqq7ftgUvQN4hf3SW6G0kXKtbn8S8K1v6m1
ujO8bxnSxfWHfhnSyJKKRHZRbtfeZPvFu+4ria8ou7kIYQZCKnfxZXKjxBX+cOYOB4PdO0tNbmUR
Wuw1dagso9t8Qa1GtWeCX1mpQCWfHGEULq8T7SDJjLKMF5zGLQxZKZCACpMRCuE9jznrt6lRvkV6
sYhMNCzn3LS/0RPHJ4e7+X4Fj7u+hJ+/BIEBepO+FFiOmeAg2Tx7q9+mfxe8F+h8vB7reeOlElra
AyRhr3BM9OCPnyAsHk1Zk+QxOK4wLAzqtDHcE9LRjTEerBqIuy2AiD3AMgYGMsYzD0mx0K3dCRAU
j26Cr7UKX5qQuiyV91FiVyAR23AUfuQi8YsQwSXRtgEHEUebkQDZtippESFyVx8mIL5ZfH2diVsP
j5RJJ82UCmzfbsFYtzqO3P5f1lOOq2AVvJCbPNj7Zot+3uXHlH1TWDz60jIzqenkrZMm1fk3Wn/K
AVUxsplHoDWaGEa5TiEfF5chCuhF0Ovt3CX9fYDD2isO+QZ0S6YSkZV17Z4yQ+DWB76OxpI4PZ0m
KeU4YqXFvaywb2TnYxPpQhTNiBICMFDPtf3DG+vJZSixNT6AAdXAqQk83Q8GIt0lT8bpyMY5t3rq
0D5Lc+1OvI86CYPt3KLT3JpmezPT/jcOsg57uduM7oW2zVgR5scpx7Ip70QDWe92agxj3VrVdEoZ
6DDQE4oPMiehIq4zXed6/IrrBVSEUGm3nx/QGrR9krvRruzEljs34zfOUP8b+FDJGZPvqFCLcGwf
lAHgdhq2ZRbjfGasl9PANtvuIFazErSbrjCWEiHyZU8WHICo3SWJimpPepIwW78+zbIUxhaH8F26
ayhrxQbVCWYz/ye8ylRSaMTLelb0jQovORRG9QXIrtUv7Z2CQ6VHL5s5hwD094R7ep2YQThzjuog
KrsqOLVsXHddRHiCYK/I+qRW3xO9UKYDNW98G7UGqui3FyvXojS1YBqDHGKSlynAFJl+tRerhNLw
mGwhPzqdtoW4iTpOUNgURWKcLZAT1JiuZEm359b32FRjhCe+Y6V6tntJkUIxcvSRyRK9tOaNkHVV
sjg9B1SeilK2te6l/tlooQ954iwVa5PZ05pqQYmLmGjEjrpvBqnRcG4vQ5lCIpkQ/MVG7bXkKfFS
D+ziAX7catC5rQqpVgyzvIKsXAWVwgPiGE8QlmfJelb7ecabQfz6l3tejodLZ3mYKlZ78KmndXnR
GYxVgitySKk9mpHE1xI662eC+5cG/C6eiSJ3vEA8glmBfhO+oe+TLaFeh6CbMuyTwgP41IOw0wJR
W84vBbSJGGpoKYtl0bKt3k86WTGOlCd/OdNC/xzhX5KYpjB+WqBkQCiVuS/QcCxCc0SoqH+4J0Ij
SbqZZvGW+vuCm1PWzSJHXebbqwh79Rggpu1gCdl0ApjZOhJ/MLNAHVDpcA4wnUqQb/iVk/N1ePIs
p3Q4aCys2Gx3Z3kMmhM+Pp5v5uyqhgLgJd4cZonRMrA5nV8FiTa0LQzIn39ZIUH0zCm89HIQTEzr
wWuVugtP2uDc6r7Kmkyk8to0GCCAjseYAxRQWmGdsi/ZAkJo9ohcyQOdVpp0buh9tJ6gcXNwr2MJ
QHq0rniXTOgs2XogAVydxIlsGvu5RRcHT86E9OisduMZmRL/jJiJPkWrWYcYzbydWZVAKhyutn2H
+z3Q2XgjKgPsvcFfy0QlzIjEXgNEmdDRhnpTnWgr4/5VWo5MMrgu/WFt0DiTNAPygbWZBTV+VKT2
Gi7JYDdNSpUl9KXtjvP3dvdJGmlGWRxnlRt3PP0BF7dmje9ZciZTNb1tJa7/i57KnbZ7EsasN0vM
3TRnENOu89uNhmKVHnQqKhhs2YqyS7NWFxdKdKQEJyA863sTCrRJW6Ju7da2RHy8IDbUg2OYoW02
ufgp0lM4wmNXGF/et6dOT2ekHYYzN5e8NoCuo8eqYCa8WREYJ5ty8NzQcFuO9tAwbAGN0c2BCktM
6kx+2qdNVuPD7g4CTbMstQQJixGsvLb9VIjEjBV8cMvEZeHB9m8J7JQribORv7S5u+mifXp6Ap4o
ryqbVADi2G77M8we72Apt3YiAXP7Kyb5BVBFnPKKuSBj/J3ONL3xaMCOZFzFFBCR/ovsbQtUlr5a
9i4P/pp6gnZ1HE7ej4XPF/7mHTC5BCzSWAE0j9IbtQIOECpadlf+bcM5TIF19x6RMTsLEVr79HxB
hFJzXhf1r2ikFs+O+etVARS28fr0P5IVjDGjlyRTZCNy3Hm6ONPG8e0fF/wnKO+5YESLYxheKgad
otZB6gDNd4LtjLVFPgA+V5+lpCCYQwyJ4GyKpZs9GkyJ5wzQ45eG278aPkFcJk6ONFUsXILv4lOF
4Xwco6wasA8EoLYNh08kxeA4MMvmzkEuvBIWIli3RulqQtUhIjNC6AvqylzEmA1PVfHSwHPx0Nu+
gvx7tYTDxbbcmAFA8fIYIx/+wHtGdyZgDnyE6Jir2MiE1QzrCtFYUJ16HeZ+MUGH08Dn1DYHWpKT
qoWN+WVu+0gTz9/ASc4Jmw3zrmwkwzatgvTn/Ao5Wr6IxdUMbIfgTC2KkJ7UMhErgNw6JNN0TLXm
WDhA/8ZcIM/Ia8kjhPJyja4f77btWZ2wpFZP9oDqxyNjJtDs61vGzO4QlGy56fnTe8ddiNGwmWGO
T3RO+iHzdLSkQhkyrhRppIWSsl1K+Xg1oEGfDP8YZq2DIeIzTf0FRDVVdDU+27my/BulwC1MWIpg
uBKAkFGYhYuifiJtBiGF344k6k9D3/72nNhukB6FUpbJTdx9X+oUGYbi27ziYKm2ObPah+NPbINg
vaQae4g/xOj30PraDrEweOXhlxwfti+gN0uN1Vg0N1/O0vFmQQILOB7gkwK2cbr1tCHWqxJHlgpD
21B6eod60RTa2ElP/DhY6Y07uchGo4346Si+iaNTlTYm1nWfGOMU+AR2S03WF7ICiPLN6GxULWfs
/aFUQWwX1zWH2+355o1X5DVTDXg+hNDGYr4RqlPwqZQuGB4Xj4mnpvBVJV8qTClt9zrlyvl/X9db
e26i08eA9Fg8736U6iGINePheu+fWGlToe1O8QmhYGVPLiHpocXlFsQM2njyW8ndtGq3xqchkF67
H57FNdLd3L+rEfIRtXEayXv0dii94SMTyk/Io8ZJjLbxrCKKZBIY7i208qPM6OhTBA0nGtfpm34p
b79kc8s4fYLNYC4szmB0ureqYcp27oSexeM0T15yP/3bhB7Xh1XsteWIyfE1JiqtJHwTmTeDQjbs
pf/Gn0EszCeTs17C86XJdbm1DlL5lRhtMM5Xzd40Jkv050AEjlVLfF5ayFZSd2M31PxJ9kO17QM3
3SuxWYIKiRyiBqBPZSnOfZiUlIvAFtagdMFqwoRmS8dSk3BByLaCwpcEEz+cjvopdIkqMkoFrTJK
/M3qk7lzJk/xNICHXldbL/Q6llZ9cmyYEo2MpKpwP+jkPoiKULPIf9LpABZ8o/QWh7jmErffsabC
ASzM3byNBCub5A/fpZdIbyId1w8EsYaV2dSq7z4e2OlNBLy/gD/fB2FjKlpxhRv6Tam8SgxDTvC8
HWK7PlptSZGehVBZd4mbnPaH1V/f2bE9MbKnhoLORcIoZzERLs7u8SO0Ivc0jGVuJECUbskUCdvt
SNaKGM6tGeTVcu1zFlDLlvpZv7c+f42QsVP7WuWsLXMRHp2bSjs+EUpn6aVbdYRygNT8ZwNt9eUR
cZrutI4feA3vJx3XvPKX9bc6SI4TV5Ml/SR4cLYeRzziTsWrNUZHNoqVQ9YDCsZGN/8c/ohiemVf
E1jAMq/XD1+sQQ2aom5GeMUn/SGgGvceMBIX5GBpuVxWjItvIpznV0IWqp8bRWZEYrX6yUNkkpLR
+PNLVix5ysHCymDRJczSepuOgg9oqmCwrPd/McVArO5QyTtRQQYEzPdwRM2Rmb3tdBDCQQdYWw5t
/AXb3K8EWvpgARcyowfy/QmvTdrOZveszEMWP/P/kLRCEk1YM4f3XizGZFrrum+05/3IxmterETt
lolv2Rkzt4MsKEearFzKsWzdUPlesbfShCim01bjg0iDwPz7ZtW794EtQLyO/cw03w57Q2c3nKUH
XAujWSXvjVRdm6sS6hCCNf3A8PNeoClx9Xe98dw1Bl70aC7EPtfVOibHAYyFIgY4VCFeOFH7Xc5L
GvTbP7Itt/iyThrFzPUMhxnbwu91ZYTxwc6hvLTiegMz1XqTJyRn5iUxFUCw0IJKoE9uSCnM1Ty/
B0+9oAnK6rvQKRK6TNzEhpi3Y6IygLJrLF8TFytlUEzzLnBGaUCxxWC1XVTr9exghE4f0theQJ9h
+Lg6FnBxMjPOyxN2vrjJz5lz0fn8Mh5tLZBI2s0xcuU2A/hPtO8Qd6WMgFV3Ryk2Ojk9vJ+2FRXa
SJ9vHksITG3q0m1JdJX3a+W4O2KXnj3CTXeukERtxmsvaLRZrpisEuX0b7o9up1Mqp0z3X2QILsP
4stiNpiqsHbgylics0/5NGs407nDy6AUBTvwtOrWNCGd1BI9dLcP+2+jt2qNtEYBEochwoofXttw
jGRp6fKkKXl3untkf9EhtfeTPvxlmEa4TNr7ZsRj7GSbYM7MvyYykwqly0ncZ3+C7kPdJD7qAdWo
fxg6xPoIrmTzWQiogS1VAf+OqeKF0uQsBF0GN0RxTAbshSxRKBSdkr+2yKVInp9s7mRuh/3Y4aCd
2DQ71vXvigwe1LGiC04muhJg6WusFR52VWSu1rQt3WpoYmVvLrTkN7yWJ7k8iCHPtTdNDHYnzDq8
Sdq0m9M/sfp6lI7OTZrSy6Nk9aN+wxmTmW+Dc1nBdDU54QqoERjfL/4qJ1I8qoX4CWYcZ+6TjuoS
zIp/5lvVx7oW9A6yzXmCWSS/wOFpLpynw7HeS2LEFtn50U7Fu9Vtq5f0TZtokgivYl+RM72/3812
8efXvFLNUIPeEgsV8LQg6LPpj1EIzYLi4ugjREyCEGO7SGCS/NZ7VBefJ8PTopgbhRzhKED95xsN
TZhfkzoxZsZazmNkXGrqR/zH4gIf68sqKjvTBz3LTJkMOW0VFAe9oVQsUxNM64j4ik41JTKpHgcq
4YEBbMMFTwuhsp81z8sA7vckgdRbORgjMAUT1+6Ld8wkGfrkXIU4wPaWoXMz5C5SWnCYF/+j9L+/
bibZfjuvZdfGthySddQ5dhovhup2IP2/+LVZupkXKhTuD69xuavl7VqBU8ufXFtLbEQbZFY+zKlZ
8BMlq2qmy3LD37xL1MJlLm3USuROkoHMbklSnGGRVUFb8/GTJPkGNPV4I4+VP3SpJZ2Y//Rk5BRP
iPP8cxj6Hm3OcVJXaBwy62WVTbyi8ot8W2dA/zmkWnmC/QPXiQhmhFbY+U1FhbigZJOh+50Y01Ll
gvw6Vfp3yz2tRoycNaGCpLdgxTdqtdHffOKCoUXrUiApJ3LQSvJQlKVcOh/qsCEwDaND5uLKfJCZ
c/r8E11F1lzsJguDWoDYgJ4kjVB1zAoxsP2OiWY3qjR3lCpRVaH2PsPsojdHnhQCZOao5QOECLr2
ucrObbwuGsMFJhw/JAyHNLYHXh5yc/kIgLj1pSLN40OqwaNr8Q8gCjvFfhwScTs7b0y1bMmW3eLQ
TRShDZYoteeHb8LezM5XBIxCm3EOjkVEOePJKLYh/yBPQwcOln/Y9LWKgs/t3vXquSxbhA4NYMpr
jPcpxn7r3Vg3wLmIqcX5dSuKr8Y146tRJhaWIetWJxCwpzYzrqr44VEPBhPGpNNEoQVU59mXt+0I
FqfexfGWwdc/TUTubsYSA92GdsU/WUqW40L91mUmG7vT0N1LSAVvU3GZOzAbWRjeZ4kqAAn3I9Sh
SAb4xgeCIgjYLan8EhaCL9l7pFJU6fTc0VUbNQeIErMVUwp+F6iLHf0CgTZvi6cnuZJZ7EVI6/j2
j3Jnk24u8aD5Rhigni7vKDT/jQdeeydxagU6h78JYgEGxjOlNXp87oU2qS2NMsOA8TEgrnnMYTHk
QUwRuLMWiGNWYG1vsvKpvX0F1pIplKDhlpdBtoAPfnFEXZudZ5c7qE16X0qgLAbht/uhBZcC/KSv
iFNXl5fBNUhEnkim/tYPWMTl/5FzcQP/CTrBXPbVIB3QCTVnOyFBEAnlUkKmnywV9/BvZ3buBjm/
fwOHxIKhZvPvCn/HJrD7L3CFaoT+U9a3bICg5e+e6s1hnoDYsD4SrRm8qQSeeKWB+ynN2jdlWi9R
McJcU3egfnsHUcQvneITVPx+/CmEWL+P76IFTRD3odNKXWX8MXo/R+BQfqUh4Py7bMBiHu3ghqIb
VhTSHfD/OWuzRa631eutJqsMt529X7P6cAk9BFDwfglHZ4vgPxk0hc6pc4c08iNxtfTim3EChOUY
d+Bxpxo3azTm921tQJVLcDpIySZFmiEKF3CpLbhdesLCOMQC8IRlX/qnhzgYeBn0WJPrJf/F/jP+
XCTbIjYZRhXNfMS5eQdBMqjQ59QKOUhG+kJ4Jr4QLJX/ytGnkk0jEuBmTFXCpce7Qm2YNQkD4Gpt
pWcbHK9NngIC/HaaRyclXZrHKuZElbRYQF1GY3+MUqDR9zqAyovHt25CpGYwlW2AwU3GX7CvtCeM
UJi8DawE9OmmjVDjzHfI6KTg94o6+RgBvhLmePLeo0rxsfzEhXnfXF/R9KwD4iaj67JKmATgtRbx
nGhMkXKG4mhhU2G4onySO+dg64vv4KkKj4OnCKFw4gYjmaPsMRWMoq3B41SxdxrrABBvQ/B/UAQ9
fGRC9ae1+t3Tyb/bft2wdm4n00S9zIaYIVURpvtF8O4YhFaH/YNXPTgIlrgqH92xXIQmCp7sCIRr
endsB7HeHvFemz/ptoKAhG7BUU+qe0Nz+XQ0KUMzodSAj3Fwks7hSHLb4e7V0Uwi2ckB7OQMRcfM
lp7Ysa7GhOiHPp+uXDOq+G19JyTk30xI3m7twHKdlj4DUPb29N+OPgFIPi7xXub+/jBu7FIdh/b+
rPFCeKvpC6lPIWk9Yva0y91I/lrCjM2YFNJgkE5jSYmW/DLmeOypKtRhu0A6lOZ+2z+ooNYGsKnk
kQmQX8ezywiGNA8e4/rAxRNCpP5l5dGZV51vNnJhEeQ5UOuPOAR4xxGImZmqYH4VPzQxuX3pCJCv
l4Ef3fgtQpnGCWCMcknv4G/2s3//VCM9Hf2vyo/iwOt/Rzlou+mSm6ffzjZTZIfU4pcN8bZXYnNK
eVNPe+Xb+Lg+z1khY8skVlvbuesx0DJT20qsYTjJvfsTolxfmE1+ZgBFFWCbNl7hAeElR7vYKQQR
s9CFsUDajhCC81JdpMunKevEgwAKQP6QSB8KA+ETlew5IviBYpt5rXaPvIj8xVA/cZD2/kuDYSsF
Gy0+bEXuYFl1PJiyFZ9ElErNo6HQ4SkeXK9LoYRcPV4rKp80yq6YTNv09ukbj0bADf85eqi9rd9b
WmkyPBXTlZ+N8bed2T5nUXsDXsp7aWauWoZu1LDxpi0k548PkmRENokd5EQasvT9zraxtp9TCl6L
4IhMtiebgA+3N6U7R1Hiv0phoIepaT7AlG7rT3rjZqCBxJSRxWnEC8RPXsYSTp4C5gB9oLbxkIQU
e6qJOzhJIe/AfA0Ewc9gxfuS6870Y8uXrQXPKxSz4ZAScNsNlm+QMteuVwRWRbW0NpvvZFulyBLA
OAXh27Ur88aSsSVzOVeO1k/KOq+P5QTJ0OflhJthkz0CpxEDvUT2682p7rNrmZ08fQNbO7oKtqqr
6uvbX4a1cBAtzjBf902w7ucCi8+pfRTdZLzAk3EQFsT6MFRwxtDoVl/E1U/PxXhKz46NucBvR7eO
GuGuDcQmu+tPAdbGQtkrxOYSP4sJMkoNGit1v+4HiuVUD0DVT2Qbt+JbX0fp5beSHkQ+VK3AFm+q
dXYH7x6rNN7AF9dQvzqx7jAKEhrK31RuF/Fz5KpBsGxn1YpXExNF7XXnr9eOZ0bNBctVTGfLE//1
nRwLr1fD1RmkJzKVOI9xXX5MWDCwVw/EmSdm6V9RcmxdaEiqG1cebM4YdivSTN4DagIH9oV757gP
vx8UDEBXlFMt7/VDB8A2sG1JXldrFNvNyfbHmkxwK+Cl5CkvOEcf7RQ9NjgiQIxwL6Ii0TA6y7lU
KDFJdHaCmGZFZiS3OXIOCpNqnYpMHcoFFL+HJA2Hs4kcHgemOG7C5QrIUl9JjuklorlXN/pjoAWu
a6JFuG/bmZmpeAjKYdf4VDwVm+4ADlLoaLeVe/44ZyVDCfna5d6GGYUDfBQ5840x6B5BbGjt5Afr
1A5zuwhtHeNZ92oNGbrYif/hCPI7Qk4ilzjhBpoxJOEIKT8RYZ5obE2tO/8OU9EwNEpXxHV60rt+
7xkdDRSarO7BtWkWmXAWuofMnoGKVPuIQ7an6V+CjOrnt3KbhVuEWKKb4K0YZZZ1hUlj+BQ3v9Wf
JGLwZsJfj+vPgLkApwns2vBZmYV1NluRionw7fGKWvkRllBjYiEjnhE5Cl010HLMtXdUSOFSKZff
0y+zWsscUEQ1sVXe1Ows/zie2knVixkrmcmubqxkhXezWH55TA7xkIt2N6tRN58ptXnxAu2OXzN0
lPf/fkczmVFt8W7s2sY3iBKBEUzsxjdmDrIGuehwcB01crvPA49WfVDMo9TlodqKBRRkY+TtBEXf
9tr93Vy8sE4lbG6uaOuQ5o+MlCPEcwV+x6idaOZdX4nqMePQscn9aN7VECk3RQWEeQy8/UehAiLR
SBIEUKI+wTGxT89ulDF2U7HqXMqDPEwpoYN5zTzQJSYZJUYeB0ldVotLQfoD7WmSRQWUAGBExGg7
B/UlcxBmL7+LGCGWs5TjB+Kg/3xXvdDydeY54H3pG0fBkLtcRf8jZG4Gr+xkAiUaqzzQ8FFXmwIU
A3o+2cRPVkPVcURurcxD6hRv6NMUg9qcsOSKrRaw4jfXQVMbP+QQYbNHMJwbfd7eX7d8+tF2iFpR
kmCj2M1bDUXGNzYBJ8mhA8DcEQW/01ZH9tK80WP2xPDqLzEhMfpbPUz8WwYHnF/UMaz1/7hN2ZpS
NVcc1mqiwPjS0vAr5r+taitKgkm/3xOeBLodGy5FpM+rEWCg69yGMsY6s47P201O6Ipc+ZiDwAcu
Ag7hvTo4DvVtAwwS/nZyu0hK059aWi2uv9HofqLP+nnmqjvanYtoPt0Hlp4FK+ep9a1NUcSLbYBA
tSPJdRlQmW7fRWBdHGSwaAY3lhWQieUg2nQY9GtFpQW/GZ/4DWeKzO1hNt+jIHqzEkEnF3VYsojp
UiP/8v4VMQoDDNRwXH88q7kpqoNFDurcprA9N+M69TWCodIZmUbXHNg3mauSidpu6Gxvix7xRokH
gzHta8cgqmtONrHYfARrwi15vyHQIdNOPDJCV05WuYB7viHrP1iw0PI/+cGQ7qcg7jo8/aP0GWpa
qOP87e99VvKxVLHoseytIs5vo8VG8YulRvrIpv7TQhxVwEhPVC29Ben/oyFkZiHOI0wfL98mePua
3JpgG2KREuGfxigYce5kL2cv4nJdPmmG1ePnyeMIz59DoD3DxzTtMn8Q1r+hKxMnI3M+OaynidMt
LhZ5waDfJRrcomj0MqMK9Mb85s1ZACPxXG2RqMcNvWhZvLck9P/zi8GqZbV8XLq6C5U8gQFsAsO1
XSAxJpPv3VUpfW9nD6CQyoIwSpelEpMhYkgouhJmIIXaD9VWzCV1/0CdNWmQOaDscCB1noGK4Py7
iaKbtKPD6YaIKxpPioorkyEwsumoNPw89mVvtfuPgtpeCX6MKrKSJGk6Vp3hlGsHE0oSvvZZ25DM
7qhFVY8AQIdouV8POy+k1lIWO7EGILkCM0HJsbrR3PzM0JfZj1h0VvZ6r7heiVdV3orEi3a2e/+T
4t815faTdonnz2HcYHL4adHznkv+AlIM/9v0Zk/g5ZbH9JssuPj3gaUWVXKJLH+Anr21DW7kE5MF
qexxZkATLZQmmnHEj6TJFGYcHdcSSikG4YhZIIoaC3llu50HKVndQ/jdKEgw0brZ7+cCD1RmvwQ3
y+xUCGv5laOQ3i7OeJebQmLboqP/YrNv/COfSp5WUmF0jf6aufDrlrGs3jZCE1DCptt7MnZoCWxN
QaxLxTg89Fc/ItoWtGYTKOg30j6jM0Y7GpxX1fnx2mvnGyG+KgnnB+61pZN19Kr0h6fxd1XLVBd2
RHDIWK21pYj2OXfSm4pPqOJvP47fYWmMVeBXVe3aRmv0H1jWJYJjV0WyTCDUT0y6njv9UJBs/YbA
VhY/YVoCboWc4s5s32AY8YY0XA+8MB0XRoyfsVOi2XNCRxlMX4wmQst01/tt/4W7ztBPxxBU6jnp
LSrXcMT/tpviMZIb/J4KZzF/nSbFWqa6KyZdWkdJsJjF8Rt09P5eMdqA8/1qVZwUKR2UIU1zilHg
WS1Q9RFzmUo/oqWcxgI8kOdgMBLN1+k9IvhOO+24DRqMwcf42DFlGWaxPjfMtaUAHhWJFeZeuzx2
fkNZuj8/bINDLLbdcuKygxZjinjhpVP9vU25bhldwibD5rQ0XlFvmg3EhI8A16TkIP9Zbguaq0mp
zvgf+1XDAtQRmQIu4M90k5i46ymG5fByN0FSFjCm8RNTRVJNpWhlbFYKArIAmA9Vz0FsVjfE4+ch
VlkvKUKoY/Sgc7iUDsx3fqwk6dtEZuD95FovWBqcL4ymr4GQ7euzA5tV0YF6DuRSR2luyBIZoRsB
0f1t7ysKYZ290r8tCWpPPNDVIvqC0ozG87CkYlNB3dnley2v47zEss+4tvtPXkuesjxRWlnkTYer
Dkg/O+ayk/9IxnYsQz6mu+sG7MrVTIDWE1+dDCfOQAVk22pIJjJNwYLFKvhIBAu0Yo1IvorT7/KI
SarE9SUikFXUHvNPQcYHasZCv7XUa/zdM19QLohD7sDGBUKlEOYeV1DTEmr6zZy6xOO+q3g4Guc8
DgePLuE78KzQ7+CectTxILIXWak21Muls8wF1kzpRAUKFWxMA9SDCozF3RVjYI+lUTooN74N0UPU
YA7W+fDzDfiJAdVQo4HpTB3uRU5p8QvCfIQgpD3No4MrQZyDGKQSoWNvHMzjOxGEPoQjJZEKkLyZ
kwJX21J6LQ8stFjyvKmlX+eApK0RZrPgaFfHXqU18ZUx7tro54jpjDgzbjVqYANgx+IaOJrN8kk/
E4Gfq9QDXccBFTYW2yZyEViR/F8pJ9+QA6r1DC8cEkPNUWKo63h70vAbRFldnE/A9+lvDSOv8YWu
tDRcFg/TnYv1dpMp5DGpqopIqUs5KMxABD7nzM8vXQbnKqaRU3OM33LbTPgZEdXNc8hDg5hfs4X9
uI46CTT+oWqG9J/XEph/4DsaoXp1KwlH7WRuNcVqFTIwmQr3RXakHP2ieiotNCaVF/+CEVh0J4oB
GwjHZ1VsvJcA/9sgTDT0x21I6qzGO1IAAsIdiSE5ODm1r9cQUWxcyNsHiN1L+MHqGl0xSnVVduSf
PRuFaKxjF44PA2oPLunzygLq4paf80mbwK+MvYPO0xuVOp5zg2SXlgPr+jro3GuK7jI5zoJwj0Co
UA28FABPVABeAZequlk2Wxx/ZvA7RAyU9ivAswC7J0swDSvc+bdfEnmOmB2vFPmIRj9ZtkPOAvVY
lFxwvRc8v9jezpcwsetKka+OHoJyJ/RXOdsRL8ynbTJuCgxLcTgVvOTRe6Tt6GO5P8QSxAuL5JEo
F3V07NaDr6rg2OMAlAvoO6wPiFUNL/umsz6aN4Co/uPczeYJW2tq7cHWaXHaZJIaN/DSaDryZArp
dhVnDu90OaJVUdsn61/3h24YRadCbute3UqPu3Zg5LftMZ9N1M9UlZhAn/adTGLs1/cz6Zpd7EWf
z07meE0GeBJm+OzI25Jo0w+U0/QX7wdYAeyA65ctNqGvCOnzkKGP977VcXHD5spjYYPwTn96k7AV
kIxD6/YC2Pkm+4HLkxpNYqUELgk2QErKILUIurVdGORGUSBjqDvL+i7Qb+3Nit3GkzROBiNzv87G
Uwq97PHTyE8u+J4DY65nNbdruwNLah1pjq0HG5qcP62syQj+6qxQ6+wwUFpa+19MfWizGPWoKBjL
HtwV3BRycSzhTBHWN/59V8pVapEXmX07DSvQPk6k2ebJ+3dnzFzK05y1x2lyP1QjFFVs3hIHemBM
ZnA1AED2xf9c+XvmMnccupAXiGrH7NZ6XYcFJetWH67tI31OX0CX0YdDyuz40EfRwkLQRUVwXtCE
iSU22ds2qI/AIS/y6DDtFcQhWGS2rZcSd2t+nou3ce9yUDJSN3Jsig9AoAtz9tARrKBEsj6e2sPJ
5Y/2fCwxsv4uPftimMy59L45kp0ADYvyxhm/UpB39JS6j54fY4ShMhEdT0G5xAVMZ5RP9qqikNcb
FCKSsvWAoUTM7T+VhIkk+OgQ9wSFd2jsCaCNbgfKDlRiQCOisCAbxbB8iFLYs/rlFTn1hf31lopL
BfjdVJ4rD6FEd7PADZqQRPDbFun3kj5JVGmYQK9Z3IKksIDyQ0AYUrXHcQvhI/5zoiDin34Ch2GJ
71nKIxEt/DEDmOz2iKWYjzO0EsAYaBwA79TGAOupY7gsf0OnC9I8ZKe84x4Gg3Gm4wJUxlesBL8p
MpqEHeDW2jWeaUUH7uaSShKxYwHdPTHC4kiArnJoYNx4i79RcjjkU9B8IqdIfYXkE2evmzteBghP
qiT1vJXZxK0sP83JZuPEnPF1ZvcJu6rxqBXn/awsMaJmjZwjEn3Q26PuEKMBbaCOQfU41waA3kyI
hQIIsp2enErneIfIFtDcuHOn67f2Av35NHJtbzhocxin3S+Ls/zn0lnXLvxOV0GzXVdDe6uwlUCO
nw81c/9Yc5F+GMsvb9yTeiRMV4IuuMxnchZnMIGuNpbyYIBzlsmiFivurNRHXrD1TQwDfQbkI8Pd
HpxEDkLhhcB+G6k8EqTBtRumzdKOCBh0gljmT1dr6QG1+XER6NVYBOafJgDWgULPAgHQqflW1ZtY
FuYR1WTfzgWqO5HERt/ZmEa9/agQUQpfWtX4XJiCIkC3pvfF4Wte/06LN91t2CFW0GJSBtJMs6Pf
pB2MHN8JzXrhKfr8Gy2+LKsvJ5ca51Gw1jfbnVkPQktcjr8BF+fkoIf1m5+AJF8M3c8mWg8zc+6M
WMbcgw3kneHjNP2PwFijKo7SKdb58VQ9RKJNEfUuNr/i6rouOLpWVV1IlScfibd0X8jmetYi//bP
uYvd4Ftb4tuTUhEY+8CbT82TBLFaUiedNCp/y9pIrEqiwZ7oaqdWQM77y6fY+4a4wvDzy3z2FJ7q
5TmSiwZXTo9LCHjO7km6kARZ0kw9xmzo/lP8o7NijBnlkpwfMTUEP0PUvnGYMIyXd5lb7mhGJ5tP
hONJ+ZotptSs6tcUOXVARsFQPw2DbbUD2msWobRuEFetr8PWNUoSreRCIoDRIH8GidM+0cdGwTVo
+F+WeWASVuzt21vH0GOl6mTV35vwXvTmAgEg+RNGkrVGZwkU7FNEm/hXAFgAfr5/ZkbBfibYTbja
S7XjtFF93HV3gia0k5HlqsAMfpHzDlWJsXEXDfWTu9HTyHMYVYGffjsOOqAIaEuA4fNU/ckBG9XJ
5/fAbgJuipVphqFwWvOzMVzNk+JYNy/R65GYw3nzx+ttfjrQ6yte/LFt3QXwZsEaGThvZrQ76dZX
ZqKrK3BInRCod5CpTArK9VyuGJMiqTQrAnNb3n2u3zk+2KTzhqrHa29UJ9URlf555vKaYL5z5MO/
CD1YP4Y/bwoRTvuafXViflvlhm35j+Xif3B5H6x3Mu70BxPbMglT93Pwad2p7PMQ6BpANXAQoE+Z
slskGHiC4rirtzjPF8cEjRRaz5u4aQVtDhaZpb/72TPwxWII+sc1TJqXYSek+FYdUBiOv9gWT6U7
JNeE1K9TiCxOqLZQtVfpgGgDGWdtLATtESB9ELatJgfYxeySPzwoEZnl2S71T0WEJiqXx10pIOhN
+iIcIkoVoDqZKVgBVaX7ZSgr5QltJlQNxEwmR07l5MHlMxkBLnl5PCG8cVMR2KbW5UC51Ea7G07j
enVfbob8oWZMZ8pWxEzjKppR1PDOdXzYDMD/FVVTjBLIhovyw9gPPIc8t0u+/6HP6Wtdx0rK9LRD
oQGuTS+2oINXlzN+cn+Cd8mI93KLQw65sLx7FyxhYWWkHF5vweHq94urXtwe1d6gQK16DRPJMCIu
3Lvi7xPvKdTTLE4+TaBwSPnlhWCRsnqTT07NtUzw8ZmPlOkcChnVIq3P1pznP4Xd9HfW5l4CBN8T
nGo4dfybUKoOcQndcGCjFdFD2D+85GABi1Jc0EHDo+Jjgi4u0WMcBP/r6cLY0yN/Ep/MG6zd7mu8
Y+J/T9Drvax577HE6tdVGQ01YmJh2E704efBL+bsMtLbLtRwmYSlw8ujPRZgpbRawfb+zYhmHoHA
iO6XOFiReZhpbqvGz7n2O0OtrwlrBNk3lgKRj3h+WfxABtbQZfeGPulxEozqDSKyTOhhqR03LjhR
tv+zrlnk4VHc3E3oYQTxzpnPFqGs6eaG12Z0Eds/npgg+l8GCNMsSCFQ1Sk1r6NPcevmTYMeA94N
veXASgkssJd+IDSlO3N1U4qfJn+rcxbsOxCXH+Jt1Dnf1T0SOqjf4Lb9GqmSrYaSeKsi/f1pPtzf
e2B7Bbvr4hFp2FvHvPJFx2jEetiabjOSGKMY5SIV5ijXg5Cd7mPnEsq3KRUFCmU8bNNTHn0w8Dst
T+j86Dd5ONvylsOwmXA8f1PYihlhw7UXoYk6YDbB7aNVMOiQM+mxG+wxmmX+Zkq/1X02Llq7T4XX
PAKN9OFi6o2y/dBGLH19JHyGwX+W7yF9LaxfiMVs6OkN80iXmsREFAgwzJFKvRh24xbXtZxCpCFl
04WzI9iYPBkrwoMxt1+QdyrRfg4Nj6fAD6fJ+BX5qYgbBBDgNSK9PWxUGItO+BGQLRMBJ/ZyCoaB
HJBPt1f7eJAN2tfk77quw0jBSxpbjDJZG4NXoqRikvFePvGKQ5KV0qb9yptLeLdk+GQUVG0WzqL1
fpYJmenYzMzRGLsY0bR/pzDbMzYKulSGx9tIDOxWMGpSh6V9WuaB4v/YnGIgdnSnsueKK56KGNgL
X3/F9dhQGk2BDNwNe1RvX/wm/5yOl+JTJty/Ka4dTN/h5J0qtscSVxxgtRB/ziBWFNs/KqqTSG88
Lpi2ouuxGir+Hr7SFfvo0f4J7qhyqaaedUadjqKTSCxJIH0MWcBZlONzAb4LN2AYsz69r8V7DkUE
8ru5LOhR7XD3TB619lcw3T9Q50LN4BqIx8c264aRtyvla0pa/rh098432JOXHuNLptbK7ijkFzn7
jCx8ZMWBl3OhHvtjue5d2MxTxOpvnZT/BOPLn1NHF+lAB8tTh6nqTxRfeXSmZol5O63SjihjBJCu
4uwqxxrzaPvi6Xtx6gg4xqF3fmOB2LVX7JAR+wvcqXWJC7HqWiumd/3hlu4TWI/zcb2YOXFZedjn
BDEvuWTGBQtyh9NdnvcWPZUX5FxI99yGr9WSCR9eXAjpH3i4BjJxEwRu/wQvJA5Ba0noZ+ZqGslt
kHCKA1dCKWE2DhzPiIEIr00vxbvVxY/GpeZmuVRJZTF1aGxfvpbMy7tS6NnBYcWwrEojVKHhCT1T
ms16Fe+eyRBguk46/xLC2ziKT2EzIMVMSDgivb4RLPWl/rNrgVa1VqbrYFHq4CJwRoH+UUswOGdK
1D7WiTDaB3VLNHcSRcLzvBliUc05f1Ct3J5WNrDxsU99JrtTOXL5jLDOJE6sHYkR38mSluj94ajq
DC5byxxfmeaK4nA4zpnmX34w18z+aeB6jM7IaX/94S0VT9LNFQKnOrX81Hi9VjCYfC3ZAzDSWfHo
UsbZQBmepR855FcDYOCYK43GDwuy5GdJgFqVD7FYA592ln0CQ5XmQlQuFEAzEeiBIZ/UbiBfh4iP
+5zEJYn5Rxge46+uHUWW1dESn8Ag7s7ZKdLT3E4rP+AAywtXhhFX/akvhdfujW4iVNHui9Pjlb64
aKoSGa9o/wNdwDPLcciR/bEI6GH/Ahcd+TErlb2YWAZklQ36J+PWywrUqC4b5b++RY0kp1OI3pCb
fwNCm5fU0/RKhafu7Ex3o26XGxnN9KJrI2DhTrwcDLNP7mS7v6f9GZ1+MmDqw24qX5w7kpzgA7wF
Wi6LN5y1KNNRKocBP6f3bUIkAvP3Q91s8huwoCGn0cV8flO2tIbIwnwJ2ht7sAINiRdelX2DQH8U
oyWuIH94KMOwN6s3dpkr+ruaom2c2THwJTKrS1CLKWB7Q5ANXmdmQK4PmiC+gYL4X1oREayXhOYm
BKc6/R5RKrf+aeFzTyq9iraUWcGcj+s5K15bHzj6trkredpl3oVLTt1X//c3307GmxKcnyLNMR0h
XoXqCxLkB6cueqGZzksCTqx/DvXwQ8+fH9JlJ4pPqJ2qOUNLdjosherYfzzDA9LuZfsT1X3PFSyz
8wn19le3fcftxd0kJ7xp18u3iYF2yBfRDZGpi8EdUnV6x2dz+ZRT6nVLJCgDkXjIlwyQSJBB/S/2
/JIroiC4Vnm7sdbaFg5+B5j9zUSUWIJhwhuN+ZzmCSqv27yibSC/tk1rgn1IjbvxGjNTgNVF/7Bi
MJjEP8dmsnjEx6G2yryTIJxYUqX8j5+qETv0JtbewbF7V4R1o5oWx6lKZ2H9F7h/roWVStC48I5n
+2WUJk+nXA+VOrbTVVHkZInp+R2wnHhd8QJ+efTGjY+HVBWP2sccrA9quJTuyosr1tdLdgCB97M6
s5GsCTk64mIZfu+tdLo+e55xO9lD14b+4yTKRlri33vvOo7zfVk93gBOcEn+P0dMJ/ojSBtTPsxo
ERkAjwygps8cl9L88jEzeAxdoz4txD5xyKaubBli3UjVRZpYNZSX+M3Xsm01YqsuUUM7S++8/9xt
h3l/Qn9xpkm2Qfs9rG1HuA/a5mWOdMMYYGVYSnLpINXjcsGdH+Qp2PUWH36tuTZ/KYPtsPSTjiXw
94BI4ktMvOS+UZnjGh7XPeBFXH2Ao0S7/8XjwjoX/B/M53+o1LCpUiqFKmEAWZzncrHsahmDoveU
cFToxdZLbM5/w2pCA8Z9RRUbUtSBdnZfLIP0AgFLZtbzFfIma5sMgyr4Uk+aotGoBkOfzlKK9JVB
xn8rWTe5nkNV5I1L5JOhGO9LxELcdnPvAyesi8rgBfk1u2MPkj3MADqqEste6jNv9voljMlNixiQ
Use3XMgoyr1pV0R3WkJcR9iZilqI5nBY4GPxb1bXxsklzeuyetV67iMuqC7oXyihsuaZ8e+oW9t8
1wegR/gqV/zZEnawY694cKj9Tal+omq67ydFEz2w/GASsHZiHY+z1mPmNUEpOy5R9dO55Iokku+e
4k4S0A+ZQGTbc6Fe78uu/4YD5tbnclA6iB0qckDnrg/slg9HQyHkWQWFFnwQsbnRcKqa7VxR5Czg
37IO4O4s7uWrpgl2xWr5IBcG7CVtVvbeVHPrzNxlreFGGDH7S6urzmWY0p7OHSIrfkZMrUkK5jeP
D11OpofDOiwHyW6gD4d3dIoABcPEl7xySSY+Fcmmanwhu8+hoVYksc4QE1/j+K9PoUTlb6sqS3zx
Pupv8uvwkvBHW9EmH0Yq/ZRR9J8CyrTRFabLvPofB6J20NSlTCTpTqd592SKl+Kq6kcFtS21qH8a
AdoKQfigz2Idd7+3MCz8zGwPeCxyTPBd5/RzcpVYqU17OTiNsWJWUK/axw+YlzMWr3IOFfrYaO0V
q/ENDdfDsTP9LodydYL7cRGhyan3Vyn/dz93Fb7sSWX8qn1CCqCnfFSarH7ks4udCmH9CjZ0PiEg
+xf93vBiaGt+xRtBNvgBlJE7vDcK/Z56oymLaeH8wSxAxHRHeN7o1IQEQ/B+1/7oiQzCfZcXvpH+
NS8FeEvwfwu2MfAE+y3SvRctpoMspadtts/rIvixkpgA94zihUg5Hzq0qgN9KbVrNK0df0XuRDdk
Phu7pkBmGG8DtoJAFqJ5DpAPP/sSEzY40AqbtlFL8P62nETSPEkQuksRgTaEyPJa8bSWlPuCcS4F
NEom/yF0hanN8C4ZgNDo+wM3q6EMMUf6tIoCtj2uxqW1sSitkcW17fIkV2eyz98yyVWpcz/M5p3l
MEBTTppaO8SBStdTFe+jZ2ufNpBr0NNWTgiUOTf/xugc6gjy2QO4CcXT+c0IlRZYLG8kY5uY38T5
bdRNuEveDO/YF66McaBETAOKr3WHXjnkq9CamH1jwUdVyhtgU4srbKoOLaMvrdWBSeRfYpxSsuWQ
LpeDtR7xK9MFIOgnfeAmobUjFXHPUKgbwQotZnbTzlNsWDg3Rgm2rxsT33rVhZTQ22XBDC/oaGqR
3I8uUuuMqvNFFD9GLzcZvHVkqYGtN/dYPtPI5cHQbszskMl5eNK/jJaZh9yXh3rZkH7VZdjPFy0E
9luLXGt0KDriXM0JpLZhpopGkHSBy1VtEkMlXocRlY+lsdrYQI72FmSF2mP60Mgdq6bpCVrTPc0c
veWmTzFc3J/F+KQwPvmAIp64/MvfeQgKH3gciwxx649lSz7XSXKTWF4+n0qlWtsojcYzhsVb1Z1M
HZEnpQzwuX69f4+JWRBKN3vwFSZbhP5Za7nNku5D+sK8g/nYLu7OJZXKBB80FyJvqs3s02KbcTDQ
MqrnGsGMb5e2x4UzgZ/l71shJi1SrOzUvikP2tpDA6bnBnGDNoDGMlPZWpeI8Ph0lFW5GP6r5eh4
OiUjTFvHbL+w5wzF4SRsCBLTkPEIlGxG6bIEpbS6ovwlKnvy5thr/ctfEDhSMGSHlf+n2HI11xLq
EZalay7NE09zQ/pU/QcJPo9JyT2xmtLhJrONJYyEBlIfxylFH+x7911irEe5RaiZeKXgbV5LTCTD
+IzIrxACPNG244Yv5y2i40QC3k4h0SVVn5cAkPVLnjwkwXIDvFiTge38onJ/tTU8z0skkGGpe228
l5PbA9xhuI5RkPnrNwFLLtkmDHvCmBeGwIC7/qMQzcnA5omu7IwiD2vwRlD1P/eKxxQ6RrNDsu5H
eZMmMXmBfj0FTB1MkBbkwNcmGNwjQPawr8tWC6MtjsPuRg7ZNOX6gnCaCEJpgPWVGjdviUBFnHke
+4C7EFr5Y1jDC1rDmqnRs6S4UgTnoZUdnWwET5glnUjGUF/4UbZiIGTZM9ylIAuSz5BIPZxT8VNm
edULrROjmtrHDSi3rfpBK/mBNmSU7VR6/RnA3fbs+LgcygpDs/ZUvvVwltaN74V/qrM03KVSQrj2
0D63gux+/ZxTZfw948zStBZiF8Xb+d2kzGYGYi+ak2CnxU9uX3+uKOz3PXr5FgzMPGpBgOHBlttK
Jo/Ubfk//qiSW2p4MhwjMvb3EOGznSKhBo4OrIJ8jGHsg28ISUSfdbaT37DVtHL/ZxW0VW1Jnk/0
XySYGE0X0ugG7DcaHf1aLA+X6jfbAt9JfAX2NS8T1eTiK5CNIxhMzGHr9CkOd3A+QoHnHx2U3XIv
O4ylugKhK2AwwTSsei3NdeOe5Viqk5i3fVz+5D3xnSQ7/+LqDnLPVSlERc9WqiRYG/iJ7LVB9rgQ
8Wi158ualduZ0A8W3vyreqcKdE7RBvBuTLslr8DWZsyvwtKu+ft1zvci4HA5T3fJLLLJ0a2bRiyd
BJue+NXbNSMZnh8bTXeJGIdt6kS8gPJVvYrTI1+RtAqzhM/86/Xda0VkIczSJprgOBETPQXFkdBx
c6KA2o5jY6y1uTptVJ3x+5s/IZhxspjK0fGZIzxzDjKdsehAzcr5ovR5W2dLsJy+h5dkPU4B80jn
2Q/X+gezgrRhfCioWjmXs3Ap0POmeK6wyftTMBWT1wDH5LtyibNz2OxsUTyLpDNd+o5549zESFVC
kYUqNgg2H3ucL3nhvzESLU9SjBb421xTTUpMjtmGaNON0wtaHe2DHDrRUr+J0/RPUh2ugdtyCBZt
HGcAckZyfwLNM/MSEfV2LyRK2Ls65uexpuzXw9ideXQ1QIEcHYmD5f6cYU5sijvRnYZ7GC6NP1m+
KjUqafywxGHwJDUURk1NnOmQuwhrnMxNgdbzGE4s2jvMdvGKZ3MtwpHxgWrWsqDDQnd9HuTJCMDV
tLKW+mgqcnJybZlOWUuQZJiOiHFPBjVbATZ2GEkO2tFAT+cec0bgaGELbOBY37vUU+OGFE1xcfcY
arjOWJqsVC+dkCUw5tfoH3wga7N7pYiqP+z5P6e6jzr/68CXzjfqRspGZMyrGa/mFWSRGucXjnmp
/Q6pPtQbo/KhlCRn9Vjj0wdbeO/OLaSWEs8ERqIjY888d1UmJSEBjzo0pHow+zQdLXZSXq1I9Z9l
BQAVNPdo5JPFc3dWX7PoN1maSCGk2HHK1P++Yujf/VMoUmSmiDPdQLjU/BNkrcc5TOeJ6b5Tshl1
KN+yruQ+B8bkufgchclFmRW3TiLIytHmf1dcCoUBLtJv1UjKzeVVcpvprPer/RwKyKzEFmXpCvol
Uq3SR0M2c8DsGZbK+KarfIk7THAJmj5CFeqI7LdBMTm0LNLuXCutuI2kEi49mY5S3aUxIFvvVQny
S/WgufEDYE5NIuS59EfB2VNrHUYsr6Ce1lZ2196pFn7zZ2UXT+SBow1mMzyOKeg1JMlUojyu2Z2o
zy030bFut8Td/sIurOd0oGVCATI7QAIF87Ifx4+0x5S65LSK5qgMmz4EAs9m+EJA5DsOS+tV6Brb
0IY6kKFmiP5ToI8u4iNJq8bjyBScgm4gHQJRAShVyHMudm0JMVZFPaY80YIFIfeq33Ae36GHr1rO
TWBEyq/Z9moJsr4HnGo21SQ0OzuhOOaLMRrCxla8vZTSFiEIOAt6WI0GEMFc05hGnsYapx8KfMqs
qi1r/k3QteNV1dAelaqdwFU0RLEPI+fSK7wbPfYltp/M5+2Y0ua5cKiR1kwKPsvensS1615q98kx
Ad8mNqM60CiQbfkqkbGWfdczvr/vZDQkboNQW3dU0y4BX9VAUxuqpiU55NE+GtSkjH9AW8jPhN6v
cnf3NCY5lnTZDy1x/rIy8bj5XHSj9s7KXg0NjhlZb6fsntS/821g48/9opVByarud6z3oq88R2Sh
J4uBGGEe35EuR4itdc7nE1wDQG3NbXhrE76E2vWAITvyu2vJWuUx+zgpoczCwKrSMwadWO1n2Ycy
u5ebzyPqlz9VH1VBc/+7AcQGGsFMhgVtYfw3R7rwg2PZ1Zvxj10Qs2Ec8zkQd1i2iYdAFRueov6/
cWFdw9vP2uf2lm7RDNbX5spfyN4gfISmooyQpuukPLtfie6PRs3OSHF7QoEa4BM4mI1FopjG7kp0
F99+ZpWVtTrBUT0vhE9m8hZn0iYyQcxM3fV5oxCjD06kEfFe61UNhMUxme+w7vP7mi4nBByk57Ja
U5bM4iCC4UzrbllJT0bJC+1R9+PWQq673n+BmBGxahmX26rbj0qkuj0xCeyCLYDi7jOAlNzdrADV
ozIwP5s2gmqTglMZFtFdNmUHWyZZ96bhVDUukOcgmHI8LqDnX2J7UMmqX5v0egHWDxKJmxi/dKqz
qhvuyN8eC4DJ5Sae3u84Tf3IIc9I///SjqzziPtsTrsW8NJnu6tiNq2t7HEpFCMkmjfJq2nJSTFg
PbXP/+GDrdNAiMuuAsal3Ysz0f1HE7S7LjasIIVuPPByAGXFk9Mc7jOO3W0qG8kCXf7npTK+3GSh
J3iQ9WtCEkcSh9t+OVYUVn7InQ74XaoZsfLxaGDeWZqutez7Ymd45n1NqLLuv40Je2EyTgaLLCi2
nCUB4eqH1b4jq54TGTORQU2gBQFXDKEg0GV3FIBcblQR9n6GnVFZ6jwlEO7zg4VRYRzho7+dJgHs
6FWP4dfu2g2og12QkFkTKey7Zwz5E79jx2LmSB38yDePjFikWH7F9L3zmD47GPJ57Yd4fUNVmw0j
ETi6AfDD5s6sMC2WzIXumD/xfRP87LxQ0PWjMJkqmBmnj3KRkg==
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

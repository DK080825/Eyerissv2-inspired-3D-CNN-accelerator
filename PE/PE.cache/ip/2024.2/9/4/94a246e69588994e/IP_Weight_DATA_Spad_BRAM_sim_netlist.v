// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
// Date        : Thu Apr 16 23:23:55 2026
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
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [11:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [11:0]douta;

  wire [6:0]addra;
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
  wire [6:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [6:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [11:0]NLW_U0_s_axi_rdata_UNCONNECTED;
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
  (* C_WRITE_DEPTH_A = "100" *) 
  (* C_WRITE_DEPTH_B = "100" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "12" *) 
  (* C_WRITE_WIDTH_B = "12" *) 
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
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(douta),
        .doutb(NLW_U0_doutb_UNCONNECTED[11:0]),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 22240)
`pragma protect data_block
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
M33raCG/sWcEXQ==
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

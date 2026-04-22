// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
// Date        : Wed Mar 25 21:00:19 2026
// Host        : Adrian running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ IP_Iact_DATA_Spad_BRAM_sim_netlist.v
// Design      : IP_Iact_DATA_Spad_BRAM
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xck26-sfvc784-2LV-c
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "IP_Iact_DATA_Spad_BRAM,blk_mem_gen_v8_4_9,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_9,Vivado 2024.2" *) 
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_9 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 22032)
`pragma protect data_block
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
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

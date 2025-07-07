module fusion_weight_top(
    input        clk_ch1    ,
    input        clk_ch2    ,
    input        move_r     ,//图像右移控制，高电平脉冲有效，一个脉冲右移一列
    input        rst_n      ,
    input [23:0] ch1_data   ,
    input        ch1_valid  ,
    input [23:0] ch2_data   ,
    input        ch2_valid  ,
    output [23:0]fusion_data,
    output       fusion_valid
   );
wire empty_w1,empty_w2;//fifo空标志，高为空
wire rd_w1,rd_w2;//fifo读使能，高有效
wire [23:0] q_w1,q_w2;//fifo读出数据，IP设置了输出缓存寄存器，数据延迟读使能一个时钟
wire [8:0] fusion_r,fusion_g,fusion_b;
reg rd_r;
reg fusion_valid_r;
reg [23:0] fusion_data_r;
reg        move_r_s;//表示需要右移1列，完成前保持高电平，完成后拉低
assign rd_w1 = ~empty_w1 && ~empty_w2;//两个fifo都有数据时就同时读两个fifo
assign rd_w2 = ~empty_w1 && ~empty_w2;//两个fifo都有数据时就同时读两个fifo
assign fusion_r = {1'b0,q_w1[23:16]} + {1'b0,q_w2[23:16]};//r通道求和
assign fusion_g = {1'b0,q_w1[15:8]}  + {1'b0,q_w2[15:8]}; //g通道求和
assign fusion_b = {1'b0,q_w1[7:0]}   + {1'b0,q_w2[7:0]};  //b通道求和
assign fusion_valid = fusion_valid_r;
assign fusion_data = fusion_data_r;
fusion_fifo u_fusion_fifo_1
 (
  .wr_data         (ch1_data ),
  .wr_en           (ch1_valid),
  .wr_clk          (clk_ch1  ),
  .wr_rst          (~rst_n),
  .full            (),
  .almost_full     (),
  
  .rd_data         (q_w1     ),
  .rd_en           (rd_w1    ),
  .rd_clk          (clk_ch2  ),
  .empty           (empty_w1 ),
  .rd_rst          (~rst_n),
  
  .almost_empty    ()
);
fusion_fifo u_fusion_fifo_2
 (
  .wr_data         (ch2_data ),
  .wr_en           (ch2_valid || (move_r_s && ~ch2_valid)),
  .wr_clk          (clk_ch2  ),
  .wr_rst          (~rst_n),
  .full            (),
  .almost_full     (),
  
  .rd_data         (q_w2     ),
  .rd_en           (rd_w2    ),
  .rd_clk          (clk_ch2  ),
  .empty           (empty_w2 ),
  .rd_rst          (~rst_n),
  
  .almost_empty    ()
);
//对fifo读使能打一拍得到数据valid
always@(posedge clk_ch2 or negedge rst_n)
if(!rst_n)
    rd_r <= 1'b0;
else
    rd_r <= rd_w1;
//求平均，截尾1位相当于除以2
always@(posedge clk_ch2 or negedge rst_n)
if(!rst_n)
    begin
    fusion_valid_r <= 1'b0;
    fusion_data_r  <= 24'd0;
    end
else
    begin
    fusion_valid_r <= rd_r;
    fusion_data_r <= {fusion_r[8:1],fusion_g[8:1],fusion_b[8:1]};
    end
//move_r_s产生逻辑:检测到move_r则拉高，然后趁ch2_valid为低时强行写一个数据进fifo，接着拉低move_r_s
always@(posedge clk_ch2 or negedge rst_n)
if(!rst_n)
    move_r_s <= 1'b0;
else
    move_r_s <= move_r?1'b1:((move_r_s && ~ch2_valid)?1'b0:move_r_s);
endmodule
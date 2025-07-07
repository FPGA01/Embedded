module uart_control(
	//global clock
    input wire			sys_clk,  
    input wire			sys_rst_n,
	input wire          rx_finish,
	input wire  [7:0]   rx_data,
	input wire			key5,
	input wire          key6,
	input wire          key7,
	input wire          cam_frame_vsync ;
	input wire          cam_frame_href  ;
	input wire          cam_frame_valid ;
	input wire  [15:0]  cam_frame_data  ;
	input wire          cam_frame_vsync1 ;
	input wire          cam_frame_href1  ;
	input wire          cam_frame_valid1 ;
	input wire  [15:0]  cam_frame_data1  ;
	input wire          post1_frame_vsync,
	input wire          post1_frame_href,
	input wire          post1_frame_clken,
	input wire    [7:0]	post1_img_red,	
	input wire    [7:0]	post1_img_green,	
	input wire    [7:0]	post1_img_blue,
	input wire          post2_frame_vsync,
	input wire          post2_frame_href,
	input wire          post2_frame_clken,
	input wire[23:0]	post2_img,
	input wire 		    post00_frame_vsync;
	input wire 		    post00_frame_href ;
	input wire 		    post00_frame_clken;
	input wire [7:0]	post00_img_Y      ;
	input wire			post11_frame_vsync;	
	input wire			post11_frame_href;	
	input wire			post11_frame_clken;	
	input wire    [7:0]	post11_img_Y;	
	input wire			post22_frame_vsync;	 
	input wire			post22_frame_href;	 
	input wire			post22_frame_clken;	 
	input wire			post22_img_Bit;		 
	input wire			post33_frame_vsync;	
    input wire			post33_frame_href;	
    input wire			post33_frame_clken;	
    input wire			post33_img_Bit;	
	input wire			post44_frame_vsync;	
	input wire			post44_frame_href;	
	input wire			post44_frame_clken;	
	input wire			post44_img_Bit;	
	input wire			post55_frame_vsync;
	input wire			post55_frame_href;	
	input wire			post55_frame_clken;
	input wire			post55_img_Bit;	
	output wire [11:0]  CHAR_POS_X,			
	output wire [11:0]  CHAR_POS_Y,
	output wire			vsync1,
	output wire			href1 ,
	output wire			clken1,
	output wire [15:0]  img1  ,
	output wire			vsync2,
	output wire			href2 ,
	output wire			clken2,
	output wire [15:0]  img2  
   );
   
//状态机1————————————————————————————————————————————————————————————————————————————————
reg key5_d;
always@(posedge sys_clk or negedge sys_rst_n)begin
if(!sys_rst_n)
	begin 
		key5_d <= 0;
	end
	else begin
	key5_d <= key5;end
end  

reg key6_d;
always@(posedge sys_clk or negedge sys_rst_n)begin
if(!sys_rst_n)
	begin 
		key6_d <= 0;
	end
	else begin
	key6_d <= key6;end
end  

reg key7_d;
always@(posedge sys_clk or negedge sys_rst_n)begin
if(!sys_rst_n)
	begin 
		key7_d <= 0;
	end
	else begin
	key7_d <= key7;end
end  

localparam  normal    = 4'b0000,
            sedu     = 4'b0001,
            liangdu = 4'b0011;
reg     [3:0] state;
reg 		post_frame_vsync;   
reg 		post_frame_href ;   
reg 		post_frame_clken;    
reg 	[15:0]    post_img  ;
reg 	[3:0]    seducnt  ;

always@(posedge sys_clk or negedge sys_rst_n)begin
	if((!sys_rst_n)||(seducnt >= 4'd9))begin
		seducnt<=4'd0;
	end
	else if((key7_d == 0)&&(key7 == 1))begin
		seducnt<=seducnt + 4'd1;
	end
	else begin
		seducnt<=seducnt;
	end
end

always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)begin
		state<= normal;
	end
	else begin
		case(state)
			normal:begin
				if((key7_d == 0)&&(key7 == 1))begin
					state <= sedu;
				end
				else if(((key5_d == 0)&&(key5 == 1))||((key6_d == 0)&&(key6 == 1)))begin
					state <= liangdu;
				end
				else begin
					state <= state;
				end
				end
			sedu:begin 
				if(seducnt>= 4'd9)begin
					state<= normal;
				end
				else begin
					state<= state;
				end
				end
			liangdu:begin
				if((key7_d == 0)&&(key7 == 1))begin
					state<= sedu;
				end
				else begin
					state<= state;
				end
				end
			default:
				begin
					state<= normal;
				end
		endcase
	end
end
					


always@(*)begin//状态机第二段
		case(state)
			normal:begin
				post_frame_vsync <= cam_frame_vsync1;
				post_frame_href  <= cam_frame_href1 ;
				post_frame_clken <= cam_frame_valid1;
				post_img <= cam_frame_data1  ; 
					end
			sedu:begin
				post_frame_vsync <= post1_frame_vsync ;
				post_frame_href  <= post1_frame_href  ;
				post_frame_clken <= post1_frame_clken ;
				post_img <= {post1_img_red[7:3],post1_img_green[7:2],post1_img_blue[7:3]}  ;  
					end
			liangdu:begin
				post_frame_vsync <= post2_frame_vsync ;
				post_frame_href  <= post2_frame_href  ;
				post_frame_clken <= post2_frame_clken ;
				post_img <= {post2_img[23:19],post2_img[15:10],post2_img[7:3]}  ;
					end
			default:
				begin
				post_frame_vsync <= cam_frame_vsync1;
				post_frame_href  <= cam_frame_href1 ;
				post_frame_clken <= cam_frame_valid1;
				post_img <= cam_frame_data1  ;   
				end
		endcase
end

assign vsync1 = post_frame_vsync;
assign href1 = post_frame_href ;
assign clken1 = post_frame_clken;
assign img1 = post_img  ;

//状态机2——————————————————————————————————————————————————————————————————————————————————
reg 		post_frame_vsync1;   
reg 		post_frame_href1 ;   
reg 		post_frame_clken1;    
reg 	[15:0]    post_img1  ;

reg rx_finish_d;
always@(posedge sys_clk or negedge sys_rst_n)begin
if(!sys_rst_n)
	begin 
		rx_finish_d <= 0;
	end
	else begin
	rx_finish_d <= rx_finish;end
end  


localparam  yuantu    = 4'b0000,
            huidu     = 4'b0001,
            zhongzhi = 4'b0010,
			sobel    = 4'b0011,
            fushi     = 4'b0100,
			pengzhang    = 4'b0101,
            erzhi     = 4'b0110;
reg     [3:0] state1;				

always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)begin
		state1<= yuantu;
	end
	else if((rx_finish_d == 0)&&(rx_finish == 1))begin
		case(rx_data)
		8'b00000000:begin state1 <= yuantu   ; end//0
		8'b00000001:begin state1 <= huidu    ; end//1
		8'b00000010:begin state1 <= zhongzhi ; end//2
		8'b00000100:begin state1 <= sobel    ; end//4
		8'b00001000:begin state1 <= fushi    ; end//8
		8'b00010000:begin state1 <= pengzhang; end//10
		8'b00100000:begin state1 <= erzhi    ; end//20
		default:begin state1 <= yuantu   ; end
		endcase
	end
	else begin
		state1 <= state1;
	end
end
			

always@(*)begin		
	case(state1)
		yuantu:begin
			post_frame_vsync1 <= cam_frame_vsync;
			post_frame_href1  <= cam_frame_href ;
			post_frame_clken1 <= cam_frame_valid;
			post_img1 <= cam_frame_data  ; 
				end
		huidu:begin
			post_frame_vsync1 <= post00_frame_vsync ;
			post_frame_href1  <= post00_frame_href  ;
			post_frame_clken1 <= post00_frame_clken ;
			post_img1 <= {post00_img_Y[7:3],post00_img_Y[7:2],post00_img_Y[7:3]}  ;  
				end
		zhongzhi:begin
			post_frame_vsync1 <= post11_frame_vsync ;
			post_frame_href1  <= post11_frame_href  ;
			post_frame_clken1 <= post11_frame_clken ;
			post_img1 <= {post11_img_Y[7:3],post11_img_Y[7:2],post11_img_Y[7:3]}  ;
				end
		sobel:begin
			post_frame_vsync1 <= post22_frame_vsync ;
			post_frame_href1  <= post22_frame_href  ;
			post_frame_clken1 <= post22_frame_clken ;
			post_img1 <= {16{post22_img_Bit}}  ;
				end
		fushi:begin
			post_frame_vsync1 <= post33_frame_vsync ;
			post_frame_href1  <= post33_frame_href  ;
			post_frame_clken1 <= post33_frame_clken ;
			post_img1 <= {16{post33_img_Bit}}  ;
				end
		pengzhang:begin
			post_frame_vsync1 <= post44_frame_vsync ;
			post_frame_href1  <= post44_frame_href  ;
			post_frame_clken1 <= post44_frame_clken ;
			post_img1 <= {16{post44_img_Bit}}  ;
				end
		erzhi:begin
			post_frame_vsync1 <= post55_frame_vsync ;
			post_frame_href1  <= post55_frame_href  ;
			post_frame_clken1 <= post55_frame_clken ;
			post_img1 <= {16{post55_img_Bit}}  ;
				end
		default:
			begin
			post_frame_vsync1 <= cam_frame_vsync;
			post_frame_href1  <= cam_frame_href ;
			post_frame_clken1 <= cam_frame_valid;
			post_img1 <= cam_frame_data  ;   
			end
	endcase
end

assign vsync2 = post_frame_vsync1;
assign href2 = post_frame_href1 ;
assign clken2 = post_frame_clken1;
assign img2 = post_img1  ;

//状态机3————————————————————————————————————————————————————————————————————————————

localparam  chushi    = 4'b0000,
            left     = 4'b0001,
            right = 4'b0010,
			up    = 4'b0011,
            down     = 4'b0100;
reg     [3:0] state2;	

always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)begin
		state2<= chushi;
	end
	else if((rx_finish_d == 0)&&(rx_finish == 1))begin
		case(rx_data)
		8'b00110000:begin state2 <= chushi   ; end//30
		8'b01000000:begin state2 <= left    ; end//40
		8'b01010010:begin state2 <= right ; end//52
		8'b01100100:begin state2 <= up    ; end//64
		8'b01110000:begin state2 <= down    ; end//70
		default:begin state2 <= chushi   ; end
		endcase
	end
	else begin
		state2 <= state2;
	end
end

reg  [11:0]POS_X;
reg  [11:0]POS_Y;
reg  [3:0]leftcnt;
reg  [3:0]upcnt;

always@(posedge sys_clk or negedge sys_rst_n)begin
	if((!sys_rst_n)||((rx_finish_d == 1)&&(rx_finish == 0)&&(leftcnt >= 4'd13)))begin
		leftcnt<=4'd0;
	end
	else if((rx_finish_d == 1)&&(rx_finish == 0)&&(state2==left))begin
		leftcnt<=leftcnt - 4'd1;
	end
	else if((rx_finish_d == 1)&&(rx_finish == 0)&&(state2==right))begin
		leftcnt<=leftcnt + 4'd1;
	end
	else begin
		leftcnt<=leftcnt;
	end
end

always@(posedge sys_clk or negedge sys_rst_n)begin
	if((!sys_rst_n)||((rx_finish_d == 1)&&(rx_finish == 0)&&(upcnt >= 4'd8)))begin
		upcnt<=4'd0;
	end
	else if((rx_finish_d == 1)&&(rx_finish == 0)&&(state2==up))begin
		upcnt<=upcnt - 4'd1;
	end
	else if((rx_finish_d == 1)&&(rx_finish == 0)&&(state2==down))begin
		upcnt<=upcnt + 4'd1;
	end
	else begin
		upcnt<=upcnt;
	end
end

always@(*)begin		
	case(state2)
		chushi:begin
				POS_X<= 'd100;
			    POS_Y<= 'd100;
				end
		left,right:begin
			case(leftcnt)
				4'd0:begin POS_X<= 'd100;POS_Y<=POS_Y;end
				4'd1:begin POS_X<= 'd200;POS_Y<=POS_Y;end
				4'd2:begin POS_X<= 'd300;POS_Y<=POS_Y;end
				4'd3:begin POS_X<= 'd400;POS_Y<=POS_Y;end
				4'd4:begin POS_X<= 'd500;POS_Y<=POS_Y;end
				4'd5:begin POS_X<= 'd600;POS_Y<=POS_Y;end
				4'd6:begin POS_X<= 'd700;POS_Y<=POS_Y;end
				4'd7:begin POS_X<= 'd800;POS_Y<=POS_Y;end
				4'd8:begin POS_X<= 'd900;POS_Y<=POS_Y;end
				4'd9:begin POS_X<= 'd1000;POS_Y<=POS_Y;end
				4'd10:begin POS_X<= 'd1100;POS_Y<=POS_Y;end
				4'd11:begin POS_X<= 'd1200;POS_Y<=POS_Y;end
				4'd12:begin POS_X<= 'd1300;POS_Y<=POS_Y;end
				4'd13:begin POS_X<= 'd1400;POS_Y<=POS_Y;end
				default:begin POS_X<= POS_X;POS_Y<=POS_Y;end
			endcase
			end
		up,down:begin
			case(upcnt)
				4'd0:begin POS_Y<= 'd100;POS_X<=POS_X;end
				4'd1:begin POS_Y<= 'd200;POS_X<=POS_X;end
				4'd2:begin POS_Y<= 'd300;POS_X<=POS_X;end
				4'd3:begin POS_Y<= 'd400;POS_X<=POS_X;end
				4'd4:begin POS_Y<= 'd500;POS_X<=POS_X;end
				4'd5:begin POS_Y<= 'd600;POS_X<=POS_X;end
				4'd6:begin POS_Y<= 'd700;POS_X<=POS_X;end
				4'd7:begin POS_Y<= 'd800;POS_X<=POS_X;end
				4'd8:begin POS_Y<= 'd900;POS_X<=POS_X;end
				default:begin POS_X<= POS_X;POS_Y<=POS_Y;end
			endcase
			end
		default:
			begin
			POS_X<= POS_X; 
			POS_Y<= POS_Y;
			end
	endcase
end

assign CHAR_POS_X = POS_X ;
assign CHAR_POS_Y = POS_Y ;




   
endmodule
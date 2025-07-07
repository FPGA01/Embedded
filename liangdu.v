`timescale 1ns / 1ns

module liangdu(
    input clk,
    input rst_n,
    input Vsync,
    input Hsync,
    input De,
    input [23:0] RGB,
    output Vsync_o,
    output Hsync_o,
    output De_o,    
    output [23:0]RGB_o,
    input key1,
	input key2
);

/*
wire clk;
wire rst_n;
wire Vsync;
wire Hsync;
wire De;
wire [23:0] RGB;
wire  Vsync_o;
wire  Hsync_o;
wire  De_o;    
wire  [23:0]RGB_o;*/
/*wire key1;
wire key2;*/


reg key1_d;
always@(posedge clk or negedge rst_n)begin
if(!rst_n)
	begin 
		key1_d <= 0;
	end
	else begin
	key1_d <= key1;end
end  

reg key2_d;
always@(posedge clk or negedge rst_n)begin
if(!rst_n)
	begin 
		key2_d <= 0;
	end
	else begin
	key2_d <= key2;end
end  

reg [1:0]CONTRAST_SIG;
reg [1:0]BRIGHT_SIG;
reg[7:0] CONTRAST;
reg[7:0] BRIGHT;


always@(posedge clk or negedge rst_n)
begin
if(!rst_n)begin
	CONTRAST<=8'd0;
	end
else if((key2_d == 0)&&(key2 == 1)&&(CONTRAST_SIG!=2)&&(BRIGHT_SIG!=1))begin
	if(CONTRAST<8'd70)CONTRAST <= CONTRAST + 8'd10;
	else CONTRAST<=8'd0;
	end
else begin
	CONTRAST<=CONTRAST;
	end
end

always@(posedge clk or negedge rst_n)
begin
if(!rst_n)begin
	BRIGHT<=8'd0;
	end
else if((key2_d == 0)&&(key2 == 1)&&(BRIGHT_SIG!=2)&&(CONTRAST_SIG==0))begin
	if(BRIGHT<8'd70)BRIGHT <= BRIGHT + 8'd10;
	else BRIGHT<=8'd0;
	end
else begin
	BRIGHT<=BRIGHT;
	end
end

reg[7:0]a;

always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
	begin BRIGHT_SIG<=0;CONTRAST_SIG<=1;  
	a<=8'd0;
	end
else if((key1_d == 0)&&(key1 == 1))begin
	if(a<8'd3)a <= a + 8'd1;
	else a<=8'd0;
	case (a)
    8'd0:  begin BRIGHT_SIG<=1;CONTRAST_SIG<=0;  end
	8'd1:   begin CONTRAST_SIG<=0;BRIGHT_SIG<=0;  end        
    8'd2:  begin CONTRAST_SIG<=1;BRIGHT_SIG<=0;   end        
    8'd3:  begin BRIGHT_SIG<=2;CONTRAST_SIG<=0;   end        
   // 8'd4:  begin BRIGHT_SIG<=0;CONTRAST_SIG<=2;  end
	default:begin BRIGHT_SIG<=0;CONTRAST_SIG<=1;  end
	endcase
	end
else begin
    a<=a;
	CONTRAST_SIG<=CONTRAST_SIG;
	BRIGHT_SIG<=BRIGHT_SIG;
	end
end
 
   
constrast_ipcore u_constrast_ipcore(
    .Pclk(clk),
    .Rst(rst_n),
    .Vsync(Vsync),
    .Hsync(Hsync),
    .De(De),
    .RGB(RGB),
    .CONTRAST_SIG(CONTRAST_SIG),
    .BRIGHT_SIG(BRIGHT_SIG),
    .CONTRAST(CONTRAST),
    .BRIGHT(BRIGHT),
    .Vsync_o(Vsync_o),
    .Hsync_o(Hsync_o),
    .De_o(De_o),
    .RGB_o(RGB_o)  
    ); 
     
    
    
    
endmodule

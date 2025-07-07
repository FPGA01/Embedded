module baohe_rgb(
//global clock
	input				clk,  				//cmos video pixel clock
	input				rst_n,				//global reset
	//Image data prepred to be processd
	input				per_frame_vsync,	//Prepared Image data vsync valid signal
	input				per_frame_href,		//Prepared Image data href vaild  signal
	input				per_frame_clken,	//Prepared Image data output/capture enable clock
	input		[7:0]	per_img_red,			//Prepared Image brightness input
	input		[7:0]	per_img_green,			//Prepared Image data of Cb
	input		[7:0]	per_img_blue,			//Prepared Image data of Cr
	//Image data has been processd
	output				post_frame_vsync,	//Processed Image data vsync valid signal
	output				post_frame_href,	//Processed Image data href vaild  signal
	output				post_frame_clken,	//Processed Image data output/capture enable clock
	output		[7:0]   post_img_red,			//Prepared Image data of Y
	output		[7:0]   post_img_green,	    //Prepared Image data of Cb
	output		[7:0]	post_img_blue,		//Prepared Image data of Cr
//key
	input				key			
   );
 
reg [15:0]r;
reg [7:0]a;

reg [7:0]temp_img_red;
reg [7:0]temp_img_green;
reg [7:0]temp_img_blue;

reg key_d;
always@(posedge clk or negedge rst_n)begin
if(!rst_n)
	begin 
		key_d <= 0;
	end
	else begin
	key_d <= key;end
end 
   
always@(posedge clk or negedge rst_n)begin
if(!rst_n)begin
	a<=8'd1;
end
else if ((key_d == 0)&&(key == 1))begin
	if(a<8'd1)a <= a + 8'd1;
	else a<=8'd0;
	end
	else begin
	a<=a;
	end
end 

always@(*)begin
case (a)
    8'd0: r <= (16'h0000);
    8'd1: r <= (16'h1000);
    8'd2: r <= (16'h1000);
    8'd3: r <= (16'h1000);
    8'd4: r <= (16'h0666);
    8'd5: r <= (16'h0800);
    8'd6: r <= (16'h099A);
    8'd7: r <= (16'h0B33);
    8'd8: r <= (16'h0CCD);
    8'd9: r <= (16'h0E66);
    8'd10:r <= (16'h1000);
   8'd11:r <= (16'h119A);
    8'd12:r <= (16'h1333);
    8'd13:r <= (16'h14CD);
    8'd14:r <= (16'h1666);
    8'd15:r <= (16'h1800);
    8'd16:r <= (16'h199A);
    8'd17:r <= (16'h1B33);
    8'd18:r <= (16'h1CCD);
    8'd19:r <= (16'h1E66);
    8'd20:r <= (16'h2000);
    8'd21:r <= (16'h219A);
    8'd22:r <= (16'h2333);
    8'd23:r <= (16'h24CD);
    8'd24:r <= (16'h2666);
    8'd25:r <= (16'h2800);
    8'd26:r <= (16'h299A);
    8'd27:r <= (16'h2B33);
    8'd28:r <= (16'h2CCD);
    8'd29:r <= (16'h2E66);
    8'd30:r <= (16'h3000);
    8'd31:r <= (16'h319A);
    8'd32:r <= (16'h3333);
    8'd33:r <= (16'h34CD);
    8'd34:r <= (16'h3666);
    8'd35:r <= (16'h3800);
    8'd36:r <= (16'h399A);
    8'd37:r <= (16'h3B33);
    8'd38:r <= (16'h3CCD);
    8'd39:r <= (16'h3E66);
    8'd40:r <= (16'h4000);
    8'd41:r <= (16'h419A);
    8'd42:r <= (16'h4333);
    8'd43:r <= (16'h44CD);
    8'd44:r <= (16'h4666);
    8'd45:r <= (16'h4800);
    8'd46:r <= (16'h499A);
    8'd47:r <= (16'h4B33);
    8'd48:r <= (16'h4CCD);
    8'd49:r <= (16'h4E66);
    8'd50:r <= (16'h5000);
	default:r<=(16'h1000);
	endcase
end  

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
	temp_img_red<=0;
	temp_img_green<=0;
	temp_img_blue<=0;
	end
	else begin
	temp_img_red<=per_img_red - ((per_img_blue>>1) + (per_img_green>>1));
	temp_img_green<=per_img_green - ((per_img_blue>>1) + (per_img_red>>1));
	temp_img_blue<=per_img_blue - ((per_img_red>>1) + (per_img_green>>1));
	end
end

wire [23:0]p1;
wire [23:0]p2;
wire [23:0]p3;

mult mult1 (
  .a(temp_img_red),        // input [7:0]
  .b(r),        // input [15:0]
  .clk(clk),    // input
  .rst(!rst_n),    // input
  .ce(1'b1),      // input
  .p(p1)         // output [23:0]
);

mult mult2 (
  .a(temp_img_green),        // input [7:0]
  .b(r),        // input [15:0]
  .clk(clk),    // input
  .rst(!rst_n),    // input
  .ce(1'b1),      // input
  .p(p2)         // output [23:0]
);

mult mult3 (
  .a(temp_img_blue),        // input [7:0]
  .b(r),        // input [15:0]
  .clk(clk),    // input
  .rst(!rst_n),    // input
  .ce(1'b1),      // input
  .p(p3)         // output [23:0]
);

wire [7:0]per_img_red0;
wire [7:0]per_img_green0;
wire [7:0]per_img_blue0;

shift_regs#(
    .DWIDTH(24),   
    .DELAY_DUTY(4)
)shift_regs_0
(
    .clk(clk),
    .rst_n(rst_n),
    .idata({per_img_red,per_img_green,per_img_blue}),
    .odata({per_img_red0,per_img_green0,per_img_blue0})
);

reg [7:0]mid_img_red;
reg [7:0]mid_img_green;
reg [7:0]mid_img_blue;

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
	mid_img_red<=0;
	mid_img_green<=0;
	mid_img_blue<=0;
	end
	else if(r==16'h1000) begin
	mid_img_red<=per_img_red0 - (p1>>12);
	mid_img_green<=per_img_green0 - (p2>>12);
	mid_img_blue<=per_img_blue0 - (p3>>12);
	end
	else begin
	mid_img_red<=per_img_red0 + (p1>>12);
	mid_img_green<=per_img_green0 + (p2>>12);
	mid_img_blue<=per_img_blue0 + (p3>>12);
	end
end


reg	[4:0]per_frame_vsync_r;
reg	[4:0]per_frame_href_r;	
reg	[4:0]per_frame_clken_r;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		per_frame_vsync_r <= 0;
		per_frame_href_r <= 0;
		per_frame_clken_r <= 0;
		end
	else
		begin
		per_frame_vsync_r 	<= 	{per_frame_vsync_r[3:0], 	per_frame_vsync};
		per_frame_href_r 	<= 	{per_frame_href_r[3:0], 	per_frame_href};
		per_frame_clken_r 	<= 	{per_frame_clken_r[3:0], 	per_frame_clken};
		end
end
assign	post_frame_vsync 	= 	per_frame_vsync_r[4];
assign	post_frame_href 	= 	per_frame_href_r[4];
assign	post_frame_clken 	= 	per_frame_clken_r[4];

assign post_img_red  =  post_frame_href ? mid_img_red  : 8'd0;
assign post_img_green = post_frame_href ? mid_img_green: 8'd0;
assign post_img_blue =  post_frame_href ? mid_img_blue : 8'd0;








  
endmodule
module sedu_setup(
//global clock
	input				clk,  				//cmos video pixel clock
	input				rst_n,				//global reset

	//Image data prepred to be processd
	input				per_frame_vsync,	//Prepared Image data vsync valid signal
	input				per_frame_href,		//Prepared Image data href vaild  signal
	input				per_frame_clken,	//Prepared Image data output/capture enable clock
	input		[7:0]	per_img_Y,			//Prepared Image brightness input
	input		[7:0]	per_img_Cb,			//Prepared Image data of Cb
	input		[7:0]	per_img_Cr,			//Prepared Image data of Cr
	//Image data has been processd
	output				post_frame_vsync,	//Processed Image data vsync valid signal
	output				post_frame_href,	//Processed Image data href vaild  signal
	output				post_frame_clken,	//Processed Image data output/capture enable clock
	output		[7:0]	post_img_Y,			//Prepared Image data of Y
	output		[7:0]	post_img_Cb,	    //Prepared Image data of Cb
	output		[7:0]	post_img_Cr,		//Prepared Image data of Cr

//key
	input				key		
   );
   
reg key_d;
always@(posedge clk or negedge rst_n)begin
if(!rst_n)
	begin 
		key_d <= 0;
	end
	else begin
	key_d <= key;end
end   
   
   
   

reg signed [31:0]cos;
reg  [31:0]sin;
reg [7:0]a;
reg [7:0]temp_img_Y; 
reg [7:0]temp_img_Cb;
reg [7:0]temp_img_Cr;
always@(posedge clk or negedge rst_n)
begin
if(!rst_n)begin
	a<=8'd1;
	sin <= (17'd0);      
	cos <= (17'd65536);
end
else if((key_d == 0)&&(key == 1))begin
	if(a<8'd9)a <= a + 8'd1;
	else a<=8'd1;
case (a)
    8'd1:   begin sin <= (17'd0);      cos <= (17'd65536);  end        //0     1
    8'd2:  begin sin <= (17'd32769);  cos <= (17'd56759);   end        //0.5   0.866
    8'd3:  begin sin <= (17'd46341);  cos <= (17'd46341);   end        //0.707
    8'd4:  begin sin <= (17'd56759);  cos <= (17'd32769);   end        //0.866 0.5
    8'd5:  begin sin <= (17'd65536);  cos <= (17'd0);       end        //1     0
    8'd6: begin sin <= (17'd56759);  cos <= (-17'd32769);   end        //0.866  -0.5
    8'd7: begin sin <= (17'd46341);  cos <= (-17'd46341);   end        //0.707   -0.707
    8'd8: begin sin <= (17'd32769);  cos <= (-17'd56759);   end        //0.5  -0.866
    8'd9: begin sin <= (17'd0);      cos <= (-17'd65536);   end        //0   -1
	default:begin sin <= (17'd0);      cos <= (17'd65536);  end 
	endcase
	end
	else begin
		a<=a;
		sin<=sin;
		cos<=cos;
	end
end   

always@(posedge clk or negedge rst_n)
begin
if(!rst_n)begin
	temp_img_Y<= 0;
	temp_img_Cb<= 0;
    temp_img_Cr<= 0;
	end
else begin
	temp_img_Y<=  per_img_Y;
	temp_img_Cb<= ((per_img_Cb*cos)>>>16) + ((per_img_Cr*sin)>>>16);
	temp_img_Cr<= ((per_img_Cr*cos)>>>16) - ((per_img_Cb*sin)>>>16);
	end
end
   
reg	per_frame_vsync_r;
reg	per_frame_href_r;	
reg	per_frame_clken_r;
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
		per_frame_vsync_r 	<= 	{per_frame_vsync_r, 	per_frame_vsync};
		per_frame_href_r 	<= 	{per_frame_href_r, 	per_frame_href};
		per_frame_clken_r 	<= 	{per_frame_clken_r, 	per_frame_clken};
		end
end
assign	post_frame_vsync 	= 	per_frame_vsync_r;
assign	post_frame_href 	= 	per_frame_href_r;
assign	post_frame_clken 	= 	per_frame_clken_r;
assign	post_img_Y 	= 	post_frame_href ? temp_img_Y : 8'd0;
assign	post_img_Cb =	post_frame_href ? temp_img_Cb: 8'd0;
assign	post_img_Cr = 	post_frame_href ? temp_img_Cr: 8'd0;  
   
   
   
   
endmodule
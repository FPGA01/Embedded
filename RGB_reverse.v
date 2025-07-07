module RGB_reverse(
	//global clock
	input				clk,  				//cmos video pixel clock
	input				rst_n,				//global reset
	//Image data prepred to be processd
	input				per_frame_vsync,	//Prepared Image data vsync valid signal
	input				per_frame_href,		//Prepared Image data href vaild  signal
	input				per_frame_clken,	//Prepared Image data output/capture enable clock
	input		[15:0]	per_img,			//Prepared Image brightness input
	//Image data has been processd
	output				post_frame_vsync,	//Processed Image data vsync valid signal
	output				post_frame_href,	//Processed Image data href vaild  signal
	output				post_frame_clken,	//Processed Image data output/capture enable clock
	output		[15:0]   post_img			//Prepared Image data of Y
   );

wire[4:0]inve_R ;
wire[5:0]inve_G ;
wire[4:0]inve_B ;
   
assign inve_R = 5'b11111  - per_img[15:11];
assign inve_G = 6'b111111 - per_img[10:5];
assign inve_B = 5'b11111  - per_img[4:0];   

assign post_img  = {inve_R,inve_G,inve_B};  
assign post_frame_vsync  =per_frame_vsync;
assign post_frame_href   =per_frame_href;
assign post_frame_clken  =per_frame_clken; 
   
endmodule
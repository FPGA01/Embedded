`timescale 1ns/1ns
module sedu(
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



wire 		post0_frame_vsync; 
wire 		post0_frame_href ; 
wire 		post0_frame_clken; 
wire [7:0]	post0_img_Y      ; 
wire [7:0]	post0_img_Cb     ; 
wire [7:0]	post0_img_Cr     ; 

RGB888_YCbCr444	u_RGB888_YCbCr444
(
	//global clock
	.clk				(clk),					//cmos video pixel clock
	.rst_n				(rst_n),				//system reset

	//Image data prepred to be processd
	.per_frame_vsync	(per_frame_vsync),		//Prepared Image data vsync valid signal
	.per_frame_href		(per_frame_href),		//Prepared Image data href vaild  signal
	.per_frame_clken	(per_frame_clken),		//Prepared Image data output/capture enable clock
	.per_img_red		(per_img_red),			//Prepared Image red data input
	.per_img_green		(per_img_green),		//Prepared Image green data input
	.per_img_blue		(per_img_blue),			//Prepared Image blue data input
	
	//Image data has been processd
	.post_frame_vsync	(post0_frame_vsync),		//Processed Image frame data valid signal
	.post_frame_href	(post0_frame_href),		//Processed Image hsync data valid signal
	.post_frame_clken	(post0_frame_clken),		//Processed Image data output/capture enable clock
	.post_img_Y			(post0_img_Y),			//Processed Image brightness output
	.post_img_Cb		(post0_img_Cb),			//Processed Image blue shading output
	.post_img_Cr		(post0_img_Cr)			//Processed Image red shading output
);

wire 		post1_frame_vsync; 
wire 		post1_frame_href ; 
wire 		post1_frame_clken; 
wire [7:0]	post1_img_Y      ; 
wire [7:0]	post1_img_Cb     ; 
wire [7:0]	post1_img_Cr     ; 

sedu_setup u_sedu_setup
(
	//global clock
	.clk(clk),  				//cmos video pixel clock
	.rst_n(rst_n),				//global reset

	//Image data prepred to be processd
	.per_frame_vsync(post0_frame_vsync),	//Prepared Image data vsync valid signal
	.per_frame_href(post0_frame_href),		//Prepared Image data href vaild  signal
	.per_frame_clken(post0_frame_clken),	//Prepared Image data output/capture enable clock
	.per_img_Y(post0_img_Y),			//Prepared Image brightness input
	.per_img_Cb(post0_img_Cb),			//Prepared Image data of Cb
	.per_img_Cr(post0_img_Cr),			//Prepared Image data of Cr
	//Image data has been processd
	.post_frame_vsync(post1_frame_vsync),	//Processed Image data vsync valid signal
	.post_frame_href(post1_frame_href),	//Processed Image data href vaild  signal
	.post_frame_clken(post1_frame_clken),	//Processed Image data output/capture enable clock
	.post_img_Y(post1_img_Y),		//Prepared Image data of Y
	.post_img_Cb(post1_img_Cb),	    //Prepared Image data of Cb
	.post_img_Cr(post1_img_Cr),		//Prepared Image data of Cr

//key
	.key(key)				
);


YCbCr444_RGB888 u_YCbCr444_RGB888
(
	//global clock
	.clk(clk),  				//cmos video pixel clock
	.rst_n(rst_n),				//global reset

	//CMOS YCbCr444 data output
	.per_frame_vsync(post1_frame_vsync),	//Prepared Image data vsync valid signal
	.per_frame_href(post1_frame_href),		//Prepared Image data href vaild  signal
	.per_frame_clken(post1_frame_clken),	//Prepared Image data output/capture enable clock	
	.per_img_Y(post1_img_Y),			//Prepared Image data of Y
	.per_img_Cb(post1_img_Cb),			//Prepared Image data of Cb
	.per_img_Cr(post1_img_Cr),			//Prepared Image data of Cr

	
	//CMOS RGB888 data output
	.post_frame_vsync(post_frame_vsync),	//Processed Image data vsync valid signal
	.post_frame_href(post_frame_href),	//Processed Image data href vaild  signal
	.post_frame_clken(post_frame_clken),	//Processed Image data output/capture enable clock
	.post_img_red(post_img_red),		//Prepared Image green data to be processed	
	.post_img_green(post_img_green),		//Prepared Image green data to be processed
	.post_img_blue(post_img_blue)		//Prepared Image blue data to be processed
);


endmodule
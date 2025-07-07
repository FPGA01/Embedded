module YCbCr_reverse(
		//global clock
		input					clk,  				//cmos video pixel clock
		input					rst_n,				//global reset
		//Image data prepred to be processd
		input					per_frame_vsync,	//Prepared Image data vsync valid signal
		input					per_frame_href,		//Prepared Image data href vaild  signal
		input					per_frame_clken,	//Prepared Image data output/capture enable clock
		input		[7:0]		per_img_Y,			//Prepared Image brightness input
		
		//Image data has been processd
		output					post_frame_vsync,	//Processed Image data vsync valid signal
		output					post_frame_href,	//Processed Image data href vaild  signal
		output					post_frame_clken,	//Processed Image data output/capture enable clock
		output		[7:0]		post_img_Y			//Processed Image Bit flag outout(1: Value, 0:inValid)
   );
 

assign post_frame_vsync  =per_frame_vsync;
assign post_frame_href   =per_frame_href;
assign post_frame_clken  =per_frame_clken;
assign post_img_Y    = 8'd255 - per_img_Y; //灰度反转

  
   
endmodule
module signalSender (input [9:0]xpixel, input [8:0]ypixel, input strike, output reg signal);

	
	always@(*)
		begin
			if(strike == 1'b1)
				begin 
					signal <= 1'b1;
				end
			else if((xpixel == 3'b111) && (ypixel <= 8'b11100110) && (ypixel >= 8'b10101111))
				begin
					signal <= 1'b1;
				end
			else 
				begin 
					signal <= 0;
				end
				
			end
		
endmodule


module AI (input reset, input clock, input gameOver, input en, output [3:0]dy, output [3:0]dx, output throw);
	wire clockwire;
	wire [3:0] numwire;

	randomNumGen rng1(.clock(clock), .reset(reset), .enable(en), .num(numwire)); 
	throwRanges tr1(.sel(numwire), .details(tdetails));
	
	
		assign throw = (en && !gameOver)?1:0;
		wire [7:0]tdetails;
	
	assign dy = tdetails[7:4];
	assign dx = tdetails[3:0];
	
endmodule

module randomNumGen (input clock, input reset, input enable, output reg[3:0]num);

	
	
	reg [18:0] rand, randnxt, randdon;

	
	wire fb = rand[18] ^ rand[5] ^ rand[1] ^ rand[0];
	
	always @ (posedge clock or posedge reset) 
	begin
		if (reset == 1)
				begin 
					rand <= 19'b1111111111111111111;
					
				end
		else
				begin 
				 rand <= randnxt;
				
				end 
	end
	
	always @(*)
		begin 
			randnxt = rand;
			randnxt = {rand[17:0],fb};
			randdon = rand;

		end 
		
	always @(randdon)
		begin
			if (enable == 1)
				begin 
					num = randdon[3:0];
				end
		end
		
endmodule



module throwRanges (input sel, output reg [7:0]details);
	
	
	always@(sel)
		begin 
			case(sel)
				4'b0000: details = {4'b0001, 4'b0010};
				4'b0001: details = {4'b0010, 4'b0100};
				4'b0010: details = {4'b0010, 4'b0011};
				4'b0011: details = {4'b0010, 4'b0011};
				4'b0100: details = {4'b0001, 4'b0010};
				4'b0101: details = {4'b0010, 4'b0010};
				4'b0110: details = {4'b0010, 4'b0011};
				4'b0111: details = {4'b0010, 4'b0100};
				4'b1000: details = {4'b0010, 4'b0011};
				4'b1001: details = {4'b0001, 4'b0010};
				4'b1010: details = {4'b0010, 4'b0011};
				4'b1011: details = {4'b0010, 4'b0100};
				4'b1100: details = {4'b0010, 4'b0010};
				4'b1101: details = {4'b0010, 4'b0011};
				4'b1110: details = {4'b0001, 4'b0010};
				4'b1111: details = {4'b0010, 4'b0100};
				default : details = {4'b0010,4'b0100};
			endcase
		end
		
endmodule

	
			
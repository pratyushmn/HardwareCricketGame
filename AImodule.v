module AI (input reset, input clock, input en, output throw, output [3:0] dx, dy, sel);
	wire clockwire;
	wire [3:0] numwire;
	wire [7:0] throwDetails;
	//wire [7:0]td;
		
	
	//clockSignalGen csg1(.clock(clock50), .gameOver(gameOver), .reset(reset), .clockSignal(clockwire));
	randomNumGen rng1(.clock(clock), .reset(reset), .enable(en), .num(numwire)); 
	throwRanges tr1(.sel(numwire), .details(throwDetails));
	
	assign throw = en;
	
	assign dy = throwDetails[7:4];
	assign dx = throwDetails[3:0];
	assign sel = numwire;
	//assgin throw = clockwire;
	
endmodule


module clockSignalGen(input clock, input gameOver, input reset, output clockSignal);
		
		reg [27:0]count;
	
	always @(posedge clock)
		begin 
			if (reset == 1'b1 || gameOver == 1'b1)
				count <= 28'b1011111010111100001000000000;
				
			else if (count == 0)
				count <= 28'b1011111010111100001000000000;
			else
				count <= count - 1;
		end
	
				assign clockSignal = (count == 0)?1:0;
			
			
endmodule 


module randomNumGen (input clock, input reset, input enable, output reg[3:0]num);

	
	
	reg [18:0] rand, randnxt, randdon;
	//reg [2:0] counter, counternext;
	
	wire fb = rand[18] ^ rand[5] ^ rand[1] ^ rand[0];
	
	always @ (posedge clock or posedge reset) 
	begin
		if (reset == 1)
				begin 
					rand <= 19'b1111111111111111111;
					//num <= 4'b0000;
					//randdon <= 19'b1111111111111111111;
					//count <= 0;
				end
		else
				begin 
				 rand <= randnxt;
				 //counter = counternext;
				end 
	end
	
	always @(*)
		begin 
			randnxt = rand;
			//counternext = count;
				
				randnxt = {rand[17:0],fb};
				//countnext = counter + 1;
				
//		if(counter == 8)
//			begin 
//				counter = 0;
			randdon = rand;
//			end
		
	//	detail = randdon[3:0]
		
		end 
		
	always @(randdon)
		begin
			if (enable == 1)
				begin 
					num = randdon[3:0];
				end
		end
		
endmodule



module throwRanges (input [3:0] sel, output reg [7:0]details);
	
	
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
				default : details = {4'b0001,4'b0010};
			endcase
		end
		
endmodule


module HEX(B,S);
    input [3:0]B;
	 output [6:0]S;
    wire [6:0]W; wire [3:0]D;
    assign D = B;
    assign W[0] = !((!D[0]|D[1]|D[2]|D[3]) & (D[0]|D[1]|!D[2]|D[3]) & (!D[0]|!D[1]|D[2]|!D[3]) & (!D[0]|D[1]|!D[2]|!D[3]));
    assign W[1] = !((!D[0]|D[1]|!D[2]|D[3]) & (D[0]|!D[1]|!D[2]|D[3]) & (!D[0]|!D[1]|D[2]|!D[3]) & (D[0]|D[1]|!D[2]|!D[3]) & (D[0]|!D[1]|!D[2]|!D[3]) & (!D[0]|!D[1]|!D[2]|!D[3]));
    assign W[2] = !((D[0]|!D[1]|D[2]|D[3]) & (D[0]|D[1]|!D[2]|!D[3]) & (D[0]|!D[1]|!D[2]|!D[3]) & (!D[0]|!D[1]|!D[2]|!D[3]));
    assign W[3] = !((!D[0]|D[1]|D[2]|D[3]) & (D[0]|D[1]|!D[2]|D[3]) & (!D[0]|!D[1]|!D[2]|D[3]) & (D[0]|!D[1]|D[2]|!D[3]) & (!D[0]|!D[1]|!D[2]|!D[3]));
    assign W[4] = !((!D[0]|D[1]|D[2]|D[3]) & (!D[0]|!D[1]|D[2]|D[3]) & (D[0]|D[1]|!D[2]|D[3]) & (!D[0]|D[1]|!D[2]|D[3]) & (!D[0]|!D[1]|!D[2]|D[3]) & (!D[0]|D[1]|D[2]|!D[3]));
    assign W[5] = !((!D[0]|D[1]|D[2]|D[3]) & (D[0]|!D[1]|D[2]|D[3]) & (!D[0]|!D[1]|D[2]|D[3]) & (!D[0]|!D[1]|!D[2]|D[3])&(!D[0]|D[1]|!D[2]|!D[3]));
    assign W[6] = !((D[0]|D[1]|D[2]|D[3]) & (!D[0]|D[1]|D[2]|D[3]) & (!D[0]|!D[1]|!D[2]|D[3]) & (D[0]|D[1]|!D[2]|!D[3]));
    assign S = W;
endmodule
			
module GameAnalyzer (input reset,
							input throw,
							input strike,
							input [8:0]pixelx,
							input [7:0]pixely,
							input clock,
							output gameOverSignal,
							output [3:0]counter,
							output out,
							output four, 
							output two, 
							output six,
							output one,
							output zero,
							output [6:0]hex0,
							output [6:0]hex1,
							output [6:0]hex2,
							output [6:0]hex3,
							output [6:0]hex4,
							output [6:0]hex5);
							
		wire [3:0] score1wire;
		wire [3:0] score10wire; 
		wire [3:0] score100wire;
		wire [3:0] ballwire;
		wire [3:0] overwire;
		wire overSignal;
		wire outwire;
		wire zerowire;
		wire onewire;
		wire twowire;
		wire fourwire;
		wire sixwire;
		wire isGameOver;
		wire counterwire;
		wire hit;
		
	assign out = outwire;
	assign four = fourwire;
	assign six = sixwire;
	assign two = twowire;
	assign one = onewire;
	
	assign zero = zerowire;
		
		
		runDetector r1(.pixelx(pixelx),
							.pixely(pixely),
							.strike(strike),
							.reset(reset),
							.out(outwire),
							.zero(zerowire),
							.one(onewire),
							.two(twowire),
							.four(fourwire),
							.six(sixwire));
							
		ScoreKeeper sk1( .throw(throw),
							  .strike(strike),
							  .out(outwire),
							  .zero(zerowire), 
							  .one(onewire),
							  .two(twowire),
							  .four(fourwire),
							  .six(sixwire),
							  .clock(clock), 
							  .reset(reset), 
							  .gameOver(gameOverSignal),
							  .scorehundreds(score100wire), 
							  .scoretens(score10wire), 
							  .scoreones(score1wire), 
							  .count(counterwire));
							  
		OverCount oc1( .overdone(overSignal), .clock(clock), .reset(reset), .out(outwire), .over(overwire), .gameOver(gameOverSignal));
		
		BallCount bc1( .throw(throw), .out(outwire), .gameOver(gameOverSignal), .clock(clock), .reset(reset), .ball(ballwire), .over(overSignal));
		
		hexDecoder scoreh0 ( .B(score1wire), .S(hex0));
		hexDecoder scoreh1 ( .B(score10wire), .S(hex1));
		hexDecoder scoreh2 ( .B(score100wire), .S(hex2));
		hexDecoder runsh3 ( .B(counterwire), .S(hex3));
		hexDecoder ballcounth4 ( .B(ballwire), .S(hex4));
		hexDecoder overcounth5 ( .B(overwire), .S(hex5));
		
	
		
endmodule

module runDetector (input [8:0]pixelx,
						  input [7:0]pixely,
                    input strike,
						  input reset,
						  output reg out,
						  output reg zero,
						  output reg one,
						  output reg two,
						  output reg four,
						  output reg six);

	always@(*)
		begin
			if(reset == 1'b1)
				begin
					one <= 0;
					two <= 0;
					four <= 0;
					six <= 0;
					zero <= 0;
					out <= 0;
				end
			else
				begin
					if ((pixelx >= 5'b10111) && (pixelx  < 6'b101101))
						begin
							zero <= 0;
							two <= 0;
							four <= 0;
							six <= 0;
							out <= 0;
							one <= 1'b1;
						end
					else if ((pixelx >= 6'b101101) && (pixelx  < 7'b1000111))
						begin 
							zero <= 0;
							one <= 0;
							four <= 0;
							six <= 0;
							out <= 0;
							two <= 1'b1;
						end
					else if ((pixelx >= 7'b1000111) && (pixelx  < 7'b1100100))
						begin 
							zero <= 0;
							one <= 0;
							two <= 0;
							six <= 0;
							out <= 0;
							four <= 1'b1;
						end
					else if ((pixelx >= 7'b1100100) && (pixelx  < 8'b01110100))
						begin
							zero <= 0;
							one <= 0;
							two <= 0;
							four <= 0;
							out <= 0;
							six <= 1'b1;
						end 
					else if ((pixelx >= 8'b01110100) && (pixelx  < 8'b10010001))
						begin
							zero <= 0;
							one <= 0;
							two <= 0;
							six <= 0;
							out <= 0;
							four <= 1'b1;
						end
					else if ((pixelx >= 8'b10010001) && (pixelx  < 8'b10101011))
						begin 
							zero <= 0;
							one <= 0;
							four <= 0;
							six <= 0;
							out <= 0;
							two <= 1'b1;
						end
					else if ((pixelx <= 3'b111) && (pixelx >= 3'b100) && (pixely <= 8'b11100110) && (pixely >= 8'b10101111))
						begin 
							zero <= 0;
							one <= 0;
							two <= 0;
							four <= 0;
							six <= 0;
							out <= 1'b1;
						end
					else 
						begin
							zero <= 1'b1;
							one <= 0;
							two <= 0;
							four <= 0;
							six <= 0;
							out <= 0;
						end					

				end
		end

endmodule 


module ScoreKeeper (input throw, 
						  input strike,
						  input out,
						  input zero,
					     input one,
						  input two,
						  input four,
						  input six,
						  input clock, 
						  input reset, 
						  input gameOver,
						  output reg [3:0]scorehundreds, 
						  output reg [3:0]scoretens, 
						  output reg[3:0]scoreones,
						  output reg[3:0]count);

	
	
	
	always@(posedge clock)
		begin 
			if(reset == 1'b1)
				begin 
					count <= 0;
					scoreones <= 0;
					scoretens <= 0;
					scorehundreds <= 0;
				end
			else if (gameOver == 1'b1)
				begin
					count <= 0;
				end
			else if(strike == 1'b1)
				begin
					if (out == 1'b1)
						begin
							count <= 0;
						end
					else if (one == 1'b1)
						begin
							count <= 4'b0001;
						end
					else if (two == 1'b1)
						begin
							count <= 4'b0010;
						end
					else if (four == 1'b1)
						begin
							count <= 4'b0100;
						end
					else if (six == 1'b1)
						begin
							count <= 4'b0110;	
						end
					else
						begin
						 count <= 4'b0000;
						end
				end
			
			if(count != 0)
				begin
					count <= count - 1;
					if(scoreones == 4'b1001)
						begin
							scoreones <= 0;
							if(scoretens == 4'b1001)
								begin
									scorehundreds <= scorehundreds + 1'b1;
									scoretens <= 0;
								end
							else 
								begin
									scoretens <= scoretens + 1'b1;
								end
						end
					else 
						begin
							scoreones <= scoreones + 1'b1;
						end
				end
			 else if (reset == 1'b1)
				begin
					scoreones <= 0;
					scoretens <= 0;
					scorehundreds <=0;
				end
			else
				begin 
					scoreones <= scoreones;
					scoretens <= scoretens;
					scorehundreds <= scorehundreds;
				end
		end
			
endmodule


module BallCount (input throw, input out, input gameOver, input clock, input reset, output reg [3:0]ball, output reg over);

	

	always @(posedge clock)
		begin
			if (reset == 1'b1)
				begin
					ball <= 0;
					over <= 0;
				end
			else if (throw == 1'b1)
				begin
					 if(ball == 4'b0101)
						begin 
							ball <= 0;
							over <= 1;
						end
					
					else
						begin 
							ball <= ball + 1;
							over <= 0;
						end
					if (gameOver)
						begin
							ball <= 0;
						end
				end
			else if (gameOver)
				begin
					ball <= 0;
				end
			else 
				begin
					over <= 0;
				end
		end
		
endmodule

module OverCount (input overdone, input clock, input reset, input out, output reg [3:0]over, output reg gameOver);
	
	always @(posedge clock)
		begin 
			if (reset == 1'b1)
				begin
					over <= 0;
					gameOver <= 0;
				end
			else if (out == 1'b1)
						begin
							gameOver <= 1;
						end
			else if (overdone == 1'b1)
				begin
					over <= over + 1;
					if (over == 4'b0101)
						begin
							gameOver <= 1;
						end
					else 
						begin
							gameOver <= 0;
						end
				end
		end		
		
endmodule

		
		
module hexDecoder(B,S);
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
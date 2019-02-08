module Project
	(
		CLOCK_50,						//	On Board 50 MHz 
		KEY, 
		HEX0,
		HEX1,
		HEX2,
		//HEX3,
		HEX4,
		HEX5,
		SW,
		LEDR,
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[7:0]
		VGA_G,	 						//	VGA Green[7:0]
		VGA_B   						 //	VGA Blue[7:0]
	);
	
	// Declare your inputs and outputs here
	input [3:0] KEY;
	input [9:0] SW;
	output [6:0] HEX0, HEX1, HEX2, HEX4, HEX5;
	//output [6:0] HEX3;
	output [9:0] LEDR;   
	input CLOCK_50;
   	
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0]
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire start;
	assign start = !KEY[1];
	wire clear, enable, resetn, reset_AI;
	reg [26:0] count;
	reg [30:0] count2;
	wire finish, upFlag, doneDraw, doneDelete, doneOver;
	wire load_Score, load_New, load_shiftD, load_shiftU, load_shiftL, load_Del, load_Done, load_Reset, load_Over, score_w, enable2;
	wire writeEnable, busy;
	wire [8:0] X;
	wire [7:0] Y;
	wire [11:0] colour;
	wire [3:0] dx, dy;
	wire throwSignal;
	wire boom;
	wire gameOverSignal;
	wire signalwire;
	wire hitSignal;
	wire onewire, twowire, fourwire, sixwire, outwire, zerowire;
	wire [8:0]xposition;
	wire [7:0]yposition;
		
	assign reset_AI = SW[0];
	
	// always block for clock (every one second)
	
	always @(posedge CLOCK_50) begin
	   if(clear==1'b1)
		   count<=26'd0;
	   else
		   count<=count+1'b1;
	end
	
	always @(posedge CLOCK_50) begin
	   if(enable2==1'b1)
		   count2<=count2+1'b1;
	   else
		   count2<=0;
	end

	assign clear=enable;
	assign enable=(count==26'd3125000)?1'b1:1'b0;
	assign enable2=(count2==30'd500000000)?1'b1:1'b0;

	assign LEDR[7] = load_Reset;
	assign LEDR[8] = load_Score;
	assign LEDR[9] = score_w;
	assign LEDR[0] = gameOverSignal;

	AI A0(.reset(load_Over), .clock(CLOCK_50), .gameOver(gameOverSignal), .en(load_Reset), .dx(dx), .dy(dy), .throw(throwSignal));
	
	Strike s1 (.swing(KEY[0]), .clock(CLOCK_50), .reset(), .strike(boom));
	
	
	GameAnalyzer g1(.reset(start),
					 .throw(throwSignal),
					 .strike(signalwire),
					 .pixelx(xposition),
					 .pixely(yposition),
					 .clock(CLOCK_50),
					 .gameOverSignal(gameOverSignal),
					 .out(outwire),
					 .four(fourwire),
					 .one(onewire),
					 .two(twowire),
					 .six(sixwire),
					 .zero(zerowire),
					 .counter(),
					 .hex0(HEX0),
					 .hex1(HEX1),
					 .hex3(),
					 .hex2(HEX2),
					 .hex4(HEX4),
					 .hex5(HEX5));
	
	signalSender ss1( .xpixel(xposition), .ypixel(yposition), .strike(boom), .signal(signalwire));
	
	// control and datapath modules
	control C0(.clock(CLOCK_50), .resetn(!signalwire), .finish(finish), .start(start), .enable1(enable), .upFlag(upFlag), .doneDraw(doneDraw), .doneDelete(doneDelete), .doneOver(doneOver),
				.load_New(load_New), .load_shiftD(load_shiftD), .load_shiftU(load_shiftU), .load_shiftL(load_shiftL),
				.load_Del(load_Del), .load_Done(load_Done), .load_Reset(load_Reset), .load_Over(load_Over), .load_Score(load_Score), .enable2(enable2), .gameOver(gameOverSignal), 
				.doneScore(doneScore), .score_w(score_w));
	
	datapath D0(.clock(CLOCK_50), .resetn(!signalwire), 
				.load_New(load_New), .load_shiftD(load_shiftD), .load_shiftU(load_shiftU), .load_shiftL(load_shiftL),
				.load_Del(load_Del), .load_Done(load_Done), .load_Reset(load_Reset), .load_Over(load_Over), .load_Score(load_Score),
				.writeEn(writeEnable), .busy(busy), .upFlag(upFlag), .doneDraw(doneDraw), .doneDelete(doneDelete), .doneOver(doneOver), .doneScore(doneScore), .finish(finish),
				.X(X), .Y(Y), .colour(colour), .dx(dx), .dy(dy), .x_reg(xposition), .y_reg(yposition),
				.one(onewire), .two(twowire), .four(fourwire), .six(sixwire), .zero(zerowire), .out(outwire));
				
	
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(1'b1),
			.clock(CLOCK_50),
			.colour(colour),
			.x(X),
			.y(Y),
			.plot(writeEnable),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
			
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 4;
		defparam VGA.BACKGROUND_IMAGE = "startscreen.mif";		
endmodule

module control (clock,resetn, finish, start,
   load_shiftD,      
   load_shiftU,
   load_shiftL,
   load_Del,
   load_Reset,
   load_Done,
	load_Over,
   enable1,
   upFlag,
   doneDraw,
	doneDelete,
	doneOver,
	doneScore,
	load_New, enable2, gameOver, load_Score, score_w);

	input clock, resetn, enable1, upFlag, doneDraw, finish, doneScore, doneDelete, doneOver, finish, start, gameOver, enable2;
	output reg load_New, load_shiftD, load_shiftU, load_shiftL, load_Del, load_Done, load_Reset, load_Over, load_Score, score_w;
	reg [5:0] current_state, next_state; 
    
    localparam  S_Reset         = 5'd0, 
					 S_StartAnimation= 5'd1,                
                S_ShiftUp       = 5'd2,
					 S_ShiftDown     = 5'd3,
                S_ShiftLeft     = 5'd4,
					 S_PrintNew      = 5'd5,
					 S_PrintWait     = 5'd6,
					 S_Delete        = 5'd7,
					 S_Done          = 5'd8,
					 S_Initial       = 5'd9,
					 S_Over			  = 5'd10,
					 S_Score			  = 5'd11,
					 S_ScoreWait     = 5'd12;
					 
					 
	always@(*)
		
	 begin: state_table 
			 
		  case (current_state)
		  
			S_Initial: next_state = start? S_Delete: S_Initial;
				  
			S_Reset: next_state = S_StartAnimation;
			
			S_StartAnimation: next_state = upFlag? S_ShiftUp : S_ShiftDown;
			
			S_ShiftUp: next_state = S_ShiftLeft; 

			S_ShiftDown: next_state = S_ShiftLeft; 
			
			S_ShiftLeft: next_state = S_PrintNew;
						
			S_PrintNew: next_state =  doneDraw? S_PrintWait : S_PrintNew;
			
			S_PrintWait: next_state = enable1? S_Delete : S_PrintWait;
			
			S_Delete: next_state = doneDelete? S_Done : S_Delete;
						
			S_Done: begin 
						if (gameOver)
							begin
								next_state = S_Over;
							end
						else if (finish || (!resetn))
							begin 
								next_state = S_Score;
							end
						else 
							begin
								next_state = S_StartAnimation;
							end
						end
						
			S_Score: next_state = doneScore? S_ScoreWait: S_Score;
			
			S_ScoreWait: next_state = enable2? S_Reset: S_ScoreWait;
			
			S_Over: next_state = doneOver? S_Initial : S_Over;
			
			
			default:
				next_state = S_Initial;
				
			endcase
	 end
	 
	// Output logic aka all of our datapath control signals
		
	always @(*)
	  
	  begin: enable_signals
			 // By default make all our signals 0
			
	  load_shiftD=1'b0;       
	  load_shiftU=1'b0;
	  load_shiftL=1'b0;
	  load_Del=1'b0;
	  load_Reset = 1'b0;
	  load_Done = 1'b0; 
	  load_New = 1'b0;
	  load_Over = 1'b0;
	  load_Score = 1'b0;
	  score_w = 1'b0;
	  
	  
	 case (current_state)
	 
		S_StartAnimation : begin
		
			load_shiftU=1'b0;
			load_shiftL=1'b0;
			load_Del=1'b0;
			load_Reset = 1'b0;
			load_shiftD = 1'b0; 
			load_Done = 1'b0;
			load_New = 1'b0;
			load_Over = 1'b0;
			load_Score = 1'b0;
			score_w = 1'b0;
			
		end
				  
		S_ShiftDown: begin
		   
			load_shiftU=1'b0;
			load_shiftL=1'b0;
			load_Del=1'b0;
			load_Reset = 1'b0;
			load_shiftD = 1'b1; 
			load_Done = 1'b0;
			load_New = 1'b0;
			load_Over = 1'b0;
			load_Score = 1'b0;
			score_w = 1'b0;
			
		end
		
		S_ShiftUp: begin
			  load_shiftD=1'b0;       
			  load_shiftL=1'b0;
			  load_Del=1'b0;
			  load_Reset = 1'b0;
			  load_shiftU = 1'b1; 
			  load_Done = 1'b0;
			  load_New = 1'b0;
			  load_Over = 1'b0;
			  load_Score = 1'b0;
			score_w = 1'b0;
			  
		end
		
		
		S_ShiftLeft: begin
		  load_shiftD=1'b0;       
		  load_shiftU=1'b0;
		  load_Del=1'b0;
		  load_Reset = 1'b0;
		  load_Done = 1'b0;
		  load_shiftL = 1'b1; 
		  load_New = 1'b0;
		  load_Over = 1'b0;
		  load_Score = 1'b0;
			score_w = 1'b0;
		  
		end
		
		
		S_PrintNew: begin
	 
		 load_shiftD=1'b0;       
		 load_shiftU=1'b0;
		 load_shiftL=1'b0;
		 load_Del=1'b0;
		 load_Reset = 1'b0;
		 load_Done = 1'b0;
		 load_New = 1'b1;
		 load_Over = 1'b0;
		 load_Score = 1'b0;
		 score_w = 1'b0;
		 
		end
		
		S_Reset: begin
		
		 load_shiftD=1'b0;       
		 load_shiftU=1'b0;
		 load_shiftL=1'b0;
		 load_Del=1'b0;
		 load_Reset = 1'b1; 
		 load_New = 1'b0;
		 load_Done = 1'b0;
		 load_Over = 1'b0;
		 load_Score = 1'b0;
		 score_w = 1'b0;
			
		end
		
		S_Delete: begin
		
		 load_shiftD=1'b0;       
		 load_shiftU=1'b0;
		 load_shiftL=1'b0;
		 load_Del=1'b1;
		 load_Reset = 1'b0; 
		 load_New = 1'b0;
		 load_Done = 1'b0;
		 load_Over = 1'b0;
		 load_Score = 1'b0;
		 score_w = 1'b0;
		 
		end
			
		S_Done: begin
		
		load_shiftD=1'b0;       
		load_shiftU=1'b0;
		load_shiftL=1'b0;
		load_New = 1'b0;
		load_Del=1'b0;
		load_Reset = 1'b0;
		load_Done = 1'b1;
		load_Over = 1'b0;
		load_Score = 1'b0;
		score_w = 1'b0;
		
		end
		
		S_Over: begin
		
		load_shiftD=1'b0;       
	  load_shiftU=1'b0;
	  load_shiftL=1'b0;
	  load_Del=1'b0;
	  load_Reset = 1'b0;
	  load_Done = 1'b0; 
	  load_New = 1'b0;
	  load_Over = 1'b1;
	  load_Score = 1'b0;
		score_w = 1'b0;
	  
	  end
	  
	  S_Initial: begin
		
		load_shiftD=1'b0;       
	  load_shiftU=1'b0;
	  load_shiftL=1'b0;
	  load_Del=1'b0;
	  load_Reset = 1'b1;
	  load_Done = 1'b0; 
	  load_New = 1'b0;
	  load_Over = 1'b0;
	  load_Score = 1'b0;
	  score_w = 1'b0;
	  
	  end
	  
	  S_Score: begin
	  
	  load_shiftD=1'b0;       
	  load_shiftU=1'b0;
	  load_shiftL=1'b0;
	  load_Del=1'b0;
	  load_Reset = 1'b0;
	  load_Done = 1'b0; 
	  load_New = 1'b0;
	  load_Over = 1'b0;
	  load_Score = 1'b1;
	  score_w = 1'b0;
	  
	  end
	  
	  S_ScoreWait: begin
	  
	  load_shiftD=1'b0;       
	  load_shiftU=1'b0;
	  load_shiftL=1'b0;
	  load_Del=1'b0;
	  load_Reset = 1'b0;
	  load_Done = 1'b0; 
	  load_New = 1'b0;
	  load_Over = 1'b0;
	  load_Score = 1'b0;
	  score_w = 1'b1;
	  
	  end
	  
		
		default: begin
		
	  load_shiftD=1'b0;       
	  load_shiftU=1'b0;
	  load_shiftL=1'b0;
	  load_Del=1'b0;
	  load_Reset = 1'b0;
	  load_Done = 1'b0; 
	  load_New = 1'b0;
	  load_Over = 1'b0;
	  load_Score = 1'b0;
	  score_w = 1'b0;
	  
	  end
	endcase
	end

	// current_state registers
	  
	always@(posedge clock)
	  
		begin: state_FFs
		  
			if(!resetn)       
				current_state <= S_Reset; 
			else            
				current_state <= next_state;
	 
	end // state_FFS


endmodule

module datapath(clock,resetn,load_New,load_shiftD,load_shiftU,load_shiftL,load_Del,load_Reset,load_Over,load_Done,load_Score,doneScore,upFlag,X,Y,colour,doneDraw,doneDelete, doneOver, finish, busy, writeEn, dx, dy, x_reg, y_reg,
						one, two, four, six, out, zero);

	input clock,resetn,load_shiftD,load_shiftU,load_shiftL,load_Del,load_Reset,load_Done,load_New,load_Score,load_Over;
	input [3:0] dx, dy;
	input one, two, four, six, out, zero;
	output reg [8:0] x_reg;
	output reg [7:0] y_reg;
	wire [8:0] x_new;
	wire [7:0] y_new;
	wire [8:0] x_del;
	wire [7:0] y_del;
	wire [8:0] x_over;
	wire [7:0] y_over;
	wire [8:0] x_score;
	wire [7:0] y_score;
	wire [11:0] colour_new;
	wire [11:0] colour_del;
	wire [11:0] colour_over;
	wire [11:0] colour_score;
	wire plot_new, busy_new, done_new;
	wire plot_del, busy_del, done_del;
	wire plot_over, busy_over, done_over;
	wire plot_score, busy_score, done_score;
	output reg [8:0] X;
	output reg [7:0] Y;
	output reg [11:0] colour;
	output reg writeEn, busy, upFlag, finish; 
	output doneDraw, doneDelete, doneOver, doneScore;
	
	renderSprite U0(.clock(clock), .x_left(x_reg), .y_upper(y_reg), .drawEnable(load_New), 
							.x_out(x_new), .y_out(y_new), .colourOut(colour_new), .writeEn(plot_new), .done(doneDraw), .busy(busy_new));
							
	renderBackground U1(.clock(clock), .x_left(x_reg), .y_upper(y_reg), .drawEnable(load_Del), 
							.x_out(x_del), .y_out(y_del), .colourOut(colour_del), .writeEn(plot_del), .done(doneDelete), .busy(busy_del));
							
	renderStart U2(.clock(clock), .x_left(x_reg), .y_upper(y_reg), .drawEnable(load_Over), 
							.x_out(x_over), .y_out(y_over), .colourOut(colour_over), .writeEn(plot_over), .done(doneOver), .busy(busy_del));
	
	renderScore U3(.clock(clock), .x_left(x_reg), .y_upper(y_reg), .drawEnable(load_Score), 
						.x_out(x_score), .y_out(y_score), .colourOut(colour_score), .writeEn(plot_score), .done(doneScore), .busy(busy_score),
							.one(one), .two(two), .four(four), .six(six), .out(out), .zero(zero));
	
	always@(posedge clock) begin

		if (load_shiftD) begin	
			y_reg <= y_reg+dy;
			if(y_reg == 8'd218)
				upFlag <= 1'b1;			
		end
		
		if (load_shiftU) begin	
			y_reg <= y_reg-dy;
			if(y_reg == 8'b0)
				upFlag <= 1'b0;			
		end
		
		if (load_shiftL) begin
			x_reg <= x_reg-dx;
		end
		
		
		if (load_New) begin
			X <= x_new;
			Y <= y_new;
			colour <= colour_new;
			writeEn <= plot_new;
			busy <= busy_new;
		end
		
		if (load_Del) begin	
			X <= x_del;
			Y <= y_del;
			colour <= colour_del;
			writeEn <= plot_del;
			busy <= busy_del;
		end
		
		if (load_Over) begin	
			X <= x_over;
			Y <= y_over;
			colour <= colour_over;
			writeEn <= plot_over;
			busy <= busy_over;
		end
		
		if (load_Score) begin	
			X <= x_score;
			Y <= y_score;
			colour <= colour_score;
			writeEn <= plot_score;
			busy <= busy_score;
		end
		
		if (load_Done) begin
			if (x_reg<=9'b0)
				finish <= 1'b1;
		end
		
		if (load_Reset) begin
			finish <= 1'b0;
			x_reg <= 9'b100110110;
			y_reg <= 8'b01100100;
			writeEn <= 1'b0;
			upFlag <= 1'b0;
			busy <= 1'b0;
		end
	end
endmodule

module renderBackground (clock, x_left, y_upper, drawEnable, x_out, y_out, colourOut, writeEn, done, busy);
	input clock;
	input [8:0] x_left;
	input [7:0] y_upper;
	reg [8:0] x_start;
	reg [7:0] y_start;
	input drawEnable;
	output [11:0] colourOut;
	output reg [8:0] x_out;
	output reg [7:0] y_out;
	output reg writeEn, done, busy;
	wire [16:0] address;
	reg [8:0] counterX;
	reg [7:0] counterY;
	
	vga_address_translator V0(.x(x_out), .y(y_out), .mem_address(address));
	backgroundram R0(.address(address), .clock(clock), .data(12'b0), .wren(1'b0), .q(colourOut));
	
	always @ (posedge clock)
	begin
		if (!drawEnable)
		begin
			counterX <= 4'b0000;
			counterY <= 4'b0000;
			x_start <= x_left;
			y_start <= y_upper;
			done <= 1'b0;
			writeEn <= 0;
			busy <= 0;
			
		end
		else if (drawEnable)
		begin			
			writeEn <= 1;
			busy <= 1;
			if (counterY <= 8'b11110000)
			begin
				
				if (counterX <= 9'b101000000)
				begin
					x_out <= counterX;
					counterX <= counterX + 1;
				end
				else begin
					counterX <= 9'b0;
					y_out <= counterY;
					counterY <= counterY + 1;
				end
				
			end
			else begin
				counterY <= 8'b0;
				done <= 1'b1;
				busy <= 1'b0;
			end
			
		end
	end
endmodule

module renderSprite (clock, x_left, y_upper, drawEnable, x_out, y_out, colourOut, writeEn, done, busy);
	input clock;
	input [8:0] x_left;
	input [7:0] y_upper;
	reg [8:0] x_start;
	reg [7:0] y_start;
	input drawEnable;
	output [11:0] colourOut;
	output reg [8:0] x_out;
	output reg [7:0] y_out;
	output reg writeEn, done, busy;
	wire [6:0] address;
	reg [3:0] counterX;
	reg [3:0] counterY;
	
	sprite_address_translator V1(.x(counterX), .y(counterY), .mem_address(address));
	spriteram R1(.address(address), .clock(clock), .data(12'b0), .wren(1'b0), .q(colourOut));
	
	always @ (posedge clock)
	begin
		if (!drawEnable)
		begin
			counterX <= 4'b0000;
			counterY <= 4'b0000;
			x_start <= x_left;
			y_start <= y_upper;
			done <= 1'b0;
			writeEn <= 0;
			busy <= 0;
			
		end
		else if (drawEnable)
		begin
			writeEn <= 1;
			busy <= 1;
			if (counterY <= 4'b1001)
			begin
				
				if (counterX <= 4'b1001)
				begin
					x_out <= x_start + counterX;
					counterX <= counterX + 1;
				end
				else begin
					counterX <= 4'b0000;
					y_out <= y_start + counterY;
					counterY <= counterY + 1;
				end
				
			end
			else begin
				counterY <= 4'b0000;
				done <= 1'b1;
				busy <= 1'b0;
			end
		end
	end
endmodule

module renderStart (clock, x_left, y_upper, drawEnable, x_out, y_out, colourOut, writeEn, done, busy);
	input clock;
	input [8:0] x_left;
	input [7:0] y_upper;
	reg [8:0] x_start;
	reg [7:0] y_start;
	input drawEnable;
	output [11:0] colourOut;
	output reg [8:0] x_out;
	output reg [7:0] y_out;
	output reg writeEn, done, busy;
	wire [16:0] address;
	reg [8:0] counterX;
	reg [7:0] counterY;
	
	vga_address_translator V0(.x(x_out), .y(y_out), .mem_address(address));
	startscreen R2(.address(address), .clock(clock), .data(12'b0), .wren(1'b0), .q(colourOut));
	
	always @ (posedge clock)
	begin
		if (!drawEnable)
		begin
			counterX <= 4'b0000;
			counterY <= 4'b0000;
			x_start <= x_left;
			y_start <= y_upper;
			done <= 1'b0;
			writeEn <= 0;
			busy <= 0;
			
		end
		else if (drawEnable)
		begin
			writeEn <= 1;
			busy <= 1;
			if (counterY <= 8'b11110000)
			begin
				
				if (counterX <= 9'b101000000)
				begin
					x_out <= counterX;
					counterX <= counterX + 1;
				end
				else begin
					counterX <= 9'b0;
					y_out <= counterY;
					counterY <= counterY + 1;
				end
				
			end
			else begin
				counterY <= 8'b0;
				done <= 1'b1;
				busy <= 1'b0;
			end
			
		end
	end
endmodule

module renderScore (clock, x_left, y_upper, drawEnable, x_out, y_out, colourOut, writeEn, done, busy,
							one, two, four, six, out, zero);
	input clock;
	input one, two, four, six, out, zero;	
	input [8:0] x_left;
	input [7:0] y_upper;
	reg [8:0] x_start;
	reg [7:0] y_start;
	input drawEnable;
	wire [11:0] zeroColourOut, oneColourOut, twoColourOut, fourColourOut, sixColourOut, outColourOut; 
	output reg [11:0] colourOut;
	output reg [8:0] x_out;
	output reg [7:0] y_out;
	output reg writeEn, done, busy;
	wire [6:0] address;
	reg [7:0] counterX;
	reg [7:0] counterY;
	
	score_address_translator V1(.x(counterX), .y(counterY), .mem_address(address));
	zeroram R0(.address(address), .clock(clock), .data(12'b0), .wren(1'b0), .q(zeroColourOut));
	oneram R1(.address(address), .clock(clock), .data(12'b0), .wren(1'b0), .q(oneColourOut));
	two R2(.address(address), .clock(clock), .data(12'b0), .wren(1'b0), .q(twoColourOut));
	four R4(.address(address), .clock(clock), .data(12'b0), .wren(1'b0), .q(fourColourOut));
	six R6(.address(address), .clock(clock), .data(12'b0), .wren(1'b0), .q(sixColourOut));
	out RI(.address(address), .clock(clock), .data(12'b0), .wren(1'b0), .q(outColourOut));
	
	always @ (posedge clock)
	begin
		if (!drawEnable)
		begin
			counterX <= 4'b0000;
			counterY <= 4'b0000;
			x_start <= 4'b1010;
			y_start <= 7'b1101110;
			done <= 1'b0;
			writeEn <= 0;
			busy <= 0;
			
		end
		else if (drawEnable)
		begin
			writeEn <= 1;
			busy <= 1;
			if (counterY <= 7'b1100011)
			begin
				
				if (counterX <= 7'b1100011)
				begin
					x_out <= x_start + counterX;
					counterX <= counterX + 1;
				end
				else begin
					counterX <= 7'b0;
					y_out <= y_start + counterY;
					counterY <= counterY + 1;
				end
				
				if (out == 1'b1)
				begin
					colourOut <= outColourOut;
				end
				else if (one == 1'b1)
				begin
					colourOut <= oneColourOut;
				end
				else if (two == 1'b1)
				begin
					colourOut <= twoColourOut;
				end
				else if (four == 1'b1)
				begin
					colourOut <= fourColourOut;
				end
				else if (six == 1'b1)
				begin
					colourOut <= sixColourOut;
				end
				else if (zero == 1'b1)
				begin
					colourOut <= zeroColourOut;
				end
				else
				begin
					colourOut <= {12'b0};
				end
				
			end
			else begin
				counterY <= 7'b0;
				done <= 1'b1;
				busy <= 1'b0;
			end
		end
	end
endmodule	

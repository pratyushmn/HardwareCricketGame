module Strike (swing, clock, reset, strike);

	input clock, reset, swing;
	output reg strike;
	reg [5:0] current_state, next_state;
	
	localparam  S_Default  = 5'd0,
					S_Hit_wait = 5'd1,
					S_Hit      = 5'd2;
				
	always @(*)
	
	begin: state_table
		
		case (current_state)
			
			S_Default: next_state = (!swing)? S_Hit_wait : S_Default;
			
			S_Hit_wait: next_state = (swing)? S_Hit: S_Hit_wait;
			
			S_Hit: next_state = S_Default;
			
		default: next_state = S_Default;
		
		endcase
	end
	
	always @(*)
	
	begin: enable_signals
	
		strike = 1'b0;
		
		case (current_state)
		
			S_Hit: begin
				strike = 1'b1;
			end
			
			S_Hit_wait : begin
				strike = 1'b0;
			end
			
			S_Default: begin
				strike = 1'b0;
			end
			
		endcase
		
	end
	
	always@(posedge clock)
	  
		begin: state_FFs
		  
			if(reset)       
				current_state <= S_Default; 
			else            
				current_state <= next_state;
	 
		end
		
endmodule

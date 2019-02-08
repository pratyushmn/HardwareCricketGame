module score_address_translator(x, y, mem_address);
	input [6:0] x;
	input [6:0] y;
	output reg [14:0] mem_address;
	wire [14:0] address = {1'b0, y, 6'd0} + {1'b0, y, 5'd0} + {1'b0, y, 2'd0} + {1'b0, x};
	always @(*)
	begin
		mem_address = address;
	end
endmodule

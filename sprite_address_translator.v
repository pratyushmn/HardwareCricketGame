module sprite_address_translator(x, y, mem_address);
	input [3:0] x;
	input [3:0] y;
	output reg [6:0] mem_address;
	wire [6:0] address = {1'b0, y, 3'd0} + {1'b0, y, 1'd0} + {1'b0, x};
	always @(*)
	begin
		mem_address = address;
	end
endmodule

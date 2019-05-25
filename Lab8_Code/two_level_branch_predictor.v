
module two_level_branch_predictor(clk, reset_n, input_ip, output_prediction, input_taken);
	input clk;
	input reset_n;

	input [63:0] input_ip;
	input [0:0] input_taken;
	output [0:0] output_prediction;

	reg [0:0] output_reg;

	reg [66:0] branch_table [0:255];
	reg [1 : 0] state;

	reg [63:0] prev_ip;




	// you can add more variables

	assign output_prediction = output_reg;
	integer i;
	reg is_hit;
	reg entry_added;

	initial begin
		is_hit <= 0 ;
		output_reg <= 0;
		entry_added <= 0;
		state <= 2'b00;
		prev_ip <= 64'bz;
		for(i = 0; i < 256; i = i+ 1) begin
			branch_table[i] = 67'b0;
		end
	end


	always @ (*) begin
		case(state)
			2'b00 : output_reg = 0; 
			2'b01 : output_reg = 0;
			2'b10 : output_reg = 1;
			2'b11 : output_reg = 1;
		endcase
	end

	always @ (negedge reset_n) begin
		// reset all state asynchronously
		
		is_hit <= 0 ;
		output_reg <= 0;
		entry_added <= 0;
		state <= 2'b00;
		prev_ip <= 64'bz;

		for(i = 0; i < 256; i = i+ 1) begin
			branch_table[i] = 67'b0;
		end

		$display("reset_n activated");
	end

	always @ (posedge clk) begin
		is_hit = 0 ;
		entry_added = 0;

		for(i = 0; i < 256; i = i+1) begin
			if((input_ip == branch_table[i][66 : 3]) && branch_table[i][2]) begin
				state = branch_table[i][1:0];
				is_hit = 1;
			end
		end
		if(!is_hit) begin
			for(i = 0; i < 256; i = i+1) begin
				if(branch_table[i][2] == 0 && !entry_added) begin
					branch_table[i][66 : 3] = input_ip;
					state = 2'b00;
					branch_table[i][2] = 1;
					entry_added = 1;
				end
			end
		end

		for(i = 0; i < 256; i = i+1) begin
			if((prev_ip == branch_table[i][66 : 3]) && branch_table[i][2]) begin
				case (branch_table[i][1:0])
					2'b00 : branch_table[i][1:0] = input_taken ? 2'b01 : 2'b00;
					2'b01 : branch_table[i][1:0] = input_taken ? 2'b10 : 2'b00;
					2'b10 : branch_table[i][1:0] = input_taken ? 2'b11 : 2'b01;
					2'b11 : branch_table[i][1:0] = input_taken ? 2'b11 : 2'b10;
				endcase		
			end
		end

		prev_ip = input_ip;

	end

endmodule

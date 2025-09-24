`timescale 1ns/1ns

module tb_abs();
	reg [15:0] A;
	wire [15:0] res;
	abs abs(A, res);
	
	initial begin
		A = 10;
		#10
		A = -7;
		#10
		A = -5;
		#10;
		A = 3;
		$stop;
	end
endmodule



module shiftreg_tb;
    reg clk;
    reg rst;
    reg inz;
    reg ld;
    reg shiftl;
    reg in;
    reg [15:0] par_load;

    wire [15:0] ans;
    wire co;

    shiftreg uut (
        .clk(clk),
        .rst(rst),
        .inz(inz),
        .ld(ld),
        .shiftl(shiftl),
        .in(in),
        .par_load(par_load),
        .ans(ans),
        .co(co)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        inz = 0;
        ld = 0;
        shiftl = 0;
        in = 0;
        par_load = 16'b0;

        #10;
        rst = 0;

        par_load = 16'b1010101010101010;
        ld = 1;
        #10;
        ld = 0;

        shiftl = 1;
        in = 1;
        #10;
        shiftl = 0;

        shiftl = 1;
        in = 0;
        #10;
        shiftl = 0;

        inz = 1;
        #10;
        inz = 0;

        $stop;
    end

endmodule


module divider_tb;

    reg clk;
    reg rst;
    reg start;
    reg [15:0] A;
    reg [15:0] B;

    wire [15:0] R;
    wire [15:0] Q;
    wire ready;
    wire startoutwrap;
    divider uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .A(A),
        .B(B),
        .R(R),
        .Q(Q),
        .ready(ready),
	.startoutwrap(startoutwrap)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        A = 0;
        B = 0;

        #10;
        rst = 0;
		//-----test 1 ------ A = 25 , B = 5
        A = 16'd25;
        B = 16'd5;
        start = 1;
        #10;
        start = 0;

        #1000
		//-----test 2 ------ A = -50 , B = 7
        A = -16'd50;
        B = 16'd7;
        start = 1;
        #10;
        start = 0;

        #1000
		//-----test 3 ------ A = 0 , B = 8
        A = 16'd0;
        B = 16'd8;
        start = 1;
        #10;
        start = 0;

        #1000
		//-----test 4 ------ A = 100 , B = -25
        A = 16'd100;
        B = -16'd25;
        start = 1;
        #10;
        start = 0;

        #1000
		//-----test 5 ------ A = 23 , B = 0
        A = 16'd23;
        B = 16'd0;
        start = 1;
        #10;
        start = 0;

        #1000

        $stop;
    end

endmodule

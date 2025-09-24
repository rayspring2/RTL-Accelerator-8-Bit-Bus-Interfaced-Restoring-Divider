`timescale 1ns/1ns

module top_tb();
    logic clk = 0, rst = 0, startData = 0, receivedData = 0;
	wire outbuffFull, ReadytoAccept;
    logic [7:0] bussin, bussout;  

    divTop mytopdiv(clk, rst, startData, receivedData, bussin,
                  outbuffFull, ReadytoAccept, bussout);

    always #2 clk = ~clk;

    initial begin
        #20 rst=1; #10 rst=0;
        #5 bussin = 8'd0;
        #20 startData = 1 ; #20 startData = 0;
        #5 bussin = 8'd25;
        #20 startData = 1 ; #10 startData = 0;
        #5 bussin = 8'd0;
        #20 startData = 1 ; #10 startData = 0;
        #8 bussin = 8'd5;
        #20 startData = 1 ; #10 startData = 0;
	#160
        //#40 startData = 1 ; #10 startData = 0;
        //#20 rst=1; #10 rst=0;
       
        receivedData = 1; #10 receivedData = 0; 
        #20 receivedData = 1; #10 receivedData = 0; 
        #20 receivedData = 1; #10 receivedData = 0; 
        #20 receivedData = 1; #10 receivedData = 0; 
        #30 $stop;
    end

    
endmodule
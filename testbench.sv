module tb;
  reg [1:0]clk;
  reg [3:0]money;
  reg [1:0]reset;
  reg [1:0]choice;
  wire [1:0]delivery;
  wire [3:0]change;
  wire [2:0]states;
  vendingmachine v0(clk,money,reset,states,choice,delivery,change);
  always #5 clk=~clk;
  initial
    begin
      $dumpfile("vendingmachine.vcd");
      $dumpvars(0,tb);
      $monitor($time," Money=%b Choice=%b Reset=%b State=%b Delivery=%b Change=%b ",money,choice,reset,states,delivery,change);
    end
  initial
    begin
      clk<=1'b0;
      #5;
      choice<=2'b10;
      reset<=1'b0;
      #10;
      money<=4'b1010;
      reset<=1'b0;
      #10;
      reset<=1'b1;
      #10 $finish;
    end
endmodule
      
     
      
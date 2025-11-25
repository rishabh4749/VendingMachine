module tb;
  reg clk;                  // 1-bit clock 
  reg [3:0] money;
  reg reset;                // 1-bit reset 
  reg [1:0] choice;
  wire delivery;            // 1-bit delivery
  wire [3:0] change;
  wire [2:0] states;
  
  // Instantiate vending machine
  vendingmachine v0(clk, money, reset, states, choice, delivery, change);
  
  // Clock generation - 10ns period
  always #5 clk = ~clk;
  
  // Waveform dump and monitoring
  initial begin
    $dumpfile("vendingmachine.vcd");
    $dumpvars(0, tb);
    $monitor($time, " Money=%b Choice=%b Reset=%b State=%b Delivery=%b Change=%b", 
             money, choice, reset, states, delivery, change);
  end
  
  // Test stimulus
  initial begin
    // Initialize
    clk = 1'b0;
    reset = 1'b1;
    money = 4'b0000;
    choice = 2'b00;
    
    // Release reset
    #10 reset = 1'b0;
    
    // Select Product 2 (Rs. 5)
    #10 choice = 2'b10;
    
    // Insert Rs. 10 (expect delivery with Rs. 5 change)
    #10 money = 4'b1010;
    
    // Clear money input
    #10 money = 4'b0000;
    
    // Apply reset to return to IDLE
    #10 reset = 1'b1;
    
    #10 $finish;
  end
endmodule

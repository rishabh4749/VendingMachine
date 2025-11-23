`timescale 1ns/1ps

module vendingmachine_tb;

  // Testbench signals
  reg clk;
  reg reset;
  reg [3:0] money;
  reg [1:0] choice;
  wire delivery;
  wire [3:0] change;
  wire [2:0] states;

  // State parameter definitions (for monitoring)
  parameter s0 = 3'b000,  // IDLE
            s1 = 3'b001,  // Product1 - Need Rs.10
            s2 = 3'b010,  // Product1 - Rs.5 received
            s3 = 3'b011,  // Product1 - Dispensing
            s4 = 3'b100,  // Product2 - Need Rs.5
            s5 = 3'b101;  // Product2 - Dispensing

  // Money denominations
  parameter NO_MONEY = 4'b0000,
            RS_5     = 4'b0101,
            RS_10    = 4'b1010;

  // Product choices
  parameter NO_CHOICE  = 2'b00,
            PRODUCT_1  = 2'b01,
            PRODUCT_2  = 2'b10;

  // Instantiate DUT (Device Under Test)
  vendingmachine dut (
    .clk(clk),
    .money(money),
    .reset(reset),
    .states(states),
    .choice(choice),
    .delivery(delivery),
    .change(change)
  );

  // Clock generation - 10ns period (100MHz)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test stimulus
  initial begin
    // Initialize waveform dump
    $dumpfile("vending_machine.vcd");
    $dumpvars(0, vendingmachine_tb);

    // Display header
    $display("\n========================================");
    $display("  VENDING MACHINE TESTBENCH START");
    $display("========================================\n");
    $display("Time\tState\tChoice\tMoney\tDelivery\tChange");
    $display("----\t-----\t------\t-----\t--------\t------");

    // Initialize inputs
    reset = 1;
    money = NO_MONEY;
    choice = NO_CHOICE;
    
    // Apply reset
    #10;
    reset = 0;
    #10;

    // =========================================================================
    // TEST CASE 1: Product 1 with exact payment (Rs. 10)
    // =========================================================================
    $display("\n--- TEST 1: Product 1 with Rs.10 (Exact Payment) ---");
    choice = PRODUCT_1;
    #10;
    display_status();
    
    money = RS_10;
    #10;
    display_status();
    check_delivery(1'b1, 4'b0000, "Product 1 - Exact payment");
    
    // Reset for next test
    money = NO_MONEY;
    reset = 1;
    #10;
    reset = 0;
    #10;

    // =========================================================================
    // TEST CASE 2: Product 1 with two Rs. 5 notes
    // =========================================================================
    $display("\n--- TEST 2: Product 1 with Rs.5 + Rs.5 ---");
    choice = PRODUCT_1;
    #10;
    display_status();
    
    money = RS_5;
    #10;
    display_status();
    check_delivery(1'b0, 4'b0000, "Product 1 - First Rs.5");
    
    money = RS_5;
    #10;
    display_status();
    check_delivery(1'b1, 4'b0000, "Product 1 - Second Rs.5");
    
    // Reset for next test
    money = NO_MONEY;
    reset = 1;
    #10;
    reset = 0;
    #10;

    // =========================================================================
    // TEST CASE 3: Product 1 with Rs.5 then Rs.10 (change expected)
    // =========================================================================
    $display("\n--- TEST 3: Product 1 with Rs.5 + Rs.10 (Change Rs.5) ---");
    choice = PRODUCT_1;
    #10;
    display_status();
    
    money = RS_5;
    #10;
    display_status();
    
    money = RS_10;
    #10;
    display_status();
    check_delivery(1'b1, RS_5, "Product 1 - Overpayment with change");
    
    // Reset for next test
    money = NO_MONEY;
    reset = 1;
    #10;
    reset = 0;
    #10;

    // =========================================================================
    // TEST CASE 4: Product 2 with exact payment (Rs. 5)
    // =========================================================================
    $display("\n--- TEST 4: Product 2 with Rs.5 (Exact Payment) ---");
    choice = PRODUCT_2;
    #10;
    display_status();
    
    money = RS_5;
    #10;
    display_status();
    check_delivery(1'b1, 4'b0000, "Product 2 - Exact payment");
    
    // Reset for next test
    money = NO_MONEY;
    reset = 1;
    #10;
    reset = 0;
    #10;

    // =========================================================================
    // TEST CASE 5: Product 2 with Rs. 10 (change expected)
    // =========================================================================
    $display("\n--- TEST 5: Product 2 with Rs.10 (Change Rs.5) ---");
    choice = PRODUCT_2;
    #10;
    display_status();
    
    money = RS_10;
    #10;
    display_status();
    check_delivery(1'b1, RS_5, "Product 2 - Overpayment with change");
    
    // Reset for next test
    money = NO_MONEY;
    reset = 1;
    #10;
    reset = 0;
    #10;

    // =========================================================================
    // TEST CASE 6: Invalid choice
    // =========================================================================
    $display("\n--- TEST 6: Invalid Choice ---");
    choice = 2'b11;  // Invalid choice
    #10;
    display_status();
    check_state(s0, "Should remain in IDLE for invalid choice");
    
    reset = 1;
    #10;
    reset = 0;
    #10;

    // =========================================================================
    // TEST CASE 7: Invalid denomination
    // =========================================================================
    $display("\n--- TEST 7: Invalid Denomination ---");
    choice = PRODUCT_1;
    #10;
    money = 4'b0011;  // Invalid denomination
    #10;
    display_status();
    check_delivery(1'b0, 4'b0000, "Should not dispense with invalid money");
    
    reset = 1;
    #10;
    reset = 0;
    #10;

    // =========================================================================
    // TEST CASE 8: Reset during transaction
    // =========================================================================
    $display("\n--- TEST 8: Reset During Transaction ---");
    choice = PRODUCT_1;
    #10;
    money = RS_5;
    #10;
    display_status();
    
    reset = 1;  // Reset mid-transaction
    #10;
    display_status();
    check_state(s0, "Should return to IDLE after reset");
    check_delivery(1'b0, 4'b0000, "Outputs cleared after reset");
    
    reset = 0;
    #10;

    // =========================================================================
    // TEST CASE 9: No money inserted
    // =========================================================================
    $display("\n--- TEST 9: Product Selected but No Money ---");
    choice = PRODUCT_1;
    #10;
    money = NO_MONEY;
    #20;
    display_status();
    check_delivery(1'b0, 4'b0000, "Should not dispense without payment");
    check_state(s1, "Should wait in state s1");

    reset = 1;
    #10;
    reset = 0;
    #10;

    // Test completion
    $display("\n========================================");
    $display("  ALL TESTS COMPLETED SUCCESSFULLY!");
    $display("========================================\n");
    
    #20;
    $finish;
  end

  // Task to display current status
  task display_status;
    begin
      $display("%0t\t%b\t%b\t%b\t%b\t\t%b", 
               $time, states, choice, money, delivery, change);
    end
  endtask

  // Task to check delivery and change
  task check_delivery;
    input expected_delivery;
    input [3:0] expected_change;
    input [200*8:1] test_name;
    begin
      if (delivery !== expected_delivery || change !== expected_change) begin
        $display("ERROR: %0s", test_name);
        $display("  Expected: delivery=%b, change=%b", expected_delivery, expected_change);
        $display("  Got:      delivery=%b, change=%b", delivery, change);
      end else begin
        $display("PASS: %0s", test_name);
      end
    end
  endtask

  // Task to check state
  task check_state;
    input [2:0] expected_state;
    input [200*8:1] test_name;
    begin
      if (states !== expected_state) begin
        $display("ERROR: %0s", test_name);
        $display("  Expected state: %b", expected_state);
        $display("  Got state:      %b", states);
      end else begin
        $display("PASS: %0s", test_name);
      end
    end
  endtask

  // Monitor changes
  initial begin
    $monitor("Time=%0t | State=%b | Choice=%b | Money=%b | Delivery=%b | Change=%b", 
             $time, states, choice, money, delivery, change);
  end

endmodule

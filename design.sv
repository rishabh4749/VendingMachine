// VENDING MACHINE FINITE STATE MACHINE (FSM)
// This module implements a vending machine with two products:
//   - Product 1 (choice=01): Costs Rs. 10
//   - Product 2 (choice=10): Costs Rs. 5
// Accepts denominations: Rs. 5 (0101) and Rs. 10 (1010)
// Provides change when overpayment occurs

module vendingmachine(
  input clk,                    // System clock
  input [3:0] money,            // Money inserted (0101=Rs.5, 1010=Rs.10)
  input reset,                  // Asynchronous reset
  input [1:0] choice,           // Product selection (01=Product1, 10=Product2)
  output reg delivery,          // Item dispensed flag
  output reg [3:0] change,      // Change to return
  output reg [2:0] states       // Current state (for debugging)
);

  // State Definitions
  parameter s0 = 3'b000,        // IDLE: Waiting for product selection
            s1 = 3'b001,        // Product1 selected: Need Rs. 10 (waiting for payment)
            s2 = 3'b010,        // Product1: Rs. 5 received (need Rs. 5 more)
            s3 = 3'b011,        // Product1: Payment complete (dispensing)
            s4 = 3'b100,        // Product2 selected: Need Rs. 5 (waiting for payment)
            s5 = 3'b101;        // Product2: Payment complete (dispensing)

  // Main FSM Logic - Sequential always block
  always @(posedge clk) begin
    if (reset) begin
      // Reset to IDLE state
      states   <= s0;
      delivery <= 1'b0;
      change   <= 4'b0000;
    end
    else begin
      case(states)
        
        // STATE s0: IDLE - Waiting for product selection
        s0: begin
          delivery <= 1'b0;
          change   <= 4'b0000;
          
          case(choice)
            2'b01: states <= s1;    // Product 1 selected (Rs. 10)
            2'b10: states <= s4;    // Product 2 selected (Rs. 5)
            default: begin
              states <= s0;         // Stay in IDLE for invalid choice
              $display(" INVALID CHOICE ");
            end
          endcase
        end
        
        // STATE s1: Product 1 selected - Need Rs. 10 total
        s1: begin
          delivery <= 1'b0;
          change   <= 4'b0000;
          
          case(money)
            4'b1010: begin          // Rs. 10 inserted - Payment complete
              states   <= s3;
              delivery <= 1'b1;     // Dispense item
            end
            4'b0101: states <= s2;  // Rs. 5 inserted - Need Rs. 5 more
            4'b0000: states <= s1;  // No money - Stay in current state
            default: $display(" PUT IN A VALID DENOMINATION ");
          endcase
        end
        
        // STATE s2: Product 1 - Rs. 5 received, need Rs. 5 more
        s2: begin
          delivery <= 1'b0;
          change   <= 4'b0000;
          
          case(money)
            4'b0101: begin          // Another Rs. 5 inserted - Payment complete
              states   <= s3;
              delivery <= 1'b1;     // Dispense item
            end
            4'b1010: begin          // Rs. 10 inserted - Overpayment
              states   <= s3;
              delivery <= 1'b1;     // Dispense item
              change   <= 4'b0101;  // Return Rs. 5 change
            end
            4'b0000: states <= s2;  // No money - Stay in current state
            default: $display(" PUT IN A VALID DENOMINATION ");
          endcase
        end
        
        // STATE s3: Product 1 dispensed - Transaction complete
        s3: begin
          // Keep delivery high until transaction ends
          delivery <= 1'b1;
          
          // Wait for reset or handle additional transactions
          if (money == 4'b0000) begin
            states <= s3;           // Stay until reset or new transaction
          end
          else begin
            $display(" TRANSACTION IN PROGRESS - PLEASE WAIT ");
          end
        end
        
        // STATE s4: Product 2 selected - Need Rs. 5 total
        s4: begin
          delivery <= 1'b0;
          change   <= 4'b0000;
          
          case(money)
            4'b0101: begin          // Rs. 5 inserted - Exact payment
              states   <= s5;
              delivery <= 1'b1;     // Dispense item
            end
            4'b1010: begin          // Rs. 10 inserted - Overpayment
              states   <= s5;
              delivery <= 1'b1;     // Dispense item
              change   <= 4'b0101;  // Return Rs. 5 change
            end
            4'b0000: states <= s4;  // No money - Stay in current state
            default: $display(" PUT IN A VALID DENOMINATION ");
          endcase
        end
        
        // STATE s5: Product 2 dispensed - Transaction complete
        s5: begin
          // Keep delivery and change signals stable
          delivery <= 1'b1;
          
          // Maintain change if it was set
          if (change == 4'b0000 && money == 4'b0000) begin
            states <= s5;           // Stay until reset
          end
        end
        
        // DEFAULT: Error recovery - return to IDLE with product selection
        default: begin
          delivery <= 1'b0;
          change   <= 4'b0000;
          
          case(choice)
            2'b01: states <= s1;
            2'b10: states <= s4;
            default: begin
              states <= s0;
              $display(" INVALID CHOICE ");
            end
          endcase
        end
        
      endcase
    end
  end

endmodule

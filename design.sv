
module vendingmachine(clk,money,reset,states,choice,delivery,change);
  input [3:0]money;
  input [1:0]reset; 
  input [1:0]choice;
  parameter s0=3'b000,s1=3'b001,s2=3'b010,s3=3'b011,s4=3'b100,s5=3'b101;
  output reg [1:0]delivery;
  output reg [3:0]change;
  output reg [2:0]states;
  input clk;
  always @ (posedge clk)
    begin
      case(states)
        s0:begin
          if(choice==2'b01)
            begin
              states<=s1;
              delivery<=1'b0;
              change<=4'b0000;
            end
          else if(choice==2'b10)
            begin
              states<=s4;
              delivery<=1'b0;
              change<=4'b0000;
            end
          else
            begin
              $display(" INVALID CHOICE ");
            end
        end
        s1:begin
          if(money==4'b0000)
            begin
              states<=s1;
              delivery<=1'b0;
              change<=4'b0000;
            end
          else if(money==4'b1010)
            begin
              states<=s3;
              delivery<=1'b1;
              change<=4'b0000;
            end
          else if(money==4'b0101)
            begin
              states<=s2;
              delivery<=1'b0;
              change<=4'b0000;
            end
          else
            begin
              $display(" PUT IN A VALID DENOMINATION ");
            end
        end
        s3:begin
          if(reset==1'b1)
            begin
              states<=s0;
              delivery<=1'b0;
              change<=4'b0000;
            end
          else if(money==4'b1010)
            begin
              states<=s3;
              delivery<=1'b1;
              change<=4'b0000;
            end
          else if(money==4'b0101)
            begin
              states<=s2;
              delivery<=1'b0;
              change<=4'b0000;
            end
          else
            begin
              $display(" PUT IN A VALID CHOICE ");
            end
        end
        s4:begin
          if(money==0)
            begin
              states<=s4;
              delivery<=1'b0;
              change<=4'b0000;
            end
          else if(money==4'b0101)
            begin
              states<=s5;
              delivery<=1'b1;
              change<=4'b0000;
            end
          else if(money==4'b1010)
            begin
              states<=s5;
              delivery<=1'b1;
              change<=4'b0101;
            end
        end
         s5:begin
          if(reset==1'b1)
            begin
              states<=s0;
              delivery<=1'b0;
              change<=4'b0000;
            end
          else if(money==4'b1010)
            begin
              states<=s5;
              delivery<=1'b1;
              change<=4'b0101;
            end
          else if(money==4'b0101)
            begin
              states<=s5;
              delivery<=1'b1;
              change<=4'b0000;
            end
           else if(money==4'b0000)
             begin
               states<=s4;
               delivery<=1'b0;
               change<=4'b0000;
             end
          else
            begin
              $display(" PUT IN A VALID CHOICE ");
            end
        end
        default:begin
          if(choice==2'b01)
            begin
              states<=s1;
              delivery<=1'b0;
              change<=4'b0000;
            end
          else if(choice==2'b10)
            begin
              states<=s4;
              delivery<=1'b0;
              change<=4'b0000;
            end
          else
            begin
              $display(" INVALID CHOICE ");
            end
        end
      endcase
    end
endmodule
        
          

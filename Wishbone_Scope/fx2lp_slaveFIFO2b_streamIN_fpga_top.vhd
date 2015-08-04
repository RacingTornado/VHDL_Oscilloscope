----------------------------------------------------------------------------------
-- Engineer:Rahul Kumar 
-- 
-- Design Name:  FX2LP-FPGA interface (loopback)
-- Module Name:  
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;      
use IEEE.STD_LOGIC_ARITH.ALL;     
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.vcomponents.all;

entity fx2lp_slaveFIFO2b_streamIN_fpga_top is
  Port (  
 	 reset_n_out   : out STD_LOGIC;                         --used for TB
	 --fdata     : inout  STD_LOGIC_VECTOR(7 downto 0);  --  FIFO data lines.
	 faddr     : out STD_LOGIC_VECTOR(1 downto 0);     --  FIFO select lines
	 slrd      : out STD_LOGIC;                        -- Read control line
	 slwr      : out STD_LOGIC;                        -- Write control line
    
	 flagd     : in  STD_LOGIC;                        --EP6 full flag
	 --flaga     : in  STD_LOGIC;                        --EP2 empty flag
	 clk       : in  STD_LOGIC;                        --Interface Clock
	 --sloe      : out STD_LOGIC;                        --Slave Output Enable control
	 --clk_out   : out STD_LOGIC;
	 --pkt_end   : out STD_LOGIC;
         --done      : out STD_LOGIC;
         sync      : in std_logic
	  
  );
end fx2lp_slaveFIFO2b_streamIN_fpga_top;

architecture fx2lp_slaveFIFO2b_streamIN_fpga_top_arch of fx2lp_slaveFIFO2b_streamIN_fpga_top is

component clk_wiz_v3_6
	port(	
			CLK_IN1           : in     std_logic;			
			CLK_OUT1          : out    std_logic;
			CLK_OUT2          : out    std_logic;
			CLK_OUT3          : out    std_logic;
			CLK_OUT4          : out    std_logic;
			RESET             : in     std_logic;
			LOCKED            : out    std_logic
		);
end component;


--streamIN fsm signal
type stream_in_state is (stram_in_idle, stream_in_write);
signal current_stream_in_state, next_stream_in_state : stream_in_state;

signal slrd_n, slwr_n, sloe_n,slrd_d_n : std_logic;

signal CLK_OUT_0, clk_out_90, clk_out_180, CLK_OUT_270 : std_logic;
signal reset_n : std_logic;
signal lock : std_logic;

signal data_out : std_logic_vector(7 downto 0);
--signal done_d   : std_logic;
signal wait_s   : std_logic_vector(3 downto 0);

begin --architecture begining

--oddr_y : ODDR2 	                                           -- clk out buffer
--	port map
--	(
--	 D0 	=> '1',
--	 D1 	=> '0',
--	 CE 	=> '1',
--	 C0	=> clk_out_180,  
--	 C1	=> (not clk_out_180), 
--	 R  	=> '0',
--	 S  	=> '0',
--	 Q  	=> clk_out
--	);
	
		
--pll : clk_wiz_v3_6  	                                   -- PLL
--	port map(
--	 CLK_IN1         => clk,
--	 clk_out1        => clk_out_0,		
--	 clk_out2        => clk_out_90,
--	 clk_out3        => clk_out_180,
--	 CLK_OUT4	 => clk_out_270,
--	 RESET           => '0',
--	 LOCKED          => lock
--	);


--for TB
reset_n_out <= reset_n;


--output signal asignment
reset_n <= '1';	
slwr  <= slwr_n;
--slrd  <= slrd_n;
--sloe  <= sloe_n;
faddr <= "10";
--pkt_end <= '1';
--done <= done_d;

--fdata <= data_out;

--process(clk, reset_n) begin
--	if(clk'event and clk = '1')then
--		if(wait_s = "1010")then
--                	done_d <= '1';
--		end if;	
--        end if;
--end process;

process(clk, reset_n) begin
	if(reset_n = '0')then
      		wait_s <= "0000";
        elsif(clk'event and clk = '1')then
		if(wait_s < "1010")then
                	wait_s <= wait_s + '1';
		end if;	
        end if;
end process;


--write control signal generation
process(current_stream_in_state, flagd)begin
	if((current_stream_in_state = stream_in_write) and (flagd = '1'))then
		slwr_n <= '0';
	else
		slwr_n <= '1';
	end if;
end process;

--streamIN mode state machine 
streamIN_mode_fsm_f : process(clk, reset_n) begin
	if(reset_n = '0')then
      		current_stream_in_state <= stram_in_idle;
        elsif(clk'event and clk = '1')then
                current_stream_in_state <= next_stream_in_state;
        end if;
end process;

--LoopBack mode state machine combo
streamIN_mode_fsm : process(flagd, current_stream_in_state) begin
	next_stream_in_state <= current_stream_in_state;
	case current_stream_in_state is
		when stram_in_idle =>
			if((flagd = '1') and (sync = '1'))then
				next_stream_in_state <= stream_in_write;
			else
				next_stream_in_state <= stram_in_idle;
			end if;

		when stream_in_write => 
			if(flagd = '0')then
				next_stream_in_state <= stram_in_idle;
			else
				next_stream_in_state <= stream_in_write;
			end if;
				
		when others =>
			next_stream_in_state <= stram_in_idle;
		end case;
end process;

--data generator counter 


end architecture;

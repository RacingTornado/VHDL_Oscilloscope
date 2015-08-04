----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:00:20 07/30/2015 
-- Design Name: 
-- Module Name:    top_wishbone - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_wishbone is
port (
		 fdata     : inout  STD_LOGIC_VECTOR(7 downto 0);  --  FIFO data lines.
	 faddr     : out STD_LOGIC_VECTOR(1 downto 0);     --  FIFO select lines
	 --slrd      : out STD_LOGIC;                        -- Read control line
	 slwr      : out STD_LOGIC;                        -- Write control line
    
	 flagd     : in  STD_LOGIC;                        --EP6 full flag
	 --flaga     : in  STD_LOGIC;                        --EP2 empty flag
	 clk       : in  STD_LOGIC;                        --Interface Clock
	 --sloe      : out STD_LOGIC;                        --Slave Output Enable control
	 clk_out   : out STD_LOGIC;
	 --pkt_end   : out STD_LOGIC;
         --done      : out STD_LOGIC;
         reset_n : in STD_LOGIC;
			sync      : in std_logic
	

			);

end top_wishbone;

architecture Behavioral of top_wishbone is


	COMPONENT fx2lp_slaveFIFO2b_streamIN_fpga_top
	PORT(
		flagd : IN std_logic;
		clk : IN std_logic;
		sync : IN std_logic;    
		--fdata : INOUT std_logic_vector(7 downto 0);      
		reset_n_out : OUT std_logic;
		faddr : OUT std_logic_vector(1 downto 0);
		slwr : OUT std_logic
		--done : OUT std_logic
		);
	END COMPONENT;
	
	
		COMPONENT dcm_32
	PORT(
		CLKIN_IN : IN std_logic;          
		CLKFX_OUT : OUT std_logic;
		CLKIN_IBUFG_OUT : OUT std_logic;
		CLK0_OUT : OUT std_logic
		);
	END COMPONENT;
	
	
		COMPONENT line_ram
	generic(LINE_SIZE : natural := 1023; ADDR_SIZE : natural := 10 );

	PORT(
		clk : IN std_logic;
		we : IN std_logic;
		en : IN std_logic;
		data_in : IN std_logic_vector(7 downto 0);
		addr_re : IN std_logic_vector(9 downto 0);  
		addr_wr : IN std_logic_vector(9 downto 0);		
		data_out : OUT std_logic_vector(7 downto 0);
		re: IN std_logic
		);
	END COMPONENT;

signal count : integer range 0 to 3:=0;
signal Qp : std_logic_vector( 3 downto 0);
signal slwr_temp : std_logic;
signal clk_temp : std_logic;
signal clk_dcm : std_logic;
signal clk_out_temp :std_logic;
signal read_line_ram_addr : std_logic_vector(9 downto 0 ) ; 
signal write_line_ram_addr : std_logic_vector(9 downto 0 ) ; 
signal line_ram_data_in, line_ram_data_out : std_logic_vector(7 downto 0 ) ; 
signal line_ram_en, line_ram_we : std_logic ; 
signal fdata_temp : std_logic_vector(7 downto 0);
signal go : std_logic;
signal line_ram_re :std_logic;
signal data1 :  STD_LOGIC_VECTOR( 7 downto 0);
signal data2 :  STD_LOGIC_VECTOR( 7 downto 0);
signal data3 :  STD_LOGIC_VECTOR( 7 downto 0);
signal data4 :  STD_LOGIC_VECTOR( 7 downto 0);


begin

	Inst_fx2lp_slaveFIFO2b_streamIN_fpga_top: fx2lp_slaveFIFO2b_streamIN_fpga_top PORT MAP(
		--reset_n_out => ,
		--fdata => fdata,
		faddr => faddr,
		--slrd => ,
		slwr => slwr_temp,
		flagd => flagd,
		--flaga => ,
		clk => clk_out_temp,
		--sloe => ,
		--clk_out => clk_out ,
		--done => ,
		sync => sync 
	);
	
	
		Inst_dcm_32: dcm_32 PORT MAP(
		CLKIN_IN => clk,
		CLKFX_OUT => open,
		CLKIN_IBUFG_OUT => open ,
		CLK0_OUT =>  clk_out_temp
	);


			line_ram0 : line_ram --line ram to accumulate data
		generic map(LINE_SIZE => 1023, ADDR_SIZE => 10)
		port map ( 
			clk => clk_out_temp, 
			addr_re => read_line_ram_addr, 
			addr_wr => write_line_ram_addr,
			data_in => line_ram_data_in,
			data_out => line_ram_data_out, 
			en => line_ram_en,
			we => line_ram_we,
			re => line_ram_re
		); 












slwr <= slwr_temp;
clk_out<= clk_out_temp;
fdata <= fdata_temp;
line_ram_we <='1';				

line_ram_en <= '1';
line_ram_re <= '1';
data1 <=  "10000000";
data2 <=  "11000000";
data3 <=  "11100000";
data4 <=  "11110001";


	
	
--	count1:process(clk_out_temp,reset_n)
--	begin
--		if(reset_n= '0') then
--		elsif (rising_edge(clk_out_temp)) then
--			count <= count+1;
--		end if;
--	end process;
	
	
	ram_write: process(clk_out_temp,reset_n)
		begin
			if(reset_n='0') then
				write_line_ram_addr <= (others => '0');
				go <= '0';
				count <= 0;
				line_ram_data_in <= "00000000";
			elsif(rising_edge(clk_out_temp)) then
				case count is
						when 0 => line_ram_data_in<=  data1;
						when 1 => line_ram_data_in<=  data2;
						when 2 => line_ram_data_in <= data3;
						when 3 => line_ram_data_in <= data4;
						when others => line_ram_data_in <= "00000000";
				end case;
				go <= '1';
				if(count =3) then
					count <= 0;
				else
				count <= count +1;
				end if;
				write_line_ram_addr <= write_line_ram_addr + 1;
			end if;
		end process;
		
		
   ram_read: process(clk_out_temp,reset_n)
	begin
			if(reset_n='0') then
				read_line_ram_addr <= (others => '0');
				fdata_temp <= "00000000";		
			elsif(rising_edge(clk_out_temp)) then
				if(slwr_temp = '0' and go='1') then
					fdata_temp <= line_ram_data_out;
					read_line_ram_addr <= read_line_ram_addr +1;
				end if;
			end if;
	end process;


					
				
				
				
				
	
	


	




end Behavioral;


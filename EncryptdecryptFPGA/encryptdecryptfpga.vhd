----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:13:40 11/25/2016 
-- Design Name: 
-- Module Name:    encryptdecryptfpga - Behavioral 
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
use work.rc5_pkg.All;
use IEEE.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity encryptdecryptfpga is

port (

----------------some stuff are commented or set with default values to make simulation faster, don't need to input every time
		CLK: in STD_LOGIC; 
		clr	: IN STD_LOGIC;
	SSEG_CA 		: out  STD_LOGIC_VECTOR (7 downto 0);
       SSEG_AN 		: out  STD_LOGIC_VECTOR (7 downto 0);
--		  switch_display: in std_logic;
--			  led_rdy : out std_logic;
--			  led_switch: out std_logic;
--			  switch_valid: in std_logic;
--			 switch_pick: in std_logic;
--			 select_din: in std_logic_vector(1 downto 0);
--			 
--			 din_part : std_logic_vector(7 downto 0):= x"57";
--			 valid_selector: std_logic:= '0';
	 enable: IN std_logic_vector(1 downto 0):= "00";
--		  ukey_change_valk       :  in std_logic_vector(7 downto 0):= x"00";
--		  ukey_change_posk    : in std_logic_vector(1 downto 0):= "00";
--		  
		  
		 doutzT: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		  show_one: out std_logic_vector(31 downto 0);
		  show_two: out std_logic_vector(31 downto 0);
		  di_vldzT: out STD_LOGIC;
		  do_rdyzT: out std_logic;
		  key_rdykT:out std_logic;
		  
		  doutxT: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		  dinxT: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		  di_vldxT: out STD_LOGIC
		  
		);


end encryptdecryptfpga;


 architecture Behavioral of encryptdecryptfpga is
 
 -------------------------------------------------------------------------------control stuff
TYPE     StateType IS (ST_key, ST_en, ST_de, ST_READY,ST_IDLE);
			SIGNAL	state : StateType;
 
 
 
 
 
 ----------------------------------------------------------------------------------key expand
 component keyexpand
    port    (
        clr	: IN STD_LOGIC;
        clk	: IN STD_LOGIC;
		  key_in	: IN STD_LOGIC;
        skey	:  out S_ARRAY;
        key_rdy	: OUT STD_LOGIC;	
			ukey	: in STD_LOGIC_VECTOR(127 DOWNTO 0):= x"00000000000000000000000000000000";
		switch_pick: in std_logic_vector(4 downto 0)
		);
 end component;
 
--signal clrk: std_logic;
signal key_ink	: STD_LOGIC;
signal skeyk	:   S_ARRAY;   --skey to give decrypt and encrypt     
signal key_rdyk	:  STD_LOGIC:= '0';		 
signal ukeyk	: STD_LOGIC_VECTOR(127 DOWNTO 0):= x"00000000000000000000000000000001";
signal	switch_pickk: std_logic_vector(4 downto 0);

 
 
---------------------------------------------------------------------encryption

component encrypt
port(

clr: IN STD_LOGIC;  -- asynchronous reset
  clk: IN STD_LOGIC;  -- Clock signal
  din: IN STD_LOGIC_VECTOR(63 DOWNTO 0);--64-bit i/p
  dout: OUT STD_LOGIC_VECTOR(63 DOWNTO 0);--64-bit o/p
   di_vld: IN	STD_LOGIC;
	skey: IN S_ARRAY;
	do_rdy: OUT	STD_LOGIC
);

end component;

--signal clrz:  std_logic;
signal dinz:  std_LOGIC_VECTOR(63 DOWNTO 0):= x"1100110011001100";
signal doutz:  STD_LOGIC_VECTOR(63 DOWNTO 0);
signal do_rdyz:  std_logic;
signal di_vldz:  std_logic;
signal skeyz: S_ARRAY;



------------------------------------------------------------------------------decryption

component decrypt
port(

clr: IN STD_LOGIC;  -- asynchronous reset
  clk: IN STD_LOGIC;  -- Clock signal
  din: IN STD_LOGIC_VECTOR(63 DOWNTO 0);--64-bit i/p
  dout: OUT STD_LOGIC_VECTOR(63 DOWNTO 0);--64-bit o/p
   di_vld: IN	STD_LOGIC;
 do_rdy: OUT	STD_LOGIC;
 skey:in S_ARRAY
);

end component;

--signal clrx:  std_logic;
signal dinx:  std_LOGIC_VECTOR(63 DOWNTO 0):= x"11B96C96375F00FF";
signal doutx:  STD_LOGIC_VECTOR(63 DOWNTO 0);
signal do_rdyx:  std_logic;
signal di_vldx:  std_logic:= '0';
signal skeyx: S_ARRAY;



--------------------------------------------------------------- display
--type arr is array(0 to 22) of std_logic_vector(7 downto 0);
--signal NAME: arr;
--constant VAL_MAX : std_logic_vector(3 downto 0) := "1001"; --9
--
--signal Val : std_logic_vector(3 downto 0):= "1000";
--signal hexval: std_logic_vector(31 downto 0):= x"00000001";
--signal show_value : std_logic_vector(63 downto 0);
--constant CNTR_MAX : std_logic_vector(23 downto 0) := x"030D40"; --100,000,000 = clk cycles per second
--signal Cntr : std_logic_vector(26 downto 0) := (others => '0');
--signal done:  std_logic:= '0';
-----------------------------------------------------------------


--component hex2led
--port (
--CLK: in STD_LOGIC; 
--X: in STD_LOGIC_VECTOR (3 downto 0); 
--Y: out STD_LOGIC_VECTOR (7 downto 0)
--);
--end component;

--------------------------------------------------------------------------------------
begin

--led_rdy <= do_rdyx;
--led_switch <= switch_display;
--di_vldx <= switch_valid;
--clrx <= switch_display;

-----------------------these ports were made for timing testing,make my life easier
doutzT <= doutz(63 downto 32);

show_one <= skeyk(0);
show_two<= skeyk(1);

di_vldzT <= di_vldz;
do_rdyzT <= do_rdyz;
key_rdykT <= key_rdyk;

doutxT <= doutx(63 downto 32);
di_vldxT <= di_vldx;
dinxT <= dinx(63 downto 32);



--
--process(CLK,switch_display) --Last 2 switches control what value you see on the 7seg
--Begin
--
--		if rising_edge(clk) then
--			case switch_display is
--				when '1' => 
--				if(do_rdyx'EVENT and do_rdyx = '1' and done /= '1') then
--				done <= '1';
--				show_value <= doutx(63 downto 0);
--				end if;
--	
--			when others => show_value <= show_value;
--			end case;
--	end if;
--	
--end process;
--
--


--timer_counter_process : process (CLK)
--begin
--	if (rising_edge(CLK)) then
--	
--		if ( (Cntr = CNTR_MAX) ) then
--			Cntr <= (others => '0');
--			--Count_divider <= Count_divider XOR Count_divider;
--			else
--		--elsif (Count_divider > 1000) then
--		--Count_divider <= Count_divider XOR Count_divider;
--			Cntr <= Cntr + 1;
--			
--		end if;
--		--Count_divider <= Count_divider + 1;
--	end if;
--end process;
--

--process (CLK)
--begin
--	if (rising_edge(CLK)) then
--
--			
--	if (Cntr = CNTR_MAX) then
--		
--			if (Val = VAL_MAX) then
--				Val <= (others => '0');
--			else
--				Val <= Val + 1;
--			end if;
--		end if;
--	end if;
--end process;
--	
--with switch_pick select
--	hexval <=   show_value(63 downto 32) when '1',
--					show_value(31 downto 0) when others;
--
--
--with Val select
--	SSEG_AN <= "01111111" when "0001", 
--				  "10111111" when "0010", 
--				  "11011111" when "0011",
--				  "11101111" when "0100",
--				  "11110111" when "0101",
--				  "11111011" when "0110",
--				  "11111101" when "0111",
--				  "11111110" when "1000",
--				  "11111111" when others;
--
----This select statement selects the value of HexVal to the necessary
----cathode signals to display it on the 7-segment
--with Val select
--SSEG_CA <=  NAME(0) when "0001",
--				  NAME(1) when "0010",
--				  NAME(2)when "0011",
--				  NAME(3) when "0100",
--				  NAME(4) when "0101",
--				  NAME(5) when "0110",
--				  NAME(6) when "0111",
--				  NAME(7) when "1000",
-- 				 NAME(0) when others;
--
--CONV1: Hex2LED port map (CLK => CLK, X => HexVal(31 downto 28), Y => NAME(0));
--CONV2: Hex2LED port map (CLK => CLK, X => HexVal(27 downto 24), Y => NAME(1));
--CONV3: Hex2LED port map (CLK => CLK, X => HexVal(23 downto 20), Y => NAME(2));
--CONV4: Hex2LED port map (CLK => CLK,X => HexVal(19 downto 16), Y => NAME(3));		
--CONV5: Hex2LED port map (CLK => CLK, X => HexVal(15 downto 12), Y => NAME(4));
--CONV6: Hex2LED port map (CLK => CLK, X => HexVal(11 downto 8), Y => NAME(5));
--CONV7: Hex2LED port map (CLK => CLK,X => HexVal(7 downto 4), Y => NAME(6));
--CONV8: Hex2LED port map (CLK => CLK,X => HexVal(3 downto 0), Y => NAME(7));

CONV9: decrypt port map (clk => CLK ,clr => clr, din => dinx(63 downto 0), dout=> doutx(63 downto 0), di_vld => di_vldx, do_rdy =>  do_rdyx, skey => skeyx );
--
CONV10: encrypt port map (clk => CLK ,clr => clr, din => dinz(63 downto 0), dout=> doutz(63 downto 0), di_vld => di_vldz, do_rdy =>  do_rdyz, skey => skeyz );
CONV11: keyexpand port map (clk => CLK ,clr => clr, key_in => key_ink, key_rdy => key_rdyk, ukey => ukeyk, switch_pick => switch_pickk,skey => skeyk );


--process (select_din,din_part)
--	Begin 
--	
--case(select_din) is
--	When "01" =>                    dinx(15 downto 8) <= din_part;
--	When "10" =>                    dinx(23 downto 16) <= din_part;
--	When "11" =>                    dinx(31 downto 24) <= din_part;
--	When others =>                  dinx(7 downto 0) <= din_part;
--end case;
--
--end process ;



-------------------------------------------------------------------------------control shit
--This block is for fpga only, not simulations
--process(clk,ukey_change_posk)
--begin
--  if(rising_edge(clk)) THEN
--	CASE ukey_change_posk IS
--              WHEN "00" =>
--                  	ukeyk(7 downto 0) <= ukey_change_valk;
--							
--              WHEN "01"=> 
--						ukeyk(15 downto 8) <= ukey_change_valk;
--					
--				  WHEN "10" => 
--						ukeyk(23 downto 16) <= ukey_change_valk;
--				  When others =>   ukeyk(31 downto 24) <= ukey_change_valk;
--	
--end case;
--end if;
--
--end process;




	

PROCESS(clr, clk)	
     BEGIN
       IF(clr='0') THEN
           state<=ST_IDLE;
			  di_vldz <= '0';
			  di_vldx <= '0';
			  
			  
       ELSIF(clk'EVENT AND clk='1') THEN --enable key
           CASE state IS
              WHEN ST_IDLE =>
                  	IF(enable = "01" and key_rdyk = '0') THEN  
								state <= ST_KEY; 
								key_ink <= '1'; --making all valids auto trigger for testing, I didn't want to put in di_vld eveyrtime  I simulate
							END IF;
							
							IF(enable = "10" and key_rdyk = '1'  and do_rdyz = '0' ) THEN  -- enable encrypt
								state <= ST_en; 
							
								di_vldz <= '1';   --making all valids auto trigger for testing/simulation
							
							END IF;
							
							IF(enable = "11" and key_rdyk = '1' and do_rdyx = '0') THEN  
								state <= ST_de;
								
								di_vldx <= '1'; --making all valids auto trigger for testing/simulation
							END IF;

		
              WHEN ST_key =>  --enable key
						
						
						
						if(key_rdyk = '1') then
						state <= ST_READY;
						end if;
							
              WHEN ST_en=>  --enable encrypt
						skeyz <= skeyk;
						di_vldz <= '1';
						
						if(do_rdyz = '1') then
						state <= ST_READY;
						end if;
						
				  WHEN ST_de=> --enable decrypt
				  
					skeyx <= skeyk;
						di_vldx <= '1';

						if(do_rdyx = '1') then
						state <= ST_READY;

						end if;
						
					when ST_READY=>
						state <= ST_IDLE;
--					IF() THEN  
--								state <= ST_KEY; 
--								key_ink <= '1';
--							END IF;
--							
--							IF(enable = "10") THEN  -- enable encrypt
--								state <= ST_en; 
--								skeyz <= skeyk;
--								di_vldz <= '1';
--							
--							END IF;
--							
----							IF(enable = "11") THEN  
----								state <= ST_de;
----								skeyx <= skeyk;
----								di_vldx <= '1';
----							END IF;
--							
					
					when others =>
						
          END CASE;
        END IF;
  END PROCESS;







end Behavioral;

-------------------------------------------



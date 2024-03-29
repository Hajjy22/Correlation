

Library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity correlation is
	port(
		CLK : in std_logic;                                 
		RSTn : in std_logic;                                
		In_re : in std_logic_vector(11 downto 0);           
		Evalue : in std_logic ;                            
		Corr_symbole : out std_logic_vector(16 downto 0);   
		Corr_trame : out std_logic_vector(18 downto 0)) ;   
end correlation;

architecture arch_correlation of correlation is 

---------------------------- shiftregister1 ----------------------
	COMPONENT shiftregister1 IS
		PORT
		(
			clock		: IN STD_LOGIC ;
			shiftin		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
			shiftout		: OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
			taps		: OUT STD_LOGIC_VECTOR (11 DOWNTO 0)
		);
	END COMPONENT;

----------------------------  shiftregister2 ----------------------

	COMPONENT shiftregister2 IS
		PORT
		(
			clock		: IN STD_LOGIC ;
			shiftin		: IN STD_LOGIC_VECTOR (16 DOWNTO 0);
			shiftout		: OUT STD_LOGIC_VECTOR (16 DOWNTO 0);
			taps		: OUT STD_LOGIC_VECTOR (16 DOWNTO 0)
		);
	END COMPONENT;
	


	SIGNAL s_in_re , O1 , O2  , s_in_retard0 ,s_in_retard1 ,s_add_0 ,s_add_1: STD_LOGIC_VECTOR(11 downto 0);
	
	SIGNAL s_int0 , s_int1 ,s_int2 ,s_int3  : STD_LOGIC_VECTOR(16 downto 0);
	
	SIGNAL s_int4 : STD_LOGIC_VECTOR(11 downto 0);
	
	SIGNAL s_int5 , s_int6 ,s_int7 ,s_int8 ,s_int9: STD_LOGIC_VECTOR(18 downto 0);
	

BEGIN

	
-----------------------    SR1 - SR2 -SR3  ----------------------------------
	SR1 : shiftregister1 
		PORT MAP (
			clock		=> CLK,
			shiftin		=> In_re,
			shiftout	=> O1,
			taps		=> OPEN
		);


	SR2 : shiftregister1
		PORT MAP (
			clock		=> CLK,
			shiftin		=> O1,
			shiftout	=> O2,
			taps		=> OPEN
		); 
 
  SR3 : shiftregister2
		PORT MAP (
			clock		=> CLK,
			shiftin		=> s_int0,
			shiftout	=> s_int1,
			taps		=> OPEN
		); 
		
----------------------    R1-R2-R3-R4-R5-R6 ----------------------------------				
	R1_R2_R3_R4_R5_56 : process (RSTn,CLK)
	begin
		if RSTn = '0' then 
			s_in_re <= (others => '0');
			s_in_retard0 <= (others => '0');
			s_int3 <= (others => '0');
			s_in_retard1 <= (others => '0');
			s_int7 <= (others => '0');
			s_int9 <= (others => '0');
		elsif CLK'event and CLK = '1' then 
			s_in_re <= In_re;
			s_in_retard0 <= O2;
			s_int3 <= s_int2;
			s_in_retard1 <= O1;
			s_int7 <= s_int6;
			s_int9 <= s_int8;
		end if;
	end process;
	
		
-----------------------   OP1 - OP4  --------------------------------
	OP1 : process(RSTn, CLK)
		 begin
		 if RSTn = '0' then
			 s_int0 <= (others => '0');
		 elsif CLK'event and CLK='1' then
			 if (s_add_0(11)='1') then
				 s_int0 <=  -(s_add_0(11)&s_add_0(11)&s_add_0(11)&s_add_0(11)&s_add_0(11)&s_add_0);
			 elsif (s_add_0(11)='0') then
				 s_int0 <= (s_add_0(11)&s_add_0(11)&s_add_0(11)&s_add_0(11)&s_add_0(11)&s_add_0);
			 end if;   
		  end if;    
         end process;
	
	OP3 : process(RSTn, CLK)
		 begin
		 if RSTn = '0' then
			 s_int4 <= (others => '0');
		 elsif CLK'event and CLK='1' then
			 if (s_add_1(11)='1') then
				 s_int4 <=  -s_add_1;
			 else 
				 s_int4 <= s_add_1;
			 end if;   
		  end if;    
     end process;
     
  ----------------------    ADD-0  --------------------
	s_add_0 <= s_in_retard0 - s_in_re ; 
	   
  -----------------------    OP2   ------------------		
	s_int2 <= s_int3 + s_int0 - s_int1; 
	
------------------------------   ADD-1  ----------------
	
	s_add_1 <= s_in_retard1 - s_in_re ;
--------------------------------    OP4  --------------------------
	s_int5 <= s_int4 + s_int7 ; 
  
--------------------------------     MUX1  -----------------------

	s_int6 <= s_int5 when evalue = '0' else (others => '0');
 
	
---------------------------------     MUX2  ---------------------
  
	s_int8 <= s_int9 when evalue = '0' else s_int7; 
	
	
	------------------------------------------- Resultat :  Corr_symbole , corr_trame  ------------------------------
	
	Corr_symbole <= s_int3;
	
	corr_trame <= s_int9 ; 
	
end arch_correlation;
	

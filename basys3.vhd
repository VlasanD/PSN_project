----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/10/2022 09:25:10 PM
-- Design Name: 
-- Module Name: basys3 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity basys3 is
  Port (
  signal clk:in std_logic;
signal btn:in std_logic_vector(4 downto 0);
signal sw:in std_logic_vector(15 downto 0);
signal led:out std_logic_vector(15 downto 0);
signal an:out std_Logic_vector(3 downto 0);
signal cat:out std_logic_vector(7 downto 0)
   );
end basys3;

architecture Behavioral of basys3 is

signal btn_start:std_logic;
signal btn_rst:std_logic;
signal btn_ready:std_logic;
signal btn_drt:std_logic;
signal btn_stg:std_logic;

signal afisare_stare:std_logic_vector(3 downto 0);
signal afisare_stanga:std_logic_vector(3 downto 0);
signal afisare_dreapta:std_logic_vector(3 downto 0);
signal afisare_intensitate:std_logic_vector(2 downto 0);
signal afisare_timer_stanga:std_logic_vector(3 downto 0);
signal afisare_timer_dreapta:std_logic_vector(3 downto 0);

signal date:std_logic_vector(15 downto 0):=(others=>'0');
begin
--instantiere pentru butonul de start
btnc:entity WORK.mpg port map
(
btn=>btn(0),
clk=>clk,
en=>btn_start
);
--instantiere pentru butonul de reset
btnu:entity WORK.mpg port map
(
btn=>btn(1),
clk=>clk,
en=>btn_rst
);

--instantiere pentru butonul ready
btnd:entity WORK.mpg port map
(
btn=>btn(4),
clk=>clk,
en=>btn_ready
);
btnr:entity WORK.mpg port map
(
btn=>btn(3),
clk=>clk,
en=>btn_drt
);
btnl:entity WORK.mpg port map
(
btn=>btn(2),
clk=>clk,
en=>btn_stg
);
-- instantiere pentru UCC
uc:entity WORK.UCC port map
(
  clk=>clk,
  rst=>btn_rst,
  btn_start=>btn_start,
  btn_ready=>btn_ready,
  btn_stg=>btn_stg,
  btn_drt=>btn_drt,
  sw=>sw,
  afisare_stare=>afisare_stare,
  afisare_stanga=>afisare_stanga,
  afisare_dreapta=>afisare_dreapta,
  afisare_timer_stanga=>afisare_timer_stanga,
  afisare_timer_dreapta=>afisare_timer_dreapta,
  afisare_intensitate=>afisare_intensitate
);

date<=afisare_stanga & afisare_timer_stanga & afisare_timer_dreapta & afisare_dreapta;

-- instantiere pentru SSD
afisor:entity WORK.displ7seg port map
(
Clk=>clk,
Rst=>'0',
Data=>date,
An=>an,
Seg=>cat
);

led(15 downto 0)<=sw(15 downto 0);

end Behavioral;

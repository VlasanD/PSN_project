----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/10/2022 09:48:28 PM
-- Design Name: 
-- Module Name: UCC - Behavioral
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

entity UCC is
  Port (
  signal clk:in std_logic;
 signal rst:in std_logic;
 signal btn_start:in std_logic;
 signal btn_ready:in std_logic;
 signal btn_stg:in std_logic;
 signal btn_drt:in std_logic;
 signal sw:in std_logic_vector(15 downto 0);
 signal afisare_stare:out std_logic_vector(3 downto 0);
 signal afisare_stanga:out std_logic_vector(3 downto 0);
 signal afisare_dreapta:out std_logic_vector(3 downto 0);
 signal afisare_timer_stanga:out std_logic_vector(3 downto 0);
 signal afisare_timer_dreapta:out std_logic_vector(3 downto 0);
 signal afisare_intensitate:out std_logic_vector(2 downto 0)
   );
end UCC;

architecture Behavioral of UCC is

signal ptn_matched:std_logic:='0';

-- semnale pentru viteza animatiei
signal timp_numarator:integer:=0;
signal intensitate:std_logic_vector(2 downto 0):="000";

-- semnale pentru divizoru de frecventa
signal div_frec:integer:=0;
signal semnal_divizat:std_logic:='0';
signal reset_intern:std_logic:='0';

--semnale pentru care jucator incepe
signal incepe:std_logic:='0';

--counter
signal counter:integer:=0;

--semnale pentru fsm
type stari is (idle,start,actualizare,jucator_stanga_0,interm1,jucator_dreapta_0,jucator_stanga_1,interm2,jucator_dreapta_1,animatie,scorL,scorR,stop);
signal stare_curenta:stari:=idle;
signal stare_urmatoare:stari:=idle;

--semnale intermediare afisare
signal scor_stanga:std_logic_vector(3 downto 0):="0000";
signal scor_dreapta:std_logic_vector(3 downto 0):="0000";

signal counter_b:std_logic_vector (3 downto 0):="0000";

signal ptn_stg:std_logic_vector(7 downto 0):="00000000";
signal ptn_drt:std_logic_vector(7 downto 0):="00000000";

begin

  --determinam viteza animatiei
  
  timp_numarator<= 99999999 when intensitate="000" else -- 100 000 000 1s     --0     49999999
                 74999999 when intensitate="001" else --  75 000 000 0.75s  --1     24999999
                 49999999 when intensitate="010" else --  50 000 000 0.5s   --2
                 24999999 when intensitate="011" else --  25 000 000 0.25s  --3
                  9999999 when intensitate="100" else --  10 000 000 0.1s   --4
                  7499999 when intensitate="101" else --   7 500 000 0.075s --5
                  499999 when intensitate="110" else  --   5 000 000 0.05s  --6
                  249999;                             --   2 500 000 0.025s --7
 
 -- procese pentru FSM( fsm cu 3 procese) cu resetare asincrona       

 --proces de actualizare a starii actuale
process(clk,rst)
begin                                   
if rst='1' then
stare_curenta<=idle;
elsif clk='1' and clk'event then
stare_curenta<=stare_urmatoare;
end if;                
end process;

 --proces pentru a determina starea urmatoare 
process(stare_curenta,btn_start,btn_ready,incepe,counter,scor_stanga,scor_dreapta,ptn_matched)
begin
case stare_curenta is
when idle=>if btn_start='1' then
                stare_urmatoare<=start;
           else
                stare_urmatoare<=idle;
           end if;
when start=>if btn_ready='1' then
                if incepe='0' then
                    stare_urmatoare<=jucator_stanga_0;
                elsif incepe='1'then 
                    stare_urmatoare<=jucator_dreapta_1;
                end if;
            else 
                stare_urmatoare<=start;
            end if;
when actualizare=> stare_urmatoare<=start;
when jucator_stanga_0=>if counter=16 then
                            stare_urmatoare<=interm1;
                       elsif counter<=15 then
                            stare_urmatoare<=jucator_stanga_0;
                       end if;
when interm1=>stare_urmatoare<=jucator_dreapta_0;
when jucator_dreapta_0=>if counter=16 and ptn_matched='1' then 
                            stare_urmatoare<=actualizare;
                        elsif counter=16 and ptn_matched='0' then 
                            stare_urmatoare<=scorL;  
                        elsif counter<=15 then
                            stare_urmatoare<=jucator_dreapta_0;
                        end if;
 when jucator_dreapta_1=>if counter=16 then
                            stare_urmatoare<=interm2;
                         elsif counter<=15 then
                            stare_urmatoare<=jucator_dreapta_1;
                         end if;  
when interm2=>stare_urmatoare<=jucator_stanga_1;                             
when jucator_stanga_1=>if counter=16 and ptn_matched='1' then 
                            stare_urmatoare<=actualizare;
                       elsif counter=16 and ptn_matched='0' then 
                            stare_urmatoare<=scorR;  
                       elsif counter<=15 then
                            stare_urmatoare<=jucator_stanga_1;
                        end if;                               
when scorL=>stare_urmatoare<=animatie;
when scorR=>stare_urmatoare<=animatie;
when animatie=>if scor_stanga="1111" or scor_dreapta="1111" then
                    stare_urmatoare<=stop;
               else
               --elsif scor_stanga/="1111" or scor_dreapta/="1111" then
                    stare_urmatoare<=start;
               end if;
when others=>stare_urmatoare<=idle;          
end case;            
end process;
 
--proces pentru a determina valoarea semnalelor de iesire
process(stare_curenta)
begin
case stare_curenta is 
when idle=>reset_intern<='1';afisare_stare<="0000";
when start=>reset_intern<='1';afisare_stare<="0001";
when actualizare=>reset_intern<='1';afisare_stare<="0010";
when jucator_stanga_0=>reset_intern<='0';afisare_stare<="0011";
when jucator_dreapta_0=>reset_intern<='0';afisare_stare<="0101";
when jucator_stanga_1=>reset_intern<='0';afisare_stare<="0110";
when jucator_dreapta_1=>reset_intern<='0';afisare_stare<="0111";
when scorL=>reset_intern<='1';afisare_stare<="1000";
when scorR=>reset_intern<='1';afisare_stare<="1001";
when animatie=>reset_intern<='1';afisare_stare<="1010";
when interm1=>reset_intern<='1';afisare_stare<="1111";
when interm2=>reset_intern<='1';afisare_stare<="1111";
when others=>reset_intern<='1';afisare_stare<="1011";
end case;
end process;

-- proces pentru divizor de frecventa variabil cu resetare asincrona                  
process(clk,reset_intern)
begin
if reset_intern='1' then
    div_frec<=0;
elsif clk='1' and clk'event then
    if div_frec=timp_numarator then 
        div_frec<=0;
        semnal_divizat<=not(semnal_divizat);
    else
        div_frec<=div_frec+1;
    end if;
end if;
end process;
--process in functie de ceas pentru semnale interne
process(clk)
begin
if clk='1' and clk'event then
    if stare_curenta=idle then
        intensitate<="000";
        scor_stanga<="0000";
        scor_dreapta<="0000";
        if btn_drt='1'then 
            incepe<='1';
        elsif btn_stg='1' then
            incepe<='0';
        end if;
    end if;
    if stare_curenta=actualizare then
        intensitate<=intensitate+1;
    end if;
    if stare_curenta=scorL then
       scor_stanga<=scor_stanga+1;
       incepe<='1';
    end if;
    if stare_curenta=scorR then
       scor_dreapta<=scor_dreapta+1;
       incepe<='0';
    end if; 
    if stare_curenta=jucator_stanga_1 then
        incepe<='0';
    end if;
    if stare_curenta=jucator_dreapta_0 then
        incepe<='1';
    end if;
end if;
end process;    
-- numarator in functie de un semnal divizat
process(semnal_divizat,reset_intern)
begin
if reset_intern='1' then
    counter<=0;
elsif Rising_edge(semnal_divizat) then
    if counter=17 then
        counter<=0;
    else
        counter<=counter+1;
    end if;
end if;
end process;

-- proces pentru sw
--process(sw,stare_curenta)
--begin
--if stare_curenta=jucator_dreapta_0 or stare_curenta=jucator_stanga_1 then
--    ptn_matched<='1';
--    if sw(0)/=sw(15) then
--        ptn_matched<='0';
--    end if;
--    if sw(1)/=sw(14) then
--        ptn_matched<='0';
--    end if;
--    if sw(2)/=sw(13) then
--        ptn_matched<='0';
--    end if;
--    if sw(3)/=sw(12) then
--        ptn_matched<='0';
--    end if;
--    if sw(4)/=sw(11) then
--        ptn_matched<='0';
--    end if;
--    if sw(5)/=sw(10) then
--        ptn_matched<='0';
--    end if;
--    if sw(6)/=sw(9) then
--        ptn_matched<='0';
--    end if;
--    if sw(7)/=sw(8) then
--        ptn_matched<='0';
--    end if;
--end if;
--end process;
-- process pt switch cu "memorie"
process(sw,stare_curenta,ptn_stg,ptn_drt)
begin
if stare_curenta=jucator_dreapta_0 or stare_curenta=jucator_dreapta_1 then
    ptn_drt(7 downto 0)<="00000000";
    if sw(0)='1' then
        ptn_drt(7)<='1';
    end if;
    if sw(1)='1' then
        ptn_drt(6)<='1';
    end if;
    if sw(2)='1' then
        ptn_drt(5)<='1';
    end if;
    if sw(3)='1' then
        ptn_drt(4)<='1';
    end if;
    if sw(4)='1' then
        ptn_drt(3)<='1';
    end if;
    if sw(5)='1' then
        ptn_drt(2)<='1';
    end if;
    if sw(6)='1' then
        ptn_drt(1)<='1';
    end if;
    if sw(7)='1' then
        ptn_drt(0)<='1';
    end if;
end if;
if stare_curenta=jucator_stanga_0 or stare_curenta=jucator_stanga_1 then
    ptn_stg(7 downto 0)<="00000000";
    ptn_stg(7 downto 0)<=sw(15 downto 8);
end if;
if stare_curenta=jucator_dreapta_0 or stare_curenta=jucator_stanga_1 then
    if ptn_stg(7 downto 0)=ptn_drt(7 downto 0) then
        ptn_matched<='1';
    else
        ptn_matched<='0';
    end if;
end if;
end process;

process(semnal_divizat,reset_intern)
begin
if reset_intern='1' then
    counter_b<="0000";
elsif Rising_edge(semnal_divizat) then
    if counter_b="1111" then
        counter_b<="0000";
    else
        counter_b<=counter_b+1;
    end if;
end if;
end process;

process(stare_curenta,counter_b)
begin
if stare_curenta=jucator_dreapta_0 or stare_curenta=jucator_dreapta_1 then
afisare_timer_dreapta<=counter_b;
else
afisare_timer_dreapta<="0000";
end if;
if stare_curenta=jucator_stanga_0 or stare_curenta=jucator_stanga_1 then
afisare_timer_stanga<=counter_b;
else
afisare_timer_stanga<="0000";
end if;
end process;

afisare_stanga<=scor_stanga;
afisare_dreapta<=scor_dreapta;
afisare_intensitate<=intensitate;

end Behavioral;
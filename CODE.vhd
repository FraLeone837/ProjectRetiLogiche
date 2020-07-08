library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;


entity project_reti_logiche is
    Port ( i_clk : in STD_LOGIC;
           i_start : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_address : out STD_LOGIC_VECTOR (15 downto 0);
           o_done : out STD_LOGIC;
           o_en : out STD_LOGIC;
           o_we : out STD_LOGIC;
           o_data : out STD_LOGIC_VECTOR (7 downto 0));
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

type state_type is (init, rmem0, rmem1, rmem2, rmem3, rmem4, rmem5, rmem6, rmem7, wait_start, find_difference, check_difference, not_in_wz, in_wz, reset_parametres, reset_done);
signal CURRENT_STATE : state_type;
signal NEXT_STATE : state_type;
type memory_type is array (7 downto 0) of std_logic_vector(7 downto 0);
signal mem : memory_type;
signal diff : std_logic_vector (7 downto 0);
signal cod_diff : std_logic_vector (3 downto 0);
signal count : std_logic_vector (2 downto 0);

begin

combin: process (i_clk)
begin
if(i_clk'EVENT and i_clk='0') then
    case CURRENT_STATE is
        when init =>
            count <= "000";
            o_address <= "0000000000000000"; 
            o_en <= '1';
            o_we <= '0';
            o_done <= '0';
            NEXT_STATE <= rmem0;
        
        when rmem0 =>
            mem(0) <= i_data;
            o_address <= "0000000000000001"; 
            NEXT_STATE <= rmem1;
       
        when rmem1 =>
            mem(1) <= i_data;
            o_address <= "0000000000000010";
            NEXT_STATE <= rmem2;
       
        when rmem2 =>
            mem(2) <= i_data;
            o_address <= "0000000000000011";
            NEXT_STATE <= rmem3;
       
        when rmem3 =>
            mem(3) <= i_data;
            o_address <= "0000000000000100";
            NEXT_STATE <= rmem4;
     
        when rmem4 =>
            mem(4) <= i_data;
            o_address <= "0000000000000101";
            NEXT_STATE <= rmem5;
    
        when rmem5 =>
            mem(5) <= i_data;
            o_address <= "0000000000000110";
            NEXT_STATE <= rmem6;
    
        when rmem6 =>
            mem(6) <= i_data;
            o_address <= "0000000000000111";
            NEXT_STATE <= rmem7;
     
        when rmem7 =>
            mem(7) <= i_data;
            o_address <= "0000000000001000";
            NEXT_STATE <= wait_start;
     
        when wait_start =>            
            if i_start = '1' then
                o_en <= '0';
                NEXT_STATE <= find_difference;
            else                
                NEXT_STATE <= wait_start;
            end if;
            
         when find_difference =>
            diff <= std_logic_vector(unsigned(i_data) - unsigned(mem(conv_integer(count)))) ;            
            NEXT_STATE <= check_difference; 
            
         when check_difference =>
            if cod_diff = "0000" then
                if count = 7 then   
                    o_address <= "0000000000001001";                 
                    NEXT_STATE <= not_in_wz;
                else
                    count <= std_logic_vector(unsigned(count) + "001");
                    NEXT_STATE <= find_difference;
                end if;
            else
                o_address <= "0000000000001001";                
                NEXT_STATE <= in_wz;
            end if;
            
         when not_in_wz =>
            o_en <= '1';
            o_we <= '1';
            o_data <= i_data;
            o_done <= '1';
            NEXT_STATE <= reset_parametres;
            
         when in_wz =>
            o_en <= '1';
            o_we <= '1';
            o_data <= '1' & count & cod_diff;
            o_done <= '1';
            NEXT_STATE <= reset_parametres;
           
         when reset_parametres =>
            o_en <= '1';
            o_we <= '0';
            o_address <= "0000000000001000";
            count <= "000";
            if (i_start = '0') then                      
                NEXT_STATE <= reset_done;
            else 
                NEXT_STATE <= reset_parametres;
            end if;
            
         when reset_done =>
            o_done <= '0';
            NEXT_STATE <= wait_start;                          
    end case;
    end if;
end process;

memory: process (i_clk, i_rst) 
begin
    if(i_clk'EVENT and i_clk='1') then
        if(i_rst = '1') then 
            CURRENT_STATE <= init;
        else
            CURRENT_STATE <= NEXT_STATE;
        end if;
    end if;
end process;

codify_diff: process(diff)
begin
    case diff is
        when "00000000" => cod_diff <= "0001"; 
        when "00000001" => cod_diff <= "0010";          
        when "00000010" => cod_diff <= "0100";           
        when "00000011" => cod_diff <= "1000";           
        when others => cod_diff <= "0000";            
    end case;
end process;   

end Behavioral;
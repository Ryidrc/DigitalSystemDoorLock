library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Doorlock is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        enable    : in  STD_LOGIC; -- click enter pw pas input
        mode      : in  STD_LOGIC; -- mode set/input pw
        unlock_button : in  STD_LOGIC; -- unlock dari dalem
        switches  : in  STD_LOGIC_VECTOR (3 downto 0);
        led_set   : out STD_LOGIC; -- indicator kalo set pw
        led_input : out STD_LOGIC; -- indicator kalo input pw
        led_ok    : out STD_LOGIC; -- indicator kalo password bener
        pw1, pw2, pw3, pw4, pw5, pw6, pw7, pw8 : out STD_LOGIC; -- indicator lagi input digit password ke berapa
                
        seg: out STD_LOGIC_VECTOR (7 downto 0);
        an : out STD_LOGIC_VECTOR (7 downto 0)
    );
end Doorlock;

architecture Behavioral of Doorlock is

    -- main code
    signal pw_reg     : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal input_pw   : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal display_data : STD_LOGIC_VECTOR (31 downto 0);
    signal count      : INTEGER range 0 to 8 := 0;
    signal enable_reg : std_logic := '0';
    
    signal digit_0, digit_1, digit_2, digit_3, digit_4, digit_5, digit_6, digit_7 : STD_LOGIC_VECTOR(3 downto 0);
    
    signal refresh_count : unsigned(16 downto 0) := (others => '0');
    signal mux_count     : INTEGER range 0 to 7 := 0;
    
    signal current_digit : STD_LOGIC_VECTOR(3 downto 0);
    signal seg_temp      : STD_LOGIC_VECTOR(7 downto 0);

    -- 7 segment
    signal seg_mode   : std_logic := '0';
    signal correction : std_logic := '0';
    signal display_state : std_logic := '0'; --state lagi munculin angka atau benar/salah
    
    -- 5 second timer
    signal unlock_timer    : INTEGER range 0 to 500_000_000 := 0;
    signal timer_active    : std_logic := '0';

begin

    -- main code
    process(clk, reset)
    begin
        
        -- reset button pressed
        if reset = '1' then
            unlock_timer <= 0;
            pw_reg   <= (others => '0');
            input_pw <= (others => '0');
            timer_active <= '0';
            count    <= 0;
            led_ok   <= '0';
            enable_reg <= '0';
            seg_mode <= '0';
        
        elsif rising_edge(clk) then
            -- 5 second timer
            if timer_active = '1' then
                if unlock_timer = 500_000_000 - 1 then
                    led_ok  <= '0';
                    timer_active <= '0';
                    unlock_timer <= 0;
                    seg_mode <= '0';
                else
                    unlock_timer <= unlock_timer + 1;
                end if;
            end if;
            
            -- unlock from inside button
            if unlock_button = '1' then
                led_ok <= '1';
                seg_mode <= '1';
                correction <= '1';
                timer_active <= '1';
                unlock_timer <= 0;
            end if;
            
            -- password input
            if enable = '1' and enable_reg = '0' then
            
                -- set password 
                if mode = '1' then
                    if count < 8 then
                        seg_mode <= '0';
                        pw_reg((count*4+3) downto (count*4)) <= switches;
                        count <= count + 1;
                    else
                        count <= 0;
                    end if;
                
                -- check password
                else
                    if count < 8 then
                        seg_mode <= '0';
                        input_pw((count*4+3) downto (count*4)) <= switches;
                        count <= count + 1;
                    else
                        if input_pw = pw_reg then
                            led_ok <= '1';
                            seg_mode <= '1';
                            correction <= '1';
                            timer_active <= '1';
                            unlock_timer <= 0;
                        else
                            led_ok <= '0';
                            seg_mode <= '1';
                            correction <= '0';
                            timer_active <= '1';
                        end if;
                        count <= 0;
                    end if;
                end if;
            end if;
            enable_reg <= enable;
        end if;
    end process;

    -- 7 segment main code
    -- refresh count set to 1ms
    process(clk)
    begin
        if rising_edge(clk) then
            if refresh_count = 100_000 - 1 then  
                refresh_count <= (others => '0');
                
                if mux_count = 7 then
                    mux_count <= 0;
                else
                    mux_count <= mux_count + 1;
                end if;
                
            else
                refresh_count <= refresh_count + 1;
            end if;
        end if;
    end process;
    
    -- pick which digit selected
    process(mux_count, digit_0, digit_1, digit_2, digit_3, digit_4, digit_5, digit_6, digit_7)
    begin
        case mux_count is
            when 0 =>
                current_digit <= digit_0;
                an <= "01111111";            
            when 1 =>
                current_digit <= digit_1; 
                an <= "10111111";             
            when 2 =>
                current_digit <= digit_2; 
                an <= "11011111";             
            when 3 =>
                current_digit <= digit_3; 
                an <= "11101111";     
            when 4 =>
                current_digit <= digit_4; 
                an <= "11110111";       
            when 5 =>
                current_digit <= digit_5; 
                an <= "11111011";       
            when 6 =>
                current_digit <= digit_6; 
                an <= "11111101";       
            when 7 =>
                current_digit <= digit_7; 
                an <= "11111110";              
            when others =>
                current_digit <= "0000";
                an <= "11111111";             
        end case;
    end process;
    
    -- decoder 4-bit 0-F
    process (current_digit)
    begin
        case current_digit is
            -- number decode 0-9
            when "0000" => seg_temp <= "11000000"; 
            when "0001" => seg_temp <= "11111001"; 
            when "0010" => seg_temp <= "10100100"; 
            when "0011" => seg_temp <= "10110000";
            when "0100" => seg_temp <= "10011001";
            when "0101" => seg_temp <= "10010010"; 
            when "0110" => seg_temp <= "10000010"; 
            when "0111" => seg_temp <= "11111000"; 
            when "1000" => seg_temp <= "10000000"; 
            when "1001" => seg_temp <= "10010000";
            
            -- alphabet decode A-F (changed for benar salah)
            when "1010" => seg_temp <= "10000011"; -- b
            when "1011" => seg_temp <= "10000110"; -- E
            when "1100" => seg_temp <= "10101011"; -- n
            when "1101" => seg_temp <= "10001000"; -- A
            when "1110" => seg_temp <= "10101111"; -- r
            when "1111" => seg_temp <= "10001001"; -- H
            
            when others => seg_temp <= "11111111"; 
        end case;
    end process;
    
    -- 7 segment display mode
    process(seg_mode, correction, pw_reg, input_pw, mode)
    begin
        if seg_mode = '0' then
            -- display number
            if mode = '1' then
                display_data <= pw_reg;
            else
                display_data <= input_pw;
            end if;
        else
            -- display message
            if correction = '1' then
                -- b E n A r
                display_data <= x"000EDCBA";
            else
                -- S A L A H
                display_data <= x"000FD1D5";
            end if;
        end if;
    end process;

    led_set   <= mode;
    led_input <= not mode;

    pw1 <= '1' when count = 1 else '0';
    pw2 <= '1' when count = 2 else '0';
    pw3 <= '1' when count = 3 else '0';
    pw4 <= '1' when count = 4 else '0';
    pw5 <= '1' when count = 5 else '0';
    pw6 <= '1' when count = 6 else '0';
    pw7 <= '1' when count = 7 else '0';
    pw8 <= '1' when count = 8 else '0';

    digit_0 <= display_data(3 downto 0);     
    digit_1 <= display_data(7 downto 4);      
    digit_2 <= display_data(11 downto 8);    
    digit_3 <= display_data(15 downto 12);  
    digit_4 <= display_data(19 downto 16);     
    digit_5 <= display_data(23 downto 20);      
    digit_6 <= display_data(27 downto 24);    
    digit_7 <= display_data(31 downto 28);  
    
    seg <= seg_temp;

end Behavioral;

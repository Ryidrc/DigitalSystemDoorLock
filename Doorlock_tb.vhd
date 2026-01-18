-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : Sun, 18 Jan 2026 13:31:07 GMT
-- Request id : cfwk-fed377c2-696ce09bc1cf8

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_Doorlock is
end tb_Doorlock;

architecture tb of tb_Doorlock is

    component Doorlock
        port (clk           : in std_logic;
              reset         : in std_logic;
              enable        : in std_logic;
              mode          : in std_logic;
              unlock_button : in std_logic;
              switches      : in std_logic_vector (3 downto 0);
              led_set       : out std_logic;
              led_input     : out std_logic;
              led_ok        : out std_logic;
              pw1           : out std_logic;
              pw2           : out std_logic;
              pw3           : out std_logic;
              pw4           : out std_logic;
              pw5           : out std_logic;
              pw6           : out std_logic;
              pw7           : out std_logic;
              pw8           : out std_logic;
              seg           : out std_logic_vector (7 downto 0);
              an            : out std_logic_vector (7 downto 0));
    end component;

    signal clk           : std_logic;
    signal reset         : std_logic;
    signal enable        : std_logic;
    signal mode          : std_logic;
    signal unlock_button : std_logic;
    signal switches      : std_logic_vector (3 downto 0);
    signal led_set       : std_logic;
    signal led_input     : std_logic;
    signal led_ok        : std_logic;
    signal pw1           : std_logic;
    signal pw2           : std_logic;
    signal pw3           : std_logic;
    signal pw4           : std_logic;
    signal pw5           : std_logic;
    signal pw6           : std_logic;
    signal pw7           : std_logic;
    signal pw8           : std_logic;
    signal seg           : std_logic_vector (7 downto 0);
    signal an            : std_logic_vector (7 downto 0);

    constant TbPeriod : time := 10 ns;
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';
    
    -- Helper procedures
    procedure pulse_enable(signal enable_sig : out std_logic) is
    begin
        wait for TbPeriod * 2;
        enable_sig <= '1';
        wait for TbPeriod * 2;
        enable_sig <= '0';
        wait for TbPeriod * 2;
    end procedure;
    
    procedure input_digit(
        signal switches_sig : out std_logic_vector(3 downto 0);
        signal enable_sig : out std_logic;
        constant digit : in integer) is
    begin
        switches_sig <= std_logic_vector(to_unsigned(digit, 4));
        pulse_enable(enable_sig);
    end procedure;

begin

    dut : Doorlock
    port map (clk           => clk,
              reset         => reset,
              enable        => enable,
              mode          => mode,
              unlock_button => unlock_button,
              switches      => switches,
              led_set       => led_set,
              led_input     => led_input,
              led_ok        => led_ok,
              pw1           => pw1,
              pw2           => pw2,
              pw3           => pw3,
              pw4           => pw4,
              pw5           => pw5,
              pw6           => pw6,
              pw7           => pw7,
              pw8           => pw8,
              seg           => seg,
              an            => an);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    clk <= TbClock;

    stimuli : process
    begin
        -- ***EDIT*** Adapt initialization as needed
        enable <= '0';
        mode <= '0';
        unlock_button <= '0';
        switches <= (others => '0');

        -- Reset generation
        -- ***EDIT*** Check that reset is really your reset signal
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;

        -- ***EDIT*** Add stimuli here
        
        -- Test 1: Set password to 12345678
        report "=== Test 1: Setting password to 12345678 ===";
        mode <= '1'; -- Set password mode
        wait for TbPeriod * 5;
        
        input_digit(switches, enable, 1);
        input_digit(switches, enable, 2);
        input_digit(switches, enable, 3);
        input_digit(switches, enable, 4);
        input_digit(switches, enable, 5);
        input_digit(switches, enable, 6);
        input_digit(switches, enable, 7);
        input_digit(switches, enable, 8);
        
        wait for TbPeriod * 20;
        
        -- Test 2: Enter correct password
        report "=== Test 2: Entering correct password ===";
        mode <= '0'; -- Input password mode
        wait for TbPeriod * 5;
        
        input_digit(switches, enable, 1);
        input_digit(switches, enable, 2);
        input_digit(switches, enable, 3);
        input_digit(switches, enable, 4);
        input_digit(switches, enable, 5);
        input_digit(switches, enable, 6);
        input_digit(switches, enable, 7);
        input_digit(switches, enable, 8);
        
        wait for TbPeriod * 20;
        assert led_ok = '1' report "LED OK should be on for correct password" severity error;
        
        -- Wait for timer to expire (simulate part of 5 seconds)
        wait for TbPeriod * 100;
        
        -- Test 3: Enter incorrect password
        report "=== Test 3: Entering incorrect password ===";
        mode <= '0';
        wait for TbPeriod * 5;
        
        input_digit(switches, enable, 9);
        input_digit(switches, enable, 9);
        input_digit(switches, enable, 9);
        input_digit(switches, enable, 9);
        input_digit(switches, enable, 9);
        input_digit(switches, enable, 9);
        input_digit(switches, enable, 9);
        input_digit(switches, enable, 9);
        
        wait for TbPeriod * 20;
        assert led_ok = '0' report "LED OK should be off for incorrect password" severity error;
        
        wait for TbPeriod * 100;
        
        -- Test 4: Unlock from inside button
        report "=== Test 4: Testing unlock button ===";
        unlock_button <= '1';
        wait for TbPeriod * 10;
        unlock_button <= '0';
        wait for TbPeriod * 10;
        assert led_ok = '1' report "LED OK should be on after unlock button" severity error;
        
        wait for TbPeriod * 100;
        
        -- Test 5: Reset test
        report "=== Test 5: Testing reset functionality ===";
        reset <= '1';
        wait for TbPeriod * 10;
        reset <= '0';
        assert led_ok = '0' report "LED OK should be off after reset" severity error;
        
        wait for TbPeriod * 50;
        
        -- Test 6: Set new password and verify
        report "=== Test 6: Setting new password 00001111 ===";
        mode <= '1';
        wait for TbPeriod * 5;
        
        input_digit(switches, enable, 0);
        input_digit(switches, enable, 0);
        input_digit(switches, enable, 0);
        input_digit(switches, enable, 0);
        input_digit(switches, enable, 1);
        input_digit(switches, enable, 1);
        input_digit(switches, enable, 1);
        input_digit(switches, enable, 1);
        
        wait for TbPeriod * 20;
        
        -- Verify new password
        mode <= '0';
        wait for TbPeriod * 5;
        
        input_digit(switches, enable, 0);
        input_digit(switches, enable, 0);
        input_digit(switches, enable, 0);
        input_digit(switches, enable, 0);
        input_digit(switches, enable, 1);
        input_digit(switches, enable, 1);
        input_digit(switches, enable, 1);
        input_digit(switches, enable, 1);
        
        wait for TbPeriod * 20;
        assert led_ok = '1' report "LED OK should be on for new correct password" severity error;
        
        wait for TbPeriod * 100;
        
        report "=== Testbench Complete ===";
        
        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_Doorlock of tb_Doorlock is
    for tb
    end for;
end cfg_tb_Doorlock;

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

    signal clk           : std_logic := '0';
    signal reset         : std_logic := '0';
    signal enable        : std_logic := '0';
    signal mode          : std_logic := '0';
    signal unlock_button : std_logic := '0';
    signal switches      : std_logic_vector (3 downto 0) := (others => '0');
    signal led_set       : std_logic;
    signal led_input     : std_logic;
    signal led_ok        : std_logic;
    signal pw1, pw2, pw3, pw4, pw5, pw6, pw7, pw8 : std_logic;
    signal seg           : std_logic_vector (7 downto 0);
    signal an            : std_logic_vector (7 downto 0);

    constant CLK_PERIOD : time := 10 ns;

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

    -- Clock Generation
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimuli Process
    stimuli : process
    begin
        -- Initialize
        enable <= '0';
        mode <= '0';
        unlock_button <= '0';
        switches <= (others => '0');

        -- Initial Reset
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;

        -- -----------------------------------------------------
        -- PRE-STEP: SET CORRECT PASSWORD (To 12345678)
        -- -----------------------------------------------------
        mode <= '1';
        wait for CLK_PERIOD;
        for i in 1 to 8 loop
            switches <= std_logic_vector(to_unsigned(i, 4));
            wait for CLK_PERIOD;
            enable <= '1'; 
            wait for CLK_PERIOD;
            enable <= '0'; 
            wait for CLK_PERIOD;
        end loop;
        -- 9th click to save
        enable <= '1'; wait for CLK_PERIOD; enable <= '0';
        wait for 100 ns;

        -- -----------------------------------------------------
        -- 1. WRONG PASSWORD TEST
        -- -----------------------------------------------------
        mode <= '0'; -- Input mode
        switches <= "1111"; -- Input F (Wrong digit)
        
        -- Input 8 wrong digits
        for i in 1 to 8 loop
            wait for CLK_PERIOD;
            enable <= '1'; 
            wait for CLK_PERIOD;
            enable <= '0'; 
            wait for CLK_PERIOD;
        end loop;

        -- 9th click to Check
        enable <= '1'; wait for CLK_PERIOD; enable <= '0';
        
        -- Verification: led_ok should be '0'
        wait for 100 ns; 

        -- -----------------------------------------------------
        -- 2. RESET BUTTON TEST
        -- (Interrupting input halfway)
        -- -----------------------------------------------------
        -- Enter 4 digits (PW1-PW4 should light up)
        for i in 1 to 4 loop
            switches <= std_logic_vector(to_unsigned(i, 4));
            wait for CLK_PERIOD;
            enable <= '1'; 
            wait for CLK_PERIOD;
            enable <= '0'; 
            wait for CLK_PERIOD;
        end loop;
        
        wait for 100 ns; -- Observe lights are ON
        
        -- PRESS RESET
        reset <= '1';
        wait for 50 ns;
        reset <= '0';
        wait for 50 ns;
        
        -- Verification: PW1-PW4 should now be OFF.
        -- Try entering 1 digit again to prove we are back at digit 1
        switches <= x"1";
        enable <= '1'; wait for CLK_PERIOD; enable <= '0';
        wait for 100 ns;
        
        -- Clear remaining inputs to clean up for next test
        reset <= '1'; wait for 20 ns; reset <= '0';

        -- -----------------------------------------------------
        -- 3. WAIT FOR 5 SECONDS (AUTO-LOCK TEST)
        -- -----------------------------------------------------
        -- First, Unlock successfully
        unlock_button <= '1';
        wait for 50 ns;
        unlock_button <= '0';
        
        -- Check that LED is ON
        wait for 100 ns; 
        
        -- NOW WAIT FOR TIMEOUT
        -- Note: If you did not change the constant in Doorlock.vhd,
        -- this line simulates 5 seconds of real time.
        -- Use a smaller constant in design for faster sim.
        
        wait for 5 sec; -- <--- This is the 5 second wait
        
        -- Verification: led_ok should turn OFF after this wait
        wait for 100 ns;

        -- End Simulation
        wait;
    end process;

end tb;

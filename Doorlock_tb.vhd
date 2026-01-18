-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : Sun, 18 Jan 2026 13:31:07 GMT
-- Request id : cfwk-fed377c2-696ce09bc1cf8

library ieee;
use ieee.std_logic_1164.all;

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
    signal TbSimEnded : std_logic := '0';

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
    clk <= not clk after TbPeriod/2 when TbSimEnded /= '1' else '0';

    stimuli : process
    begin
        -- ***EDIT*** Adapt initialization as needed
        clk <= '0';
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
        
        -- Set password: 1234 5678
        mode <= '1';
        for i in 1 to 8 loop
            switches <= std_logic_vector(to_unsigned(i, 4));
            wait for 50 ns;
            enable <= '1';
            wait for 50 ns;
            enable <= '0';
            wait for 50 ns;
        end loop;
        wait for 200 ns;
        
        -- Enter correct password
        mode <= '0';
        for i in 1 to 8 loop
            switches <= std_logic_vector(to_unsigned(i, 4));
            wait for 50 ns;
            enable <= '1';
            wait for 50 ns;
            enable <= '0';
            wait for 50 ns;
        end loop;
        wait for 500 ns;
        
        -- Enter wrong password
        for i in 0 to 7 loop
            switches <= "1111";
            wait for 50 ns;
            enable <= '1';
            wait for 50 ns;
            enable <= '0';
            wait for 50 ns;
        end loop;
        wait for 500 ns;
        
        -- Test unlock button
        unlock_button <= '1';
        wait for 100 ns;
        unlock_button <= '0';
        wait for 500 ns;

        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_Doorlock of tb_Doorlock is
    for tb
    end for;
end cfg_tb_Doorlock;

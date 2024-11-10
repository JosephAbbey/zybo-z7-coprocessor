library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_gpio_output_slave_lite_v1_0_S_AXI is
  generic (
    -- Users to add parameters here

    C_GPIO_WIDTH       : INTEGER := 4;

    -- User parameters ends
    -- Do not modify the parameters beyond this line

    -- Width of S_AXI data bus
    C_S_AXI_DATA_WIDTH : INTEGER := 32;
    -- Width of S_AXI address bus
    C_S_AXI_ADDR_WIDTH : INTEGER := 4
  );
  port (
    -- Users to add ports here

    GPIO          : out STD_LOGIC_VECTOR(C_GPIO_WIDTH - 1 downto 0);

    -- User ports ends
    -- Do not modify the ports beyond this line

    -- Global Clock Signal
    S_AXI_ACLK    : in  STD_LOGIC;
    -- Global Reset Signal. This Signal is Active LOW
    S_AXI_ARESETN : in  STD_LOGIC;
    -- Write address (issued by master, acceped by Slave)
    S_AXI_AWADDR  : in  STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH - 1 downto 0);
    -- Write channel Protection type. This signal indicates the
    -- privilege and security level of the transaction, and whether
    -- the transaction is a data access or an instruction access.
    S_AXI_AWPROT  : in  STD_LOGIC_VECTOR(2 downto 0);
    -- Write address valid. This signal indicates that the master signaling
    -- valid write address and control information.
    S_AXI_AWVALID : in  STD_LOGIC;
    -- Write address ready. This signal indicates that the slave is ready
    -- to accept an address and associated control signals.
    S_AXI_AWREADY : out STD_LOGIC;
    -- Write data (issued by master, acceped by Slave) 
    S_AXI_WDATA   : in  STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH - 1 downto 0);
    -- Write strobes. This signal indicates which byte lanes hold
    -- valid data. There is one write strobe bit for each eight
    -- bits of the write data bus.    
    S_AXI_WSTRB   : in  STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH/8) - 1 downto 0);
    -- Write valid. This signal indicates that valid write
    -- data and strobes are available.
    S_AXI_WVALID  : in  STD_LOGIC;
    -- Write ready. This signal indicates that the slave
    -- can accept the write data.
    S_AXI_WREADY  : out STD_LOGIC;
    -- Write response. This signal indicates the status
    -- of the write transaction.
    S_AXI_BRESP   : out STD_LOGIC_VECTOR(1 downto 0);
    -- Write response valid. This signal indicates that the channel
    -- is signaling a valid write response.
    S_AXI_BVALID  : out STD_LOGIC;
    -- Response ready. This signal indicates that the master
    -- can accept a write response.
    S_AXI_BREADY  : in  STD_LOGIC;
    -- Read address (issued by master, acceped by Slave)
    S_AXI_ARADDR  : in  STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH - 1 downto 0);
    -- Protection type. This signal indicates the privilege
    -- and security level of the transaction, and whether the
    -- transaction is a data access or an instruction access.
    S_AXI_ARPROT  : in  STD_LOGIC_VECTOR(2 downto 0);
    -- Read address valid. This signal indicates that the channel
    -- is signaling valid read address and control information.
    S_AXI_ARVALID : in  STD_LOGIC;
    -- Read address ready. This signal indicates that the slave is
    -- ready to accept an address and associated control signals.
    S_AXI_ARREADY : out STD_LOGIC;
    -- Read data (issued by slave)
    S_AXI_RDATA   : out STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH - 1 downto 0);
    -- Read response. This signal indicates the status of the
    -- read transfer.
    S_AXI_RRESP   : out STD_LOGIC_VECTOR(1 downto 0);
    -- Read valid. This signal indicates that the channel is
    -- signaling the required read data.
    S_AXI_RVALID  : out STD_LOGIC;
    -- Read ready. This signal indicates that the master can
    -- accept the read data and response information.
    S_AXI_RREADY  : in  STD_LOGIC
  );
end axi_gpio_output_slave_lite_v1_0_S_AXI;

architecture arch_imp of axi_gpio_output_slave_lite_v1_0_S_AXI is

  -- AXI4LITE signals
  signal axi_awaddr          : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH - 1 downto 0);
  signal axi_awready         : STD_LOGIC;
  signal axi_wready          : STD_LOGIC;
  signal axi_bresp           : STD_LOGIC_VECTOR(1 downto 0);
  signal axi_bvalid          : STD_LOGIC;
  signal axi_araddr          : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH - 1 downto 0);
  signal axi_arready         : STD_LOGIC;
  signal axi_rresp           : STD_LOGIC_VECTOR(1 downto 0);
  signal axi_rvalid          : STD_LOGIC;

  -- Example-specific design signals
  -- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
  -- ADDR_LSB is used for addressing 32/64 bit registers/memories
  -- ADDR_LSB = 2 for 32 bits (n downto 2)
  -- ADDR_LSB = 3 for 64 bits (n downto 3)
  constant ADDR_LSB          : INTEGER := (C_S_AXI_DATA_WIDTH/32) + 1;
  constant OPT_MEM_ADDR_BITS : INTEGER := 1;
  ------------------------------------------------
  ---- Signals for user logic register space example
  --------------------------------------------------
  ---- Number of Slave Registers 4
  signal slv_reg0            : STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH - 1 downto 0);
  signal slv_reg1            : STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH - 1 downto 0);
  signal slv_reg2            : STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH - 1 downto 0);
  signal slv_reg3            : STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH - 1 downto 0);
  signal byte_index          : INTEGER;

  signal mem_logic           : STD_LOGIC_VECTOR(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);

  --State machine local parameters
  constant Idle              : STD_LOGIC_VECTOR(1 downto 0) := "00";
  constant Raddr             : STD_LOGIC_VECTOR(1 downto 0) := "10";
  constant Rdata             : STD_LOGIC_VECTOR(1 downto 0) := "11";
  constant Waddr             : STD_LOGIC_VECTOR(1 downto 0) := "10";
  constant Wdata             : STD_LOGIC_VECTOR(1 downto 0) := "11";
  --State machine variables
  signal state_read          : STD_LOGIC_VECTOR(1 downto 0);
  signal state_write         : STD_LOGIC_VECTOR(1 downto 0);
begin
  -- I/O Connections assignments

  S_AXI_AWREADY <= axi_awready;
  S_AXI_WREADY  <= axi_wready;
  S_AXI_BRESP   <= axi_bresp;
  S_AXI_BVALID  <= axi_bvalid;
  S_AXI_ARREADY <= axi_arready;
  S_AXI_RRESP   <= axi_rresp;
  S_AXI_RVALID  <= axi_rvalid;
  mem_logic     <= S_AXI_AWADDR(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB) when (S_AXI_AWVALID = '1') else
               axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);

  -- Implement Write state machine
  -- Outstanding write transactions are not supported by the slave i.e., master should assert bready to receive response on or before it starts sending the new transaction
  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        --asserting initial values to all 0's during reset                                       
        axi_awready <= '0';
        axi_wready  <= '0';
        axi_bvalid  <= '0';
        axi_bresp   <= (others => '0');
        state_write <= Idle;
      else
        case (state_write) is
          when Idle => --Initial state inidicating reset is done and ready to receive read/write transactions                                       
            if (S_AXI_ARESETN = '1') then
              axi_awready <= '1';
              axi_wready  <= '1';
              state_write <= Waddr;
            else
              state_write <= state_write;
            end if;
          when Waddr => --At this state, slave is ready to receive address along with corresponding control signals and first data packet. Response valid is also handled at this state                                       
            if (S_AXI_AWVALID = '1' and axi_awready = '1') then
              axi_awaddr <= S_AXI_AWADDR;
              if (S_AXI_WVALID = '1') then
                axi_awready <= '1';
                state_write <= Waddr;
                axi_bvalid  <= '1';
              else
                axi_awready <= '0';
                state_write <= Wdata;
                if (S_AXI_BREADY = '1' and axi_bvalid = '1') then
                  axi_bvalid <= '0';
                end if;
              end if;
            else
              state_write <= state_write;
              if (S_AXI_BREADY = '1' and axi_bvalid = '1') then
                axi_bvalid <= '0';
              end if;
            end if;
          when Wdata => --At this state, slave is ready to receive the data packets until the number of transfers is equal to burst length                                       
            if (S_AXI_WVALID = '1') then
              state_write <= Waddr;
              axi_bvalid  <= '1';
              axi_awready <= '1';
            else
              state_write <= state_write;
              if (S_AXI_BREADY = '1' and axi_bvalid = '1') then
                axi_bvalid <= '0';
              end if;
            end if;
          when others => --reserved                                       
            axi_awready <= '0';
            axi_wready  <= '0';
            axi_bvalid  <= '0';
        end case;
      end if;
    end if;
  end process;
  -- Implement memory mapped register select and write logic generation
  -- The write data is accepted and written to memory mapped registers when
  -- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
  -- select byte enables of slave registers while writing.
  -- These registers are cleared when reset (active low) is applied.
  -- Slave register write enable is asserted when valid address and data are available
  -- and the slave is ready to accept the write address and write data.

  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        slv_reg0 <= (others => '0');
        slv_reg1 <= (others => '0');
        slv_reg2 <= (others => '0');
        slv_reg3 <= (others => '0');
      else
        if (S_AXI_WVALID = '1') then
          case (mem_logic) is
            when b"00" =>
              for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes                   
                  -- slave registor 0
                  slv_reg0(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
            when b"01" =>
              for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes                   
                  -- slave registor 1
                  slv_reg1(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
            when b"10" =>
              for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes                   
                  -- slave registor 2
                  slv_reg2(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
            when b"11" =>
              for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  -- Respective byte enables are asserted as per write strobes                   
                  -- slave registor 3
                  slv_reg3(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
            when others =>
              slv_reg0 <= slv_reg0;
              slv_reg1 <= slv_reg1;
              slv_reg2 <= slv_reg2;
              slv_reg3 <= slv_reg3;
          end case;
        end if;
      end if;
    end if;
  end process;

  -- Implement read state machine
  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        --asserting initial values to all 0's during reset                                          
        axi_arready <= '0';
        axi_rvalid  <= '0';
        axi_rresp   <= (others => '0');
        state_read  <= Idle;
      else
        case (state_read) is
          when Idle => --Initial state inidicating reset is done and ready to receive read/write transactions                                          
            if (S_AXI_ARESETN = '1') then
              axi_arready <= '1';
              state_read  <= Raddr;
            else
              state_read <= state_read;
            end if;
          when Raddr => --At this state, slave is ready to receive address along with corresponding control signals                                          
            if (S_AXI_ARVALID = '1' and axi_arready = '1') then
              state_read  <= Rdata;
              axi_rvalid  <= '1';
              axi_arready <= '0';
              axi_araddr  <= S_AXI_ARADDR;
            else
              state_read <= state_read;
            end if;
          when Rdata => --At this state, slave is ready to send the data packets until the number of transfers is equal to burst length                                          
            if (axi_rvalid = '1' and S_AXI_RREADY = '1') then
              axi_rvalid  <= '0';
              axi_arready <= '1';
              state_read  <= Raddr;
            else
              state_read <= state_read;
            end if;
          when others => --reserved                                          
            axi_arready <= '0';
            axi_rvalid  <= '0';
        end case;
      end if;
    end if;
  end process;
  -- Implement memory mapped register select and read logic generation
  S_AXI_RDATA <= slv_reg0 when (axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB) = "00") else
                 slv_reg1 when (axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB) = "01") else
                 slv_reg2 when (axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB) = "10") else
                 slv_reg3 when (axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB) = "11") else
                 (others => '0');

  -- Add user logic here

  GPIO <= slv_reg0(C_GPIO_WIDTH - 1 downto 0);

  -- User logic ends

end arch_imp;

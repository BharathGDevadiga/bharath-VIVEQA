# Sentinel-RV Combined Team 1 + Team 2 Code

Team 1 security/core RTL is followed by Team 2 peripheral RTL. Each testbench is placed immediately after its related source group. The final sections contain the combined top, constraints, and test runner.

## Source - aes128_encrypt.v

**Path:** `aes\aes128_encrypt.v`

```verilog
`timescale 1ns/1ps

// Iterative AES-128 encryption engine. Bytes use the FIPS-197 order
// (byte 0 is data[127:120]); the state is therefore column-major.
module aes128_encrypt (
    input  wire         clk,
    input  wire         reset,
    input  wire         start,
    input  wire [127:0] plaintext,
    input  wire [127:0] key,
    output reg  [127:0] ciphertext,
    output reg          busy,
    output reg          done
);
    reg [127:0] state_reg;
    reg [127:0] round_key;
    reg [3:0] round;
    reg [127:0] next_key;

    function automatic [7:0] gf_multiply;
        input [7:0] left;
        input [7:0] right;
        reg [7:0] multiplicand;
        reg [7:0] multiplier;
        reg [7:0] product;
        integer index;
        begin
            multiplicand = left;
            multiplier = right;
            product = 8'h00;
            for (index = 0; index < 8; index = index + 1) begin
                if (multiplier[0]) product = product ^ multiplicand;
                multiplicand = multiplicand[7] ? ((multiplicand << 1) ^ 8'h1B) : (multiplicand << 1);
                multiplier = multiplier >> 1;
            end
            gf_multiply = product;
        end
    endfunction

    function automatic [7:0] gf_inverse;
        input [7:0] value;
        reg [7:0] result;
        reg [7:0] base;
        integer index;
        begin
            if (value == 8'h00) begin
                gf_inverse = 8'h00;
            end else begin
                result = 8'h01;
                base = value;
                // value^254, calculated with fixed square-and-multiply steps.
                for (index = 0; index < 8; index = index + 1) begin
                    if (index != 0) result = gf_multiply(result, base);
                    base = gf_multiply(base, base);
                end
                gf_inverse = result;
            end
        end
    endfunction

    function automatic [7:0] aes_sbox;
        input [7:0] value;
        reg [7:0] inverse;
        begin
            inverse = gf_inverse(value);
            aes_sbox = inverse ^ {inverse[6:0], inverse[7]} ^
                       {inverse[5:0], inverse[7:6]} ^
                       {inverse[4:0], inverse[7:5]} ^
                       {inverse[3:0], inverse[7:4]} ^ 8'h63;
        end
    endfunction

    function automatic [7:0] state_byte;
        input [127:0] value;
        input integer index;
        begin
            state_byte = value[127 - (index * 8) -: 8];
        end
    endfunction

    function automatic [127:0] sub_bytes;
        input [127:0] value;
        reg [127:0] result;
        integer index;
        begin
            result = 128'd0;
            for (index = 0; index < 16; index = index + 1)
                result[127 - (index * 8) -: 8] = aes_sbox(state_byte(value, index));
            sub_bytes = result;
        end
    endfunction

    function automatic [127:0] shift_rows;
        input [127:0] value;
        reg [127:0] result;
        integer column;
        integer row;
        integer destination_index;
        integer source_index;
        begin
            result = 128'd0;
            for (column = 0; column < 4; column = column + 1)
                for (row = 0; row < 4; row = row + 1) begin
                    destination_index = (4 * column) + row;
                    source_index = (4 * ((column + row) % 4)) + row;
                    result[127 - (destination_index * 8) -: 8] = state_byte(value, source_index);
                end
            shift_rows = result;
        end
    endfunction

    function automatic [7:0] xtime;
        input [7:0] value;
        begin
            xtime = value[7] ? ((value << 1) ^ 8'h1B) : (value << 1);
        end
    endfunction

    function automatic [127:0] mix_columns;
        input [127:0] value;
        reg [127:0] result;
        reg [7:0] byte0;
        reg [7:0] byte1;
        reg [7:0] byte2;
        reg [7:0] byte3;
        integer column;
        begin
            result = 128'd0;
            for (column = 0; column < 4; column = column + 1) begin
                byte0 = state_byte(value, (4 * column));
                byte1 = state_byte(value, (4 * column) + 1);
                byte2 = state_byte(value, (4 * column) + 2);
                byte3 = state_byte(value, (4 * column) + 3);
                result[127 - ((4 * column) * 8) -: 8] = xtime(byte0) ^ (xtime(byte1) ^ byte1) ^ byte2 ^ byte3;
                result[127 - (((4 * column) + 1) * 8) -: 8] = byte0 ^ xtime(byte1) ^ (xtime(byte2) ^ byte2) ^ byte3;
                result[127 - (((4 * column) + 2) * 8) -: 8] = byte0 ^ byte1 ^ xtime(byte2) ^ (xtime(byte3) ^ byte3);
                result[127 - (((4 * column) + 3) * 8) -: 8] = (xtime(byte0) ^ byte0) ^ byte1 ^ byte2 ^ xtime(byte3);
            end
            mix_columns = result;
        end
    endfunction

    function automatic [7:0] rcon;
        input [3:0] round_number;
        begin
            case (round_number)
                4'd1: rcon = 8'h01; 4'd2: rcon = 8'h02; 4'd3: rcon = 8'h04;
                4'd4: rcon = 8'h08; 4'd5: rcon = 8'h10; 4'd6: rcon = 8'h20;
                4'd7: rcon = 8'h40; 4'd8: rcon = 8'h80; 4'd9: rcon = 8'h1B;
                default: rcon = 8'h36;
            endcase
        end
    endfunction

    function automatic [127:0] next_round_key;
        input [127:0] current_key;
        input [7:0] current_rcon;
        reg [31:0] word0;
        reg [31:0] word1;
        reg [31:0] word2;
        reg [31:0] word3;
        reg [31:0] transformed_word;
        reg [31:0] next_word0;
        reg [31:0] next_word1;
        reg [31:0] next_word2;
        reg [31:0] next_word3;
        begin
            word0 = current_key[127:96];
            word1 = current_key[95:64];
            word2 = current_key[63:32];
            word3 = current_key[31:0];
            transformed_word = {aes_sbox(word3[23:16]), aes_sbox(word3[15:8]),
                                aes_sbox(word3[7:0]), aes_sbox(word3[31:24])} ^ {current_rcon, 24'h000000};
            next_word0 = word0 ^ transformed_word;
            next_word1 = word1 ^ next_word0;
            next_word2 = word2 ^ next_word1;
            next_word3 = word3 ^ next_word2;
            next_round_key = {next_word0, next_word1, next_word2, next_word3};
        end
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            ciphertext <= 128'd0;
            state_reg <= 128'd0;
            round_key <= 128'd0;
            round <= 4'd0;
            busy <= 1'b0;
            done <= 1'b0;
        end else begin
            done <= 1'b0;
            if (!busy) begin
                if (start) begin
                    state_reg <= plaintext ^ key;
                    round_key <= key;
                    round <= 4'd1;
                    busy <= 1'b1;
                end
            end else begin
                next_key = next_round_key(round_key, rcon(round));
                round_key <= next_key;
                if (round < 4'd10) begin
                    state_reg <= mix_columns(shift_rows(sub_bytes(state_reg))) ^ next_key;
                    round <= round + 1'b1;
                end else begin
                    ciphertext <= shift_rows(sub_bytes(state_reg)) ^ next_key;
                    busy <= 1'b0;
                    done <= 1'b1;
                end
            end
        end
    end
endmodule
```

## Testbench - tb_aes128_encrypt.v

**Path:** `tb\tb_aes128_encrypt.v`

```verilog
`timescale 1ns/1ps
module tb_aes128_encrypt;
    reg clk=0, reset=1, start=0;
    reg [127:0] plaintext=128'h00112233445566778899AABBCCDDEEFF;
    reg [127:0] key=128'h000102030405060708090A0B0C0D0E0F;
    wire [127:0] ciphertext; wire busy, done;
    aes128_encrypt dut (.clk(clk),.reset(reset),.start(start),.plaintext(plaintext),.key(key),.ciphertext(ciphertext),.busy(busy),.done(done));
    always #5 clk=~clk;
    initial begin
        repeat(3) @(posedge clk); reset=0;
        @(negedge clk); start=1; @(negedge clk); start=0;
        wait(done); #1;
        if (ciphertext !== 128'h69C4E0D86A7B0430D8CDB78070B4C55A) $display("FAIL: AES ciphertext=%h",ciphertext);
        else $display("PASS: aes128_encrypt FIPS-197 vector");
        $finish;
    end
endmodule
```

## Source - crc_stream.v

**Path:** `crc\crc_stream.v`

```verilog
`timescale 1ns/1ps

module crc_stream #(
    parameter integer WIDTH = 32,
    parameter [WIDTH-1:0] POLY = 32'h04C11DB7,
    parameter [WIDTH-1:0] INIT = {WIDTH{1'b1}}
) (
    input  wire             clk,
    input  wire             reset,
    input  wire             start,
    input  wire             data_valid,
    input  wire [7:0]       data_byte,
    input  wire             data_last,
    output reg  [WIDTH-1:0] crc,
    output reg              busy,
    output reg              crc_valid
);
    reg [WIDTH-1:0] current_crc;
    reg [WIDTH-1:0] updated_crc;

    function automatic [WIDTH-1:0] update_crc;
        input [WIDTH-1:0] initial_crc;
        input [7:0] byte_value;
        reg [WIDTH-1:0] temporary_crc;
        integer bit_index;
        begin
            temporary_crc = initial_crc;
            for (bit_index = 0; bit_index < 8; bit_index = bit_index + 1) begin
                if (temporary_crc[WIDTH-1] ^ byte_value[7-bit_index])
                    temporary_crc = {temporary_crc[WIDTH-2:0], 1'b0} ^ POLY;
                else
                    temporary_crc = {temporary_crc[WIDTH-2:0], 1'b0};
            end
            update_crc = temporary_crc;
        end
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            crc <= INIT;
            current_crc <= INIT;
            busy <= 1'b0;
            crc_valid <= 1'b0;
        end else begin
            crc_valid <= 1'b0;
            if (!busy && start) begin
                current_crc <= INIT;
                busy <= 1'b1;
            end else if (busy && data_valid) begin
                updated_crc = update_crc(current_crc, data_byte);
                current_crc <= updated_crc;
                if (data_last) begin
                    crc <= updated_crc;
                    busy <= 1'b0;
                    crc_valid <= 1'b1;
                end
            end
        end
    end
endmodule
```

## Source - crc16_ccitt.v

**Path:** `crc\crc16_ccitt.v`

```verilog
`timescale 1ns/1ps

module crc16_ccitt (
    input wire clk, input wire reset, input wire start,
    input wire data_valid, input wire [7:0] data_byte, input wire data_last,
    output wire [15:0] crc, output wire busy, output wire crc_valid
);
    crc_stream #(.WIDTH(16), .POLY(16'h1021), .INIT(16'hFFFF)) engine (
        .clk(clk), .reset(reset), .start(start), .data_valid(data_valid), .data_byte(data_byte),
        .data_last(data_last), .crc(crc), .busy(busy), .crc_valid(crc_valid)
    );
endmodule
```

## Source - crc32_mpeg2.v

**Path:** `crc\crc32_mpeg2.v`

```verilog
`timescale 1ns/1ps

module crc32_mpeg2 (
    input wire clk, input wire reset, input wire start,
    input wire data_valid, input wire [7:0] data_byte, input wire data_last,
    output wire [31:0] crc, output wire busy, output wire crc_valid
);
    crc_stream #(.WIDTH(32), .POLY(32'h04C11DB7), .INIT(32'hFFFFFFFF)) engine (
        .clk(clk), .reset(reset), .start(start), .data_valid(data_valid), .data_byte(data_byte),
        .data_last(data_last), .crc(crc), .busy(busy), .crc_valid(crc_valid)
    );
endmodule
```

## Testbench - tb_crc_engines.v

**Path:** `tb\tb_crc_engines.v`

```verilog
`timescale 1ns/1ps
module tb_crc_engines;
    reg clk=0, reset=1, start=0, data_valid=0, data_last=0;
    reg [7:0] data_byte=0;
    wire [15:0] crc16; wire crc16_busy, crc16_valid;
    wire [31:0] crc32; wire crc32_busy, crc32_valid;
    integer index;
    reg [8*9-1:0] message="123456789";
    crc16_ccitt crc16_dut (.clk(clk),.reset(reset),.start(start),.data_valid(data_valid),.data_byte(data_byte),.data_last(data_last),.crc(crc16),.busy(crc16_busy),.crc_valid(crc16_valid));
    crc32_mpeg2 crc32_dut (.clk(clk),.reset(reset),.start(start),.data_valid(data_valid),.data_byte(data_byte),.data_last(data_last),.crc(crc32),.busy(crc32_busy),.crc_valid(crc32_valid));
    always #5 clk=~clk;
    task send_byte; input [7:0] value; input last; begin
        @(negedge clk); data_byte=value; data_last=last; data_valid=1;
        @(negedge clk); data_valid=0; data_last=0;
    end endtask
    initial begin
        repeat(3) @(posedge clk); reset=0;
        @(negedge clk); start=1; @(negedge clk); start=0;
        for(index=0;index<9;index=index+1) send_byte(message[8*(8-index) +: 8], index==8);
        wait(crc16_valid && crc32_valid); #1;
        if (crc16!==16'h29B1 || crc32!==32'h0376E6E7) $display("FAIL: CRC16=%h CRC32=%h",crc16,crc32);
        else $display("PASS: CRC known-answer vectors");
        $finish;
    end
endmodule
```

## Source - nonce_generator.v

**Path:** `security\nonce_generator.v`

```verilog
`timescale 1ns/1ps

module nonce_generator #(
    parameter [63:0] SEED = 64'h1D872B41C5E93A7F
) (
    input  wire        clk,
    input  wire        reset,
    input  wire        request,
    output reg [63:0] nonce,
    output reg        nonce_valid
);
    reg [63:0] lfsr;
    wire feedback = lfsr[63] ^ lfsr[62] ^ lfsr[60] ^ lfsr[59];

    always @(posedge clk) begin
        if (reset) begin
            lfsr <= SEED;
            nonce <= 64'd0;
            nonce_valid <= 1'b0;
        end else begin
            nonce_valid <= 1'b0;
            if (request) begin
                nonce <= lfsr;
                nonce_valid <= 1'b1;
                lfsr <= {lfsr[62:0], feedback};
            end
        end
    end
endmodule
```

## Source - replay_protection.v

**Path:** `security\replay_protection.v`

```verilog
`timescale 1ns/1ps

// A one-entry-per-cycle scan maps cleanly to a small BRAM-backed nonce window.
// DEPTH should be a power of two for a natural circular replacement policy.
module replay_protection #(
    parameter integer NONCE_WIDTH = 64,
    parameter integer DEPTH = 64
) (
    input  wire                   clk,
    input  wire                   reset,
    input  wire                   check_start,
    input  wire [NONCE_WIDTH-1:0] nonce_in,
    output reg                    busy,
    output reg                    check_done,
    output reg                    replay_detected,
    output reg                    nonce_accepted
);
    localparam integer INDEX_W = (DEPTH <= 1) ? 1 : $clog2(DEPTH);
    reg [NONCE_WIDTH-1:0] nonce_table [0:DEPTH-1];
    reg [DEPTH-1:0] valid_table;
    reg [NONCE_WIDTH-1:0] nonce_reg;
    reg [INDEX_W-1:0] scan_index;
    reg [INDEX_W-1:0] write_index;

    always @(posedge clk) begin
        if (reset) begin
            valid_table <= {DEPTH{1'b0}};
            nonce_reg <= {NONCE_WIDTH{1'b0}};
            scan_index <= {INDEX_W{1'b0}};
            write_index <= {INDEX_W{1'b0}};
            busy <= 1'b0;
            check_done <= 1'b0;
            replay_detected <= 1'b0;
            nonce_accepted <= 1'b0;
        end else begin
            check_done <= 1'b0;
            replay_detected <= 1'b0;
            nonce_accepted <= 1'b0;
            if (!busy) begin
                if (check_start) begin
                    nonce_reg <= nonce_in;
                    scan_index <= {INDEX_W{1'b0}};
                    busy <= 1'b1;
                end
            end else if (valid_table[scan_index] && nonce_table[scan_index] == nonce_reg) begin
                busy <= 1'b0;
                check_done <= 1'b1;
                replay_detected <= 1'b1;
            end else if (scan_index == DEPTH - 1) begin
                nonce_table[write_index] <= nonce_reg;
                valid_table[write_index] <= 1'b1;
                write_index <= write_index + 1'b1;
                busy <= 1'b0;
                check_done <= 1'b1;
                nonce_accepted <= 1'b1;
            end else begin
                scan_index <= scan_index + 1'b1;
            end
        end
    end
endmodule
```

## Testbench - tb_replay_protection.v

**Path:** `tb\tb_replay_protection.v`

```verilog
`timescale 1ns/1ps
module tb_replay_protection;
    reg clk=0, reset=1, check_start=0; reg [63:0] nonce_in=0;
    wire busy, check_done, replay_detected, nonce_accepted;
    replay_protection #(.DEPTH(4)) dut (.clk(clk),.reset(reset),.check_start(check_start),.nonce_in(nonce_in),.busy(busy),.check_done(check_done),.replay_detected(replay_detected),.nonce_accepted(nonce_accepted));
    always #5 clk=~clk;
    task check_nonce; input [63:0] value; begin
        @(negedge clk); nonce_in=value; check_start=1; @(negedge clk); check_start=0;
        wait(check_done); #1;
    end endtask
    initial begin
        repeat(3) @(posedge clk); reset=0;
        check_nonce(64'h0123456789ABCDEF);
        if (!nonce_accepted || replay_detected) $display("FAIL: first nonce rejected");
        check_nonce(64'h0123456789ABCDEF);
        if (!replay_detected || nonce_accepted) $display("FAIL: replay not detected");
        else $display("PASS: replay_protection");
        $finish;
    end
endmodule
```

## Source - xadc_monitor.v

**Path:** `xadc\xadc_monitor.v`

```verilog
`timescale 1ns/1ps

// Feed this monitor from an XADC Wizard or an XADC primitive adapter. The
// thresholds are raw 12-bit XADC codes and must be calibrated for the board.
module xadc_monitor #(
    parameter [11:0] VCCINT_MIN = 12'h500,
    parameter [11:0] VCCINT_MAX = 12'h600,
    parameter [11:0] TEMP_MAX = 12'hA00,
    parameter integer FAULT_SAMPLES = 2
) (
    input  wire        clk,
    input  wire        reset,
    input  wire        sample_valid,
    input  wire [11:0] vccint_code,
    input  wire [11:0] temperature_code,
    input  wire        clear_alarm,
    output reg         glitch_event,
    output reg         alarm_latched,
    output reg [11:0]  last_vccint,
    output reg [11:0]  last_temperature
);
    localparam integer COUNT_W = (FAULT_SAMPLES <= 1) ? 1 : $clog2(FAULT_SAMPLES + 1);
    reg [COUNT_W-1:0] fault_count;
    wire out_of_range = (vccint_code < VCCINT_MIN) || (vccint_code > VCCINT_MAX) ||
                        (temperature_code > TEMP_MAX);

    always @(posedge clk) begin
        if (reset) begin
            glitch_event <= 1'b0;
            alarm_latched <= 1'b0;
            last_vccint <= 12'd0;
            last_temperature <= 12'd0;
            fault_count <= {COUNT_W{1'b0}};
        end else begin
            glitch_event <= 1'b0;
            if (clear_alarm && !out_of_range) begin
                alarm_latched <= 1'b0;
                fault_count <= {COUNT_W{1'b0}};
            end
            if (sample_valid) begin
                last_vccint <= vccint_code;
                last_temperature <= temperature_code;
                if (out_of_range) begin
                    if (fault_count < FAULT_SAMPLES)
                        fault_count <= fault_count + 1'b1;
                    if (fault_count == FAULT_SAMPLES - 1) begin
                        glitch_event <= 1'b1;
                        alarm_latched <= 1'b1;
                    end
                end else
                    fault_count <= {COUNT_W{1'b0}};
            end
        end
    end
endmodule
```

## Testbench - tb_xadc_monitor.v

**Path:** `tb\tb_xadc_monitor.v`

```verilog
`timescale 1ns/1ps
module tb_xadc_monitor;
    reg clk=0, reset=1, sample_valid=0, clear_alarm=0; reg [11:0] vccint=12'h550, temperature=12'h500;
    wire glitch_event, alarm_latched; wire [11:0] last_vcc,last_temp;
    xadc_monitor #(.FAULT_SAMPLES(2)) dut (.clk(clk),.reset(reset),.sample_valid(sample_valid),.vccint_code(vccint),.temperature_code(temperature),.clear_alarm(clear_alarm),.glitch_event(glitch_event),.alarm_latched(alarm_latched),.last_vccint(last_vcc),.last_temperature(last_temp));
    always #5 clk=~clk;
    task sample; begin @(negedge clk); sample_valid=1; @(negedge clk); sample_valid=0; end endtask
    initial begin
        repeat(3) @(posedge clk); reset=0;
        sample; if (alarm_latched) $display("FAIL: normal XADC reading");
        vccint=12'h400; sample; sample;
        if (!alarm_latched) $display("FAIL: XADC glitch not latched"); else $display("PASS: xadc_monitor");
        $finish;
    end
endmodule
```

## Source - security_controller.v

**Path:** `security\security_controller.v`

```verilog
`timescale 1ns/1ps

module security_controller (
    input  wire clk,
    input  wire reset,
    input  wire packet_valid,
    input  wire packet_crc_ok,
    input  wire replay_done,
    input  wire replay_detected,
    input  wire xadc_glitch,
    input  wire clear_alarm,
    output reg  replay_check_start,
    output reg  command_accepted,
    output reg  command_rejected,
    output reg  alarm_latched,
    output wire aes_reset,
    output reg [2:0] secure_state
);
    localparam [2:0] IDLE = 3'd0, CRC_CHECK = 3'd1, REPLAY_CHECK = 3'd2,
                     ACCEPT = 3'd3, REJECT = 3'd4, LOCKDOWN = 3'd5;
    assign aes_reset = alarm_latched | xadc_glitch;

    always @(posedge clk) begin
        if (reset) begin
            replay_check_start <= 1'b0;
            command_accepted <= 1'b0;
            command_rejected <= 1'b0;
            alarm_latched <= 1'b0;
            secure_state <= IDLE;
        end else begin
            replay_check_start <= 1'b0;
            command_accepted <= 1'b0;
            command_rejected <= 1'b0;
            if (clear_alarm && !xadc_glitch && secure_state != CRC_CHECK && secure_state != REPLAY_CHECK)
                alarm_latched <= 1'b0;
            if (xadc_glitch) begin
                alarm_latched <= 1'b1;
                command_rejected <= 1'b1;
                secure_state <= LOCKDOWN;
            end else begin
                case (secure_state)
                    IDLE: if (packet_valid) secure_state <= CRC_CHECK;
                    CRC_CHECK: begin
                        if (packet_crc_ok) begin
                            replay_check_start <= 1'b1;
                            secure_state <= REPLAY_CHECK;
                        end else begin
                            alarm_latched <= 1'b1;
                            secure_state <= REJECT;
                        end
                    end
                    REPLAY_CHECK: if (replay_done) begin
                        if (replay_detected) begin
                            alarm_latched <= 1'b1;
                            secure_state <= REJECT;
                        end else
                            secure_state <= ACCEPT;
                    end
                    ACCEPT: begin
                        command_accepted <= 1'b1;
                        secure_state <= IDLE;
                    end
                    REJECT: begin
                        command_rejected <= 1'b1;
                        secure_state <= LOCKDOWN;
                    end
                    default: if (clear_alarm) secure_state <= IDLE;
                endcase
            end
        end
    end
endmodule
```

## Testbench - tb_security_controller.v

**Path:** `tb\tb_security_controller.v`

```verilog
`timescale 1ns/1ps
module tb_security_controller;
    reg clk=0, reset=1, packet_valid=0, packet_crc_ok=0, replay_done=0, replay_detected=0, xadc_glitch=0, clear_alarm=0;
    wire replay_start, accepted, rejected, alarm, aes_reset; wire [2:0] state;
    security_controller dut (.clk(clk),.reset(reset),.packet_valid(packet_valid),.packet_crc_ok(packet_crc_ok),.replay_done(replay_done),.replay_detected(replay_detected),.xadc_glitch(xadc_glitch),.clear_alarm(clear_alarm),.replay_check_start(replay_start),.command_accepted(accepted),.command_rejected(rejected),.alarm_latched(alarm),.aes_reset(aes_reset),.secure_state(state));
    always #5 clk=~clk;
    initial begin
        repeat(3) @(posedge clk); reset=0;
        packet_crc_ok=1; @(negedge clk); packet_valid=1; @(negedge clk); packet_valid=0;
        wait(replay_start); @(negedge clk); replay_done=1; replay_detected=0; @(negedge clk); replay_done=0;
        wait(accepted);
        if (alarm) $display("FAIL: valid packet alarmed");
        packet_crc_ok=0; @(negedge clk); packet_valid=1; @(negedge clk); packet_valid=0;
        wait(rejected); if (!alarm || !aes_reset) $display("FAIL: CRC failure not locked down");
        else $display("PASS: security_controller");
        $finish;
    end
endmodule
```

## Source - packet_formatter.v

**Path:** `packet\packet_formatter.v`

```verilog
`timescale 1ns/1ps

// Outbound frame: A5 | nonce[63:0] | sequence | AES-128 ciphertext | CRC-32/MPEG-2.
module packet_formatter (
    input  wire         clk,
    input  wire         reset,
    input  wire         aes_reset,
    input  wire         start,
    input  wire [127:0] plaintext,
    input  wire [127:0] key,
    input  wire [63:0]  nonce,
    input  wire [7:0]   sequence,
    output reg  [239:0] packet,
    output reg          packet_valid,
    output reg          busy
);
    localparam [2:0] IDLE = 3'd0, AES_START = 3'd1, AES_WAIT = 3'd2,
                     CRC_START = 3'd3, CRC_SEND = 3'd4, CRC_WAIT = 3'd5;
    reg [2:0] state;
    reg aes_start;
    reg crc_start;
    reg crc_data_valid;
    reg crc_data_last;
    reg [7:0] crc_data;
    reg [4:0] byte_index;
    reg [63:0] nonce_reg;
    reg [7:0] sequence_reg;
    reg [127:0] plaintext_reg;
    reg [127:0] key_reg;
    reg [127:0] cipher_reg;
    wire [127:0] aes_ciphertext;
    wire aes_busy;
    wire aes_done;
    wire [31:0] crc_value;
    wire crc_busy;
    wire crc_valid;

    aes128_encrypt aes (
        .clk(clk), .reset(reset | aes_reset), .start(aes_start), .plaintext(plaintext_reg), .key(key_reg),
        .ciphertext(aes_ciphertext), .busy(aes_busy), .done(aes_done)
    );
    crc32_mpeg2 crc (
        .clk(clk), .reset(reset), .start(crc_start), .data_valid(crc_data_valid), .data_byte(crc_data),
        .data_last(crc_data_last), .crc(crc_value), .busy(crc_busy), .crc_valid(crc_valid)
    );

    function automatic [7:0] frame_byte;
        input [4:0] index;
        begin
            if (index == 0)
                frame_byte = 8'hA5;
            else if (index <= 8)
                frame_byte = nonce_reg >> (8 * (8 - index));
            else if (index == 9)
                frame_byte = sequence_reg;
            else
                frame_byte = cipher_reg >> (8 * (25 - index));
        end
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            aes_start <= 1'b0;
            crc_start <= 1'b0;
            crc_data_valid <= 1'b0;
            crc_data_last <= 1'b0;
            crc_data <= 8'd0;
            byte_index <= 5'd0;
            nonce_reg <= 64'd0;
            sequence_reg <= 8'd0;
            plaintext_reg <= 128'd0;
            key_reg <= 128'd0;
            cipher_reg <= 128'd0;
            packet <= 240'd0;
            packet_valid <= 1'b0;
            busy <= 1'b0;
        end else begin
            aes_start <= 1'b0;
            crc_start <= 1'b0;
            crc_data_valid <= 1'b0;
            crc_data_last <= 1'b0;
            packet_valid <= 1'b0;
            if (aes_reset) begin
                state <= IDLE;
                busy <= 1'b0;
            end else begin
                case (state)
                    IDLE: if (start) begin
                        nonce_reg <= nonce;
                        sequence_reg <= sequence;
                        plaintext_reg <= plaintext;
                        key_reg <= key;
                        busy <= 1'b1;
                        state <= AES_START;
                    end
                    AES_START: begin
                        aes_start <= 1'b1;
                        state <= AES_WAIT;
                    end
                    AES_WAIT: if (aes_done) begin
                        cipher_reg <= aes_ciphertext;
                        state <= CRC_START;
                    end
                    CRC_START: begin
                        crc_start <= 1'b1;
                        byte_index <= 5'd0;
                        state <= CRC_SEND;
                    end
                    CRC_SEND: begin
                        crc_data <= frame_byte(byte_index);
                        crc_data_valid <= 1'b1;
                        crc_data_last <= (byte_index == 5'd25);
                        if (byte_index == 5'd25)
                            state <= CRC_WAIT;
                        else
                            byte_index <= byte_index + 1'b1;
                    end
                    default: if (crc_valid) begin
                        packet <= {8'hA5, nonce_reg, sequence_reg, cipher_reg, crc_value};
                        packet_valid <= 1'b1;
                        busy <= 1'b0;
                        state <= IDLE;
                    end
                endcase
            end
        end
    end
endmodule
```

## Testbench - tb_packet_formatter.v

**Path:** `tb\tb_packet_formatter.v`

```verilog
`timescale 1ns/1ps
module tb_packet_formatter;
    reg clk=0, reset=1, aes_reset=0, start=0;
    reg [127:0] plaintext=128'h00112233445566778899AABBCCDDEEFF;
    reg [127:0] key=128'h000102030405060708090A0B0C0D0E0F;
    reg [63:0] nonce=64'h0102030405060708; reg [7:0] sequence=8'h12;
    wire [239:0] packet; wire packet_valid,busy;
    packet_formatter dut (.clk(clk),.reset(reset),.aes_reset(aes_reset),.start(start),.plaintext(plaintext),.key(key),.nonce(nonce),.sequence(sequence),.packet(packet),.packet_valid(packet_valid),.busy(busy));
    always #5 clk=~clk;
    initial begin
        repeat(3) @(posedge clk); reset=0;
        @(negedge clk); start=1; @(negedge clk); start=0;
        wait(packet_valid); #1;
        if (packet[239:232]!==8'hA5 || packet[231:168]!==nonce || packet[167:160]!==sequence || packet[159:32]!==128'h69C4E0D86A7B0430D8CDB78070B4C55A) $display("FAIL: packet formatter");
        else $display("PASS: packet_formatter");
        $finish;
    end
endmodule
```

## Source - picorv32_wrapper.v

**Path:** `cpu\picorv32_wrapper.v`

```verilog
`timescale 1ns/1ps

// Add the official picorv32.v source and define SENTINEL_USE_PICORV32 for an
// implementation build. The no-core branch keeps peripheral simulations and
// security RTL elaboration independent of a third-party CPU source file.
module picorv32_wrapper (
    input  wire        clk,
    input  wire        reset,
    output wire        trap,
    output wire        mem_valid,
    output wire        mem_instr,
    input  wire        mem_ready,
    output wire [31:0] mem_addr,
    output wire [31:0] mem_wdata,
    output wire [3:0]  mem_wstrb,
    input  wire [31:0] mem_rdata
);
`ifdef SENTINEL_USE_PICORV32
    picorv32 #(
        .ENABLE_MUL(1),
        .ENABLE_DIV(1),
        .ENABLE_IRQ(0),
        .PROGADDR_RESET(32'h0000_0000),
        .STACKADDR(32'h0000_0FFC)
    ) cpu (
        .clk(clk), .resetn(!reset), .trap(trap),
        .mem_valid(mem_valid), .mem_instr(mem_instr), .mem_ready(mem_ready),
        .mem_addr(mem_addr), .mem_wdata(mem_wdata), .mem_wstrb(mem_wstrb), .mem_rdata(mem_rdata),
        .mem_la_read(), .mem_la_write(), .mem_la_addr(), .mem_la_wdata(), .mem_la_wstrb(),
        .pcpi_valid(), .pcpi_insn(), .pcpi_rs1(), .pcpi_rs2(), .pcpi_wr(1'b0), .pcpi_rd(32'd0), .pcpi_wait(1'b0), .pcpi_ready(1'b0),
        .irq(32'd0), .eoi()
    );
`else
    assign trap = 1'b0;
    assign mem_valid = 1'b0;
    assign mem_instr = 1'b0;
    assign mem_addr = 32'd0;
    assign mem_wdata = 32'd0;
    assign mem_wstrb = 4'd0;
`endif
endmodule
```

## Source - simple_bram_memory.v

**Path:** `cpu\simple_bram_memory.v`

```verilog
`timescale 1ns/1ps

module simple_bram_memory #(
    parameter integer WORDS = 1024,
    parameter MEM_FILE = "cpu/cpu_test_program.hex"
) (
    input  wire        clk,
    input  wire        reset,
    input  wire        mem_valid,
    input  wire [31:0] mem_addr,
    input  wire [31:0] mem_wdata,
    input  wire [3:0]  mem_wstrb,
    output reg         mem_ready,
    output reg [31:0]  mem_rdata
);
    localparam integer ADDR_W = (WORDS <= 1) ? 1 : $clog2(WORDS);
    reg [31:0] memory [0:WORDS-1];
    wire [ADDR_W-1:0] word_address = mem_addr[ADDR_W+1:2];

    initial begin
        if (MEM_FILE != "") $readmemh(MEM_FILE, memory);
    end

    always @(posedge clk) begin
        if (reset) begin
            mem_ready <= 1'b0;
            mem_rdata <= 32'd0;
        end else begin
            mem_ready <= mem_valid;
            if (mem_valid) begin
                mem_rdata <= memory[word_address];
                if (mem_wstrb[0]) memory[word_address][7:0] <= mem_wdata[7:0];
                if (mem_wstrb[1]) memory[word_address][15:8] <= mem_wdata[15:8];
                if (mem_wstrb[2]) memory[word_address][23:16] <= mem_wdata[23:16];
                if (mem_wstrb[3]) memory[word_address][31:24] <= mem_wdata[31:24];
            end
        end
    end
endmodule
```

## Testbench - tb_simple_bram_memory.v

**Path:** `tb\tb_simple_bram_memory.v`

```verilog
`timescale 1ns/1ps
module tb_simple_bram_memory;
    reg clk=0, reset=1, valid=0; reg [31:0] addr=0,wdata=0; reg [3:0] wstrb=0;
    wire ready; wire [31:0] rdata;
    simple_bram_memory #(.WORDS(16),.MEM_FILE("")) dut (.clk(clk),.reset(reset),.mem_valid(valid),.mem_addr(addr),.mem_wdata(wdata),.mem_wstrb(wstrb),.mem_ready(ready),.mem_rdata(rdata));
    always #5 clk=~clk;
    initial begin
        repeat(2) @(posedge clk); reset=0;
        @(negedge clk); addr=0; wdata=32'hDEADBEEF; wstrb=4'hF; valid=1;
        @(negedge clk); valid=0; wstrb=0;
        @(negedge clk); valid=1; @(negedge clk); valid=0;
        #1; if (rdata!==32'hDEADBEEF) $display("FAIL: BRAM memory read=%h",rdata); else $display("PASS: simple_bram_memory");
        $finish;
    end
endmodule
```

## CPU Program - cpu_test_program.hex

**Path:** `cpu\cpu_test_program.hex`

```text
00000013
00100093
00200113
002081B3
00302023
0000006F
```

## Source - sentinel_rv_security.v

**Path:** `sentinel_rv_security.v`

```verilog
`timescale 1ns/1ps

module sentinel_rv_security (
    input  wire         clk,
    input  wire         reset,
    input  wire         rx_packet_valid,
    input  wire [63:0]  rx_nonce,
    input  wire         rx_crc_ok,
    input  wire         clear_alarm,
    input  wire         xadc_sample_valid,
    input  wire [11:0]  xadc_vccint_code,
    input  wire [11:0]  xadc_temperature_code,
    output wire         command_accepted,
    output wire         command_rejected,
    output wire         alarm,
    output wire         aes_reset,
    input  wire         tx_start,
    input  wire [127:0] tx_plaintext,
    input  wire [127:0] tx_key,
    input  wire [63:0]  tx_nonce,
    input  wire [7:0]   tx_sequence,
    output wire [239:0] tx_packet,
    output wire         tx_packet_valid,
    output wire         tx_busy,
    output wire         cpu_trap
);
    wire replay_start, replay_busy, replay_done, replay_detected, nonce_accepted;
    wire xadc_glitch_event, xadc_alarm;
    wire [11:0] unused_vccint, unused_temperature;
    wire [2:0] secure_state;
    wire [63:0] generated_nonce;
    wire generated_nonce_valid;
    wire formatter_start;
    wire formatter_busy;
    reg transmit_pending;
    reg [127:0] pending_plaintext;
    reg [127:0] pending_key;
    reg [63:0] pending_nonce;
    reg [7:0] pending_sequence;
    wire cpu_mem_valid, cpu_mem_instr, cpu_mem_ready;
    wire [31:0] cpu_mem_addr, cpu_mem_wdata, cpu_mem_rdata;
    wire [3:0] cpu_mem_wstrb;

    xadc_monitor xadc (
        .clk(clk), .reset(reset), .sample_valid(xadc_sample_valid), .vccint_code(xadc_vccint_code),
        .temperature_code(xadc_temperature_code), .clear_alarm(clear_alarm), .glitch_event(xadc_glitch_event),
        .alarm_latched(xadc_alarm), .last_vccint(unused_vccint), .last_temperature(unused_temperature)
    );
    replay_protection replay (
        .clk(clk), .reset(reset), .check_start(replay_start), .nonce_in(rx_nonce), .busy(replay_busy),
        .check_done(replay_done), .replay_detected(replay_detected), .nonce_accepted(nonce_accepted)
    );
    security_controller controller (
        .clk(clk), .reset(reset), .packet_valid(rx_packet_valid), .packet_crc_ok(rx_crc_ok),
        .replay_done(replay_done), .replay_detected(replay_detected),
        .xadc_glitch(xadc_glitch_event | xadc_alarm), .clear_alarm(clear_alarm),
        .replay_check_start(replay_start), .command_accepted(command_accepted),
        .command_rejected(command_rejected), .alarm_latched(alarm), .aes_reset(aes_reset), .secure_state(secure_state)
    );
    packet_formatter formatter (
        .clk(clk), .reset(reset), .aes_reset(aes_reset), .start(formatter_start), .plaintext(pending_plaintext), .key(pending_key),
        .nonce((generated_nonce_valid && pending_nonce == 64'd0) ? generated_nonce : pending_nonce), .sequence(pending_sequence), .packet(tx_packet), .packet_valid(tx_packet_valid), .busy(formatter_busy)
    );
    nonce_generator nonce_source (
        .clk(clk), .reset(reset), .request(tx_start && !transmit_pending && tx_nonce == 64'd0),
        .nonce(generated_nonce), .nonce_valid(generated_nonce_valid)
    );

    assign formatter_start = transmit_pending && (pending_nonce != 64'd0 || generated_nonce_valid);
    assign tx_busy = transmit_pending | formatter_busy;

    always @(posedge clk) begin
        if (reset) begin
            transmit_pending <= 1'b0;
            pending_plaintext <= 128'd0;
            pending_key <= 128'd0;
            pending_nonce <= 64'd0;
            pending_sequence <= 8'd0;
        end else begin
            if (aes_reset)
                transmit_pending <= 1'b0;
            else begin
                if (tx_start && !transmit_pending) begin
                    pending_plaintext <= tx_plaintext;
                    pending_key <= tx_key;
                    pending_sequence <= tx_sequence;
                    pending_nonce <= tx_nonce;
                    transmit_pending <= 1'b1;
                end
                if (transmit_pending && pending_nonce == 64'd0 && generated_nonce_valid)
                    pending_nonce <= generated_nonce;
                if (formatter_start)
                    transmit_pending <= 1'b0;
            end
        end
    end
    picorv32_wrapper cpu (
        .clk(clk), .reset(reset), .trap(cpu_trap), .mem_valid(cpu_mem_valid), .mem_instr(cpu_mem_instr),
        .mem_ready(cpu_mem_ready), .mem_addr(cpu_mem_addr), .mem_wdata(cpu_mem_wdata),
        .mem_wstrb(cpu_mem_wstrb), .mem_rdata(cpu_mem_rdata)
    );
    simple_bram_memory memory (
        .clk(clk), .reset(reset), .mem_valid(cpu_mem_valid), .mem_addr(cpu_mem_addr), .mem_wdata(cpu_mem_wdata),
        .mem_wstrb(cpu_mem_wstrb), .mem_ready(cpu_mem_ready), .mem_rdata(cpu_mem_rdata)
    );
endmodule
```

## Testbench - tb_sentinel_rv_security.v

**Path:** `tb\tb_sentinel_rv_security.v`

```verilog
`timescale 1ns/1ps
module tb_sentinel_rv_security;
    reg clk=0, reset=1, rx_valid=0, rx_crc_ok=1, clear_alarm=0, xadc_valid=0;
    reg [63:0] rx_nonce=64'hCAFEBABE12345678;
    reg [11:0] vccint=12'h550, temp=12'h500;
    reg tx_start=0; reg [127:0] tx_plain=0, tx_key=0; reg [63:0] tx_nonce=0; reg [7:0] tx_seq=0;
    wire accepted,rejected,alarm,aes_reset,tx_valid,tx_busy,cpu_trap; wire [239:0] tx_packet;
    sentinel_rv_security dut (.clk(clk),.reset(reset),.rx_packet_valid(rx_valid),.rx_nonce(rx_nonce),.rx_crc_ok(rx_crc_ok),.clear_alarm(clear_alarm),.xadc_sample_valid(xadc_valid),.xadc_vccint_code(vccint),.xadc_temperature_code(temp),.command_accepted(accepted),.command_rejected(rejected),.alarm(alarm),.aes_reset(aes_reset),.tx_start(tx_start),.tx_plaintext(tx_plain),.tx_key(tx_key),.tx_nonce(tx_nonce),.tx_sequence(tx_seq),.tx_packet(tx_packet),.tx_packet_valid(tx_valid),.tx_busy(tx_busy),.cpu_trap(cpu_trap));
    always #5 clk=~clk;
    initial begin
        repeat(3) @(posedge clk); reset=0;
        @(negedge clk); rx_valid=1; @(negedge clk); rx_valid=0;
        wait(accepted); #1;
        if (alarm || aes_reset) $display("FAIL: security top accepted packet alarmed"); else $display("PASS: sentinel_rv_security accepted packet");
        $finish;
    end
endmodule
```

## Source - baud_gen.v

**Path:** `uart\baud_gen.v`

```verilog
`timescale 1ns/1ps

module baud_gen #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer BAUD = 115_200,
    parameter integer OVERSAMPLE = 16
) (
    input  wire clk,
    input  wire reset,
    output reg  tick
);
    localparam integer DIVISOR = (CLK_HZ / (BAUD * OVERSAMPLE) > 0) ?
                               (CLK_HZ / (BAUD * OVERSAMPLE)) : 1;
    localparam integer COUNT_W = (DIVISOR <= 1) ? 1 : $clog2(DIVISOR);

    reg [COUNT_W-1:0] count;

    always @(posedge clk) begin
        if (reset) begin
            count <= {COUNT_W{1'b0}};
            tick  <= 1'b0;
        end else if (count == DIVISOR - 1) begin
            count <= {COUNT_W{1'b0}};
            tick  <= 1'b1;
        end else begin
            count <= count + 1'b1;
            tick  <= 1'b0;
        end
    end
endmodule
```

## Testbench - tb_baud_gen.v

**Path:** `tb\tb_baud_gen.v`

```verilog
`timescale 1ns/1ps
module tb_baud_gen;
    reg clk = 0, reset = 1;
    wire tick;
    integer cycles = 0, ticks = 0;
    baud_gen #(.CLK_HZ(160), .BAUD(10), .OVERSAMPLE(1)) dut (.clk(clk), .reset(reset), .tick(tick));
    always #5 clk = ~clk;
    always @(posedge clk) begin
        cycles = cycles + 1;
        if (tick) ticks = ticks + 1;
    end
    initial begin
        #17 reset = 0;
        repeat (65) @(posedge clk);
        if (ticks < 3 || ticks > 5) $display("FAIL: unexpected tick count %0d", ticks);
        else $display("PASS: baud_gen");
        $finish;
    end
endmodule
```

## Source - uart_tx.v

**Path:** `uart\uart_tx.v`

```verilog
`timescale 1ns/1ps

module uart_tx (
    input  wire       clk,
    input  wire       reset,
    input  wire       baud_tick,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output reg        tx,
    output reg        busy
);
    reg [3:0] bit_index;
    reg [7:0] data_reg;

    always @(posedge clk) begin
        if (reset) begin
            tx        <= 1'b1;
            busy      <= 1'b0;
            bit_index <= 4'd0;
            data_reg  <= 8'd0;
        end else if (!busy) begin
            tx <= 1'b1;
            if (tx_start) begin
                busy      <= 1'b1;
                bit_index <= 4'd10;
                data_reg  <= tx_data;
            end
        end else if (baud_tick) begin
            if (bit_index == 4'd10) begin
                tx        <= 1'b0;
                bit_index <= 4'd0;
            end else if (bit_index < 4'd8) begin
                tx        <= data_reg[bit_index];
                bit_index <= bit_index + 1'b1;
            end else if (bit_index == 4'd8) begin
                tx        <= 1'b1;
                bit_index <= 4'd9;
            end else begin
                tx   <= 1'b1;
                busy <= 1'b0;
            end
        end
    end
endmodule
```

## Testbench - tb_uart_tx.v

**Path:** `tb\tb_uart_tx.v`

```verilog
`timescale 1ns/1ps
module tb_uart_tx;
    reg clk = 0, reset = 1, baud_tick = 0, tx_start = 0;
    reg [7:0] tx_data = 8'hA5;
    wire tx, busy;
    uart_tx dut (.clk(clk), .reset(reset), .baud_tick(baud_tick), .tx_start(tx_start), .tx_data(tx_data), .tx(tx), .busy(busy));
    always #5 clk = ~clk;
    task tick; begin @(negedge clk); baud_tick = 1; @(negedge clk); baud_tick = 0; end endtask
    initial begin
        repeat (2) @(posedge clk); reset = 0;
        @(negedge clk); tx_start = 1; @(negedge clk); tx_start = 0;
        tick; if (tx !== 1'b0) $display("FAIL: missing start bit");
        tick; if (tx !== 1'b1) $display("FAIL: bit 0");
        tick; if (tx !== 1'b0) $display("FAIL: bit 1");
        repeat (6) tick;
        tick; if (tx !== 1'b1) $display("FAIL: stop bit");
        tick; if (busy) $display("FAIL: transmitter remained busy"); else $display("PASS: uart_tx");
        $finish;
    end
endmodule
```

## Source - uart_rx.v

**Path:** `uart\uart_rx.v`

```verilog
`timescale 1ns/1ps

module uart_rx (
    input  wire       clk,
    input  wire       reset,
    input  wire       baud16_tick,
    input  wire       rx,
    output reg [7:0] rx_data,
    output reg        rx_valid,
    output reg        framing_error
);
    localparam [1:0] IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;

    reg [1:0] state;
    reg [3:0] sample_count;
    reg [2:0] bit_index;
    reg [7:0] shift_reg;
    reg rx_meta, rx_sync;

    always @(posedge clk) begin
        rx_meta <= rx;
        rx_sync <= rx_meta;
        if (reset) begin
            state         <= IDLE;
            sample_count  <= 4'd0;
            bit_index     <= 3'd0;
            shift_reg     <= 8'd0;
            rx_data       <= 8'd0;
            rx_valid      <= 1'b0;
            framing_error <= 1'b0;
        end else begin
            rx_valid <= 1'b0;
            if (baud16_tick) begin
                case (state)
                    IDLE: begin
                        sample_count <= 4'd0;
                        if (!rx_sync)
                            state <= START;
                    end
                    START: begin
                        if (sample_count == 4'd7) begin
                            sample_count <= 4'd0;
                            if (!rx_sync) begin
                                bit_index <= 3'd0;
                                state <= DATA;
                            end else
                                state <= IDLE;
                        end else
                            sample_count <= sample_count + 1'b1;
                    end
                    DATA: begin
                        if (sample_count == 4'd15) begin
                            sample_count <= 4'd0;
                            shift_reg[bit_index] <= rx_sync;
                            if (bit_index == 3'd7)
                                state <= STOP;
                            else
                                bit_index <= bit_index + 1'b1;
                        end else
                            sample_count <= sample_count + 1'b1;
                    end
                    default: begin
                        if (sample_count == 4'd15) begin
                            sample_count  <= 4'd0;
                            framing_error <= !rx_sync;
                            if (rx_sync) begin
                                rx_data  <= shift_reg;
                                rx_valid <= 1'b1;
                            end
                            state <= IDLE;
                        end else
                            sample_count <= sample_count + 1'b1;
                    end
                endcase
            end
        end
    end
endmodule
```

## Testbench - tb_uart_rx.v

**Path:** `tb\tb_uart_rx.v`

```verilog
`timescale 1ns/1ps
module tb_uart_rx;
    reg clk = 0, reset = 1, baud16_tick = 1, rx = 1;
    wire [7:0] rx_data; wire rx_valid, framing_error;
    reg [7:0] captured; reg captured_valid = 0;
    uart_rx dut (.clk(clk), .reset(reset), .baud16_tick(baud16_tick), .rx(rx), .rx_data(rx_data), .rx_valid(rx_valid), .framing_error(framing_error));
    always #5 clk = ~clk;
    always @(posedge clk) if (rx_valid) begin captured <= rx_data; captured_valid <= 1; end
    task send_byte; input [7:0] value; integer bit_no; begin
        rx = 0; repeat (16) @(posedge clk);
        for (bit_no = 0; bit_no < 8; bit_no = bit_no + 1) begin rx = value[bit_no]; repeat (16) @(posedge clk); end
        rx = 1; repeat (18) @(posedge clk);
    end endtask
    initial begin
        repeat (2) @(posedge clk); reset = 0;
        send_byte(8'h3C);
        if (!captured_valid || captured !== 8'h3C || framing_error) $display("FAIL: uart_rx data=%h valid=%b err=%b", captured, captured_valid, framing_error);
        else $display("PASS: uart_rx");
        $finish;
    end
endmodule
```

## Source - uart_top.v

**Path:** `uart\uart_top.v`

```verilog
`timescale 1ns/1ps

module uart_top #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer BAUD = 115_200
) (
    input  wire       clk,
    input  wire       reset,
    input  wire       uart_rx_i,
    output wire       uart_tx_o,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output wire       tx_busy,
    output wire [7:0] rx_data,
    output wire       rx_valid,
    output wire       framing_error
);
    wire baud16_tick;
    reg [3:0] tx_divider;
    reg tx_tick;

    baud_gen #(.CLK_HZ(CLK_HZ), .BAUD(BAUD), .OVERSAMPLE(16)) baud_clock (
        .clk(clk), .reset(reset), .tick(baud16_tick)
    );

    always @(posedge clk) begin
        if (reset) begin
            tx_divider <= 4'd0;
            tx_tick    <= 1'b0;
        end else begin
            tx_tick <= 1'b0;
            if (baud16_tick) begin
                if (tx_divider == 4'd15) begin
                    tx_divider <= 4'd0;
                    tx_tick    <= 1'b1;
                end else
                    tx_divider <= tx_divider + 1'b1;
            end
        end
    end

    uart_tx transmitter (
        .clk(clk), .reset(reset), .baud_tick(tx_tick), .tx_start(tx_start),
        .tx_data(tx_data), .tx(uart_tx_o), .busy(tx_busy)
    );

    uart_rx receiver (
        .clk(clk), .reset(reset), .baud16_tick(baud16_tick), .rx(uart_rx_i),
        .rx_data(rx_data), .rx_valid(rx_valid), .framing_error(framing_error)
    );
endmodule
```

## Testbench - tb_uart_top.v

**Path:** `tb\tb_uart_top.v`

```verilog
`timescale 1ns/1ps
module tb_uart_top;
    reg clk = 0, reset = 1, tx_start = 0;
    reg [7:0] tx_data = 8'hA5;
    wire tx, busy, rx_valid, framing_error; wire [7:0] rx_data;
    uart_top #(.CLK_HZ(160_000), .BAUD(10_000)) dut (
        .clk(clk), .reset(reset), .uart_rx_i(tx), .uart_tx_o(tx), .tx_start(tx_start), .tx_data(tx_data),
        .tx_busy(busy), .rx_data(rx_data), .rx_valid(rx_valid), .framing_error(framing_error));
    always #5 clk = ~clk;
    initial begin
        repeat (3) @(posedge clk); reset = 0;
        @(negedge clk); tx_start = 1; @(negedge clk); tx_start = 0;
        wait (rx_valid); #1;
        if (rx_data !== 8'hA5 || framing_error) $display("FAIL: uart_top loopback %h", rx_data);
        else $display("PASS: uart_top");
        $finish;
    end
endmodule
```

## Source - sentinel_command_rx.v

**Path:** `uart\sentinel_command_rx.v`

```verilog
`timescale 1ns/1ps

module sentinel_command_rx (
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] rx_data,
    input  wire       rx_valid,
    output reg        cmd_valid,
    output reg [7:0]  cmd_opcode,
    output reg [7:0]  cmd_sequence,
    output reg [15:0] cmd_argument,
    output reg        cmd_error
);
    localparam [7:0] SOF = 8'hA5;
    reg [2:0] byte_count;
    reg [7:0] checksum;

    always @(posedge clk) begin
        if (reset) begin
            byte_count   <= 3'd0;
            checksum     <= 8'd0;
            cmd_valid    <= 1'b0;
            cmd_error    <= 1'b0;
            cmd_opcode   <= 8'd0;
            cmd_sequence <= 8'd0;
            cmd_argument <= 16'd0;
        end else begin
            cmd_valid <= 1'b0;
            cmd_error <= 1'b0;
            if (rx_valid) begin
                if (byte_count == 3'd0) begin
                    if (rx_data == SOF) begin
                        byte_count <= 3'd1;
                        checksum <= SOF;
                    end
                end else if (rx_data == SOF) begin
                    byte_count <= 3'd1;
                    checksum <= SOF;
                end else begin
                    case (byte_count)
                        3'd1: begin cmd_opcode <= rx_data; checksum <= checksum ^ rx_data; byte_count <= 3'd2; end
                        3'd2: begin cmd_sequence <= rx_data; checksum <= checksum ^ rx_data; byte_count <= 3'd3; end
                        3'd3: begin cmd_argument[15:8] <= rx_data; checksum <= checksum ^ rx_data; byte_count <= 3'd4; end
                        3'd4: begin cmd_argument[7:0] <= rx_data; checksum <= checksum ^ rx_data; byte_count <= 3'd5; end
                        default: begin
                            if (rx_data == checksum)
                                cmd_valid <= 1'b1;
                            else
                                cmd_error <= 1'b1;
                            byte_count <= 3'd0;
                        end
                    endcase
                end
            end
        end
    end
endmodule
```

## Testbench - tb_command_rx.v

**Path:** `tb\tb_command_rx.v`

```verilog
`timescale 1ns/1ps
module tb_command_rx;
    reg clk = 0, reset = 1, rx_valid = 0; reg [7:0] rx_data = 0;
    wire cmd_valid, cmd_error; wire [7:0] opcode, sequence; wire [15:0] argument;
    sentinel_command_rx dut (.clk(clk), .reset(reset), .rx_data(rx_data), .rx_valid(rx_valid), .cmd_valid(cmd_valid), .cmd_opcode(opcode), .cmd_sequence(sequence), .cmd_argument(argument), .cmd_error(cmd_error));
    always #5 clk = ~clk;
    task send; input [7:0] value; begin @(negedge clk); rx_data=value; rx_valid=1; @(negedge clk); rx_valid=0; end endtask
    initial begin
        repeat (2) @(posedge clk); reset=0;
        send(8'hA5); send(8'h22); send(8'h09); send(8'hBE); send(8'hEF); send(8'hDF);
        @(posedge clk); #1;
        if (!cmd_valid || opcode != 8'h22 || sequence != 8'h09 || argument != 16'hBEEF) $display("FAIL: command parser");
        else $display("PASS: sentinel_command_rx");
        $finish;
    end
endmodule
```

## Source - sentinel_telemetry_tx.v

**Path:** `uart\sentinel_telemetry_tx.v`

```verilog
`timescale 1ns/1ps

module sentinel_telemetry_tx (
    input  wire       clk,
    input  wire       reset,
    input  wire       telemetry_valid,
    output wire       telemetry_ready,
    input  wire [7:0] telemetry_sequence,
    input  wire [7:0] telemetry_event,
    input  wire [11:0] telemetry_sensor,
    input  wire [7:0] telemetry_status,
    input  wire       uart_busy,
    output reg        uart_start,
    output reg [7:0]  uart_data
);
    localparam [7:0] SOF = 8'hA6;
    reg [2:0] byte_index;
    reg active, awaiting_busy;
    reg [7:0] checksum;
    reg [7:0] sequence_reg, event_reg, status_reg;
    reg [11:0] sensor_reg;

    assign telemetry_ready = !active;

    function [7:0] payload_byte;
        input [2:0] index;
        begin
            case (index)
                3'd0: payload_byte = SOF;
                3'd1: payload_byte = sequence_reg;
                3'd2: payload_byte = event_reg;
                3'd3: payload_byte = {4'd0, sensor_reg[11:8]};
                3'd4: payload_byte = sensor_reg[7:0];
                3'd5: payload_byte = status_reg;
                default: payload_byte = checksum;
            endcase
        end
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            active <= 1'b0;
            awaiting_busy <= 1'b0;
            byte_index <= 3'd0;
            uart_start <= 1'b0;
            uart_data <= 8'd0;
            checksum <= 8'd0;
            sequence_reg <= 8'd0;
            event_reg <= 8'd0;
            sensor_reg <= 12'd0;
            status_reg <= 8'd0;
        end else begin
            uart_start <= 1'b0;
            if (!active && telemetry_valid) begin
                active <= 1'b1;
                byte_index <= 3'd0;
                sequence_reg <= telemetry_sequence;
                event_reg <= telemetry_event;
                sensor_reg <= telemetry_sensor;
                status_reg <= telemetry_status;
                checksum <= SOF ^ telemetry_sequence ^ telemetry_event ^
                            {4'd0, telemetry_sensor[11:8]} ^ telemetry_sensor[7:0] ^ telemetry_status;
            end else if (active && awaiting_busy) begin
                if (uart_busy) begin
                    awaiting_busy <= 1'b0;
                    if (byte_index == 3'd6)
                        active <= 1'b0;
                    else
                        byte_index <= byte_index + 1'b1;
                end
            end else if (active && !uart_busy) begin
                uart_data <= payload_byte(byte_index);
                uart_start <= 1'b1;
                awaiting_busy <= 1'b1;
            end
        end
    end
endmodule
```

## Testbench - tb_telemetry_tx.v

**Path:** `tb\tb_telemetry_tx.v`

```verilog
`timescale 1ns/1ps
module tb_telemetry_tx;
    reg clk=0, reset=1, telemetry_valid=0, uart_busy=0;
    reg [7:0] seq=8'h11, event=8'h22, status=8'h33; reg [11:0] sensor=12'hABC;
    wire telemetry_ready, uart_start; wire [7:0] uart_data;
    reg [7:0] bytes [0:6]; integer count=0;
    sentinel_telemetry_tx dut (.clk(clk),.reset(reset),.telemetry_valid(telemetry_valid),.telemetry_ready(telemetry_ready),.telemetry_sequence(seq),.telemetry_event(event),.telemetry_sensor(sensor),.telemetry_status(status),.uart_busy(uart_busy),.uart_start(uart_start),.uart_data(uart_data));
    always #5 clk=~clk;
    always @(posedge clk) begin
        if (reset) uart_busy <= 0;
        else if (uart_start) begin bytes[count] <= uart_data; count <= count + 1; uart_busy <= 1; end
        else uart_busy <= 0;
    end
    initial begin
        repeat(2) @(posedge clk); reset=0;
        @(negedge clk); telemetry_valid=1; @(negedge clk); telemetry_valid=0;
        wait(count==7); #1;
        if (bytes[0]!=8'hA6 || bytes[1]!=seq || bytes[2]!=event || bytes[3]!={4'd0,sensor[11:8]} || bytes[4]!=sensor[7:0] || bytes[5]!=status || bytes[6]!=(8'hA6^seq^event^{4'd0,sensor[11:8]}^sensor[7:0]^status)) $display("FAIL: telemetry frame");
        else $display("PASS: sentinel_telemetry_tx");
        $finish;
    end
endmodule
```

## Source - esp32_uart.v

**Path:** `esp32\esp32_uart.v`

```verilog
`timescale 1ns/1ps

module esp32_uart #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer BAUD = 115_200
) (
    input  wire       clk,
    input  wire       reset,
    input  wire       esp_rx,
    output wire       esp_tx,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output wire       tx_busy,
    output wire [7:0] rx_data,
    output wire       rx_valid,
    output wire       framing_error
);
    uart_top #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) uart (
        .clk(clk), .reset(reset), .uart_rx_i(esp_rx), .uart_tx_o(esp_tx),
        .tx_start(tx_start), .tx_data(tx_data), .tx_busy(tx_busy),
        .rx_data(rx_data), .rx_valid(rx_valid), .framing_error(framing_error)
    );
endmodule
```

## Source - esp32_packet_parser.v

**Path:** `esp32\esp32_packet_parser.v`

```verilog
`timescale 1ns/1ps

module esp32_packet_parser (
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] rx_data,
    input  wire       rx_valid,
    output reg        message_valid,
    output reg [7:0]  message_type,
    output reg [15:0] message_value,
    output reg        message_error
);
    localparam [7:0] SOF = 8'hE3;
    reg [2:0] byte_count;
    reg [7:0] checksum;

    always @(posedge clk) begin
        if (reset) begin
            byte_count <= 3'd0;
            checksum <= 8'd0;
            message_valid <= 1'b0;
            message_error <= 1'b0;
            message_type <= 8'd0;
            message_value <= 16'd0;
        end else begin
            message_valid <= 1'b0;
            message_error <= 1'b0;
            if (rx_valid) begin
                if (byte_count == 3'd0) begin
                    if (rx_data == SOF) begin
                        byte_count <= 3'd1;
                        checksum <= SOF;
                    end
                end else if (rx_data == SOF) begin
                    byte_count <= 3'd1;
                    checksum <= SOF;
                end else begin
                    case (byte_count)
                        3'd1: begin message_type <= rx_data; checksum <= checksum ^ rx_data; byte_count <= 3'd2; end
                        3'd2: begin message_value[15:8] <= rx_data; checksum <= checksum ^ rx_data; byte_count <= 3'd3; end
                        3'd3: begin message_value[7:0] <= rx_data; checksum <= checksum ^ rx_data; byte_count <= 3'd4; end
                        default: begin
                            if (rx_data == checksum)
                                message_valid <= 1'b1;
                            else
                                message_error <= 1'b1;
                            byte_count <= 3'd0;
                        end
                    endcase
                end
            end
        end
    end
endmodule
```

## Source - esp32_dashboard.v

**Path:** `esp32\esp32_dashboard.v`

```verilog
`timescale 1ns/1ps

module esp32_dashboard (
    input  wire       clk,
    input  wire       reset,
    input  wire       telemetry_valid,
    output wire       telemetry_ready,
    input  wire [7:0] telemetry_sequence,
    input  wire [7:0] telemetry_event,
    input  wire [11:0] telemetry_sensor,
    input  wire [7:0] telemetry_status,
    input  wire       uart_busy,
    output reg        uart_start,
    output reg [7:0]  uart_data
);
    localparam [7:0] SOF = 8'hD3;
    reg active, awaiting_busy;
    reg [2:0] byte_index;
    reg [7:0] checksum, sequence_reg, event_reg, status_reg;
    reg [11:0] sensor_reg;

    assign telemetry_ready = !active;

    function [7:0] frame_byte;
        input [2:0] index;
        begin
            case (index)
                3'd0: frame_byte = SOF;
                3'd1: frame_byte = sequence_reg;
                3'd2: frame_byte = event_reg;
                3'd3: frame_byte = {4'd0, sensor_reg[11:8]};
                3'd4: frame_byte = sensor_reg[7:0];
                3'd5: frame_byte = status_reg;
                default: frame_byte = checksum;
            endcase
        end
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            active <= 1'b0;
            awaiting_busy <= 1'b0;
            byte_index <= 3'd0;
            uart_start <= 1'b0;
            uart_data <= 8'd0;
            checksum <= 8'd0;
            sequence_reg <= 8'd0;
            event_reg <= 8'd0;
            sensor_reg <= 12'd0;
            status_reg <= 8'd0;
        end else begin
            uart_start <= 1'b0;
            if (!active && telemetry_valid) begin
                active <= 1'b1;
                byte_index <= 3'd0;
                sequence_reg <= telemetry_sequence;
                event_reg <= telemetry_event;
                sensor_reg <= telemetry_sensor;
                status_reg <= telemetry_status;
                checksum <= SOF ^ telemetry_sequence ^ telemetry_event ^
                            {4'd0, telemetry_sensor[11:8]} ^ telemetry_sensor[7:0] ^ telemetry_status;
            end else if (active && awaiting_busy) begin
                if (uart_busy) begin
                    awaiting_busy <= 1'b0;
                    if (byte_index == 3'd6)
                        active <= 1'b0;
                    else
                        byte_index <= byte_index + 1'b1;
                end
            end else if (active && !uart_busy) begin
                uart_data <= frame_byte(byte_index);
                uart_start <= 1'b1;
                awaiting_busy <= 1'b1;
            end
        end
    end
endmodule
```

## Source - spi_master.v

**Path:** `adc\spi_master.v`

```verilog
`timescale 1ns/1ps

module spi_master #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer SPI_HZ = 1_000_000,
    parameter integer DATA_WIDTH = 24
) (
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  start,
    input  wire [DATA_WIDTH-1:0] tx_data,
    output reg  [DATA_WIDTH-1:0] rx_data,
    output reg                   busy,
    output reg                   done,
    output reg                   sck,
    output reg                   mosi,
    input  wire                  miso,
    output reg                   cs_n
);
    localparam integer HALF_DIV = (CLK_HZ / (SPI_HZ * 2) > 0) ?
                                  (CLK_HZ / (SPI_HZ * 2)) : 1;
    localparam integer DIV_W = (HALF_DIV <= 1) ? 1 : $clog2(HALF_DIV);
    localparam integer BIT_W = (DATA_WIDTH <= 1) ? 1 : $clog2(DATA_WIDTH);
    reg [DIV_W-1:0] divider;
    reg [BIT_W-1:0] bit_index;
    reg [DATA_WIDTH-1:0] shift_in;

    always @(posedge clk) begin
        if (reset) begin
            rx_data <= {DATA_WIDTH{1'b0}};
            busy <= 1'b0;
            done <= 1'b0;
            sck <= 1'b0;
            mosi <= 1'b0;
            cs_n <= 1'b1;
            divider <= {DIV_W{1'b0}};
            bit_index <= {BIT_W{1'b0}};
            shift_in <= {DATA_WIDTH{1'b0}};
        end else begin
            done <= 1'b0;
            if (!busy) begin
                sck <= 1'b0;
                cs_n <= 1'b1;
                if (start) begin
                    busy <= 1'b1;
                    cs_n <= 1'b0;
                    divider <= {DIV_W{1'b0}};
                    bit_index <= DATA_WIDTH - 1;
                    mosi <= tx_data[DATA_WIDTH-1];
                    shift_in <= {DATA_WIDTH{1'b0}};
                end
            end else if (divider == HALF_DIV - 1) begin
                divider <= {DIV_W{1'b0}};
                if (!sck) begin
                    sck <= 1'b1;
                    shift_in <= {shift_in[DATA_WIDTH-2:0], miso};
                end else begin
                    sck <= 1'b0;
                    if (bit_index == 0) begin
                        busy <= 1'b0;
                        cs_n <= 1'b1;
                        rx_data <= shift_in;
                        done <= 1'b1;
                    end else begin
                        bit_index <= bit_index - 1'b1;
                        mosi <= tx_data[bit_index-1'b1];
                    end
                end
            end else
                divider <= divider + 1'b1;
        end
    end
endmodule
```

## Testbench - tb_spi_master.v

**Path:** `tb\tb_spi_master.v`

```verilog
`timescale 1ns/1ps
module tb_spi_master;
    reg clk=0, reset=1, start=0, miso=0; reg [7:0] tx_data=8'hA5;
    wire [7:0] rx_data; wire busy, done, sck, mosi, cs_n;
    spi_master #(.CLK_HZ(100),.SPI_HZ(10),.DATA_WIDTH(8)) dut (.clk(clk),.reset(reset),.start(start),.tx_data(tx_data),.rx_data(rx_data),.busy(busy),.done(done),.sck(sck),.mosi(mosi),.miso(miso),.cs_n(cs_n));
    always #5 clk=~clk;
    initial begin
        repeat(2) @(posedge clk); reset=0;
        @(negedge clk); start=1; @(negedge clk); start=0;
        wait(done); #1;
        if (rx_data!==8'h00 || cs_n!==1'b1 || busy) $display("FAIL: spi_master"); else $display("PASS: spi_master");
        $finish;
    end
endmodule
```

## Source - mcp3202_sampler.v

**Path:** `adc\mcp3202_sampler.v`

```verilog
`timescale 1ns/1ps

module mcp3202_sampler #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer SPI_HZ = 1_000_000,
    parameter integer SAMPLE_HZ = 20
) (
    input  wire       clk,
    input  wire       reset,
    input  wire       force_sample,
    input  wire       channel,
    output reg [11:0] sample_value,
    output reg        sample_valid,
    output wire       busy,
    output wire       spi_sck,
    output wire       spi_mosi,
    input  wire       spi_miso,
    output wire       adc_cs_n
);
    localparam integer SAMPLE_DIV = (CLK_HZ / SAMPLE_HZ > 0) ? (CLK_HZ / SAMPLE_HZ) : 1;
    localparam integer COUNT_W = (SAMPLE_DIV <= 1) ? 1 : $clog2(SAMPLE_DIV);
    reg [COUNT_W-1:0] sample_count;
    reg start;
    reg [23:0] command_word;
    wire [23:0] received_word;
    wire spi_done;

    spi_master #(.CLK_HZ(CLK_HZ), .SPI_HZ(SPI_HZ), .DATA_WIDTH(24)) spi (
        .clk(clk), .reset(reset), .start(start), .tx_data(command_word),
        .rx_data(received_word), .busy(busy), .done(spi_done), .sck(spi_sck),
        .mosi(spi_mosi), .miso(spi_miso), .cs_n(adc_cs_n)
    );

    always @(posedge clk) begin
        if (reset) begin
            sample_count <= {COUNT_W{1'b0}};
            start <= 1'b0;
            command_word <= 24'd0;
            sample_value <= 12'd0;
            sample_valid <= 1'b0;
        end else begin
            start <= 1'b0;
            sample_valid <= 1'b0;
            if (spi_done) begin
                sample_value <= received_word[11:0];
                sample_valid <= 1'b1;
            end
            if (!busy) begin
                if (force_sample || sample_count == SAMPLE_DIV - 1) begin
                    sample_count <= {COUNT_W{1'b0}};
                    // MCP3202 command: start, single-ended, channel, MSB-first.
                    command_word <= channel ? 24'b00000111_00000000_00000000 :
                                              24'b00000110_00000000_00000000;
                    start <= 1'b1;
                end else
                    sample_count <= sample_count + 1'b1;
            end
        end
    end
endmodule
```

## Testbench - tb_mcp3202_sampler.v

**Path:** `tb\tb_mcp3202_sampler.v`

```verilog
`timescale 1ns/1ps
module tb_mcp3202_sampler;
    reg clk=0, reset=1, force_sample=0, channel=0, miso=0;
    wire [11:0] value; wire valid, busy, sck, mosi, cs_n;
    mcp3202_sampler #(.CLK_HZ(100),.SPI_HZ(10),.SAMPLE_HZ(1)) dut (.clk(clk),.reset(reset),.force_sample(force_sample),.channel(channel),.sample_value(value),.sample_valid(valid),.busy(busy),.spi_sck(sck),.spi_mosi(mosi),.spi_miso(miso),.adc_cs_n(cs_n));
    always #5 clk=~clk;
    initial begin
        repeat(2) @(posedge clk); reset=0;
        @(negedge clk); force_sample=1; @(negedge clk); force_sample=0;
        wait(valid); #1;
        if (value!==12'h000) $display("FAIL: mcp3202 sampler"); else $display("PASS: mcp3202_sampler");
        $finish;
    end
endmodule
```

## Source - lcd_driver.v

**Path:** `lcd\lcd_driver.v`

```verilog
`timescale 1ns/1ps

module lcd_driver #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer SETUP_NS = 100,
    parameter integer ENABLE_NS = 500,
    parameter integer NORMAL_US = 50,
    parameter integer CLEAR_US = 2_000
) (
    input  wire       clk,
    input  wire       reset,
    input  wire       write_en,
    input  wire       write_rs,
    input  wire [7:0] write_data,
    output wire       ready,
    output reg        lcd_rs,
    output wire       lcd_rw,
    output reg        lcd_en,
    output reg [7:0]  lcd_d
);
    localparam integer SETUP_CYCLES = (((CLK_HZ / 1_000_000) * SETUP_NS) / 1000 > 0) ?
                                      (((CLK_HZ / 1_000_000) * SETUP_NS) / 1000) : 1;
    localparam integer ENABLE_CYCLES = (((CLK_HZ / 1_000_000) * ENABLE_NS) / 1000 > 0) ?
                                       (((CLK_HZ / 1_000_000) * ENABLE_NS) / 1000) : 1;
    localparam integer NORMAL_CYCLES = (CLK_HZ / 1_000_000) * NORMAL_US;
    localparam integer CLEAR_CYCLES = (CLK_HZ / 1_000_000) * CLEAR_US;
    localparam integer MAX_CYCLES = (CLEAR_CYCLES > NORMAL_CYCLES) ? CLEAR_CYCLES : NORMAL_CYCLES;
    localparam integer COUNT_W = (MAX_CYCLES <= 1) ? 1 : $clog2(MAX_CYCLES + 1);
    localparam [2:0] IDLE = 3'd0, SETUP = 3'd1, PULSE = 3'd2, HOLD = 3'd3;
    reg [2:0] state;
    reg [COUNT_W-1:0] count, wait_cycles;

    assign ready = (state == IDLE);
    assign lcd_rw = 1'b0;

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            count <= 0;
            wait_cycles <= 0;
            lcd_rs <= 1'b0;
            lcd_en <= 1'b0;
            lcd_d <= 8'd0;
        end else begin
            case (state)
                IDLE: if (write_en) begin
                    lcd_rs <= write_rs;
                    lcd_d <= write_data;
                    lcd_en <= 1'b0;
                    count <= 0;
                    wait_cycles <= (!write_rs && (write_data == 8'h01 || write_data == 8'h02)) ? CLEAR_CYCLES : NORMAL_CYCLES;
                    state <= SETUP;
                end
                SETUP: if (count == SETUP_CYCLES - 1) begin
                    count <= 0;
                    lcd_en <= 1'b1;
                    state <= PULSE;
                end else count <= count + 1'b1;
                PULSE: if (count == ENABLE_CYCLES - 1) begin
                    count <= 0;
                    lcd_en <= 1'b0;
                    state <= HOLD;
                end else count <= count + 1'b1;
                default: if (count == wait_cycles - 1) begin
                    count <= 0;
                    state <= IDLE;
                end else count <= count + 1'b1;
            endcase
        end
    end
endmodule
```

## Testbench - tb_lcd_driver.v

**Path:** `tb\tb_lcd_driver.v`

```verilog
`timescale 1ns/1ps
module tb_lcd_driver;
    reg clk=0, reset=1, write_en=0, write_rs=0; reg [7:0] write_data=0;
    wire ready, rs, rw, en; wire [7:0] data;
    lcd_driver #(.CLK_HZ(1_000_000)) dut (.clk(clk),.reset(reset),.write_en(write_en),.write_rs(write_rs),.write_data(write_data),.ready(ready),.lcd_rs(rs),.lcd_rw(rw),.lcd_en(en),.lcd_d(data));
    always #5 clk=~clk;
    initial begin
        repeat(2) @(posedge clk); reset=0;
        @(negedge clk); write_rs=1; write_data="A"; write_en=1; @(negedge clk); write_en=0;
        wait(ready); #1;
        if (data!="A" || rs!=1 || rw!=0) $display("FAIL: lcd driver"); else $display("PASS: lcd_driver");
        $finish;
    end
endmodule
```

## Source - lcd_controller.v

**Path:** `lcd\lcd_controller.v`

```verilog
`timescale 1ns/1ps

module lcd_controller (
    input  wire         clk,
    input  wire         reset,
    input  wire         refresh,
    input  wire [127:0] line1,
    input  wire [127:0] line2,
    output reg          driver_write,
    output reg          driver_rs,
    output reg [7:0]    driver_data,
    input  wire         driver_ready
);
    localparam [2:0] INIT = 3'd0, WAIT_REFRESH = 3'd1, LINE1_ADDR = 3'd2,
                     LINE1_DATA = 3'd3, LINE2_ADDR = 3'd4, LINE2_DATA = 3'd5;
    reg [2:0] state;
    reg [2:0] init_index;
    reg [4:0] char_index;
    reg [127:0] line1_reg, line2_reg;

    function [7:0] character_at;
        input [127:0] text;
        input [4:0] position;
        begin
            character_at = text >> (8 * (15 - position));
        end
    endfunction

    function [7:0] init_byte;
        input [2:0] index;
        begin
            case (index)
                3'd0: init_byte = 8'h38;
                3'd1: init_byte = 8'h0C;
                3'd2: init_byte = 8'h06;
                default: init_byte = 8'h01;
            endcase
        end
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            state <= INIT;
            init_index <= 3'd0;
            char_index <= 5'd0;
            driver_write <= 1'b0;
            driver_rs <= 1'b0;
            driver_data <= 8'd0;
            line1_reg <= {16{8'h20}};
            line2_reg <= {16{8'h20}};
        end else begin
            driver_write <= 1'b0;
            if (driver_ready) begin
                case (state)
                    INIT: begin
                        driver_write <= 1'b1;
                        driver_rs <= 1'b0;
                        driver_data <= init_byte(init_index);
                        if (init_index == 3'd3)
                            state <= WAIT_REFRESH;
                        else
                            init_index <= init_index + 1'b1;
                    end
                    WAIT_REFRESH: if (refresh) begin
                        line1_reg <= line1;
                        line2_reg <= line2;
                        state <= LINE1_ADDR;
                    end
                    LINE1_ADDR: begin
                        driver_write <= 1'b1;
                        driver_rs <= 1'b0;
                        driver_data <= 8'h80;
                        char_index <= 5'd0;
                        state <= LINE1_DATA;
                    end
                    LINE1_DATA: begin
                        driver_write <= 1'b1;
                        driver_rs <= 1'b1;
                        driver_data <= character_at(line1_reg, char_index);
                        if (char_index == 5'd15)
                            state <= LINE2_ADDR;
                        else
                            char_index <= char_index + 1'b1;
                    end
                    LINE2_ADDR: begin
                        driver_write <= 1'b1;
                        driver_rs <= 1'b0;
                        driver_data <= 8'hC0;
                        char_index <= 5'd0;
                        state <= LINE2_DATA;
                    end
                    default: begin
                        driver_write <= 1'b1;
                        driver_rs <= 1'b1;
                        driver_data <= character_at(line2_reg, char_index);
                        if (char_index == 5'd15)
                            state <= WAIT_REFRESH;
                        else
                            char_index <= char_index + 1'b1;
                    end
                endcase
            end
        end
    end
endmodule
```

## Source - keypad_scan.v

**Path:** `keypad\keypad_scan.v`

```verilog
`timescale 1ns/1ps

module keypad_scan #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer SCAN_HZ = 1_000,
    parameter integer DEBOUNCE_SCANS = 4
) (
    input  wire       clk,
    input  wire       reset,
    output reg [3:0]  row_n,
    input  wire [3:0] col_n,
    output reg        key_valid,
    output reg [3:0]  key_code
);
    localparam integer SCAN_DIV = (CLK_HZ / SCAN_HZ > 0) ? (CLK_HZ / SCAN_HZ) : 1;
    localparam integer COUNT_W = (SCAN_DIV <= 1) ? 1 : $clog2(SCAN_DIV);
    localparam integer DEBOUNCE_W = (DEBOUNCE_SCANS <= 1) ? 1 : $clog2(DEBOUNCE_SCANS + 1);
    reg [COUNT_W-1:0] scan_count;
    reg [1:0] row_index;
    reg [3:0] candidate;
    reg [1:0] candidate_row;
    reg [DEBOUNCE_W-1:0] stable_count;
    reg key_latched;

    function [3:0] make_code;
        input [1:0] row;
        input [1:0] col;
        begin
            // Physical order: 1 2 3 A / 4 5 6 B / 7 8 9 C / E 0 F D.
            case ({row, col})
                4'h0: make_code = 4'h1; 4'h1: make_code = 4'h2;
                4'h2: make_code = 4'h3; 4'h3: make_code = 4'hA;
                4'h4: make_code = 4'h4; 4'h5: make_code = 4'h5;
                4'h6: make_code = 4'h6; 4'h7: make_code = 4'hB;
                4'h8: make_code = 4'h7; 4'h9: make_code = 4'h8;
                4'hA: make_code = 4'h9; 4'hB: make_code = 4'hC;
                4'hC: make_code = 4'hE; 4'hD: make_code = 4'h0;
                4'hE: make_code = 4'hF; default: make_code = 4'hD;
            endcase
        end
    endfunction

    function [1:0] active_column;
        input [3:0] columns;
        begin
            casex (columns)
                4'bxxx0: active_column = 2'd0;
                4'bxx01: active_column = 2'd1;
                4'bx011: active_column = 2'd2;
                default: active_column = 2'd3;
            endcase
        end
    endfunction

    always @(*) begin
        case (row_index)
            2'd0: row_n = 4'b1110;
            2'd1: row_n = 4'b1101;
            2'd2: row_n = 4'b1011;
            default: row_n = 4'b0111;
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            scan_count <= 0;
            row_index <= 0;
            candidate <= 0;
            candidate_row <= 0;
            stable_count <= 0;
            key_latched <= 1'b0;
            key_valid <= 1'b0;
            key_code <= 0;
        end else begin
            key_valid <= 1'b0;
            if (scan_count == SCAN_DIV - 1) begin
                scan_count <= 0;
                row_index <= row_index + 1'b1;
                if (col_n == 4'b1111) begin
                    if (row_index == candidate_row) begin
                        stable_count <= 0;
                        key_latched <= 1'b0;
                    end
                end else if (candidate_row == row_index &&
                             candidate == make_code(row_index, active_column(col_n))) begin
                    if (stable_count < DEBOUNCE_SCANS)
                        stable_count <= stable_count + 1'b1;
                    if (stable_count == DEBOUNCE_SCANS - 1 && !key_latched) begin
                        key_code <= candidate;
                        key_valid <= 1'b1;
                        key_latched <= 1'b1;
                    end
                end else begin
                    candidate <= make_code(row_index, active_column(col_n));
                    candidate_row <= row_index;
                    stable_count <= 1;
                end
            end else
                scan_count <= scan_count + 1'b1;
        end
    end
endmodule
```

## Source - keypad_decoder.v

**Path:** `keypad\keypad_decoder.v`

```verilog
`timescale 1ns/1ps

module keypad_decoder (
    input  wire       clk,
    input  wire       reset,
    input  wire       key_valid,
    input  wire [3:0] key_code,
    output reg        ascii_valid,
    output reg [7:0]  ascii
);
    function [7:0] code_to_ascii;
        input [3:0] code;
        begin
            if (code < 10)
                code_to_ascii = 8'h30 + code;
            else
                code_to_ascii = 8'h41 + (code - 10);
        end
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            ascii_valid <= 1'b0;
            ascii <= 8'h00;
        end else begin
            ascii_valid <= key_valid;
            if (key_valid)
                ascii <= code_to_ascii(key_code);
        end
    end
endmodule
```

## Testbench - tb_keypad.v

**Path:** `tb\tb_keypad.v`

```verilog
`timescale 1ns/1ps
module tb_keypad;
    reg clk=0, reset=1; wire [3:0] row_n; reg [3:0] col_n; wire valid; wire [3:0] code;
    keypad_scan #(.CLK_HZ(1000),.SCAN_HZ(100),.DEBOUNCE_SCANS(2)) dut (.clk(clk),.reset(reset),.row_n(row_n),.col_n(col_n),.key_valid(valid),.key_code(code));
    always #5 clk=~clk;
    always @(*) if (row_n==4'b1110) col_n=4'b1110; else col_n=4'b1111;
    initial begin
        repeat(2) @(posedge clk); reset=0;
        wait(valid); #1;
        if (code!==4'h1) $display("FAIL: keypad code %h",code); else $display("PASS: keypad_scan");
        $finish;
    end
endmodule
```

## Source - led_controller.v

**Path:** `display\led_controller.v`

```verilog
`timescale 1ns/1ps

module led_controller #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer BLINK_HZ = 2
) (
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] status,
    input  wire        alarm,
    output reg  [15:0] led
);
    localparam integer BLINK_DIV = (CLK_HZ / (BLINK_HZ * 2) > 0) ?
                                   (CLK_HZ / (BLINK_HZ * 2)) : 1;
    localparam integer COUNT_W = (BLINK_DIV <= 1) ? 1 : $clog2(BLINK_DIV);
    reg [COUNT_W-1:0] count;
    reg blink;

    always @(posedge clk) begin
        if (reset) begin
            count <= 0;
            blink <= 1'b0;
            led <= 16'd0;
        end else begin
            if (count == BLINK_DIV - 1) begin
                count <= 0;
                blink <= ~blink;
            end else
                count <= count + 1'b1;
            led <= status;
            if (alarm)
                led[15] <= blink;
        end
    end
endmodule
```

## Source - buzzer_controller.v

**Path:** `display\buzzer_controller.v`

```verilog
`timescale 1ns/1ps

module buzzer_controller #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer TONE_HZ = 2_000
) (
    input  wire clk,
    input  wire reset,
    input  wire alarm,
    input  wire enable,
    output reg  buzzer
);
    localparam integer HALF_DIV = (CLK_HZ / (TONE_HZ * 2) > 0) ?
                                  (CLK_HZ / (TONE_HZ * 2)) : 1;
    localparam integer COUNT_W = (HALF_DIV <= 1) ? 1 : $clog2(HALF_DIV);
    reg [COUNT_W-1:0] count;

    always @(posedge clk) begin
        if (reset || !enable || !alarm) begin
            count <= 0;
            buzzer <= 1'b0;
        end else if (count == HALF_DIV - 1) begin
            count <= 0;
            buzzer <= ~buzzer;
        end else
            count <= count + 1'b1;
    end
endmodule
```

## Source - sevenseg_driver.v

**Path:** `display\sevenseg_driver.v`

```verilog
`timescale 1ns/1ps

module sevenseg_driver #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer SPI_HZ = 500_000,
    parameter integer REFRESH_HZ = 100
) (
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] value,
    input  wire        display_enable,
    output reg         seg_din,
    output reg         seg_clk,
    output reg         seg_load
);
    localparam integer HALF_DIV = (CLK_HZ / (SPI_HZ * 2) > 0) ? (CLK_HZ / (SPI_HZ * 2)) : 1;
    localparam integer REFRESH_DIV = (CLK_HZ / REFRESH_HZ > 0) ? (CLK_HZ / REFRESH_HZ) : 1;
    localparam integer DIV_W = (HALF_DIV <= 1) ? 1 : $clog2(HALF_DIV);
    localparam integer REFRESH_W = (REFRESH_DIV <= 1) ? 1 : $clog2(REFRESH_DIV);
    localparam [2:0] IDLE = 3'd0, LOAD = 3'd1, HIGH = 3'd2, LOW = 3'd3, LATCH = 3'd4;
    reg [2:0] state;
    reg [DIV_W-1:0] div_count;
    reg [REFRESH_W-1:0] refresh_count;
    reg [3:0] bit_index;
    reg [2:0] word_index;
    reg [15:0] word_reg;
    reg [15:0] value_reg;

    function [15:0] transfer_word;
        input [2:0] index;
        input [15:0] number;
        begin
            case (index)
                3'd0: transfer_word = 16'h0F00; // display test off
                3'd1: transfer_word = {8'h0C, display_enable ? 8'h01 : 8'h00};
                3'd2: transfer_word = 16'h0B03; // scan four digits
                3'd3: transfer_word = 16'h09FF; // BCD decode
                3'd4: transfer_word = {8'h01, 4'h0, number[3:0]};
                3'd5: transfer_word = {8'h02, 4'h0, number[7:4]};
                3'd6: transfer_word = {8'h03, 4'h0, number[11:8]};
                default: transfer_word = {8'h04, 4'h0, number[15:12]};
            endcase
        end
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            div_count <= 0;
            refresh_count <= 0;
            bit_index <= 0;
            word_index <= 0;
            word_reg <= 0;
            value_reg <= 0;
            seg_din <= 1'b0;
            seg_clk <= 1'b0;
            seg_load <= 1'b1;
        end else begin
            if (refresh_count == REFRESH_DIV - 1)
                refresh_count <= 0;
            else
                refresh_count <= refresh_count + 1'b1;
            if (div_count == HALF_DIV - 1) begin
                div_count <= 0;
                case (state)
                    IDLE: if (refresh_count == REFRESH_DIV - 1) begin
                        value_reg <= value;
                        word_index <= 0;
                        state <= LOAD;
                    end
                    LOAD: begin
                        word_reg <= transfer_word(word_index, value_reg);
                        bit_index <= 4'd15;
                        seg_din <= transfer_word(word_index, value_reg) >> 15;
                        seg_load <= 1'b0;
                        seg_clk <= 1'b0;
                        state <= HIGH;
                    end
                    HIGH: begin seg_clk <= 1'b1; state <= LOW; end
                    LOW: begin
                        seg_clk <= 1'b0;
                        if (bit_index == 0)
                            state <= LATCH;
                        else begin
                            bit_index <= bit_index - 1'b1;
                            seg_din <= word_reg[bit_index-1'b1];
                            state <= HIGH;
                        end
                    end
                    default: begin
                        seg_load <= 1'b1;
                        if (word_index == 3'd7)
                            state <= IDLE;
                        else begin
                            word_index <= word_index + 1'b1;
                            state <= LOAD;
                        end
                    end
                endcase
            end else
                div_count <= div_count + 1'b1;
        end
    end
endmodule
```

## Source - spi_sd_master.v

**Path:** `sdcard\spi_sd_master.v`

```verilog
`timescale 1ns/1ps

// Byte-oriented SPI mode-0 engine.  A client keeps chip select asserted by
// setting hold_cs on each transfer except the final byte of a transaction.
module spi_sd_master #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer SPI_HZ = 400_000
) (
    input  wire       clk,
    input  wire       reset,
    input  wire       xfer_start,
    input  wire [7:0] xfer_data,
    input  wire       hold_cs,
    input  wire       force_cs_high,
    output reg [7:0]  xfer_rx,
    output reg        xfer_busy,
    output reg        xfer_done,
    output reg        sd_clk,
    output reg        sd_cmd,
    input  wire       sd_d0,
    output reg        sd_cs_n
);
    localparam integer HALF_DIV = (CLK_HZ / (SPI_HZ * 2) > 0) ? (CLK_HZ / (SPI_HZ * 2)) : 1;
    localparam integer DIV_W = (HALF_DIV <= 1) ? 1 : $clog2(HALF_DIV);
    reg [DIV_W-1:0] div_count;
    reg [2:0] bit_index;
    reg [7:0] shift_in;
    reg release_cs;

    always @(posedge clk) begin
        if (reset) begin
            xfer_rx <= 8'hFF;
            xfer_busy <= 1'b0;
            xfer_done <= 1'b0;
            sd_clk <= 1'b0;
            sd_cmd <= 1'b1;
            sd_cs_n <= 1'b1;
            div_count <= 0;
            bit_index <= 0;
            shift_in <= 0;
            release_cs <= 1'b1;
        end else begin
            xfer_done <= 1'b0;
            if (!xfer_busy) begin
                sd_clk <= 1'b0;
                if (xfer_start) begin
                    xfer_busy <= 1'b1;
                    sd_cs_n <= force_cs_high;
                    sd_cmd <= xfer_data[7];
                    bit_index <= 3'd7;
                    shift_in <= 8'd0;
                    div_count <= 0;
                    release_cs <= !hold_cs | force_cs_high;
                end
            end else if (div_count == HALF_DIV - 1) begin
                div_count <= 0;
                if (!sd_clk) begin
                    sd_clk <= 1'b1;
                    shift_in <= {shift_in[6:0], sd_d0};
                end else begin
                    sd_clk <= 1'b0;
                    if (bit_index == 0) begin
                        xfer_busy <= 1'b0;
                        xfer_done <= 1'b1;
                        xfer_rx <= shift_in;
                        sd_cs_n <= release_cs;
                        sd_cmd <= 1'b1;
                    end else begin
                        bit_index <= bit_index - 1'b1;
                        sd_cmd <= xfer_data[bit_index-1'b1];
                    end
                end
            end else
                div_count <= div_count + 1'b1;
        end
    end
endmodule
```

## Source - sd_card_init.v

**Path:** `sdcard\sd_card_init.v`

```verilog
`timescale 1ns/1ps

// SDHC initialization over the byte-oriented SPI engine.  The card must be
// powered and inserted before reset is released.  Supports CMD0, CMD8,
// CMD55/ACMD41 with HCS, and CMD58.  SDSC byte-addressed cards are rejected.
module sd_card_init #(
    parameter integer ACMD41_RETRIES = 1024
) (
    input  wire       clk,
    input  wire       reset,
    output reg        init_busy,
    output reg        init_done,
    output reg        init_failed,
    output reg        xfer_start,
    output reg [7:0]  xfer_data,
    output reg        xfer_hold_cs,
    output reg        xfer_force_cs_high,
    input  wire [7:0] xfer_rx,
    input  wire       xfer_busy,
    input  wire       xfer_done
);
    localparam [2:0] PRECLOCK = 3'd0, COMMAND = 3'd1, RESPONSE = 3'd2,
                     EXT_RESPONSE = 3'd3, RELEASE = 3'd4, COMPLETE = 3'd5;
    localparam [2:0] CMD0 = 3'd0, CMD8 = 3'd1, CMD55 = 3'd2,
                     ACMD41 = 3'd3, CMD58 = 3'd4;
    reg [2:0] state, command_phase, next_phase;
    reg issued;
    reg [3:0] byte_index;
    reg [3:0] preclock_count;
    reg [7:0] response_tries;
    reg [1:0] extended_index;
    reg [15:0] acmd41_tries;
    reg cmd8_echo_ok;
    reg ocr_ccs;

    function [7:0] command_byte;
        input [2:0] phase;
        input [3:0] index;
        begin
            case (phase)
                CMD0: case (index)
                    0: command_byte = 8'h40; 1,2,3,4: command_byte = 8'h00; default: command_byte = 8'h95;
                endcase
                CMD8: case (index)
                    0: command_byte = 8'h48; 1,2: command_byte = 8'h00;
                    3: command_byte = 8'h01; 4: command_byte = 8'hAA; default: command_byte = 8'h87;
                endcase
                CMD55: case (index)
                    0: command_byte = 8'h77; 1,2,3,4: command_byte = 8'h00; default: command_byte = 8'h65;
                endcase
                ACMD41: case (index)
                    0: command_byte = 8'h69; 1: command_byte = 8'h40; 2,3,4: command_byte = 8'h00; default: command_byte = 8'h77;
                endcase
                default: case (index)
                    0: command_byte = 8'h7A; 1,2,3,4: command_byte = 8'h00; default: command_byte = 8'hFD;
                endcase
            endcase
        end
    endfunction

    task fail_init;
        begin
            init_busy <= 1'b0;
            init_failed <= 1'b1;
            state <= COMPLETE;
        end
    endtask

    always @(posedge clk) begin
        if (reset) begin
            state <= PRECLOCK;
            command_phase <= CMD0;
            next_phase <= CMD0;
            issued <= 1'b0;
            byte_index <= 0;
            preclock_count <= 0;
            response_tries <= 0;
            extended_index <= 0;
            acmd41_tries <= 0;
            cmd8_echo_ok <= 1'b0;
            ocr_ccs <= 1'b0;
            init_busy <= 1'b1;
            init_done <= 1'b0;
            init_failed <= 1'b0;
            xfer_start <= 1'b0;
            xfer_data <= 8'hFF;
            xfer_hold_cs <= 1'b0;
            xfer_force_cs_high <= 1'b1;
        end else begin
            xfer_start <= 1'b0;
            case (state)
                PRECLOCK: if (!issued && !xfer_busy) begin
                    xfer_data <= 8'hFF;
                    xfer_hold_cs <= 1'b0;
                    xfer_force_cs_high <= 1'b1;
                    xfer_start <= 1'b1;
                    issued <= 1'b1;
                end else if (issued && xfer_done) begin
                    issued <= 1'b0;
                    if (preclock_count == 4'd9) begin
                        command_phase <= CMD0;
                        byte_index <= 0;
                        state <= COMMAND;
                    end else
                        preclock_count <= preclock_count + 1'b1;
                end
                COMMAND: if (!issued && !xfer_busy) begin
                    xfer_data <= command_byte(command_phase, byte_index);
                    xfer_hold_cs <= 1'b1;
                    xfer_force_cs_high <= 1'b0;
                    xfer_start <= 1'b1;
                    issued <= 1'b1;
                end else if (issued && xfer_done) begin
                    issued <= 1'b0;
                    if (byte_index == 4'd5) begin
                        response_tries <= 0;
                        state <= RESPONSE;
                    end else
                        byte_index <= byte_index + 1'b1;
                end
                RESPONSE: if (!issued && !xfer_busy) begin
                    xfer_data <= 8'hFF;
                    xfer_hold_cs <= 1'b1;
                    xfer_force_cs_high <= 1'b0;
                    xfer_start <= 1'b1;
                    issued <= 1'b1;
                end else if (issued && xfer_done) begin
                    issued <= 1'b0;
                    if (xfer_rx == 8'hFF) begin
                        if (response_tries == 8'hFF)
                            fail_init;
                        else
                            response_tries <= response_tries + 1'b1;
                    end else if (command_phase == CMD0 && xfer_rx == 8'h01) begin
                        next_phase <= CMD8;
                        state <= RELEASE;
                    end else if (command_phase == CMD8 && xfer_rx == 8'h01) begin
                        extended_index <= 0;
                        cmd8_echo_ok <= 1'b0;
                        state <= EXT_RESPONSE;
                    end else if (command_phase == CMD55 && (xfer_rx == 8'h00 || xfer_rx == 8'h01)) begin
                        next_phase <= ACMD41;
                        state <= RELEASE;
                    end else if (command_phase == ACMD41 && xfer_rx == 8'h00) begin
                        next_phase <= CMD58;
                        state <= RELEASE;
                    end else if (command_phase == ACMD41 && xfer_rx == 8'h01) begin
                        if (acmd41_tries == ACMD41_RETRIES - 1)
                            fail_init;
                        else begin
                            acmd41_tries <= acmd41_tries + 1'b1;
                            next_phase <= CMD55;
                            state <= RELEASE;
                        end
                    end else if (command_phase == CMD58 && xfer_rx == 8'h00) begin
                        extended_index <= 0;
                        state <= EXT_RESPONSE;
                    end else
                        fail_init;
                end
                EXT_RESPONSE: if (!issued && !xfer_busy) begin
                    xfer_data <= 8'hFF;
                    xfer_hold_cs <= (extended_index != 2'd3);
                    xfer_force_cs_high <= 1'b0;
                    xfer_start <= 1'b1;
                    issued <= 1'b1;
                end else if (issued && xfer_done) begin
                    issued <= 1'b0;
                    if (command_phase == CMD8 && extended_index == 2'd3)
                        cmd8_echo_ok <= (xfer_rx == 8'hAA);
                    if (command_phase == CMD58 && extended_index == 2'd0)
                        ocr_ccs <= xfer_rx[6];
                    if (extended_index == 2'd3) begin
                        if (command_phase == CMD8) begin
                            if (xfer_rx == 8'hAA) begin
                                command_phase <= CMD55;
                                byte_index <= 0;
                                state <= COMMAND;
                            end else
                                fail_init;
                        end else if (ocr_ccs) begin
                            init_busy <= 1'b0;
                            init_done <= 1'b1;
                            state <= COMPLETE;
                        end else
                            fail_init;
                    end else
                        extended_index <= extended_index + 1'b1;
                end
                RELEASE: if (!issued && !xfer_busy) begin
                    xfer_data <= 8'hFF;
                    xfer_hold_cs <= 1'b0;
                    xfer_force_cs_high <= 1'b0;
                    xfer_start <= 1'b1;
                    issued <= 1'b1;
                end else if (issued && xfer_done) begin
                    issued <= 1'b0;
                    command_phase <= next_phase;
                    byte_index <= 0;
                    state <= COMMAND;
                end
                default: begin
                    init_busy <= 1'b0;
                    xfer_force_cs_high <= 1'b0;
                end
            endcase
        end
    end
endmodule
```

## Testbench - tb_sd_card_init.v

**Path:** `tb\tb_sd_card_init.v`

```verilog
`timescale 1ns/1ps
module tb_sd_card_init;
    reg clk=0, reset=1;
    wire init_busy, init_done, init_failed, xfer_start, xfer_hold_cs, xfer_force_cs_high;
    wire [7:0] xfer_data;
    reg [7:0] xfer_rx=8'hFF;
    reg xfer_busy=0, xfer_done=0;
    reg [7:0] next_rx=8'hFF;
    reg [2:0] current_command=0;
    reg [2:0] command_bytes_left=0;
    reg response_pending=0;
    reg [2:0] extended_bytes_left=0;

    sd_card_init dut (.clk(clk),.reset(reset),.init_busy(init_busy),.init_done(init_done),.init_failed(init_failed),.xfer_start(xfer_start),.xfer_data(xfer_data),.xfer_hold_cs(xfer_hold_cs),.xfer_force_cs_high(xfer_force_cs_high),.xfer_rx(xfer_rx),.xfer_busy(xfer_busy),.xfer_done(xfer_done));
    always #5 clk=~clk;

    // Minimal SPI-card responder: only the expected initialization replies.
    always @(posedge clk) begin
        xfer_done <= 0;
        if (xfer_start) begin
            xfer_busy <= 1;
            next_rx <= 8'hFF;
            if (!xfer_force_cs_high) begin
                if (command_bytes_left != 0) begin
                    if (command_bytes_left == 1) begin
                        command_bytes_left <= 0;
                        response_pending <= 1;
                    end else
                        command_bytes_left <= command_bytes_left - 1;
                end else if (response_pending) begin
                    response_pending <= 0;
                    case (current_command)
                        0, 1, 2: next_rx <= 8'h01;
                        3, 4: next_rx <= 8'h00;
                    endcase
                    if (current_command == 1 || current_command == 4)
                        extended_bytes_left <= 4;
                end else if (extended_bytes_left != 0) begin
                    if (current_command == 1 && extended_bytes_left == 1)
                        next_rx <= 8'hAA;
                    else if (current_command == 4 && extended_bytes_left == 4)
                        next_rx <= 8'h40; // OCR: CCS set (SDHC)
                    extended_bytes_left <= extended_bytes_left - 1;
                end else if (xfer_data == 8'h40 || xfer_data == 8'h48 || xfer_data == 8'h77 || xfer_data == 8'h69 || xfer_data == 8'h7A) begin
                    case (xfer_data)
                        8'h40: current_command <= 0;
                        8'h48: current_command <= 1;
                        8'h77: current_command <= 2;
                        8'h69: current_command <= 3;
                        default: current_command <= 4;
                    endcase
                    command_bytes_left <= 5;
                end
            end
        end else if (xfer_busy) begin
            xfer_busy <= 0;
            xfer_done <= 1;
            xfer_rx <= next_rx;
        end
    end

    initial begin
        repeat(3) @(posedge clk); reset=0;
        wait(init_done || init_failed); #1;
        if (!init_done || init_failed) $display("FAIL: sd_card_init"); else $display("PASS: sd_card_init");
        $finish;
    end
endmodule
```

## Source - sd_sector_writer.v

**Path:** `sdcard\sd_sector_writer.v`

```verilog
`timescale 1ns/1ps

// Writes one 512-byte SDHC sector using CMD24. record_data is placed at the
// start of the sector and remaining bytes are zero-filled.  Card initialization
// (CMD0/CMD8/ACMD41/CMD58) must complete before write_start is asserted.
module sd_sector_writer (
    input  wire         clk,
    input  wire         reset,
    input  wire         write_start,
    input  wire [31:0]  sector_address,
    input  wire [255:0] record_data,
    input  wire [5:0]   record_length,
    output reg          busy,
    output reg          done,
    output reg          failed,
    output reg          xfer_start,
    output reg [7:0]    xfer_data,
    output reg          xfer_hold_cs,
    input  wire [7:0]   xfer_rx,
    input  wire         xfer_busy,
    input  wire         xfer_done
);
    localparam [2:0] IDLE = 3'd0, COMMAND = 3'd1, RESPONSE = 3'd2,
                     DATA = 3'd3, DATA_RESPONSE = 3'd4;
    reg [2:0] state;
    reg issued;
    reg [2:0] command_index;
    reg [9:0] data_index;
    reg [8:0] response_tries;
    reg [31:0] sector_reg;
    reg [255:0] record_reg;
    reg [5:0] length_reg;

    function [7:0] command_byte;
        input [2:0] index;
        begin
            case (index)
                3'd0: command_byte = 8'h58; // CMD24
                3'd1: command_byte = sector_reg[31:24];
                3'd2: command_byte = sector_reg[23:16];
                3'd3: command_byte = sector_reg[15:8];
                3'd4: command_byte = sector_reg[7:0];
                default: command_byte = 8'hFF; // CRC ignored after initialization
            endcase
        end
    endfunction

    function [7:0] record_byte;
        input [5:0] index;
        begin
            if (index < length_reg)
                record_byte = record_reg >> (8 * (31 - index));
            else
                record_byte = 8'h00;
        end
    endfunction

    function [7:0] data_byte;
        input [9:0] index;
        begin
            if (index == 0)
                data_byte = 8'hFE;
            else if (index <= 512)
                data_byte = record_byte(index - 1'b1);
            else
                data_byte = 8'hFF; // two CRC bytes
        end
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            issued <= 1'b0;
            command_index <= 0;
            data_index <= 0;
            response_tries <= 0;
            sector_reg <= 0;
            record_reg <= 0;
            length_reg <= 0;
            busy <= 1'b0;
            done <= 1'b0;
            failed <= 1'b0;
            xfer_start <= 1'b0;
            xfer_data <= 8'hFF;
            xfer_hold_cs <= 1'b0;
        end else begin
            xfer_start <= 1'b0;
            done <= 1'b0;
            failed <= 1'b0;
            case (state)
                IDLE: if (write_start) begin
                    busy <= 1'b1;
                    sector_reg <= sector_address;
                    record_reg <= record_data;
                    length_reg <= (record_length > 32) ? 32 : record_length;
                    command_index <= 0;
                    issued <= 1'b0;
                    state <= COMMAND;
                end
                COMMAND: if (!issued && !xfer_busy) begin
                    xfer_data <= command_byte(command_index);
                    xfer_hold_cs <= 1'b1;
                    xfer_start <= 1'b1;
                    issued <= 1'b1;
                end else if (issued && xfer_done) begin
                    issued <= 1'b0;
                    if (command_index == 3'd5) begin
                        response_tries <= 0;
                        state <= RESPONSE;
                    end else
                        command_index <= command_index + 1'b1;
                end
                RESPONSE: if (!issued && !xfer_busy) begin
                    xfer_data <= 8'hFF;
                    xfer_hold_cs <= 1'b1;
                    xfer_start <= 1'b1;
                    issued <= 1'b1;
                end else if (issued && xfer_done) begin
                    issued <= 1'b0;
                    if (xfer_rx == 8'hFF) begin
                        if (response_tries == 9'd255) begin
                            busy <= 1'b0;
                            failed <= 1'b1;
                            state <= IDLE;
                        end else
                            response_tries <= response_tries + 1'b1;
                    end else if (xfer_rx == 8'h00) begin
                        data_index <= 0;
                        state <= DATA;
                    end else begin
                        busy <= 1'b0;
                        failed <= 1'b1;
                        state <= IDLE;
                    end
                end
                DATA: if (!issued && !xfer_busy) begin
                    xfer_data <= data_byte(data_index);
                    xfer_hold_cs <= 1'b1;
                    xfer_start <= 1'b1;
                    issued <= 1'b1;
                end else if (issued && xfer_done) begin
                    issued <= 1'b0;
                    if (data_index == 10'd514)
                        state <= DATA_RESPONSE;
                    else
                        data_index <= data_index + 1'b1;
                end
                default: if (!issued && !xfer_busy) begin
                    xfer_data <= 8'hFF;
                    xfer_hold_cs <= 1'b0;
                    xfer_start <= 1'b1;
                    issued <= 1'b1;
                end else if (issued && xfer_done) begin
                    issued <= 1'b0;
                    busy <= 1'b0;
                    if (xfer_rx[4:0] == 5'b00101)
                        done <= 1'b1;
                    else
                        failed <= 1'b1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
```

## Source - sd_logger.v

**Path:** `sdcard\sd_logger.v`

```verilog
`timescale 1ns/1ps

module sd_logger #(
    parameter [31:0] FIRST_SECTOR = 32'd2048
) (
    input  wire         clk,
    input  wire         reset,
    input  wire         log_valid,
    output wire         log_ready,
    input  wire [255:0] log_record,
    output reg          logger_busy,
    output reg          log_done,
    output reg          log_failed,
    output reg          writer_start,
    output reg [31:0]   writer_sector,
    output reg [255:0]  writer_record,
    output reg [5:0]    writer_length,
    input  wire         writer_busy,
    input  wire         writer_done,
    input  wire         writer_failed
);
    localparam [1:0] IDLE = 2'd0, LAUNCH = 2'd1, WAIT = 2'd2;
    reg [1:0] state;
    reg [31:0] next_sector;
    assign log_ready = (state == IDLE);

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            next_sector <= FIRST_SECTOR;
            logger_busy <= 1'b0;
            log_done <= 1'b0;
            log_failed <= 1'b0;
            writer_start <= 1'b0;
            writer_sector <= FIRST_SECTOR;
            writer_record <= 0;
            writer_length <= 0;
        end else begin
            writer_start <= 1'b0;
            log_done <= 1'b0;
            log_failed <= 1'b0;
            case (state)
                IDLE: if (log_valid) begin
                    writer_sector <= next_sector;
                    writer_record <= log_record;
                    writer_length <= 6'd32;
                    logger_busy <= 1'b1;
                    state <= LAUNCH;
                end
                LAUNCH: begin
                    writer_start <= 1'b1;
                    state <= WAIT;
                end
                default: if (writer_done) begin
                    next_sector <= next_sector + 1'b1;
                    logger_busy <= 1'b0;
                    log_done <= 1'b1;
                    state <= IDLE;
                end else if (writer_failed) begin
                    logger_busy <= 1'b0;
                    log_failed <= 1'b1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
```

## Testbench - tb_sd_logger.v

**Path:** `tb\tb_sd_logger.v`

```verilog
`timescale 1ns/1ps
module tb_sd_logger;
    reg clk=0, reset=1, log_valid=0, writer_busy=0, writer_done=0, writer_failed=0;
    reg [255:0] record=256'h1234;
    wire log_ready, logger_busy, log_done, log_failed, writer_start; wire [31:0] writer_sector; wire [255:0] writer_record; wire [5:0] writer_length;
    sd_logger #(.FIRST_SECTOR(32'd9)) dut (.clk(clk),.reset(reset),.log_valid(log_valid),.log_ready(log_ready),.log_record(record),.logger_busy(logger_busy),.log_done(log_done),.log_failed(log_failed),.writer_start(writer_start),.writer_sector(writer_sector),.writer_record(writer_record),.writer_length(writer_length),.writer_busy(writer_busy),.writer_done(writer_done),.writer_failed(writer_failed));
    always #5 clk=~clk;
    always @(posedge clk) begin
        writer_done <= 0;
        if (writer_start) writer_busy <= 1;
        else if (writer_busy) begin writer_busy <= 0; writer_done <= 1; end
    end
    initial begin
        repeat(2) @(posedge clk); reset=0;
        @(negedge clk); log_valid=1; @(negedge clk); log_valid=0;
        wait(log_done); #1;
        if (writer_sector!=32'd9 || writer_record!=record || writer_length!=32'd32 || log_failed) $display("FAIL: sd_logger");
        else $display("PASS: sd_logger");
        $finish;
    end
endmodule
```

## Source - audit_log_writer.v

**Path:** `sdcard\audit_log_writer.v`

```verilog
`timescale 1ns/1ps

// Team 1 supplies a cryptographic digest that covers the complete event
// metadata.  Team 2 stores both the previous chain head and that digest; it
// intentionally does not replace security-core hashing with a weak RTL hash.
module audit_log_writer (
    input  wire         clk,
    input  wire         reset,
    input  wire         audit_request,
    output wire         audit_ready,
    input  wire [127:0] event_digest,
    output reg          record_valid,
    input  wire         record_ready,
    output reg [255:0]  record_data,
    output reg [127:0]  chain_head
);
    assign audit_ready = !record_valid;

    always @(posedge clk) begin
        if (reset) begin
            record_valid <= 1'b0;
            record_data <= 256'd0;
            chain_head <= 128'd0;
        end else begin
            if (record_valid && record_ready) begin
                record_valid <= 1'b0;
                chain_head <= record_data[127:0];
            end
            if (audit_request && !record_valid) begin
                record_data <= {chain_head, event_digest};
                record_valid <= 1'b1;
            end
        end
    end
endmodule
```

## Source - relay_driver.v

**Path:** `actuator\relay_driver.v`

```verilog
`timescale 1ns/1ps

module relay_driver (
    input  wire clk,
    input  wire reset,
    input  wire authorized,
    input  wire relay_set,
    input  wire relay_reset,
    output reg  relay_in,
    output reg  denied
);
    always @(posedge clk) begin
        if (reset) begin
            relay_in <= 1'b0;
            denied <= 1'b0;
        end else begin
            denied <= 1'b0;
            if (relay_reset)
                relay_in <= 1'b0;
            else if (relay_set && authorized)
                relay_in <= 1'b1;
            else if (relay_set)
                denied <= 1'b1;
        end
    end
endmodule
```

## Testbench - tb_relay_driver.v

**Path:** `tb\tb_relay_driver.v`

```verilog
`timescale 1ns/1ps
module tb_relay_driver;
    reg clk=0, reset=1, authorized=0, relay_set=0, relay_reset=0; wire relay_in, denied;
    relay_driver dut (.clk(clk),.reset(reset),.authorized(authorized),.relay_set(relay_set),.relay_reset(relay_reset),.relay_in(relay_in),.denied(denied));
    always #5 clk=~clk;
    initial begin
        repeat(2) @(posedge clk); reset=0;
        @(negedge clk); relay_set=1; @(negedge clk); relay_set=0; @(posedge clk);
        if (relay_in || !denied) $display("FAIL: relay authorized gate");
        authorized=1; @(negedge clk); relay_set=1; @(negedge clk); relay_set=0; @(posedge clk);
        if (!relay_in) $display("FAIL: relay set");
        relay_reset=1; @(posedge clk); relay_reset=0;
        if (relay_in) $display("FAIL: relay reset"); else $display("PASS: relay_driver");
        $finish;
    end
endmodule
```

## Source - motor_driver.v

**Path:** `actuator\motor_driver.v`

```verilog
`timescale 1ns/1ps

module motor_driver #(
    parameter integer PWM_BITS = 8
) (
    input  wire                clk,
    input  wire                reset,
    input  wire                authorized,
    input  wire                motor_enable,
    input  wire [1:0]          motor_command,
    input  wire [PWM_BITS-1:0] speed,
    output reg                 in1,
    output reg                 in2,
    output reg                 denied
);
    reg [PWM_BITS-1:0] pwm_count;
    wire pwm_on = (pwm_count < speed);

    always @(posedge clk) begin
        if (reset) begin
            pwm_count <= 0;
            in1 <= 1'b0;
            in2 <= 1'b0;
            denied <= 1'b0;
        end else begin
            pwm_count <= pwm_count + 1'b1;
            denied <= motor_enable && !authorized;
            if (!motor_enable || !authorized) begin
                in1 <= 1'b0;
                in2 <= 1'b0;
            end else begin
                case (motor_command)
                    2'b01: begin in1 <= pwm_on; in2 <= 1'b0; end
                    2'b10: begin in1 <= 1'b0; in2 <= pwm_on; end
                    2'b11: begin in1 <= 1'b1; in2 <= 1'b1; end
                    default: begin in1 <= 1'b0; in2 <= 1'b0; end
                endcase
            end
        end
    end
endmodule
```

## Testbench - tb_motor_driver.v

**Path:** `tb\tb_motor_driver.v`

```verilog
`timescale 1ns/1ps
module tb_motor_driver;
    reg clk=0, reset=1, authorized=0, motor_enable=0; reg [1:0] motor_command=0; reg [7:0] speed=8'hFF;
    wire in1,in2,denied;
    motor_driver dut (.clk(clk),.reset(reset),.authorized(authorized),.motor_enable(motor_enable),.motor_command(motor_command),.speed(speed),.in1(in1),.in2(in2),.denied(denied));
    always #5 clk=~clk;
    initial begin
        repeat(2) @(posedge clk); reset=0;
        motor_enable=1; motor_command=2'b01; @(posedge clk);
        if (!denied || in1 || in2) $display("FAIL: motor unauthorized gate");
        authorized=1; repeat(2) @(posedge clk);
        if (!in1 || in2) $display("FAIL: motor forward"); else $display("PASS: motor_driver");
        $finish;
    end
endmodule
```

## Source - stepper_driver.v

**Path:** `actuator\stepper_driver.v`

```verilog
`timescale 1ns/1ps

module stepper_driver #(
    parameter integer CLK_HZ = 24_000_000
) (
    input  wire       clk,
    input  wire       reset,
    input  wire       authorized,
    input  wire       start,
    input  wire       direction,
    input  wire [15:0] step_count,
    input  wire [23:0] step_period,
    output reg [3:0] stepper,
    output reg       busy,
    output reg       done,
    output reg       denied
);
    reg [23:0] period_count;
    reg [15:0] steps_left;
    reg [1:0] phase;

    function [3:0] coil_pattern;
        input [1:0] position;
        begin
            case (position)
                2'd0: coil_pattern = 4'b1001;
                2'd1: coil_pattern = 4'b0011;
                2'd2: coil_pattern = 4'b0110;
                default: coil_pattern = 4'b1100;
            endcase
        end
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            period_count <= 0;
            steps_left <= 0;
            phase <= 0;
            stepper <= 0;
            busy <= 1'b0;
            done <= 1'b0;
            denied <= 1'b0;
        end else begin
            done <= 1'b0;
            denied <= 1'b0;
            if (!busy) begin
                stepper <= 4'b0000;
                if (start && authorized && step_count != 0) begin
                    busy <= 1'b1;
                    steps_left <= step_count;
                    period_count <= 0;
                    stepper <= coil_pattern(phase);
                end else if (start && !authorized)
                    denied <= 1'b1;
            end else if (period_count >= step_period) begin
                period_count <= 0;
                if (steps_left == 16'd1) begin
                    steps_left <= 0;
                    busy <= 1'b0;
                    stepper <= 4'b0000;
                    done <= 1'b1;
                end else begin
                    steps_left <= steps_left - 1'b1;
                    if (direction)
                        phase <= phase + 1'b1;
                    else
                        phase <= phase - 1'b1;
                    stepper <= coil_pattern(direction ? (phase + 1'b1) : (phase - 1'b1));
                end
            end else
                period_count <= period_count + 1'b1;
        end
    end
endmodule
```

## Testbench - tb_stepper_driver.v

**Path:** `tb\tb_stepper_driver.v`

```verilog
`timescale 1ns/1ps
module tb_stepper_driver;
    reg clk=0, reset=1, authorized=0, start=0, direction=1; reg [15:0] step_count=2; reg [23:0] step_period=1;
    wire [3:0] stepper; wire busy,done,denied;
    stepper_driver dut (.clk(clk),.reset(reset),.authorized(authorized),.start(start),.direction(direction),.step_count(step_count),.step_period(step_period),.stepper(stepper),.busy(busy),.done(done),.denied(denied));
    always #5 clk=~clk;
    initial begin
        repeat(2) @(posedge clk); reset=0; authorized=1;
        @(negedge clk); start=1; @(negedge clk); start=0;
        wait(done); #1;
        if (stepper!=0 || busy) $display("FAIL: stepper completion"); else $display("PASS: stepper_driver");
        $finish;
    end
endmodule
```

## Source - peripheral_controller.v

**Path:** `integration\peripheral_controller.v`

```verilog
`timescale 1ns/1ps

// Arbitration only: this module transports untrusted commands to Team 1 and
// broadcasts Team 1 telemetry to both outbound links.  It performs no access
// control and never asserts actuator authorization.
module peripheral_controller (
    input  wire       clk,
    input  wire       reset,
    input  wire       pmod_cmd_valid,
    input  wire [7:0] pmod_cmd_opcode,
    input  wire [7:0] pmod_cmd_sequence,
    input  wire [15:0] pmod_cmd_argument,
    input  wire       esp_cmd_valid,
    input  wire [7:0] esp_cmd_type,
    input  wire [15:0] esp_cmd_value,
    output reg        core_command_valid,
    input  wire       core_command_ready,
    output reg [7:0]  core_command_opcode,
    output reg [7:0]  core_command_sequence,
    output reg [15:0] core_command_argument,
    output reg        core_command_source,
    input  wire       core_telemetry_valid,
    output wire       core_telemetry_ready,
    input  wire [7:0] core_telemetry_sequence,
    input  wire [7:0] core_telemetry_event,
    input  wire [11:0] core_telemetry_sensor,
    input  wire [7:0] core_telemetry_status,
    output wire       telemetry_valid,
    input  wire       telemetry_ready,
    output wire [7:0] telemetry_sequence,
    output wire [7:0] telemetry_event,
    output wire [11:0] telemetry_sensor,
    output wire [7:0] telemetry_status
);
    assign telemetry_valid = core_telemetry_valid;
    assign core_telemetry_ready = telemetry_ready;
    assign telemetry_sequence = core_telemetry_sequence;
    assign telemetry_event = core_telemetry_event;
    assign telemetry_sensor = core_telemetry_sensor;
    assign telemetry_status = core_telemetry_status;

    always @(posedge clk) begin
        if (reset) begin
            core_command_valid <= 1'b0;
            core_command_opcode <= 8'd0;
            core_command_sequence <= 8'd0;
            core_command_argument <= 16'd0;
            core_command_source <= 1'b0;
        end else if (core_command_valid) begin
            if (core_command_ready)
                core_command_valid <= 1'b0;
        end else if (pmod_cmd_valid) begin
            core_command_valid <= 1'b1;
            core_command_opcode <= pmod_cmd_opcode;
            core_command_sequence <= pmod_cmd_sequence;
            core_command_argument <= pmod_cmd_argument;
            core_command_source <= 1'b0;
        end else if (esp_cmd_valid) begin
            core_command_valid <= 1'b1;
            core_command_opcode <= esp_cmd_type;
            core_command_sequence <= 8'h00;
            core_command_argument <= esp_cmd_value;
            core_command_source <= 1'b1;
        end
    end
endmodule
```

## Source - team2_top.v

**Path:** `integration\team2_top.v`

```verilog
`timescale 1ns/1ps

module team2_top #(
    parameter integer CLK_HZ = 24_000_000,
    parameter integer UART_BAUD = 115_200
) (
    input  wire         clk_24mhz,
    input  wire         reset,

    input  wire         pmod_uart_rx,
    output wire         pmod_uart_tx,
    input  wire         esp_uart_rx,
    output wire         esp_uart_tx,

    output wire         adc_sck,
    output wire         adc_mosi,
    input  wire         adc_miso,
    output wire         adc_cs_n,
    output wire         sd_clk,
    output wire         sd_cmd,
    input  wire         sd_d0,
    output wire         sd_cs_n,
    input  wire         sd_detect_n,

    output wire         lcd_rs,
    output wire         lcd_rw,
    output wire         lcd_en,
    output wire [7:0]   lcd_d,
    output wire [3:0]   keypad_row_n,
    input  wire [3:0]   keypad_col_n,
    output wire [15:0]  led,
    output wire         buzzer,
    output wire         seg_din,
    output wire         seg_clk,
    output wire         seg_load,
    output wire         relay_in,
    output wire         motor_in1,
    output wire         motor_in2,
    output wire [3:0]   stepper,

    output wire [11:0]  core_adc_sample,
    output wire         core_adc_sample_valid,
    input  wire         core_adc_channel,
    input  wire         core_adc_force_sample,
    output wire         core_key_valid,
    output wire [7:0]   core_key_ascii,
    output wire         core_command_valid,
    input  wire         core_command_ready,
    output wire [7:0]   core_command_opcode,
    output wire [7:0]   core_command_sequence,
    output wire [15:0]  core_command_argument,
    output wire         core_command_source,

    input  wire         core_telemetry_valid,
    output wire         core_telemetry_ready,
    input  wire [7:0]   core_telemetry_sequence,
    input  wire [7:0]   core_telemetry_event,
    input  wire [11:0]  core_telemetry_sensor,
    input  wire [7:0]   core_telemetry_status,

    input  wire         core_lcd_refresh,
    input  wire [127:0] core_lcd_line1,
    input  wire [127:0] core_lcd_line2,
    input  wire [15:0]  core_led_status,
    input  wire         core_alarm,
    input  wire         core_buzzer_enable,
    input  wire [15:0]  core_sevenseg_value,
    input  wire         core_sevenseg_enable,

    input  wire         core_actuator_authorized,
    input  wire         core_relay_set,
    input  wire         core_relay_reset,
    input  wire         core_motor_enable,
    input  wire [1:0]   core_motor_command,
    input  wire [7:0]   core_motor_speed,
    input  wire         core_stepper_start,
    input  wire         core_stepper_direction,
    input  wire [15:0]  core_stepper_count,
    input  wire [23:0]  core_stepper_period,
    output wire         core_actuator_denied,
    output wire         core_stepper_busy,
    output wire         core_stepper_done,

    input  wire         core_audit_request,
    output wire         core_audit_ready,
    input  wire [127:0] core_audit_digest,
    output wire [127:0] core_audit_chain_head,
    output wire         core_audit_storage_failed
);
    wire [7:0] pmod_rx_data, esp_rx_data;
    wire pmod_rx_valid, esp_rx_valid, pmod_framing_error, esp_framing_error;
    wire pmod_tx_start, esp_tx_start, pmod_tx_busy, esp_tx_busy;
    wire [7:0] pmod_tx_data, esp_tx_data;
    wire pmod_cmd_valid, pmod_cmd_error;
    wire [7:0] pmod_cmd_opcode, pmod_cmd_sequence;
    wire [15:0] pmod_cmd_argument;
    wire esp_message_valid, esp_message_error;
    wire [7:0] esp_message_type;
    wire [15:0] esp_message_value;
    wire telemetry_valid, telemetry_ready;
    wire [7:0] telemetry_sequence, telemetry_event, telemetry_status;
    wire [11:0] telemetry_sensor;
    wire pmod_telemetry_ready, esp_telemetry_ready;

    wire lcd_write, lcd_write_rs, lcd_ready;
    wire [7:0] lcd_write_data;
    wire [3:0] keypad_code;
    wire keypad_valid;
    wire relay_denied, motor_denied, stepper_denied;
    wire stepper_done;
    wire audit_record_valid, audit_record_ready, logger_log_ready;
    wire [255:0] audit_record;
    wire logger_busy, logger_done, logger_failed;
    wire writer_start, writer_busy, writer_done, writer_failed;
    wire [31:0] writer_sector;
    wire [255:0] writer_record;
    wire [5:0] writer_length;
    wire sd_xfer_start, sd_xfer_busy, sd_xfer_done, sd_xfer_hold_cs;
    wire [7:0] sd_xfer_data, sd_xfer_rx;
    wire sd_init_busy, sd_init_done, sd_init_failed;
    wire sd_init_xfer_start, sd_init_xfer_hold_cs, sd_init_force_cs_high;
    wire [7:0] sd_init_xfer_data;
    wire sd_bus_xfer_start, sd_bus_xfer_hold_cs, sd_bus_force_cs_high;
    wire [7:0] sd_bus_xfer_data;

    uart_top #(.CLK_HZ(CLK_HZ), .BAUD(UART_BAUD)) pmod_uart (
        .clk(clk_24mhz), .reset(reset), .uart_rx_i(pmod_uart_rx), .uart_tx_o(pmod_uart_tx),
        .tx_start(pmod_tx_start), .tx_data(pmod_tx_data), .tx_busy(pmod_tx_busy),
        .rx_data(pmod_rx_data), .rx_valid(pmod_rx_valid), .framing_error(pmod_framing_error)
    );
    sentinel_command_rx pmod_command (
        .clk(clk_24mhz), .reset(reset), .rx_data(pmod_rx_data), .rx_valid(pmod_rx_valid),
        .cmd_valid(pmod_cmd_valid), .cmd_opcode(pmod_cmd_opcode), .cmd_sequence(pmod_cmd_sequence),
        .cmd_argument(pmod_cmd_argument), .cmd_error(pmod_cmd_error)
    );
    sentinel_telemetry_tx pmod_telemetry (
        .clk(clk_24mhz), .reset(reset), .telemetry_valid(telemetry_valid),
        .telemetry_ready(pmod_telemetry_ready), .telemetry_sequence(telemetry_sequence),
        .telemetry_event(telemetry_event), .telemetry_sensor(telemetry_sensor),
        .telemetry_status(telemetry_status), .uart_busy(pmod_tx_busy),
        .uart_start(pmod_tx_start), .uart_data(pmod_tx_data)
    );

    esp32_uart #(.CLK_HZ(CLK_HZ), .BAUD(UART_BAUD)) esp_uart (
        .clk(clk_24mhz), .reset(reset), .esp_rx(esp_uart_rx), .esp_tx(esp_uart_tx),
        .tx_start(esp_tx_start), .tx_data(esp_tx_data), .tx_busy(esp_tx_busy),
        .rx_data(esp_rx_data), .rx_valid(esp_rx_valid), .framing_error(esp_framing_error)
    );
    esp32_packet_parser esp_parser (
        .clk(clk_24mhz), .reset(reset), .rx_data(esp_rx_data), .rx_valid(esp_rx_valid),
        .message_valid(esp_message_valid), .message_type(esp_message_type),
        .message_value(esp_message_value), .message_error(esp_message_error)
    );
    esp32_dashboard dashboard (
        .clk(clk_24mhz), .reset(reset), .telemetry_valid(telemetry_valid),
        .telemetry_ready(esp_telemetry_ready), .telemetry_sequence(telemetry_sequence),
        .telemetry_event(telemetry_event), .telemetry_sensor(telemetry_sensor),
        .telemetry_status(telemetry_status), .uart_busy(esp_tx_busy),
        .uart_start(esp_tx_start), .uart_data(esp_tx_data)
    );

    peripheral_controller controller (
        .clk(clk_24mhz), .reset(reset), .pmod_cmd_valid(pmod_cmd_valid),
        .pmod_cmd_opcode(pmod_cmd_opcode), .pmod_cmd_sequence(pmod_cmd_sequence),
        .pmod_cmd_argument(pmod_cmd_argument), .esp_cmd_valid(esp_message_valid),
        .esp_cmd_type(esp_message_type), .esp_cmd_value(esp_message_value),
        .core_command_valid(core_command_valid), .core_command_ready(core_command_ready),
        .core_command_opcode(core_command_opcode), .core_command_sequence(core_command_sequence),
        .core_command_argument(core_command_argument), .core_command_source(core_command_source),
        .core_telemetry_valid(core_telemetry_valid), .core_telemetry_ready(core_telemetry_ready),
        .core_telemetry_sequence(core_telemetry_sequence), .core_telemetry_event(core_telemetry_event),
        .core_telemetry_sensor(core_telemetry_sensor), .core_telemetry_status(core_telemetry_status),
        .telemetry_valid(telemetry_valid), .telemetry_ready(telemetry_ready),
        .telemetry_sequence(telemetry_sequence), .telemetry_event(telemetry_event),
        .telemetry_sensor(telemetry_sensor), .telemetry_status(telemetry_status)
    );
    assign telemetry_ready = pmod_telemetry_ready && esp_telemetry_ready;

    mcp3202_sampler #(.CLK_HZ(CLK_HZ)) sampler (
        .clk(clk_24mhz), .reset(reset), .force_sample(core_adc_force_sample), .channel(core_adc_channel),
        .sample_value(core_adc_sample), .sample_valid(core_adc_sample_valid), .busy(),
        .spi_sck(adc_sck), .spi_mosi(adc_mosi), .spi_miso(adc_miso), .adc_cs_n(adc_cs_n)
    );

    lcd_controller lcd_text (
        .clk(clk_24mhz), .reset(reset), .refresh(core_lcd_refresh), .line1(core_lcd_line1),
        .line2(core_lcd_line2), .driver_write(lcd_write), .driver_rs(lcd_write_rs),
        .driver_data(lcd_write_data), .driver_ready(lcd_ready)
    );
    lcd_driver #(.CLK_HZ(CLK_HZ)) lcd_bus (
        .clk(clk_24mhz), .reset(reset), .write_en(lcd_write), .write_rs(lcd_write_rs),
        .write_data(lcd_write_data), .ready(lcd_ready), .lcd_rs(lcd_rs), .lcd_rw(lcd_rw),
        .lcd_en(lcd_en), .lcd_d(lcd_d)
    );
    keypad_scan #(.CLK_HZ(CLK_HZ)) keypad (
        .clk(clk_24mhz), .reset(reset), .row_n(keypad_row_n), .col_n(keypad_col_n),
        .key_valid(keypad_valid), .key_code(keypad_code)
    );
    keypad_decoder key_decode (
        .clk(clk_24mhz), .reset(reset), .key_valid(keypad_valid), .key_code(keypad_code),
        .ascii_valid(core_key_valid), .ascii(core_key_ascii)
    );
    led_controller #(.CLK_HZ(CLK_HZ)) leds (
        .clk(clk_24mhz), .reset(reset), .status(core_led_status), .alarm(core_alarm), .led(led)
    );
    buzzer_controller #(.CLK_HZ(CLK_HZ)) sounder (
        .clk(clk_24mhz), .reset(reset), .alarm(core_alarm), .enable(core_buzzer_enable), .buzzer(buzzer)
    );
    sevenseg_driver #(.CLK_HZ(CLK_HZ)) sevenseg (
        .clk(clk_24mhz), .reset(reset), .value(core_sevenseg_value), .display_enable(core_sevenseg_enable),
        .seg_din(seg_din), .seg_clk(seg_clk), .seg_load(seg_load)
    );

    relay_driver relay (
        .clk(clk_24mhz), .reset(reset), .authorized(core_actuator_authorized),
        .relay_set(core_relay_set), .relay_reset(core_relay_reset), .relay_in(relay_in), .denied(relay_denied)
    );
    motor_driver motor (
        .clk(clk_24mhz), .reset(reset), .authorized(core_actuator_authorized),
        .motor_enable(core_motor_enable), .motor_command(core_motor_command), .speed(core_motor_speed),
        .in1(motor_in1), .in2(motor_in2), .denied(motor_denied)
    );
    stepper_driver stepper_motor (
        .clk(clk_24mhz), .reset(reset), .authorized(core_actuator_authorized), .start(core_stepper_start),
        .direction(core_stepper_direction), .step_count(core_stepper_count), .step_period(core_stepper_period),
        .stepper(stepper), .busy(core_stepper_busy), .done(stepper_done), .denied(stepper_denied)
    );
    assign core_stepper_done = stepper_done;
    assign core_actuator_denied = relay_denied | motor_denied | stepper_denied;

    audit_log_writer audit (
        .clk(clk_24mhz), .reset(reset), .audit_request(core_audit_request), .audit_ready(core_audit_ready),
        .event_digest(core_audit_digest), .record_valid(audit_record_valid), .record_ready(audit_record_ready),
        .record_data(audit_record), .chain_head(core_audit_chain_head)
    );
    assign audit_record_ready = logger_log_ready && sd_init_done;
    sd_logger logger (
        .clk(clk_24mhz), .reset(reset), .log_valid(audit_record_valid), .log_ready(logger_log_ready),
        .log_record(audit_record), .logger_busy(logger_busy), .log_done(logger_done), .log_failed(logger_failed),
        .writer_start(writer_start), .writer_sector(writer_sector), .writer_record(writer_record),
        .writer_length(writer_length), .writer_busy(writer_busy), .writer_done(writer_done), .writer_failed(writer_failed)
    );
    sd_sector_writer sector_writer (
        .clk(clk_24mhz), .reset(reset), .write_start(writer_start), .sector_address(writer_sector),
        .record_data(writer_record), .record_length(writer_length), .busy(writer_busy), .done(writer_done),
        .failed(writer_failed), .xfer_start(sd_xfer_start), .xfer_data(sd_xfer_data),
        .xfer_hold_cs(sd_xfer_hold_cs), .xfer_rx(sd_xfer_rx), .xfer_busy(sd_xfer_busy), .xfer_done(sd_xfer_done)
    );
    sd_card_init sd_init (
        .clk(clk_24mhz), .reset(reset), .init_busy(sd_init_busy), .init_done(sd_init_done),
        .init_failed(sd_init_failed), .xfer_start(sd_init_xfer_start), .xfer_data(sd_init_xfer_data),
        .xfer_hold_cs(sd_init_xfer_hold_cs), .xfer_force_cs_high(sd_init_force_cs_high),
        .xfer_rx(sd_xfer_rx), .xfer_busy(sd_xfer_busy), .xfer_done(sd_xfer_done)
    );
    assign sd_bus_xfer_start = sd_init_busy ? sd_init_xfer_start : sd_xfer_start;
    assign sd_bus_xfer_data = sd_init_busy ? sd_init_xfer_data : sd_xfer_data;
    assign sd_bus_xfer_hold_cs = sd_init_busy ? sd_init_xfer_hold_cs : sd_xfer_hold_cs;
    assign sd_bus_force_cs_high = sd_init_busy ? sd_init_force_cs_high : 1'b0;
    spi_sd_master sd_spi (
        .clk(clk_24mhz), .reset(reset), .xfer_start(sd_bus_xfer_start), .xfer_data(sd_bus_xfer_data),
        .hold_cs(sd_bus_xfer_hold_cs), .force_cs_high(sd_bus_force_cs_high),
        .xfer_rx(sd_xfer_rx), .xfer_busy(sd_xfer_busy), .xfer_done(sd_xfer_done),
        .sd_clk(sd_clk), .sd_cmd(sd_cmd), .sd_d0(sd_d0), .sd_cs_n(sd_cs_n)
    );
    assign core_audit_storage_failed = logger_failed | sd_init_failed | !sd_detect_n;
endmodule
```

## Testbench - tb_team2_top.v

**Path:** `tb\tb_team2_top.v`

```verilog
`timescale 1ns/1ps
module tb_team2_top;
    reg clk=0, reset=1;
    // This smoke test intentionally leaves board and Team 1 inputs un-driven.
    // It verifies elaboration and reset-only behavior of the integrated design.
    team2_top dut (.clk_24mhz(clk), .reset(reset));
    always #5 clk=~clk;
    initial begin
        repeat(4) @(posedge clk); reset=0;
        repeat(20) @(posedge clk);
        $display("PASS: team2_top reset smoke");
        $finish;
    end
endmodule
```

## Source - sentinel_rv_top.v

**Path:** `sentinel_rv_top.v`

```verilog
`timescale 1ns/1ps

// Combined Team 1 + Team 2 board wrapper.
// Team 2 validates transport framing; Team 1 makes the security decision.
module sentinel_rv_top (
    input wire clk_24mhz, input wire reset,
    input wire pmod_uart_rx, output wire pmod_uart_tx,
    input wire esp_uart_rx, output wire esp_uart_tx,
    output wire adc_sck, output wire adc_mosi, input wire adc_miso, output wire adc_cs_n,
    output wire sd_clk, output wire sd_cmd, input wire sd_d0, output wire sd_cs_n, input wire sd_detect_n,
    output wire lcd_rs, output wire lcd_rw, output wire lcd_en, output wire [7:0] lcd_d,
    output wire [3:0] keypad_row_n, input wire [3:0] keypad_col_n, output wire [15:0] led,
    output wire buzzer, output wire seg_din, output wire seg_clk, output wire seg_load,
    output wire relay_in, output wire motor_in1, output wire motor_in2, output wire [3:0] stepper,

    input wire security_clear_alarm,
    input wire security_xadc_sample_valid,
    input wire [11:0] security_xadc_vccint_code,
    input wire [11:0] security_xadc_temperature_code,
    output wire security_command_accepted,
    output wire security_command_rejected,
    output wire security_alarm,
    output wire security_aes_reset,
    input wire security_tx_start,
    input wire [127:0] security_tx_plaintext,
    input wire [127:0] security_tx_key,
    input wire [63:0] security_tx_nonce,
    input wire [7:0] security_tx_sequence,
    output wire [239:0] security_tx_packet,
    output wire security_tx_packet_valid,
    output wire security_tx_busy,
    output wire security_cpu_trap,
    input wire security_audit_request,
    input wire [127:0] security_audit_digest,
    output wire security_audit_ready,
    output wire [127:0] security_audit_chain_head,
    output wire security_audit_storage_failed,
    output wire security_key_valid,
    output wire [7:0] security_key_ascii
);
    wire [11:0] core_adc_sample;
    wire core_adc_sample_valid;
    wire core_adc_channel = 1'b0;
    wire core_adc_force_sample = 1'b0;
    wire core_key_valid;
    wire [7:0] core_key_ascii;
    wire core_command_valid;
    wire core_command_ready = 1'b1;
    wire [7:0] core_command_opcode;
    wire [7:0] core_command_sequence;
    wire [15:0] core_command_argument;
    wire core_command_source;
    wire core_telemetry_valid;
    wire core_telemetry_ready;
    wire [7:0] core_telemetry_sequence;
    wire [7:0] core_telemetry_event;
    wire [11:0] core_telemetry_sensor;
    wire [7:0] core_telemetry_status;
    wire core_lcd_refresh = core_telemetry_valid | security_command_accepted | security_command_rejected;
    wire [127:0] core_lcd_line1;
    wire [127:0] core_lcd_line2;
    wire [15:0] core_led_status;
    wire core_alarm = security_alarm;
    wire core_buzzer_enable = 1'b1;
    wire [15:0] core_sevenseg_value;
    wire core_sevenseg_enable = 1'b1;
    wire core_actuator_authorized;
    wire core_relay_set;
    wire core_relay_reset;
    wire core_motor_enable;
    wire [1:0] core_motor_command;
    wire [7:0] core_motor_speed;
    wire core_stepper_start;
    wire core_stepper_direction;
    wire [15:0] core_stepper_count;
    wire [23:0] core_stepper_period = 24'd100_000;
    wire core_actuator_denied;
    wire core_stepper_busy;
    wire core_stepper_done;
    wire core_audit_request = security_audit_request;
    wire core_audit_ready;
    wire [127:0] core_audit_digest = security_audit_digest;
    wire [127:0] core_audit_chain_head;
    wire core_audit_storage_failed;
    reg [7:0] last_opcode;
    reg [15:0] last_argument;

    always @(posedge clk_24mhz) begin
        if (reset) begin
            last_opcode <= 8'd0;
            last_argument <= 16'd0;
        end else if (core_command_valid) begin
            last_opcode <= core_command_opcode;
            last_argument <= core_command_argument;
        end
    end

    assign core_lcd_line1 = security_alarm ? "SECURITY ALARM  " : "SENTINEL-RV OK  ";
    assign core_lcd_line2 = security_command_accepted ? "CMD ACCEPTED    " :
                            security_command_rejected ? "CMD REJECTED    " : "READY           ";
    assign core_led_status = {12'd0, security_alarm, security_command_rejected,
                              security_command_accepted, core_command_valid};
    assign core_sevenseg_value = last_argument;
    assign core_actuator_authorized = security_command_accepted;
    assign core_relay_set = security_command_accepted && last_opcode == 8'h01;
    assign core_relay_reset = security_command_accepted && last_opcode == 8'h02;
    assign core_motor_enable = security_command_accepted && last_opcode == 8'h03;
    assign core_motor_command = last_argument[1:0];
    assign core_motor_speed = last_argument[15:8];
    assign core_stepper_start = security_command_accepted && last_opcode == 8'h04;
    assign core_stepper_direction = last_argument[0];
    assign core_stepper_count = last_argument;
    assign core_telemetry_valid = core_adc_sample_valid | security_command_accepted | security_command_rejected;
    assign core_telemetry_sequence = core_command_sequence;
    assign core_telemetry_event = security_alarm ? 8'hEE :
                                  security_command_accepted ? 8'h01 :
                                  security_command_rejected ? 8'h02 : 8'h10;
    assign core_telemetry_sensor = core_adc_sample;
    assign core_telemetry_status = {5'd0, security_alarm, security_aes_reset, core_command_valid};

    assign security_key_valid = core_key_valid;
    assign security_key_ascii = core_key_ascii;
    assign security_audit_ready = core_audit_ready;
    assign security_audit_chain_head = core_audit_chain_head;
    assign security_audit_storage_failed = core_audit_storage_failed;

    team2_top peripherals (.*);

    sentinel_rv_security security_core (
        .clk(clk_24mhz), .reset(reset),
        .rx_packet_valid(core_command_valid),
        .rx_nonce({40'd0, core_command_sequence, core_command_argument}),
        .rx_crc_ok(core_command_valid),
        .clear_alarm(security_clear_alarm),
        .xadc_sample_valid(security_xadc_sample_valid),
        .xadc_vccint_code(security_xadc_vccint_code),
        .xadc_temperature_code(security_xadc_temperature_code),
        .command_accepted(security_command_accepted),
        .command_rejected(security_command_rejected),
        .alarm(security_alarm), .aes_reset(security_aes_reset),
        .tx_start(security_tx_start), .tx_plaintext(security_tx_plaintext),
        .tx_key(security_tx_key), .tx_nonce(security_tx_nonce),
        .tx_sequence(security_tx_sequence), .tx_packet(security_tx_packet),
        .tx_packet_valid(security_tx_packet_valid), .tx_busy(security_tx_busy),
        .cpu_trap(security_cpu_trap)
    );
endmodule
```

## Constraints - team2.xdc

**Path:** `constraints\team2.xdc`

```tcl
## AT-STLN-ARTIX7-001 Team 2 constraints
## Confirm against the schematic before programming: the supplied manual has
## conflicting SPI/SD entries. These assignments use its detailed tables.

create_clock -period 41.667 -name sys_clk [get_ports clk_24mhz]
set_property -dict {PACKAGE_PIN D13 IOSTANDARD LVCMOS33} [get_ports clk_24mhz]

## User LEDs (only LED1-LED8 are documented in the supplied manual)
set_property -dict {PACKAGE_PIN D5 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN A3 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS33} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN E6 IOSTANDARD LVCMOS33} [get_ports {led[4]}]
set_property -dict {PACKAGE_PIN C13 IOSTANDARD LVCMOS33} [get_ports {led[5]}]
set_property -dict {PACKAGE_PIN C14 IOSTANDARD LVCMOS33} [get_ports {led[6]}]
set_property -dict {PACKAGE_PIN D14 IOSTANDARD LVCMOS33} [get_ports {led[7]}]

## MAX7219 4-digit display
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports seg_din]
set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS33} [get_ports seg_load]
set_property -dict {PACKAGE_PIN H12 IOSTANDARD LVCMOS33} [get_ports seg_clk]

## LCD in 8-bit write mode
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS33} [get_ports lcd_rs]
set_property -dict {PACKAGE_PIN H3 IOSTANDARD LVCMOS33} [get_ports lcd_rw]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports lcd_en]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {lcd_d[0]}]
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {lcd_d[1]}]
set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33} [get_ports {lcd_d[2]}]
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports {lcd_d[3]}]
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports {lcd_d[4]}]
set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS33} [get_ports {lcd_d[5]}]
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {lcd_d[6]}]
set_property -dict {PACKAGE_PIN H1 IOSTANDARD LVCMOS33} [get_ports {lcd_d[7]}]

## Alarm and actuators
set_property -dict {PACKAGE_PIN K5 IOSTANDARD LVCMOS33} [get_ports buzzer]
set_property -dict {PACKAGE_PIN L5 IOSTANDARD LVCMOS33} [get_ports relay_in]
set_property -dict {PACKAGE_PIN F12 IOSTANDARD LVCMOS33} [get_ports motor_in1]
set_property -dict {PACKAGE_PIN H11 IOSTANDARD LVCMOS33} [get_ports motor_in2]
set_property -dict {PACKAGE_PIN E12 IOSTANDARD LVCMOS33} [get_ports {stepper[0]}]
set_property -dict {PACKAGE_PIN E13 IOSTANDARD LVCMOS33} [get_ports {stepper[1]}]
set_property -dict {PACKAGE_PIN E11 IOSTANDARD LVCMOS33} [get_ports {stepper[2]}]
set_property -dict {PACKAGE_PIN D11 IOSTANDARD LVCMOS33} [get_ports {stepper[3]}]

## MCP3202 SPI (manual section 4.4)
set_property -dict {PACKAGE_PIN G11 IOSTANDARD LVCMOS33} [get_ports adc_sck]
set_property -dict {PACKAGE_PIN G12 IOSTANDARD LVCMOS33} [get_ports adc_mosi]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports adc_miso]
set_property -dict {PACKAGE_PIN H14 IOSTANDARD LVCMOS33} [get_ports adc_cs_n]

## Micro-SD in SPI mode (manual section 4.6)
set_property -dict {PACKAGE_PIN C11 IOSTANDARD LVCMOS33} [get_ports sd_clk]
set_property -dict {PACKAGE_PIN B12 IOSTANDARD LVCMOS33} [get_ports sd_cmd]
set_property -dict {PACKAGE_PIN D8 IOSTANDARD LVCMOS33} [get_ports sd_d0]
set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33} [get_ports sd_cs_n]
set_property -dict {PACKAGE_PIN C12 IOSTANDARD LVCMOS33} [get_ports sd_detect_n]

## PMOD UART uses J16 IO_0/IO_1. Set the peer board to the crossed direction.
set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports pmod_uart_tx]
set_property -dict {PACKAGE_PIN R3 IOSTANDARD LVCMOS33} [get_ports pmod_uart_rx]

## The manual routes ESP32 UART through J13 but does not give FPGA ball names.
## Leave esp_uart_rx/esp_uart_tx unconstrained until the J13 schematic sheet is verified.

## The keypad table is internally inconsistent: it names 16 keys but describes
## a four-row/four-column matrix. Do not apply guessed PACKAGE_PIN properties.
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_row_n[*] keypad_col_n[*]}]
set_property PULLUP true [get_ports {keypad_col_n[*]}]
```

## Test Runner - run_tests.ps1

**Path:** `tb\run_tests.ps1`

```powershell
param(
    [string]$Icarus = "iverilog",
    [string]$Vvp = "vvp"
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$buildDirectory = Join-Path $PSScriptRoot ".build"
New-Item -ItemType Directory -Force -Path $buildDirectory | Out-Null

if (-not (Get-Command $Icarus -ErrorAction SilentlyContinue)) {
    throw "Icarus Verilog was not found. Install it or pass -Icarus <path>."
}
if (-not (Get-Command $Vvp -ErrorAction SilentlyContinue)) {
    throw "The Icarus vvp runtime was not found. Install it or pass -Vvp <path>."
}

$rtl = Get-ChildItem -Path $projectRoot -Recurse -Filter *.v |
    Where-Object { $_.DirectoryName -notlike "$PSScriptRoot*" } |
    ForEach-Object { $_.FullName }
$tests = Get-ChildItem -Path $PSScriptRoot -Filter "tb_*.v" | Sort-Object Name

foreach ($test in $tests) {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($test.Name)
    $output = Join-Path $buildDirectory "$name.out"
    & $Icarus -g2012 -s $name -o $output $test.FullName $rtl
    if ($LASTEXITCODE -ne 0) { throw "Compilation failed: $name" }
    & $Vvp $output
    if ($LASTEXITCODE -ne 0) { throw "Simulation failed: $name" }
}

Write-Host "All $($tests.Count) testbenches passed."
```

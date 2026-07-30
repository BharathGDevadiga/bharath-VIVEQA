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

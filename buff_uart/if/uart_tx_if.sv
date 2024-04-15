interface uart_tx_if #(parameter width = 8, baud_rate = 9600, clock_freq = 460800);
    logic signal;
    logic [width-1:0] data;
    logic ready;
    logic can_send_next_word;
    logic transmitted_byte;

    modport DUT (
        input data, can_send_next_word,
        output signal, ready, transmitted_byte
    );
endinterface

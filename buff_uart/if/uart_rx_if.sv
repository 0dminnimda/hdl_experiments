interface uart_rx_if #(parameter width = 8, baud_rate = 9600, clock_freq = 460800);
    logic signal;
    logic [width-1:0] data;
    logic ready;
    logic can_receive_next_word;

    modport DUT (
        input signal, can_receive_next_word,
        output data, ready
    );
endinterface

interface uart_if #(parameter width = 8, baud_rate = 9600, clock_freq = 460800);
    logic signal;
    logic [width-1:0] data;
    logic ready;

    modport RX (
        input signal,
        output data, ready
    );

    modport TX (
        input data, ready,
        output signal
    );
endinterface

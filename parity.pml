/*
    spin -a parity.pml
    gcc -o pan pan.c
    ./pan
    
*/

#define N 8

typedef Bits{
    bit array [N];
}

// Channels for the messages
chan channel1 = [0] of {Bits}
chan channel2 = [0] of {Bits}

bool changed = false;
bool result = false;
bool hasReceived = false;

active proctype sender() {
    Bits msg;
    int i;
    // Initialization from message und parity bit
    msg.array[N-1] = 0;
    for(i : 0 .. (N - 2)) {
        if
            :: msg.array[i] = 0
            :: msg.array[i] = 1 
        fi;
        msg.array[N-1] = msg.array[N-1] ^ msg.array[i]
    };
    printf("Send to attacker: ");
    for (i : 0 .. (N-1)) {
        printf("%d", msg.array[i]);
    };
    printf("\n");
    channel1 ! msg
}

active proctype receiver() {
    Bits msg;
    //receive message from attacker
    channel2 ? msg;
    hasReceived = true;
    printf("Receive from attacker: ");
    int i;
    for (i : 0 .. (N-1)) {
        printf("%d", msg.array[i]);
    };
    printf("\n");
    // test for change
    bit tester = 0;
    for(i : 0 .. (N - 2)) {
        tester = tester ^ msg.array[i]
    };
    result = (tester != msg.array[N-1]);
    printf("%d\n", result);
}

active proctype attacker() {
    Bits msg;
    // Catch message from sender
    channel1 ? msg;
    printf("Receive from sender: ");
    int i;
    for (i : 0 .. (N-1)) {
        printf("%d", msg.array[i]);
    };
    printf("\n");
    // Change one bit or not
    for (i : 0 .. (N-1)) {
        if
            :: !changed -> msg.array[i] = !msg.array[i]; changed = true; break;
            :: msg.array[i] = msg.array[i]
        fi
    };
    printf("Send to receiver: ");
    for (i : 0 .. (N-1)) {
        printf("%d", msg.array[i]);
    };
    printf("\n");
    // Send to receiver
    channel2 ! msg
}

// The receiver received the message and checked it correctly.
ltl checker {<>((changed == result) && hasReceived)}
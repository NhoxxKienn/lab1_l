#define NUM_SMOKER 2
// In order to not have any deadlock, NUM_TABACO >= 1 and NUM_PAPER >= 1 and NUM_TABACO + NUM_PAPER > NUM_SMOKER
#define NUM_TABACO 1
#define NUM_PAPER 1

// Number of resources on table
int paperAvailable = NUM_PAPER;
int tabacoAvailable = NUM_TABACO;

// The state of resources of each smoker
bool paperFlags [NUM_SMOKER];
bool tabacoFlags [NUM_SMOKER]; 
bool deadlockFlags [NUM_SMOKER];
active [NUM_SMOKER] proctype Smoker() {
    paperFlags[_pid] = false;
    tabacoFlags[_pid] = false;
    deadlockFlags[_pid] = false;
    do
        // Collect paper if available
        :: atomic{ !paperFlags[_pid] && paperAvailable > 0 -> paperFlags[_pid] = true; printf("Smoker %d acquires paper\n", _pid); 
                                                    paperAvailable = paperAvailable - 1;     deadlockFlags[_pid] = false;}

        // Collect tabaco if available
        :: atomic{ !tabacoFlags[_pid] && tabacoAvailable > 0 -> tabacoFlags[_pid] = true; printf("Smoker %d acquires tabaco\n", _pid); 
                                                    tabacoAvailable = tabacoAvailable - 1;     deadlockFlags[_pid] = false;}

        // If paper and tabaco are ready, light the cigarette
        :: atomic { paperFlags[_pid] && tabacoFlags[_pid] -> printf("Smoker %d is smoking\n", _pid); 
                                    paperFlags[_pid] = false; tabacoFlags[_pid] = false; 
                                    paperAvailable = paperAvailable + 1; tabacoAvailable = tabacoAvailable + 1;
                                        deadlockFlags[_pid] = false;
        }
        :: else -> deadlockFlags[_pid] = true;
    od
}

// No time in the future will the table always be empty
never { 
    do
        ::  (!deadlockFlags[0] || !deadlockFlags[1]) -> skip; 
        :: else -> break; 
    od
 } 
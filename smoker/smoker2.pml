// spin -a smoker2.pml
// gcc -o pan pan.c
// ./pan
#define NUM_SMOKER 2

// Availability of resources on table
bool paperAvailable = true;
bool tabacoAvailable = true;

// The state of resources of each smoker
bool paperFlags [NUM_SMOKER];
bool tabacoFlags [NUM_SMOKER]; 



active [NUM_SMOKER] proctype Smoker() {
    paperFlags[_pid] = false;
    tabacoFlags[_pid] = false;
    do
        // Collect paper if available
        // Modified code: Only collect if it already have another component or the other component can be collect next
        :: atomic {!paperFlags[_pid] && paperAvailable /* && (tabacoFlags[_pid] || tabacoAvailable) */-> paperFlags[_pid] = true; printf("Smoker %d acquires paper\n", _pid); 
                                                    paperAvailable = false; }
        // Only collect tabaco if available and paper is already collected
        // Modified code: Only collect if it already have another component or the other component can be collect next
        :: atomic {!tabacoFlags[_pid] && tabacoAvailable /* && (paperFlags[_pid] || paperAvailable) */-> tabacoFlags[_pid] = true; printf("Smoker %d acquires tabaco\n", _pid); 
                                                    tabacoAvailable = false; }
        // If paper and tabaco are ready, light the cigarette
        :: atomic{ paperFlags[_pid] && tabacoFlags[_pid] -> printf("Smoker %d is smoking\n", _pid); 
                                    paperFlags[_pid] = false; tabacoFlags[_pid] = false; 
                                    paperAvailable = true; tabacoAvailable = true; }
    od
}
 

never { 
    do
    // Smoker 1 has tabaco, smoker 2 has paper
        ::  (tabacoFlags[0] &&  paperFlags[1]) -> break; 

        // Smoker 1 has paper,  smoker 2 has tobaco
        ::  (tabacoFlags[1] &&  paperFlags[0]) -> break; 
        :: else -> skip; 
    od
 } 

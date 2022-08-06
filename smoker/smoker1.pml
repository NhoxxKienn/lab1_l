#define NUM_SMOKER 2

bool paperAvailable = true;
bool tabacoAvailable = true;

active [NUM_SMOKER] proctype Smoker() {
    bool hasPaper = false;
    bool hasTabaco = false;
    do
        // If the smoker doesn't have paper and paper is available, he takes the paper.
        :: atomic{!hasPaper && paperAvailable -> hasPaper = true; printf("Smoker %d acquires paper\n", _pid); paperAvailable = false; }
        // If the smoker doesn't have tabaco and tabaco is available, he takes the tabaco.
        :: atomic{!hasTabaco && tabacoAvailable ->  hasTabaco = true; printf("Smoker %d acquires tabaco\n", _pid); tabacoAvailable = false;}
        // If the smoker have all resources now he can smoke and the resource will be available
        :: atomic{ hasPaper && hasTabaco -> printf("Smoker %d is smoking\n", _pid); 
                                    hasPaper = false; hasTabaco = false; 
                                    paperAvailable = true; tabacoAvailable = true; } 
        :: else
    od
}

ltl deadlock { !(<>([](tabacoAvailable == 0 && paperAvailable == 0))) }

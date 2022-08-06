// Represents the left and right hand of alice
byte aliceHands[2];
// Represents the left and right hand of bob
byte bobsHands[2];

/* ... */
#define N 5

//winningHands = 0 means none is full
//winningHands = 1 means first hand is full
//winningHands = 2 means second hand is full
byte winningHands[2];

//winner = 0 means no winner
//winner = 1 means alice won
//winner = 2 means bob won
byte winner = 0;


chan turn = [0] of {bool};

proctype Alice(){
  //winning flag
  bool winning = false;
  //model a choice
  byte choice[2];
  byte tmp;
  do
  :: true ->
  atomic{
    select(tmp: 0..1);
    choice[0] = tmp;
    select(tmp: 0..1);
    choice[1] = tmp;
    printf("Player 1 choose: %d Hand and %d Hand\n", choice[0], choice[1]);
    //model the turn
    if
    :: winningHands[0] == 0 && winningHands[1] == 0 ->
      if
      :: choice[0] == 0 && choice[1] == 0 -> bobsHands[0] = (bobsHands[0] + aliceHands[0]) % N;
      :: choice[0] == 0 && choice[1] == 1 -> bobsHands[1] = (bobsHands[1] + aliceHands[0]) % N;
      :: choice[0] == 1 && choice[1] == 0 -> bobsHands[0] = (bobsHands[0] + aliceHands[1]) % N;
      :: choice[0] == 1 && choice[1] == 1 -> bobsHands[1] = (bobsHands[1] + aliceHands[1]) % N;
      fi
    :: winningHands[0] == 0 && winningHands[1] == 1 ->
      if
      :: choice[0] == 0 -> bobsHands[1] = (bobsHands[1] + aliceHands[0]) % N;
      :: choice[0] == 1 -> bobsHands[1] = (bobsHands[1] + aliceHands[1]) % N;
      fi
    :: winningHands[0] == 0 && winningHands[1] == 2 ->
      if
      :: choice[0] == 0 -> bobsHands[0] = (bobsHands[0] + aliceHands[0]) % N;
      :: choice[0] == 1 -> bobsHands[0] = (bobsHands[0] + aliceHands[1]) % N;
      fi
    :: winningHands[0] == 1 && winningHands[1] == 0 ->
      if
      :: choice[1] == 0 -> bobsHands[0] = (bobsHands[0] + aliceHands[1]) % N;
      :: choice[1] == 1 -> bobsHands[1] = (bobsHands[1] + aliceHands[1]) % N;
      fi
    :: winningHands[0] == 1 && winningHands[1] == 1 -> bobsHands[1] = (bobsHands[1] + aliceHands[1]) % N;
    :: winningHands[0] == 1 && winningHands[1] == 2 -> bobsHands[0] = (bobsHands[0] + aliceHands[1]) % N;
    :: winningHands[0] == 2 && winningHands[1] == 0 ->
      if
      :: choice[1] == 0 -> bobsHands[0] = (bobsHands[0] + aliceHands[0]) % N;
      :: choice[1] == 1 -> bobsHands[1] = (bobsHands[1] + aliceHands[0]) % N;
      fi
    :: winningHands[0] == 2 && winningHands[1] == 1 -> bobsHands[1] = (bobsHands[1] + aliceHands[0]) % N;
    :: winningHands[0] == 2 && winningHands[1] == 2 -> bobsHands[0] = (bobsHands[0] + aliceHands[0]) % N;
    fi
    //check for winning hand
    if
    :: winningHands[1] == 0 ->
      if
      :: bobsHands[0] == 0 -> winningHands[1] = 1;
      :: bobsHands[1] == 0 -> winningHands[1] = 2;
      :: else ->;
      fi
    :: winningHands[1] == 1 ->
      if
      :: bobsHands[1] == 0 -> winning = true;
      :: else ->;
      fi
    :: winningHands[1] == 2 ->
      if
      :: bobsHands[0] == 0 -> winning = true;
      :: else ->;
      fi
    fi
  }
    //printing game state
    printf("%d %d | %d %d\n", aliceHands[0], aliceHands[1], bobsHands[0], bobsHands[1]);
    if
    :: winning -> turn ! false ; winner = 1; printf("Player 1 won\n"); break;
    :: else -> turn ! true
    fi
    if
    :: turn ? eval(false) -> break;
    :: turn ? eval(true) ->;
    fi
  od
}

proctype Bob(){
  //winning flag
  bool winning = false;
  //model a choice
  byte choice[2];
  byte tmp;
  do
  :: true ->
    if
    :: turn ? eval(false) -> break;
    :: turn ? eval(true) ->;
    fi
    atomic{
    select(tmp: 0..1);
    choice[0] = tmp;
    select(tmp: 0..1);
    choice[1] = tmp;
    printf("Player 2 choose: %d Hand and %d Hand\n", choice[0], choice[1]);
    //model the turn
    if
    :: winningHands[0] == 0 && winningHands[1] == 0 ->
      if
      :: choice[0] == 0 && choice[1] == 0 -> aliceHands[0] = (aliceHands[0] + bobsHands[0]) % N;
      :: choice[0] == 0 && choice[1] == 1 -> aliceHands[1] = (aliceHands[1] + bobsHands[0]) % N;
      :: choice[0] == 1 && choice[1] == 0 -> aliceHands[0] = (aliceHands[0] + bobsHands[1]) % N;
      :: choice[0] == 1 && choice[1] == 1 -> aliceHands[1] = (aliceHands[1] + bobsHands[1]) % N;
      fi
    :: winningHands[0] == 1 && winningHands[1] == 0 ->
      if
      :: choice[0] == 0 -> aliceHands[1] = (aliceHands[1] + bobsHands[0]) % N;
      :: choice[0] == 1 -> aliceHands[1] = (aliceHands[1] + bobsHands[1]) % N;
      fi
    :: winningHands[0] == 2 && winningHands[1] == 0 ->
      if
      :: choice[0] == 0 -> aliceHands[0] = (aliceHands[0] + bobsHands[0]) % N;
      :: choice[0] == 1 -> aliceHands[0] = (aliceHands[0] + bobsHands[1]) % N;
      fi
    :: winningHands[0] == 0 && winningHands[1] == 1 ->
      if
      :: choice[1] == 0 -> aliceHands[0] = (aliceHands[0] + bobsHands[1]) % N;
      :: choice[1] == 1 -> aliceHands[1] = (aliceHands[1] + bobsHands[1]) % N;
      fi
    :: winningHands[0] == 1 && winningHands[1] == 1 -> aliceHands[1] = (aliceHands[1] + bobsHands[1]) % N;
    :: winningHands[0] == 2 && winningHands[1] == 1 -> aliceHands[0] = (aliceHands[0] + bobsHands[1]) % N;
    :: winningHands[0] == 0 && winningHands[1] == 2 ->
      if
      :: choice[1] == 0 -> aliceHands[0] = (aliceHands[0] + bobsHands[0]) % N;
      :: choice[1] == 1 -> aliceHands[1] = (aliceHands[1] + bobsHands[0]) % N;
      fi
    :: winningHands[0] == 1 && winningHands[1] == 2 -> aliceHands[1] = (aliceHands[1] + bobsHands[0]) % N;
    :: winningHands[0] == 2 && winningHands[1] == 2 -> aliceHands[0] = (aliceHands[0] + bobsHands[0]) % N;
    fi
    //check for winning hand
    if
    :: winningHands[0] == 0 ->
      if
      :: aliceHands[0] == 0 -> winningHands[0] = 1;
      :: aliceHands[1] == 0 -> winningHands[0] = 2;
      :: else ->;
      fi
    :: winningHands[0] == 1 ->
      if
      :: aliceHands[1] == 0 -> winning = true;
      :: else ->;
      fi
    :: winningHands[0] == 2 ->
      if
      :: aliceHands[0] == 0 -> winning = true;
      :: else ->;
      fi
    fi
  }
    //printing game state
    printf("%d %d | %d %d\n", aliceHands[0], aliceHands[1], bobsHands[0], bobsHands[1]);
    if
    :: winning -> turn ! false ; winner = 2;  printf("Player 2 won\n"); break;
    :: else -> turn ! true;
    fi
  od
}

init{
  //initialise all hand with 1 finger
  aliceHands[0] = 1;
  aliceHands[1] = 1;
  bobsHands[0] = 1;
  bobsHands[1] = 1;
  run Alice();
  run Bob();
  /* ... */
}

ltl player_1_can_not_win {[] (winner!=1)}
ltl player_2_can_not_win {[] (winner!=2)}

never{
  do
  :: (aliceHands[0] == 4 && aliceHands[1] == 4 && bobsHands[0] == 4 && bobsHands[1] == 4) -> break;
  :: else
  od
}

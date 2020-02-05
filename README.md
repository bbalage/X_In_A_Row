# X_In_A_Row
This is a shell script for playing five-in-a-row against another player or the computer. Also, using the input parameters it could be any positive integer in-a-row.

The main point of this project was to practice the creation of simple computer controlled opponent. The intention was not to make this artificial enemy unbeatable, but to make it able to pose a fair challenge to the human player.

The additional purpose I had with this game was to make a playable, self-made game for my travels. The point of writing it in bash was the challange, not any practical reason.

The shall script was written and tested on Ubuntu 16.04 LTS. It was also used on Ubuntu 18.04.4 LTS.



The functionality of the game is as follows:

It could be launched from command line as a shell script.

Its input parameters could define $1: the size of the playing field $2: the identical signs in a row required to win.
The input parameters should be positive integers.
The default settings are: number of fields=30, winning condition=5. (A tick-tack-toe for example could be played by the input parameters of 3 and 3.)

After the game launches it instructs the player to choose whether he wants to play a one-player game (computer enemy) or a two-player game (against another human sitting near the computer).
Buttons 1 or 2 should pushed to choose the player number. Any other buttons pushed will be ignored.
When the game starts, the first player shall place an X, the second an O, and continue till one of them wins or they run out of space.

CONTROLS ARE THE BUTTONS: W, A, S, D for moving the cursor around, and O for placing a sign.

Once the winning condition is reached or the players had ran out of space, the script shall state which player won or that it is a draw.



About the computer enemy's algorithm:

It simply takes all the fields of the playing area into an array and determines a priority for each field.

The priorities are shifted accordingly to the signs placed upon the playing ground.

Note that priorities only change when a new sign is made! Also, not all priorities are shifted, just the ones directly affected (the field where the sign was put, and one in each direction from the sign).

When the computer's turn comes, it finds the highest priority and puts its sign there.

When the priority is determined, the computer takes only a few things into consideration:

1. How many identical consecutive signs are already placed in a line (be the line horizontal, vertical or diagonal) and whose signs are those.

2. Is a series of identical signs closed on one side by the perimeter of the level or the opposition's sign; or is it free to be continued on both ends.

3. Whether by putting a sign next to an identical sign we can still reach the winning condition on that line, or there isn't enough spaces left to reach it.

The consideration of these simple aspects enable the computer enemy to pose a balanced challange to the average player.
The computer enemy could easily be overcome by thinking ahead and creating the right sets, but if the player doesn't pay attention, then the non-human opponent can very well win the game.

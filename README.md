# Mips Multiplication Game
for CS 2340 Term Project at UTDallas. based on https://www.mathsisfun.com/games/multiplication-game.html. Programmed in mips assembly. 

## Running the Program
For running in mars open the main.asm file. Enabling “Settings->Assemble all files in directory” and “Settings->Initialize Program Counter to global ‘main’ if defined” will allow the other files to be compiled. Run by first compiling then playing.

## Basics of the Game
Within the multiplication game there is a board and number line with two arrows. When it's your turn, one of the two arrows can be moved. Once moved both of the numbers that are pointed to are multiplied and the value on the board is claimed. Already claimed cells cannot be reclaimed by you or the computer. The Goal is to claim 4 in a row (similar to connect 4) to win the game. 

Once the game has started the two arrows of the number line will point to 0. The computer will play the first move without claiming a cell, Now it's your turn. 
* input the arrow you want to move. 0 corresponds to the upper arrow, 1 corresponds to the lower arrow. 
* input the value you want the arrow to point to, 1 to 9. Once imputed the two values on the numberline are multiplied and claimed on the board.
* Now the computer will play its turn, moving one of the arrows and claiming a cell.
  
This will repeat until a winner or a draw occurs. 

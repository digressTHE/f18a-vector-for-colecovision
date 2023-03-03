# f18avector
This is a f18a vdp vector demo program. Runs on colecovision/adam or phoenix system with f18a installed
It works but needs refining.

This was built using existing libraries comp.lib cvlib.lib getput.lib which i did not make.
Credit to PkK & Newcoleco for their libraries.

This particular program was comiled using cygwyn environment with and using a custome bank switching compiler from tursi located here:
https://github.com/tursilion/colecobanking


fire button left will skip the title screen
fire button left will draw a vector line each time pressed


4 & 6 slide the bitmap layer left & right
3 & 9 slide the bitmap layer up & down
7 & 8 shrink or enlarge the bitmap layer width   ( the vector lines only draw correctly if the screen is not at max width)
2 & 5 shrink or enlarge the bitmap layer height
* & # change the pallet of the bitmap layer
0 will erase the screen

fire button 2 brings up a menu you cannot see.

press fire button 2 then select 2 from the keypad will mess & lockup (i can't remember what I was doing here) I will update later
press fire button 2 then select 3 from the keypad will mess & lockup (i can't remember what I was doing here) I will update later
press fire button 2 then select 4 from the keypad will draw rectangles
press fire button 2 then select 5 from the keypad will draw lines in a circle pattern

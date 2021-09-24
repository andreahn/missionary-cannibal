# Missionary-cannibal problem in Verilog

The solution for the missionary-cannibal problem has been implemented using sequential logic in Verilog. 

---

This project is explained in detail in the report. However, the combinational logic submodule firstTermPrj is not included in the report, and is explained here instead:

Given the number of missionaries and cannibals on the left side, it produces the number on the left side in the next state as output (following the solution). If the input is incompatible with the solution, the problem goes back to initial state (everyone is on the left side). 

There are five input bits, two for number of missionaries on left side, two for number of cannibals on left side, and one bit for the direction the boat is going. 
<br><br>
The input and output can be named as follows:
<br>
<b>Input:</b><br>
A, B: bits for # of missionaries on left side<br>
C, D: bits for # of cannibals on left side<br>
E: Direction boat is going (0 = left)<br>

<br>
<b>Output:</b><br>
F1, F2: bits for # number of missionaries on left side in next state<br>
F3, F4: bits for # number of cannibals on left side in next state<br>
<br><br>
<h2>The Combinational Logic and Implementation</h2>

<h3>The combinational logic can then be defined as (found using K-maps): </h3><br>

F1 = A’B + C’D’ + B’C’E + BC + CDE’ + AE’ + AB’D <br>
F2 = BC + C’D’ + AD + AE’ + C’E + CDE’<br>
F3 = A’B + AB’ + DE’ + A’C’ + CE’ + C’D’E<br>
F4 = C’D’ + DE + CE’ + AB’C’ + A’BC<br>

<h3>In order to implement this, there are 17 wires of which some are reused to produce several output bits:</h3><br>

s1 = A’B (used by F1, F3)<br>
s2 = C’D’ (used by F1, F2, F4)<br>
s3 = B’C’E (used by F1)<br>
s4 = BC (used by F1, F2) <br>
s5 = CDE’ (used by F1, F2) <br>
s6 = AE’ (used by F1, F2) <br>
s7 = AB’D (used by F1)<br>
s8 = AD (used by F2)<br>
s9 = C’E (used by F2)<br>
s10 = AB’ (used by F3)<br>
s11 = DE’ (used by F3)<br>
s12 = A’C’ (used by F3) <br>
s13 = CE’ (used by F3, F4) <br>
s14 = C’D’E (used by F3) <br>
s15 = DE (used by F4)<br>
s16 = AB’C’ (used by F4) <br>
s17 = A’BC (used by F4)<br>

<br><br>
<h3>Finally, the output bits F1 to F4 is implemented as following:</h3><br>
F1 = s1 + s2 + s3 + s4 + s5 + s6 + s7<br>
F2 = s4 + s2 + s8 + s6 + s9 + s5<br>
F3 = s1 + s10 + s11 + s12 + s13 + s14<br>
F4 = s2 + s15 + s13 + s16 + s17<br>

<h2>Sequential and Other Logic</h2>
The remaining logic description can be found in the attached report. 

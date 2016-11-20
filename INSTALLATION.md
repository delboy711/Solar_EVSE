<h1>Installing Solar EVSE</h1>
<h2>Modifying Viridian EPC</h2>
To avoid having to have a separate power supply for Solar EVSE, it is easy to modify the Viridian EPC to break out 5v and an additional 0V 
to an additional terminal block.<br>
<img href="/Images/viridian_evse1.jpg" height=400px>
On opening the EPC it will be seen that there are plastic inserts blanking off the unused terminal positions.
A new two position terminal block can be glued to the side of the existing one, and connections made to +5V and 0V positions on the header connector on the pcb.
<img href="/Images/viridian_evse3.jpg" height=600px>
The 5V connection is on the bottom right of the header.  A spot of silicon keeps the wires in the header.
I routed the 5V wire through an 85mA polyfuse to guard against accidental short circuits.<br>
<h2>Relacing Rolec EPC</h2><img href="/Images/solar_evse_install_2.jpg" height=600px>
The Vididian EPC is almost but not quite a pin for pin replacement for the Rolec EPC.
Live and Neutral wires go to L and N, the Earth wire that went to the E terminal on the Rolec should be connected to the 0V terminal on the Viridian.
Wires that went to RL1 and RL2 terminals on the Rolec go to to P1 and P2 on the Viridian.<br>
The wire going to the CP pin on the Rolec connects to the CP pin on the Viridian.<br>
<h3>LED Connections</h3>
The Rolec and Viridian EPC have their LED connections with opposite polarity so it is not possible to make a pin for pin substitution.
Instead only a single LED can be made to work by taking the black wire that went to 0V on the Rolec and connecting it to the G terminal on the Viridian (for Green LED lighting while charging). The green wire from the fron panel connects to the OV terminal on the Viridian.<br>
<h3>Solar EVSE Connection</h3>
From the modified Viridian EPC 5V and 0V are connected to Solar EVSE, and a connection made from the IC terminal to the terminal on Solar EVSE which connects to the output of the DAC.<br>
<h2>Testing</h2><img href="/Images/solar_evse_install_1.jpg" height=600px>
Once Solar EVSE is installed and powered on with the front face off, then it should be possible to use Node Red to send commands to Solar EVSE to set the DAC Voltage. Use DAC settings between around 850 and 2622.  A multimeter connected between IC and 0V ob the EPC should show the Voltage changing with each command.
Once a car is connected you should observe different charging rates.<br>
Now all that is required is to define a suitable Node Red flow to manage the rate of charge according to available solar energy.  See the NodeRed folder for details.<br>
>



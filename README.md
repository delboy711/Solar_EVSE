# Solar EVSE
## Description
 This project is intended to manage the charging of an electric car so that the charging current is varied in accordance with available
solar power from a PV array.

## Introduction
Electric cars require an EVSE (Electric Vehicle Supply Equipment) to connect to the domestic electricity supply.  It is the responsibility
 of the EVSE to signal to the car the maximum current it is allowed to draw based on factors like the rating of the domestic wiring, and the cable 
connecting the vehicle to the EVSE.  A smart controller inside the EVSE called an EPC (Electronic Protocol Controller) performs the function by setting the duty cycle on a 12V 
pilot signal sent to the car via the charging cable.  One of the leading models of EPC is manufactured by <a href="https://ecoharmony.co.uk/collections/evse-protocol-controller/products/viridianev-tethered-epc?variant=11247832006">Viridian</a> (sometimes labelled as MainPine)
 What makes the Viridian EPC interesting to a DIYer is the fact that the available current signalled to the car can be controlled by applying a voltage on a control pin
 on the Viridian EPC.
![/Images/solar_evse_pcb.jpg](/Images/solar_evse_pcb.jpg)
This project is for an Arduino based device to set that control voltage based on a calculation of available solar power made by an <a href="https://openenergymonitor.org/emon/">OpenEnergyMonitor</a> system, and transmitted
 to the Arduino via a radio link.  The Arduino takes no part in the decision making process. It merely applies the voltage dictated by OpenEnergyMonitor.  The Viridian
 EPC has its own fail safes to prevent an unsafe current being signalled to the vehicle.

 
## Hardware required is
### Arduino Uno -
 or clone, or stripboard with Atmel328P  No crystal required.  I used a <a href="https://nathan.chantrell.net/20110910/xino-basic-arduino-clone/">Xino</a> which is a minimalist Arduino clone with no usb interface, and I 
modfied it to run off 3.3V power which has the advantage of allowing finer control of the Digital to Analogue Converter, and means no step down resistors are required
  for the RFM69CW radio module which requires a 3.3V supply.  By burning a new bootloader into the Atmega328P chip I was able to run it using the <a href="https://www.arduino.cc/en/Tutorial/ArduinoToBreadboard">8MHz internal clock</a> and so saved on the cost of a crystal, and reduced power consumption. Power was drawn from 
the 5V rail of the Viridian EPC itself by wiring in an extra screw connector into the housing of the EPC. Using a Xino at 8MHz the current requirement is 20mA.
	<h3>MPC4725</h3> Digital to Analogue converter module. It is very cheap to buy MCP4725 chips on ebay, ready mounted on a pcb which saves the trouble of trying to solder
surface mount components.
	<h3>RFM69CW</h3> 433MHz or 868MHz radio module. This is the radio module used in the OpenEnergyMonitor project. They are cheap on ebay.
	<h3>Viridian</h3> <a href="https://ecoharmony.co.uk/collections/evse-protocol-controller/products/viridianev-tethered-epc?variant=11247832006">Tethered EPC</a>  
                Viridian make their own EVSEs, but I was unable to buy one at a sensible price so instead I bought a <a href="http://www.rolecserv.com/ev-charging/product/EV-Charging-Points-For-The-Home">Rolec EVSE</a> and replaced the Rolec EPC with a Viridian.
Since both the Rolec and Viridian EPCs are DIN rail mounted modules this was a simple exchange.
	<h3>EmonPi or Emonbase</h3> from OpenEnergyMonitor.org
  
## Arduino Libraries required
* **Jeelib**
* **Wire**
* **Adafruit_MCP4725**
  
## Software required
* **Emonhub**
Part of EmonPi or Emonbase. Used to transmit commands over radio link.<br>
A patch is required for emonhub to allow it to transmit control messages to Solar_EVSE. See GitHub for required patch to emonhub.
* **Node-Red**
Included as part of EmonPi.  Used to calculate Solar PV power PV available.
See Node-Red folder for an example flow.
  
## Operation
   This sketch is very simple. The process loops continually waiting for a packet ready flag
   from the RFM69CW radio unit.  When the packet arrives it is validated for CRC and correct address and a single integer
   variable is read.  If the variable has msb bit set, then it is a command to set a new default Power on Voltage for the DAC
   to use. If msb bit is zero it is a new command to set a voltage on the DAC.
   The voltage set on the DAC is passed to the Viridian EPC which uses it to vary the duty cycle
   of the Pilot signal given to an attached electrc
   car, and so regulates the current drawn while charging.<br><br>

Installation notes are [here](INSTALLATION.md)

  

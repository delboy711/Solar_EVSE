 /*
 * Solar EVSE by Derek Jennings 
 * description:
 * This sketch will regulate a Viridian or Mainpine EPC to modulate
 * the available current available to an Electric Vehicle based on solar PV production.
 *
 * Solar_EVSE receives commands via an RFM69 radio unit from
 * an EmonPi/EmonBase OpenEnergyMonitor system to set a voltage on the control pin
 * of a Viridian EPC which will in turn signal to an Electric Vehicle
 * by varying the duty cycle of the pilot signal to the EV.
 * Node-Red is used within the EmonPi to determine how much power
 * is available from the solar panels after allowing for other loads
 * within the household.
 
 * Hardware required is
 * 	Arduino Uno - or clone, or stripboard with Atmel328P  No crystal required.
 *	MPC4725 Digital to Analogue converter module 
 *	RFM69CW 433MHz or 868MHz radio module 
 *      Viridian tethered EPC  https://ecoharmony.co.uk/collections/evse-protocol-controller/products/viridianev-tethered-epc?variant=11247832006
 *              in a suitable EVSE such as an upgraded Rolec
 *      EmonPi or Emonbase from OpenEnergyMonitor.org
 *
 * Libraries required
 *	Jeelib
 *	Wire
 *      Adafruit_MCP4725
 *
 * Software required
 *      Emonhub -   Partof EmonPi or Emonbase. Used to transmit commands over radio link
 *                  See my GitHub for required patch to emonhub.
 *      Node-Red  - Included as part of EmonPi.  Used to calculate Solar PV power PV available.
 *                  See my Githib for an example flow.
 *
 * Operation
 * This sketch is very simple. The process loops continually waiting for a packet ready flag
 * from the RFM69CW radio unit.  When the packet arrives it is validated for CRC and correct address and a simgle integer
 * variable is read.  If the variable has msb bit set, then it is a command to set a new default Power on Voltage for the DAC
 * to use. If msb bit is zero it is a new command to set a voltage on the DAC.
 * The voltage set on the DAC is passed to the Viridian EPC which uses it to vary the duty cycle
 * of the Pilot signal given to an attached electrc
 * car, and so regulates the current drawn while charging.
 */

#include <Wire.h>
#include <Adafruit_MCP4725.h>	    // Get Adafruit_MCP4725 library at https://github.com/adafruit/Adafruit_MCP4725
#define RF69_COMPAT 1               // set to 1 to use RFM69CW
#include <JeeLib.h>		    // Get Jeelib at https://github.com/jcw/jeelib 
#define RF_freq RF12_868MHZ         // Frequency of RF169CW module can be RF12_433MHZ, RF12_868MHZ or RF12_915MHZ. You should use the one matching the module you have.
const int nodeID = 24;              // RFM69 node ID pick an unused nodeID
const int networkGroup = 210;       // RFM69 wireless network group - needs to be same as emonBase and emonGLCD                                                 
boolean debug= true;                // Set to 1 for debug messages
unsigned int dacsetpoint=0;          // Value to put into MCP4725 DAC commanded by Node-Red
unsigned int loopcount=0;            // count of times through main loop 
unsigned int dacmax = 2622;          // max dac setting for 32A

Adafruit_MCP4725 dac;


/* Setup phase */
void setup() {
     
  if (debug) {
    Serial.begin(57600);
    Serial.println("Solar_EVSE controller with Open Energy Monitor"); 
    Serial.print(" Freq: "); 
    if (RF_freq == RF12_433MHZ) Serial.println("433Mhz");
    if (RF_freq == RF12_868MHZ) Serial.println("868Mhz");
    if (RF_freq == RF12_915MHZ) Serial.println("915Mhz");  
  }
  rf12_initialize(nodeID, RF_freq, networkGroup);           // initialize RFM12B/RFM69CW
  if (debug) Serial.println("   :RF Initialized");   
  
  // For MCP4725A1 the address is 0x62 (default) or 0x63 (ADDR pin tied to VCC)
  // For MCP4725A0 the address is 0x60 or 0x61
  // For MCP4725A2 the address is 0x64 or 0x65
  dac.begin(0x60);


}


/* Main loop.*/
void loop() {

   receive_rf_data();                // Has a data packet arrived on the radio?
   delay(500);
   loopcount += 1;                    // increment loop count
   if (loopcount > 7200 ) dac.setVoltage(dacmax, false);    // reset dac to max 32A if no radio message for 1 hour
}  // end main loop


void receive_rf_data()    // Check if a data packet has been received by the radio
{
  int i;
  if (rf12_recvDone()) {
    if (rf12_crc == 0 && (rf12_hdr & RF12_HDR_CTL) == 0)  // and no rf errors
    {
      int node_id_Rx = (rf12_hdr & 0x1F);                  //node ID of received packet
     if (debug) {
       Serial.print("Packet received : Node ");  
       Serial.println(node_id_Rx);
     }
      if (node_id_Rx == nodeID) {
        if (debug) Serial.print("Data received : ");
        dacsetpoint =rf12_data[0]+ 256*rf12_data[1];       // put received data into variable 
        if ( dacsetpoint > 0x7fff ) {                      // If msb set, then save in Flash ROM as new default
          dacsetpoint = dacsetpoint & 0x7fff;              // remove msb bit
          dac.setVoltage(dacsetpoint, true);		   // Write new value to DAC and to ROM         
        } else  dac.setVoltage(dacsetpoint, false);        // Write new value to DAC
        if (debug) {
          Serial.println(dacsetpoint);  
          Serial.print("RSSI : ");                           // Print RSSI value
          Serial.println(-(RF69::rssi>>1));  
          loopcount = 0;                                  // reset loop counter
        }  
      }
    }
  } 
  
} // receive_rf_data



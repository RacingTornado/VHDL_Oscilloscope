# VHDL_Oscilloscope
An oscilloscope for viewing signals

Debugging the internal logic on FPGA's can be quite a difficult task. This project aims to act as a logic analyzer and stream the signals through 
the FX2 interface available from Cypress.
The FX2 cypress chips are available on ebay http://www.ebay.com/itm/Cypress-CY7C68013A-EZ-USB-FX2LP-USB2-0-Developement-Board-module-/280870904109

The firmware running on the FX2 is compiled under SDCC.
To install SDCC follow this http://sourceforge.net/projects/sdcc/files/sdcc-linux-x86/3.5.0/. Make sure you download the 32 or 64 bit 
version depending on your machine.
The pin mappings have been slightly changed since the LCsoft board is a 56 pin version

The Streamer application from cypress can also be used to view the logic analyzed streams. It is still in work in progress, and I am trying
to get the format to be supported with jawi's OLS client which is available at https://github.com/jawi/ols

Use it in whatever project you like. However I provide no warrant for the software. It is  under the MIT License.

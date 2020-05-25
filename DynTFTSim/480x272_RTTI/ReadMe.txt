Examples for:
D2006
D10.2
FP
mP for PIC32  



For using dyntftui files:
 - copy .\SD_Card\C.dyntftui and .\SD_Card\D.dyntftui to the SD card on your board.
 - flash the already compiled DynTFTExample_With_SDCard.hex

To rebuild the PIC app, to use dyntftui files:
 - read DynTFTCodeGen doc about RTTI (chapter 8 (8.4) and chapter 10)
 - uncomment the commented code in DynTFTExample.mpas  - main routine  (look for "InitSPI1_For_uSD;")
 - go to DynTFTCodeGen, open the GUI_Example_480x272_RTTI.dyntftcg project and set the callbacks to "RTTICreateCallback" and "RTTIDestroyCallback"  (without quotes).
 - regenerate the files (this will regenerate dyntftui files)
 - rebuild (and regenerate again) the PIC32 project, until DynTFTCodeGen reports no mismatching address
 - flash the hex file
 - copy .\SD_Card\C.dyntftui and D.dyntftui to the SD card on your board.
 - start the board, the UI should work

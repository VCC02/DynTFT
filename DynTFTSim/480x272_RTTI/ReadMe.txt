Examples for:
D2006
D10.2
FP
mP for PIC32  


------------------------
       Warning: 
- RTTI and binary components work by overwriting memory at predefined locations.
- In case of reading handler addresses from lst files, always make sure they are in sync with generated code (and .dyntftui files). Otherwise, undesired memory locations will be overwritten.
If other memory locations are overwritten, input pins may switch to output pins or output pins may switch state, or whatever register may be overwritten etc.
- If using dyntftui files, make sure they are updated to SD card / USB Drive, before starting the board (at least before using them in GUI).
- Use DynTFTCodeGen to see if generated files are in sync with lst files. Read DynTFTCodeGen's documentation, to understand how it works. Always rebuild the Deksktop/MCU project(s) after generating files with DynTFTCodeGen.
- The lst monitoring feature of DynTFTCodeGen is not perfect and it may not always see/report if lst files are not in sync with generated code.
- Users may also forget to rebuild a project after regenerating output files. In that case, DynTFTCodeGen reports that lst files are in sync, but it doesn't know that the binary (exe/hex) was not rebuilt.
- Beware that if regenerating output files (DynTFTGUIObjects.pas, DynTFTHandlers.pas, *.dyntftui), when configured to read handler addresses from lst files, the current state of lst files is used.
- Always rebuild, not simply compile projects.
Although there are some safety measures to prevent running out of date RTTI instructions, you use this feature at you own risk.
------------------------

For using dyntftui files:
 - copy .\SD_Card\C.dyntftui and .\SD_Card\D.dyntftui to the SD card on your board (mikroMedia for PIC32MX7).
 - flash the already compiled DynTFTExample_With_SDCard.hex

There is also an example using Dany's FAT32 library. (Uses "D" suffix: DynTFTExampleD_With_SDCard.mpp32, DynTFTExampleD_With_SDCard.hex, C_D.dyntftui, D_D.dyntftui)  Profile: "PIC32AppDWithSDCard" (additional compiler directive: UseFAT32D)

The DynTFTExample_With_SDCard.hex (and DynTFTExampleD_With_SDCard.hex) files, work with the provided C.dyntftui, D.dyntftui (and C_D.dyntftui and D_D.dyntftui) as they are.

 __________________________________________________________________________________________________________________________________________________________________
|  Precompiled Hex file          |  Create  .dyntftui   |  Destroy  .dyntftui    |  Profile              | FAT32 Library                      | Handler addr src   |
|--------------------------------+----------------------+------------------------+-----------------------+------------------------------------+--------------------|
| DynTFTExample.hex              |  N/A                 |  N/A                   |  PIC32App             | N/A                                |  .lst file         |
| DynTFTExampleAddrArr.hex       |  N/A                 |  N/A                   |  PIC32AppAddrArr      | N/A                                | array of addresses |
| DynTFTExample_With_SDCard.hex  |  C.dyntftui          |  D.dyntftui            |  PIC32AppWithSDCard   | FAT32 Library  /  FAT32_MX (mikro) |  .lst file         |
| DynTFTExampleD_With_SDCard.hex |  C_D.dyntftui        |  D_D.dyntftui          |  PIC32AppDWithSDCard  | FAT_PIC32  /  FAT32_2_PIC32 (Dany) |  .lst file         |
|________________________________|______________________|________________________|_______________________|____________________________________|____________________|

Troubleshooting:
 - If an error is displayed in red rectangle (maybe you have to change tabs to refresh), please search its error message in DynTFTBaseDrawing.pas and see where it comes from. A detailed explanation is given at message definition in DynTFTBaseDrawing.pas.
 - If running one of the two SDCard examples, when changing from one of the tabs to Tab1 in the example UI, the blue label displays "DataSrc CodeConst". This means that the callback names were not set in the PIC32AppWithSDCard / PIC32AppDWithSDCard profile, so the project does not use the dyntftui files.
 - Changing tabs makes components lose their current settings (e.g. trackbars were set to a position and are reset when changing tabs). This happens because in the current example, components are created and destroyed using manual creation groups, and there is no code to restore component states. It has nothing to do with RTTI.

Common displayed error messages (red rectangle/text):
- "Binary data out of date"   - dyntftui files are out of date (they were not regenerated or they were not updated on SD card)  - also look in DynTFTCodeGen status bar for error messages about lst files (double-click on status bar to open messages dialog)
- "Bad Int Size"              - profile - bad setting
- "Bad Pointer Size"          - profile - bad setting
- "DataProv Read Err"         - SDCard missing, or file(s) missing, or SPI/FAT32 not initialized, or other FAT32 read error
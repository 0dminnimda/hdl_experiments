Questa:

1. Go to https://www.intel.com/content/www/us/en/software-kit/825312/questa-intel-fpgas-standard-edition-software-version-23-1-1.html
2. It will redirect you to somewhere like this:
  - https://cdrdv2.intel.com/v1/dl/getContent/825312/825315?filename=QuestaSetup-23.1std.1.993-windows.exe
  - https://cdrdv2.intel.com/v1/dl/getContent/825312/825316?filename=QuestaSetup-23.1std.1.993-linux.run
3. When running installer, chose Questa - Intel FGPA *Starter* Edition

License:

1. Go to https://licensing.intel.com/psg/s, you may need to use vpn
2. Register (for example with your gh account)
3. Click at "Sign up for Evaluation or No-Const Licenses"
4. Find "SW-QUESTA" (Questa*-Intel® FPGA Starter Edition)
5. Find and press "next" button
6. Click "+New Computer"
7. Fill out:
    - Computer name: whatever you want
    - License Type: FIXED
    - Computer Type: NIC ID
    - Primary Compiter ID:
        - Windows: `ipconfig /all` (or `//all` for bash) look for `Physical Address` field
        - Linux: `lshw -class network` look for `serial` field
8. Click "save", check both boxes and then click "generate"
10. Check your email for the license file


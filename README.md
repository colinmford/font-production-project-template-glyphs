# Font Production Project Template (For Glyphs)
Replace this Readme with info about your project!

Note: This template is for Glyphs. As of July 2021, `fontmake` currently only works for Glyphs 2 files. They're working on an update for Glyphs 3.

## Commands
### Starting a local development environment
Open this project in your terminal and use the following 3 commands:
```bash
python3 -m venv .venv
```
... to use Python3 to start a new virtual environment

```bash
source .venv/bin/activate
```
... to activate that environment

```bash
pip install -r requirements.txt
```
... to install the requirements of the project in the virtual environment. (You can also just skip the above two steps to install the requirements on your system python, but that might make things messy down the road).

And finally, if any of the below commands don't work, you might have left the virtual environment. You just need to re-activate it:
```bash
source .venv/bin/activate
```

### Building and testing fonts
```bash
./static-build.sh
```
Build OTFs, TTFs and WOFFs from `.glyphs` files in `A  Font Sources`

```bash
./static-checkOTFs.sh
./static-checkTTFs.sh
```
Use `fontbakery` to check the OTFs and TTFs in `B  Builds`, generates an HTML output in `D  Proofs`

# License
Uses MIT license. Demo fonts are Mutator Sans, by Erik van Blokland, also licensed under MIT (or BSD?).